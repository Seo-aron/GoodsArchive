package com.jeonshijang.api.api.showcase.dto;

import com.jeonshijang.api.domain.showcase.ShowcaseItem;

public record ShowcaseItemResponse(
        Long id,
        Long goodsId,
        String goodsName,
        String goodsImageUrl,
        Double positionX,
        Double positionY,
        Double scale
) {
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
