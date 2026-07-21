package com.jeonshijang.api.api.goods;

import com.jeonshijang.api.api.goods.dto.GoodsRegisterRequest;
import com.jeonshijang.api.api.goods.dto.GoodsResponse;
import com.jeonshijang.api.api.goods.dto.GoodsSummaryResponse;
import com.jeonshijang.api.api.goods.dto.GoodsUpdateRequest;
import com.jeonshijang.api.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/goods")
@RequiredArgsConstructor
public class GoodsController {

    private final GoodsService goodsService;

    @GetMapping
    public ResponseEntity<List<GoodsResponse>> getGoods(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(goodsService.getMyGoods(principal.getUserId()));
    }

    @GetMapping("/summary")
    public ResponseEntity<GoodsSummaryResponse> getSummary(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(goodsService.getMySummary(principal.getUserId()));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<GoodsResponse> register(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestPart("image") MultipartFile image,
            @RequestParam("name") String name,
            @RequestParam(value = "price", required = false) BigDecimal price,
            @RequestParam(value = "purchasedAt", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate purchasedAt,
            @RequestParam(value = "memo", required = false) String memo) {
        var request = new GoodsRegisterRequest(name, price, purchasedAt, memo);
        return ResponseEntity.ok(goodsService.registerGoods(principal.getUserId(), image, request));
    }

    @PutMapping(value = "/{goodsId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<GoodsResponse> update(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long goodsId,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @RequestParam("name") String name,
            @RequestParam(value = "price", required = false) BigDecimal price,
            @RequestParam(value = "purchasedAt", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate purchasedAt,
            @RequestParam(value = "memo", required = false) String memo) {
        var request = new GoodsUpdateRequest(name, price, memo, purchasedAt);
        return ResponseEntity.ok(goodsService.updateGoods(goodsId, principal.getUserId(), image, request));
    }

    @DeleteMapping("/{goodsId}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long goodsId) {
        goodsService.deleteGoods(goodsId, principal.getUserId());
        return ResponseEntity.noContent().build();
    }
}
