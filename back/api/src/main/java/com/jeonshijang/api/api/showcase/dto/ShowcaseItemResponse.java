package com.jeonshijang.api.api.showcase.dto;

import com.jeonshijang.api.domain.showcase.ShowcaseItem;

public record ShowcaseItemResponse(
        Long id,
        Long goodsId,
        String goodsName,
        String goodsImageUrl,
        Integer pageNumber,
        Integer shelfNumber,
        Double xPosition,
        Double yPosition,
        Double scale
) {
    public static ShowcaseItemResponse from(ShowcaseItem item) {
        return new ShowcaseItemResponse(
                item.getId(),
                item.getGoods().getId(),
                item.getGoods().getName(),
                item.getGoods().getImageUrl(),
                item.getPageNumber(),
                item.getShelfNumber(),
                item.getXPosition(),
                item.getYPosition(),
                item.getScale()
        );
    }
}
