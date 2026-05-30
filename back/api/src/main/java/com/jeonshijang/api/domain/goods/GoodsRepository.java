package com.jeonshijang.api.domain.goods;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * 역할: Goods(상품) 엔티티의 데이터베이스 접근(CRUD)을 담당하는 인터페이스입니다.
 * JpaRepository를 상속받아 기본적인 저장, 조회, 삭제 기능을 자동으로 제공받습니다.
 */
public interface GoodsRepository extends JpaRepository<Goods, Long> {
    
    /**
     * 역할: 특정 사용자가 소유한 모든 상품 목록을 조회합니다.
     * 핵심: Spring Data JPA의 메서드 이름 규칙을 통해 'SELECT * FROM goods WHERE user_id = ?' 쿼리가 자동 생성됩니다.
     */
    List<Goods> findByUserId(Long userId);
}
