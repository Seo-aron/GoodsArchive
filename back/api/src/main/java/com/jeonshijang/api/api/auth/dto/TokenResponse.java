package com.jeonshijang.api.api.auth.dto;

/**
 * 역할: 로그인 성공 시 또는 토큰 재발급 성공 시 클라이언트에게 반환하는 토큰 정보를 담는 DTO입니다.
 */
public record TokenResponse(
        String accessToken,  // 짧은 수명을 가지며, API 요청 시 인증 수단으로 사용되는 토큰
        String refreshToken, // 긴 수명을 가지며, Access Token이 만료되었을 때 재발급받기 위해 사용하는 토큰
        String tokenType     // 토큰의 타입 (주로 HTTP 헤더에 명시하는 "Bearer" 방식 사용)
) {
    /**
     * 역할: AccessToken과 RefreshToken만 받아 TokenResponse 객체를 생성하는 정적 팩토리 메서드입니다.
     * 핵심: tokenType을 항상 "Bearer"로 고정하여 일관성 있게 객체를 생성할 수 있도록 도와줍니다.
     */
    public static TokenResponse of(String accessToken, String refreshToken) {
        return new TokenResponse(accessToken, refreshToken, "Bearer");
    }
}
