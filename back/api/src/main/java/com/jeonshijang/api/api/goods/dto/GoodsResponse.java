package com.jeonshijang.api.api.goods.dto;

import com.jeonshijang.api.domain.goods.Goods;

import java.math.BigDecimal;
import java.time.LocalDate;

public record GoodsResponse(
        Long id,
        String name,
        String imageUrl,
        BigDecimal price,
        LocalDate purchasedAt,
        String memo
) {
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
