package com.jeonshijang.api.api.showcase.dto;

import jakarta.validation.constraints.NotNull;

public record PlaceItemRequest(
        @NotNull Long goodsId,
        @NotNull Double positionX,
        @NotNull Double positionY,
        @NotNull Double scale
) {}
