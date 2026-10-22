import 'package:web/web.dart' as web;
import 'session_store_native.dart';
export 'session_store_native.dart' show SessionStore, MemorySessionStore;

class BrowserSessionStore implements SessionStore {
  static const key = 'moneyday.flutter.session';
  @override
  String? read() {
    try {
      return web.window.sessionStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void write(String? value) {
    try {
      if (value == null) {
        web.window.sessionStorage.removeItem(key);
      } else {
        web.window.sessionStorage.setItem(key, value);
      }
    } catch (_) {
      /* Browsers may disable storage; keep this session in memory. */
    }
  }
}

SessionStore createSessionStore() => BrowserSessionStore();
