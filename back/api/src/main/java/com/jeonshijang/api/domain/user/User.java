package com.jeonshijang.api.domain.user;

import com.jeonshijang.api.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

/**
 * 역할: '회원(User)'의 정보를 담는 도메인 엔티티입니다.
 */
@Entity
@Table(
    name = "users", // DB에서 예약어 충돌을 피하기 위해 보통 복수형(users)을 사용합니다.
    uniqueConstraints = @UniqueConstraint(name = "uk_users_kakao_id", columnNames = "kakao_id") // 핵심: 카카오 ID는 중복될 수 없도록 고유(Unique) 제약조건을 설정합니다.
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseEntity { // BaseEntity를 상속받아 생성일(createdAt)과 수정일(updatedAt)을 자동으로 관리합니다.

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "kakao_id", nullable = false)
    private Long kakaoId; // 카카오 로그인 시 발급받는 고유 사용자 ID

    private String nickname; // 닉네임

    private String profileImageUrl; // 프로필 이미지 URL

    @Enumerated(EnumType.STRING) // 핵심: Enum 값을 DB에 저장할 때 숫자가 아닌 문자열(USER, ADMIN 등)로 저장하도록 설정합니다.
    @Column(nullable = false)
    private UserRole role; // 사용자 권한 등급

    @Builder
    public User(Long kakaoId, String nickname, String profileImageUrl) {
        this.kakaoId = kakaoId;
        this.nickname = nickname;
        this.profileImageUrl = profileImageUrl;
        this.role = UserRole.USER; // 기본 권한은 일반 유저(USER)로 설정
    }

    /**
     * 역할: 회원의 프로필 정보(닉네임, 프로필 이미지)를 수정합니다.
     */
    public void updateProfile(String nickname, String profileImageUrl) {
        this.nickname = nickname;
        this.profileImageUrl = profileImageUrl;
    }
}
