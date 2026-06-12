package com.jeonshijang.api.domain.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * 역할: User(회원) 엔티티의 데이터베이스 접근(CRUD)을 담당하는 인터페이스입니다.
 */
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * 역할: 카카오 고유 ID를 기반으로 회원 정보를 조회합니다.
     * 핵심: 주로 카카오 로그인 시 이미 가입된 회원인지 확인하기 위해 사용됩니다.
     */
    Optional<User> findByKakaoId(Long kakaoId);
}
