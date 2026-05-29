package com.jeonshijang.api.api.showcase.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record PlaceItemsRequest(
        @NotNull @Valid List<PlaceItemRequest> items
) {}
