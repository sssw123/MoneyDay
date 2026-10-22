#!/usr/bin/env python3
"""Local same-origin proxy: /api -> Spring Boot, other paths -> Flutter.

Uses the Python standard library only. No request bodies, URLs, credentials,
headers or upstream error text are logged. Not a production HTTP server.
"""

import argparse
import http.client
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


HOP_HEADERS = {
    "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
    "te", "trailer", "transfer-encoding", "upgrade", "proxy-connection",
}
MAX_BODY = 16 * 1024 * 1024


def excluded_headers(headers):
    excluded = set(HOP_HEADERS)
    for key, value in headers:
        if key.lower() == "connection":
            excluded.update(name.strip().lower() for name in value.split(","))
    return excluded


class ProxyHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.0"
    server_version = "MoneydayDevProxy"

    def log_message(self, _format, *args):
        # BaseHTTPRequestHandler normally logs the full request target; queries
        # can contain sensitive information, so suppress its access/error log.
        pass

    def fail(self, status, message):
        payload = json.dumps({"code": status, "message": message, "data": None},
                             ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(payload)

    def proxy(self):
        try:
            target = urlsplit(self.path)
        except ValueError:
            self.fail(400, "请求地址无效")
            return
        if target.scheme or target.netloc or target.fragment or not target.path.startswith("/"):
            self.fail(400, "仅支持本机 origin-form 请求")
            return
        if self.headers.get("Transfer-Encoding"):
            self.fail(400, "开发代理不接受分块请求体，请发送 Content-Length")
            return
        try:
            lengths = self.headers.get_all("Content-Length", [])
            if len(lengths) > 1:
                raise ValueError()
            length = int(lengths[0]) if lengths else 0
            if length < 0 or length > MAX_BODY:
                self.fail(413, "开发代理请求体上限为 16 MiB")
                return
        except ValueError:
            self.fail(400, "Content-Length 无效")
            return
        body = self.rfile.read(length) if length else None
        if length and len(body) != length:
            self.fail(400, "请求体不完整")
            return
        api = target.path == "/api" or target.path.startswith("/api/")
        upstream_port = self.server.api_port if api else self.server.web_port
        blocked = excluded_headers(self.headers.items()) | {"host", "content-length"}
        headers = {name: value for name, value in self.headers.items()
                   if name.lower() not in blocked}
        if body is not None:
            headers["Content-Length"] = str(len(body))
        connection = http.client.HTTPConnection("127.0.0.1", upstream_port, timeout=30)
        try:
            # Preserve path/query/body and Authorization. Do not follow redirects
            # or retry writes; the client must be able to see upstream failures.
            connection.request(self.command, self.path, body=body, headers=headers)
            response = connection.getresponse()
            payload = response.read()
            status = response.status
            response_headers = response.getheaders()
            content_length = response.getheader("Content-Length") if self.command == "HEAD" else str(len(payload))
        except (OSError, http.client.HTTPException):
            self.fail(502, "上游服务无法连接，请确认后端与 Flutter web-server 已启动")
            return
        finally:
            connection.close()
        try:
            self.send_response(status)
            blocked = excluded_headers(response_headers) | {"content-length"}
            for name, value in response_headers:
                if name.lower() not in blocked:
                    self.send_header(name, value)
            self.send_header("Content-Length", content_length or "0")
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(payload)
        except (BrokenPipeError, ConnectionResetError):
            pass

    do_GET = proxy
    do_HEAD = proxy
    do_POST = proxy
    do_PUT = proxy
    do_PATCH = proxy
    do_DELETE = proxy
    do_OPTIONS = proxy


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=5173)
    parser.add_argument("--api-port", type=int, default=8080)
    parser.add_argument("--web-port", type=int, default=5175)
    args = parser.parse_args()
    if any(port < 1 or port > 65535 for port in (args.port, args.api_port, args.web_port)):
        parser.error("端口必须为 1–65535")
    server = ThreadingHTTPServer(("127.0.0.1", args.port), ProxyHandler)
    server.api_port = args.api_port
    server.web_port = args.web_port
    print(f"MoneyDay 开发代理：http://127.0.0.1:{args.port}（Ctrl+C 退出）")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
