package com.jeonshijang.api.api.showcase.dto;

import com.jeonshijang.api.domain.showcase.Showcase;

import java.util.List;

/**
 * 역할: 클라이언트에게 전시장 전체 정보(전시장 자체 정보 + 내부 아이템 목록)를 전달할 때 사용하는 응답용 DTO입니다.
 */
public record ShowcaseResponse(
        Long id,
        String name,
        List<ShowcaseItemResponse> items
) {
    /**
     * 역할: Showcase 엔티티 객체를 응답용 DTO로 변환하는 팩토리 메서드입니다.
     */
    public static ShowcaseResponse from(Showcase showcase) {
        return new ShowcaseResponse(
                showcase.getId(),
                showcase.getName(),
                // 핵심: Showcase에 포함된 ShowcaseItem 엔티티 리스트를 순회하며 각각 ShowcaseItemResponse DTO로 변환합니다.
                showcase.getItems().stream()
                        .map(ShowcaseItemResponse::from)
                        .toList()
        );
    }
}
