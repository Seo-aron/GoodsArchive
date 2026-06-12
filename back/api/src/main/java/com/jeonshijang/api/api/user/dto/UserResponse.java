package com.jeonshijang.api.api.user.dto;

import com.jeonshijang.api.domain.user.User;

/**
 * 역할: 클라이언트에게 사용자 정보를 전달할 때 사용하는 응답용 DTO입니다.
 */
public record UserResponse(
        Long id,
        String nickname,
        String profileImageUrl
) {
    /**
     * 역할: User 엔티티 객체를 받아서 클라이언트 응답용 UserResponse DTO 객체로 변환해주는 팩토리 메서드입니다.
     */
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getNickname(),
                user.getProfileImageUrl()
        );
    }
}
