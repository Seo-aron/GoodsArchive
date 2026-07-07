package com.jeonshijang.api.domain.user;

import com.jeonshijang.api.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

/**
 * 역할: '회원(User)'의 정보를 담는 도메인 엔티티입니다.
 */
@Entity
@Table(
    name = "users",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_users_kakao_id", columnNames = "kakao_id"),
        @UniqueConstraint(name = "uk_users_login_id", columnNames = "login_id")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "kakao_id")
    private Long kakaoId;

    @Column(name = "login_id")
    private String loginId;

    private String password;

    private String nickname;

    private String profileImageUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    public static User ofKakao(Long kakaoId, String nickname, String profileImageUrl) {
        User user = new User();
        user.kakaoId = kakaoId;
        user.nickname = nickname;
        user.profileImageUrl = profileImageUrl;
        user.role = UserRole.USER;
        return user;
    }

    public static User ofLocal(String loginId, String password, String nickname) {
        User user = new User();
        user.loginId = loginId;
        user.password = password;
        user.nickname = nickname;
        user.role = UserRole.USER;
        return user;
    }

    public void updateProfile(String nickname, String profileImageUrl) {
        this.nickname = nickname;
        this.profileImageUrl = profileImageUrl;
    }
}
