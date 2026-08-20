package com.jeonshijang.api.api.showcase.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record PlaceItemRequest(
        @NotNull Long goodsId,
        @NotNull @Min(1) Integer pageNumber,
        @NotNull @Min(1) @Max(2) Integer shelfNumber,
        @NotNull Double xPosition,
        @NotNull Double yPosition,
        @NotNull Double scale
) {}
