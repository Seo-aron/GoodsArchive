package com.jeonshijang.api.api.showcase.dto;

import com.jeonshijang.api.domain.showcase.ShowcaseItem;

/**
 * 역할: 클라이언트에게 전시장 내에 배치된 '단일' 아이템의 상세 정보를 전달할 때 사용하는 응답용 DTO입니다.
 */
public record ShowcaseItemResponse(
        Long id,
        Long goodsId,
        String goodsName,
        String goodsImageUrl,
        Double positionX,
        Double positionY,
        Double scale
) {
    /**
     * 역할: ShowcaseItem 엔티티 객체를 응답용 DTO로 변환하는 팩토리 메서드입니다.
     */
    public static ShowcaseItemResponse from(ShowcaseItem item) {
        return new ShowcaseItemResponse(
                item.getId(),
                item.getGoods().getId(),
                item.getGoods().getName(),
                item.getGoods().getImageUrl(),
                item.getPositionX(),
                item.getPositionY(),
                item.getScale()
        );
    }
}
