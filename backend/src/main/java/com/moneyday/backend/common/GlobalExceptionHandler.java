package com.moneyday.backend.common;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log=LoggerFactory.getLogger(GlobalExceptionHandler.class);
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Result<Void>> api(ApiException e) { return ResponseEntity.status(e.getStatus()).body(Result.error(e.getStatus(),e.getMessage())); }
    @ExceptionHandler(org.springframework.dao.DuplicateKeyException.class)
    public ResponseEntity<Result<Void>> duplicate(Exception e) {return ResponseEntity.status(409).body(Result.error(409,"记录已存在"));}
    @ExceptionHandler({IllegalArgumentException.class,org.springframework.http.converter.HttpMessageNotReadableException.class,org.springframework.web.bind.MissingServletRequestParameterException.class,org.springframework.web.method.annotation.MethodArgumentTypeMismatchException.class})
    public ResponseEntity<Result<Void>> invalid(Exception e) {return ResponseEntity.badRequest().body(Result.error(400,e instanceof IllegalArgumentException?e.getMessage():"请求参数无效"));}
    @ExceptionHandler(org.springframework.web.servlet.resource.NoResourceFoundException.class)
    public ResponseEntity<Result<Void>> notFound(Exception e) {return ResponseEntity.status(404).body(Result.error(404,"接口不存在"));}
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Result<Void>> unexpected(Exception e) {
        // Exception messages may contain SQL bind values. Never write credentials or raw requests.
        log.error("Request failed: {}",e.getClass().getSimpleName());
        return ResponseEntity.status(500).body(Result.error(500,"服务暂时不可用"));
    }
}
