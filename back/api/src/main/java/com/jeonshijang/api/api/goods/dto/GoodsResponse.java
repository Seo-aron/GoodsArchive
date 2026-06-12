package com.jeonshijang.api.api.goods.dto;

import com.jeonshijang.api.domain.goods.Goods;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 역할: 클라이언트에게 상품 1개의 상세 정보를 전달할 때 사용하는 응답용 DTO입니다.
 */
public record GoodsResponse(
        Long id,
        String name,
        String imageUrl,
        BigDecimal price,
        LocalDate purchasedAt,
        String memo
) {
    /**
     * 역할: Goods 엔티티 객체를 받아서 클라이언트 응답용 GoodsResponse DTO 객체로 변환해주는 팩토리 메서드입니다.
     * 핵심: 서비스 로직(Service)에서 조회한 영속성 객체(Entity)를 외부에 그대로 노출하지 않고, 필요한 데이터만 추려 DTO로 매핑합니다.
     */
    public static GoodsResponse from(Goods goods) {
        return new GoodsResponse(
                goods.getId(),
                goods.getName(),
                goods.getImageUrl(),
                goods.getPrice(),
                goods.getPurchasedAt(),
                goods.getMemo()
        );
    }
}
