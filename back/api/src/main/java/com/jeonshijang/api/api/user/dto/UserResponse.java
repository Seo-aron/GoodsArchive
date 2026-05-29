package com.jeonshijang.api.api.user.dto;

import com.jeonshijang.api.domain.user.User;

public record UserResponse(
        Long id,
        String nickname,
        String profileImageUrl
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getNickname(),
                user.getProfileImageUrl()
        );
    }
}
