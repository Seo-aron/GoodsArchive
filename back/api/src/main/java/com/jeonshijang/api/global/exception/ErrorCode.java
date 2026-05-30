package com.jeonshijang.api.global.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 역할: 애플리케이션 전반에서 발생하는 예외 상황들을 일관성 있게 관리하기 위해 정의한 Enum(열거형) 클래스입니다.
 * 핵심: HTTP 상태 코드와 클라이언트에게 전달할 상세 메시지를 함께 관리하여, 예외 처리를 단순화하고 응답 규격을 통일합니다.
 */
@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    // Auth (인증/인가 관련 에러)
    INVALID_KAKAO_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 카카오 토큰입니다."),
    KAKAO_API_ERROR(HttpStatus.BAD_GATEWAY, "카카오 서버 호출에 실패했습니다."),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 토큰입니다."),
    EXPIRED_TOKEN(HttpStatus.UNAUTHORIZED, "만료된 토큰입니다."),

    // User (사용자 관련 에러)
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),

    // Goods (상품 관련 에러)
    GOODS_NOT_FOUND(HttpStatus.NOT_FOUND, "굿즈를 찾을 수 없습니다."),

    // Showcase (전시장 관련 에러)
    SHOWCASE_NOT_FOUND(HttpStatus.NOT_FOUND, "전시장을 찾을 수 없습니다."),

    // Common (공통 에러)
    FORBIDDEN(HttpStatus.FORBIDDEN, "접근 권한이 없습니다."),
    INVALID_INPUT(HttpStatus.BAD_REQUEST, "입력값이 올바르지 않습니다."),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다.");

    private final HttpStatus status; // HTTP 상태 코드 (예: 404 NOT_FOUND, 400 BAD_REQUEST 등)
    private final String message;    // 클라이언트에게 노출할 에러 상세 메시지
}