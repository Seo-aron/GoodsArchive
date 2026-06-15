package com.jeonshijang.api.api.goods.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record GoodsRegisterRequest(
        String name,
        BigDecimal price,
        LocalDate purchasedAt,
        String memo
) {}
