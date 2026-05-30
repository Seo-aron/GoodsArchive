package com.jeonshijang.api.global.exception;

import com.jeonshijang.api.global.response.ApiErrorResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

/**
 * 역할: 애플리케이션 내의 모든 컨트롤러에서 발생하는 예외(Exception)들을 한 곳에서 모아 처리하는 전역 예외 처리기입니다.
 * 핵심: @RestControllerAdvice를 사용하여 코드 중복을 줄이고, 일관된 포맷(ApiErrorResponse)으로 클라이언트에게 에러를 응답합니다.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 역할: 우리가 직접 정의한 비즈니스 예외(ApiException)가 발생했을 때 처리합니다.
     */
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ApiErrorResponse> handleApiException(ApiException e) {
        ErrorCode code = e.getErrorCode();
        log.warn("ApiException: code={}, message={}", code, code.getMessage());
        // 핵심: ErrorCode에 정의된 HTTP 상태 코드와 메시지를 응답 객체(ApiErrorResponse)로 만들어 반환합니다.
        return ResponseEntity.status(code.getStatus()).body(ApiErrorResponse.of(code));
    }

    /**
     * 역할: 클라이언트의 요청 데이터(DTO) 유효성 검증(@Valid)에 실패했을 때 발생하는 예외를 처리합니다.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleValidation(MethodArgumentNotValidException e) {
        // 핵심: 어떤 필드에서 검증이 실패했는지, 모든 에러 메시지를 수집하여 하나의 문자열로 만듭니다.
        String detail = e.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining(", "));
        log.warn("Validation failed: {}", detail);
        // 400 Bad Request 상태 코드와 함께 상세 에러 메시지를 반환합니다.
        return ResponseEntity.badRequest()
                .body(new ApiErrorResponse(ErrorCode.INVALID_INPUT.name(), detail));
    }

    /**
     * 역할: 위에서 처리하지 못한, 예상치 못한 모든 종류의 예외(런타임 에러, 서버 에러 등)를 처리합니다.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleUnexpected(Exception e) {
        log.error("Unexpected error", e);
        // 500 Internal Server Error 상태 코드와 공통 에러 메시지를 반환합니다.
        return ResponseEntity.internalServerError()
                .body(ApiErrorResponse.of(ErrorCode.INTERNAL_SERVER_ERROR));
    }
}
