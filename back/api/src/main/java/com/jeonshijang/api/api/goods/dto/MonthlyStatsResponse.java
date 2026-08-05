package com.jeonshijang.api.api.goods.dto;

import java.math.BigDecimal;

public record MonthlyStatsResponse(
        int year,
        int month,
        BigDecimal totalAmount,
        long goodsCount
) {}
