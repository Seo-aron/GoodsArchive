package com.jeonshijang.api.api.goods.dto;

import java.math.BigDecimal;

public record GoodsSummaryResponse(
        long totalCount,
        BigDecimal totalValue
) {}
