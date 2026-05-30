package com.jeonshijang.api.domain.goods;

import com.jeonshijang.api.domain.common.BaseEntity;
import com.jeonshijang.api.domain.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLRestriction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 역할: '상품(Goods)'의 정보를 담는 핵심 도메인 엔티티입니다.
 */
@Entity
@Table(
    name = "goods",
    indexes = @Index(name = "idx_goods_user_id", columnList = "user_id") // user_id로 조회가 많을 것을 대비한 인덱스 설정
)
@SQLRestriction("deleted_at IS NULL") // 핵심: Soft Delete를 위한 설정. 모든 조회 쿼리에 '삭제되지 않은' 상품만 조회하도록 조건을 자동 추가합니다.
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Goods extends BaseEntity { // BaseEntity를 상속받아 생성일(createdAt)과 수정일(updatedAt)을 자동으로 관리합니다.

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // 핵심: 상품은 특정 사용자(User)에게 속해있음을 나타내는 다대일 관계입니다.
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name; // 상품명

    @Column(nullable = false)
    private String imageUrl; // 상품 이미지 URL

    private LocalDate purchasedAt; // 구매일

    @Column(precision = 12, scale = 2)
    private BigDecimal price; // 가격 (정확한 소수점 계산을 위해 BigDecimal 사용)

    @Column(columnDefinition = "TEXT")
    private String memo; // 메모

    // 소프트 딜리트용 컬럼. @SQLRestriction이 모든 조회 쿼리에 자동 적용됨.
    @Column
    private LocalDateTime deletedAt; // 삭제 시간

    @Builder
    public Goods(User user, String name, String imageUrl,
                 LocalDate purchasedAt, BigDecimal price, String memo) {
        this.user = user;
        this.name = name;
        this.imageUrl = imageUrl;
        this.purchasedAt = purchasedAt;
        this.price = price;
        this.memo = memo;
    }

    /**
     * 역할: 상품의 상세 정보(이름, 구매일, 가격, 메모)를 수정합니다.
     */
    public void updateDetails(String name, LocalDate purchasedAt, BigDecimal price, String memo) {
        this.name = name;
        this.purchasedAt = purchasedAt;
        this.price = price;
        this.memo = memo;
    }

    /**
     * 역할: 상품을 실제로 삭제하는 대신, 삭제 시간을 기록하여 '삭제된 상태'로 변경합니다. (Soft Delete)
     */
    public void softDelete() {
        this.deletedAt = LocalDateTime.now();
    }

    /**
     * 역할: 상품이 삭제되었는지 여부를 확인합니다.
     */
    public boolean isDeleted() {
        return this.deletedAt != null;
    }
}
