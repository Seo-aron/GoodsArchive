package com.jeonshijang.api.api.auth.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 역할: 클라이언트가 카카오 로그인을 요청할 때 보내는 데이터를 담는 DTO(Data Transfer Object)입니다.
 * 핵심: Record를 사용하여 불변(Immutable) 객체로 설계되었으며, @NotBlank를 통해 필수 값이 누락되지 않도록 검증합니다.
 */
public record KakaoLoginRequest(
        @NotBlank(message = "카카오 액세스 토큰은 필수입니다.") String accessToken
) {}