package com.jeonshijang.api.domain.showcase;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

/**
 * 역할: Showcase(전시장) 엔티티의 데이터베이스 접근(CRUD)을 담당하는 인터페이스입니다.
 */
public interface ShowcaseRepository extends JpaRepository<Showcase, Long> {

    /**
     * 역할: 특정 사용자의 전시장 정보를 조회합니다.
     * 핵심: @EntityGraph를 사용하여 N+1 문제를 해결합니다. Showcase를 조회할 때, 관련된 items와 items.goods까지 한 번의 쿼리로 함께 조회(Eager Fetch)합니다.
     */
    @EntityGraph(attributePaths = {"items", "items.goods"})
    Optional<Showcase> findByUser_Id(Long userId);

    /**
     * 역할: 전시장 ID로 전시장 정보를 조회합니다.
     * 핵심: @EntityGraph를 사용하여 N+1 문제를 해결합니다. Showcase를 조회할 때, 관련된 items와 items.goods까지 한 번의 쿼리로 함께 조회(Eager Fetch)합니다.
     */
    @EntityGraph(attributePaths = {"items", "items.goods"})
    @Query("SELECT s FROM Showcase s WHERE s.id = :id")
    Optional<Showcase> findByIdWithItems(@Param("id") Long id);
}
