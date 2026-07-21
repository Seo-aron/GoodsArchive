package com.jeonshijang.api.api.goods.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record GoodsUpdateRequest(
        String name,
        BigDecimal price,
        String memo,
        LocalDate purchasedAt
) {}
