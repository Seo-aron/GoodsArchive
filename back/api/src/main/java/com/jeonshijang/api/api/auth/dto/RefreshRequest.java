package com.jeonshijang.api.api.auth.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 역할: 클라이언트가 토큰 재발급(Refresh)을 요청할 때 보내는 데이터를 담는 DTO입니다.
 */
public record RefreshRequest(
        @NotBlank(message = "리프레시 토큰은 필수입니다.") String refreshToken
) {}
