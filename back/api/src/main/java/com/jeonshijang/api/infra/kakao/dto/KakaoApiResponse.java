package com.jeonshijang.api.infra.kakao.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public record KakaoApiResponse(
        @JsonProperty("id") Long id,
        @JsonProperty("kakao_account") KakaoAccount kakaoAccount
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record KakaoAccount(
            @JsonProperty("profile") KakaoProfile profile
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record KakaoProfile(
            @JsonProperty("nickname") String nickname,
            @JsonProperty("profile_image_url") String profileImageUrl
    ) {}
}
