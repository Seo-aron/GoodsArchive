package com.jeonshijang.api.api.showcase.dto;

import com.jeonshijang.api.domain.showcase.Showcase;

import java.util.List;

public record ShowcaseResponse(
        Long id,
        String name,
        Integer maxPages,
        List<ShowcaseItemResponse> items
) {
    public static ShowcaseResponse from(Showcase showcase) {
        return new ShowcaseResponse(
                showcase.getId(),
                showcase.getName(),
                showcase.getMaxPages(),
                showcase.getItems().stream()
                        .map(ShowcaseItemResponse::from)
                        .toList()
        );
    }
}
