package com.moneyday.backend.security;

import com.moneyday.backend.common.ApiException;
import java.util.function.Supplier;

/** Request and scheduled jobs use the same explicit, always-cleaned user scope. */
public final class UserContext {
    private static final ThreadLocal<Long> CURRENT = new ThreadLocal<>();
    private UserContext() {}
    public static long requireId() {
        Long id = CURRENT.get();
        if (id == null) throw new ApiException(401, "请先登录");
        return id;
    }
    public static <T> T call(long id, Supplier<T> action) {
        Long previous = CURRENT.get(); CURRENT.set(id);
        try { return action.get(); }
        finally { if (previous == null) CURRENT.remove(); else CURRENT.set(previous); }
    }
}
