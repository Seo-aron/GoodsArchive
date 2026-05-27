package com.jeonshijang.api.domain.showcase;

import com.jeonshijang.api.domain.goods.Goods;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
    name = "showcase_item",
    indexes = {
        @Index(name = "idx_showcase_item_showcase_id", columnList = "showcase_id"),
        @Index(name = "idx_showcase_item_goods_id",   columnList = "goods_id")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ShowcaseItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "showcase_id", nullable = false)
    private Showcase showcase;

    // 굿즈 소프트 딜리트 정책으로 FK는 항상 유효한 레코드를 참조하므로 nullable = false
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goods_id", nullable = false)
    private Goods goods;

    @Column(nullable = false)
    private Double positionX;

    @Column(nullable = false)
    private Double positionY;

    @Column(nullable = false)
    private Double scale;

    @Builder
    public ShowcaseItem(Showcase showcase, Goods goods,
                        Double positionX, Double positionY, Double scale) {
        this.showcase = showcase;
        this.goods = goods;
        this.positionX = positionX;
        this.positionY = positionY;
        this.scale = scale;
    }

    public void updatePosition(Double positionX, Double positionY, Double scale) {
        this.positionX = positionX;
        this.positionY = positionY;
        this.scale = scale;
    }
}
