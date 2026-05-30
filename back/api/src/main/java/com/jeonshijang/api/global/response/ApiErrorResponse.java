package com.jeonshijang.api.global.response;

import com.jeonshijang.api.global.exception.ErrorCode;

/**
 * 역할: API 요청 처리 중 에러가 발생했을 때, 클라이언트에게 내려보낼 일관된 형식의 에러 응답 객체(DTO)입니다.
 * 구조: {"code": "에러코드명", "message": "에러 상세 메시지"} 형태의 JSON으로 변환됩니다.
 */
public record ApiErrorResponse(String code, String message) {

    /**
     * 역할: ErrorCode(Enum) 객체를 받아서 ApiErrorResponse 객체로 변환하는 팩토리 메서드입니다.
     */
    public static ApiErrorResponse of(ErrorCode errorCode) {
        return new ApiErrorResponse(errorCode.name(), errorCode.getMessage());
    }
}
