package com.jeonshijang.api.api.showcase.dto;

import jakarta.validation.constraints.NotNull;

/**
 * 역할: 전시장 내에 배치될 '단일' 아이템의 정보를 담는 요청용 DTO입니다.
 */
public record PlaceItemRequest(
        @NotNull Long goodsId,     // 배치할 상품의 ID
        @NotNull Double positionX, // X 좌표
        @NotNull Double positionY, // Y 좌표
        @NotNull Double scale      // 크기 비율
) {}
