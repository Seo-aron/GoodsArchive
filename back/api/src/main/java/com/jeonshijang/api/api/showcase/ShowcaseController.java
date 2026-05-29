package com.jeonshijang.api.api.showcase;

import com.jeonshijang.api.api.showcase.dto.PlaceItemsRequest;
import com.jeonshijang.api.api.showcase.dto.ShowcaseResponse;
import com.jeonshijang.api.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/showcases")
@RequiredArgsConstructor
public class ShowcaseController {

    private final ShowcaseService showcaseService;

    @GetMapping("/mine")
    public ResponseEntity<ShowcaseResponse> getMyShowcase(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(showcaseService.getOrCreateMyShowcase(principal.getUserId()));
    }

    @PutMapping("/{showcaseId}/items")
    public ResponseEntity<ShowcaseResponse> placeItems(
            @PathVariable Long showcaseId,
            @Valid @RequestBody PlaceItemsRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(showcaseService.placeItems(showcaseId, request, principal.getUserId()));
    }
}
