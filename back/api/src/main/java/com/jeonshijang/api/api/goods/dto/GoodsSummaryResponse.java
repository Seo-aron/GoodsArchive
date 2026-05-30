package com.jeonshijang.api.api.goods.dto;

import java.math.BigDecimal;

/**
 * 역할: 클라이언트에게 상품의 요약 정보(전체 개수, 총 가격)를 전달할 때 사용하는 응답용 DTO입니다.
 */
public record GoodsSummaryResponse(
        long totalCount,     // 전체 상품 개수
        BigDecimal totalValue // 모든 상품 가격의 총 합계
) {}
