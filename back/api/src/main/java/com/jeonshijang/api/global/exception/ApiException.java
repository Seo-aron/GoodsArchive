package com.jeonshijang.api.global.exception;

import lombok.Getter;

/**
 * 역할: 우리 애플리케이션에서 발생하는 비즈니스 로직 상의 오류를 처리하기 위해 만든 커스텀 예외(Custom Exception) 클래스입니다.
 * RuntimeException을 상속받아 Unchecked Exception으로 동작하며, 트랜잭션 롤백 등을 편리하게 수행할 수 있습니다.
 */
@Getter
public class ApiException extends RuntimeException {

    private final ErrorCode errorCode; // 앞서 정의한 ErrorCode(상태 코드와 메시지)를 담고 있습니다.

    /**
     * 역할: 예외를 발생시킬 때 특정 ErrorCode를 주입받아 초기화합니다.
     */
    public ApiException(ErrorCode errorCode) {
        super(errorCode.getMessage()); // 부모 클래스인 RuntimeException에 에러 메시지를 전달합니다.
        this.errorCode = errorCode;
    }
}
