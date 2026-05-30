package com.jeonshijang.api.domain.showcase;

import com.jeonshijang.api.domain.goods.Goods;
import jakarta.persistence.*;
import lombok.*;

/**
 * 역할: 전시장(Showcase) 내부에 배치된 특정 상품(Goods)의 위치와 크기 정보를 담는 도메인 엔티티입니다.
 */
@Entity
@Table(
    name = "showcase_item",
    indexes = {
        @Index(name = "idx_showcase_item_showcase_id", columnList = "showcase_id"), // 전시장 ID로 조회를 위한 인덱스
        @Index(name = "idx_showcase_item_goods_id",   columnList = "goods_id")    // 상품 ID로 조회를 위한 인덱스
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ShowcaseItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // 핵심: 하나의 전시장(Showcase)에 여러 개의 아이템(ShowcaseItem)이 속할 수 있습니다.
    @JoinColumn(name = "showcase_id", nullable = false)
    private Showcase showcase;

    // 굿즈 소프트 딜리트 정책으로 FK는 항상 유효한 레코드를 참조하므로 nullable = false
    @ManyToOne(fetch = FetchType.LAZY) // 핵심: 각 아이템(ShowcaseItem)은 특정 상품(Goods) 정보를 가리킵니다.
    @JoinColumn(name = "goods_id", nullable = false)
    private Goods goods;

    @Column(nullable = false)
    private Double positionX; // 전시장 내 X 좌표

    @Column(nullable = false)
    private Double positionY; // 전시장 내 Y 좌표

    @Column(nullable = false)
    private Double scale; // 배치 크기 비율 (확대/축소)

    @Builder
    public ShowcaseItem(Showcase showcase, Goods goods,
                        Double positionX, Double positionY, Double scale) {
        this.showcase = showcase;
        this.goods = goods;
        this.positionX = positionX;
        this.positionY = positionY;
        this.scale = scale;
    }

    /**
     * 역할: 전시장 내 배치된 상품의 위치와 크기를 변경합니다.
     */
    public void updatePosition(Double positionX, Double positionY, Double scale) {
        this.positionX = positionX;
        this.positionY = positionY;
        this.scale = scale;
    }
}
