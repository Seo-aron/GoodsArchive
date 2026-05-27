package com.jeonshijang.api.infra.kakao.dto;

public record KakaoUserInfo(
        Long kakaoId,
        String nickname,
        String profileImageUrl
) {
    public static KakaoUserInfo from(KakaoApiResponse response) {
        String nickname = null;
        String profileImageUrl = null;

        if (response.kakaoAccount() != null && response.kakaoAccount().profile() != null) {
            nickname = response.kakaoAccount().profile().nickname();
            profileImageUrl = response.kakaoAccount().profile().profileImageUrl();
        }

        return new KakaoUserInfo(response.id(), nickname, profileImageUrl);
    }
}
