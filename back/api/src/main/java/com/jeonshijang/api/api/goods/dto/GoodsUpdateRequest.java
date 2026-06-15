package com.jeonshijang.api.api.goods.dto;

import java.math.BigDecimal;

public record GoodsUpdateRequest(
        String name,
        BigDecimal price,
        String memo
) {}
