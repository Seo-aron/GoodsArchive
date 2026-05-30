package com.jeonshijang.api.api.showcase;

import com.jeonshijang.api.api.showcase.dto.PlaceItemsRequest;
import com.jeonshijang.api.api.showcase.dto.ShowcaseResponse;
import com.jeonshijang.api.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * 역할: 클라이언트로부터 들어오는 '전시장(Showcase)' 관련 HTTP 요청을 받아 처리하는 컨트롤러입니다.
 */
@RestController
@RequestMapping("/api/showcases")
@RequiredArgsConstructor
public class ShowcaseController {

    private final ShowcaseService showcaseService;

    /**
     * 역할: 현재 로그인한 사용자의 전시장 정보를 조회합니다. 만약 전시장이 없다면 새로 생성하여 반환합니다.
     * 엔드포인트: GET /api/showcases/mine
     */
    @GetMapping("/mine")
    public ResponseEntity<ShowcaseResponse> getMyShowcase(
            @AuthenticationPrincipal UserPrincipal principal) {
        // 핵심: 현재 로그인한 사용자의 ID를 기반으로 ShowcaseService의 로직을 호출합니다.
        return ResponseEntity.ok(showcaseService.getOrCreateMyShowcase(principal.getUserId()));
    }

    /**
     * 역할: 특정 전시장 내부에 아이템들을 배치(생성/수정)합니다.
     * 엔드포인트: PUT /api/showcases/{showcaseId}/items
     */
    @PutMapping("/{showcaseId}/items")
    public ResponseEntity<ShowcaseResponse> placeItems(
            @PathVariable Long showcaseId,
            @Valid @RequestBody PlaceItemsRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        // 핵심: 전시장 ID, 배치할 아이템 정보, 그리고 현재 로그인한 사용자 ID를 ShowcaseService로 전달하여 로직을 수행합니다.
        return ResponseEntity.ok(showcaseService.placeItems(showcaseId, request, principal.getUserId()));
    }
}
