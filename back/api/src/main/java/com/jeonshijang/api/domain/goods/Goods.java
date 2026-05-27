package com.jeonshijang.api.domain.goods;

import com.jeonshijang.api.domain.common.BaseEntity;
import com.jeonshijang.api.domain.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.SQLRestriction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "goods",
    indexes = @Index(name = "idx_goods_user_id", columnList = "user_id")
)
@SQLRestriction("deleted_at IS NULL")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Goods extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String imageUrl;

    private LocalDate purchasedAt;

    @Column(precision = 12, scale = 2)
    private BigDecimal price;

    @Column(columnDefinition = "TEXT")
    private String memo;

    // 소프트 딜리트용 컬럼. @SQLRestriction이 모든 조회 쿼리에 자동 적용됨.
    @Column
    private LocalDateTime deletedAt;

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

    public void updateDetails(String name, LocalDate purchasedAt, BigDecimal price, String memo) {
        this.name = name;
        this.purchasedAt = purchasedAt;
        this.price = price;
        this.memo = memo;
    }

    public void softDelete() {
        this.deletedAt = LocalDateTime.now();
    }

    public boolean isDeleted() {
        return this.deletedAt != null;
    }
}
