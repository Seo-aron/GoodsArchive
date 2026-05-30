package com.jeonshijang.api.infra.kakao.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 역할: 카카오 API 서버로부터 반환받는 JSON 응답 구조를 매핑하기 위한 DTO입니다.
 * 핵심: @JsonIgnoreProperties(ignoreUnknown = true)를 사용하여, 우리가 정의하지 않은 필드가 응답에 포함되어 있어도 에러 없이 파싱하도록 합니다.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record KakaoApiResponse(
        @JsonProperty("id") Long id, // 카카오 고유 ID
        @JsonProperty("kakao_account") KakaoAccount kakaoAccount // 카카오 계정 정보 (닉네임, 프로필 이미지 등 포함)
) {
    /**
     * 역할: 카카오 API 응답 내의 'kakao_account' JSON 객체를 매핑합니다.
     */
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record KakaoAccount(
            @JsonProperty("profile") KakaoProfile profile // 사용자 프로필 정보
    ) {}

    /**
     * 역할: 카카오 API 응답 내의 'profile' JSON 객체를 매핑합니다.
     */
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record KakaoProfile(
            @JsonProperty("nickname") String nickname, // 닉네임
            @JsonProperty("profile_image_url") String profileImageUrl // 프로필 이미지 URL
    ) {}
}
