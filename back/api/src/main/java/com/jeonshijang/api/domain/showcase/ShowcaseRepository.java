package com.jeonshijang.api.domain.showcase;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ShowcaseRepository extends JpaRepository<Showcase, Long> {

    @EntityGraph(attributePaths = {"items", "items.goods"})
    Optional<Showcase> findByUser_Id(Long userId);

    @EntityGraph(attributePaths = {"items", "items.goods"})
    @Query("SELECT s FROM Showcase s WHERE s.id = :id")
    Optional<Showcase> findByIdWithItems(@Param("id") Long id);
}
