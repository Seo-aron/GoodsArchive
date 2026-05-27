package com.jeonshijang.api.global.response;

import com.jeonshijang.api.global.exception.ErrorCode;

public record ApiErrorResponse(String code, String message) {

    public static ApiErrorResponse of(ErrorCode errorCode) {
        return new ApiErrorResponse(errorCode.name(), errorCode.getMessage());
    }
}
