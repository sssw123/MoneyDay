package com.moneyday.backend.common;

public class ApiException extends RuntimeException {
    private final int status;
    public ApiException(int status, String message) { super(message); this.status = status; }
    public int getStatus() { return status; }
    public static ApiException notFound() { return new ApiException(404, "记录不存在"); }
}
