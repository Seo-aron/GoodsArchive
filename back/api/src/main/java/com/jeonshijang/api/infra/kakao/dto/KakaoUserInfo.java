package com.jeonshijang.api.infra.kakao.dto;

/**
 * 역할: 카카오 API로부터 받은 사용자 정보를 우리 시스템 내부에서 일관된 형태로 사용하기 위한 DTO입니다.
 * 핵심: 복잡한 KakaoApiResponse 구조에서 필요한 정보(ID, 닉네임, 프로필 이미지)만 추출하여 단순화된 객체로 만듭니다.
 */
public record KakaoUserInfo(
        Long kakaoId,
        String nickname,
        String profileImageUrl
) {
    /**
     * 역할: KakaoApiResponse 객체를 받아 KakaoUserInfo 객체로 변환하는 팩토리 메서드입니다.
     */
    public static KakaoUserInfo from(KakaoApiResponse response) {
        String nickname = null;
        String profileImageUrl = null;

        // 핵심: 카카오 응답에서 profile 정보가 null일 수 있는 경우를 대비하여 Null-Safe하게 처리합니다.
        if (response.kakaoAccount() != null && response.kakaoAccount().profile() != null) {
            nickname = response.kakaoAccount().profile().nickname();
            profileImageUrl = response.kakaoAccount().profile().profileImageUrl();
        }

        return new KakaoUserInfo(response.id(), nickname, profileImageUrl);
    }
}
