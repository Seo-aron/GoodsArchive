package com.jeonshijang.api.api.showcase.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

import java.util.List;

/**
 * 역할: 클라이언트가 여러 개의 아이템 배치를 한 번에 요청할 때 사용하는 DTO입니다.
 */
public record PlaceItemsRequest(
        // 핵심: @Valid를 사용하여 리스트 내부의 각 PlaceItemRequest 객체들도 유효성 검사를 수행하도록 합니다.
        @NotNull @Valid List<PlaceItemRequest> items
) {}
