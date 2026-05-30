package com.jeonshijang.api.api.goods;

import com.jeonshijang.api.api.goods.dto.GoodsResponse;
import com.jeonshijang.api.api.goods.dto.GoodsSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 역할: 클라이언트로부터 들어오는 '상품(Goods)' 관련 HTTP 요청을 받아 처리하는 컨트롤러입니다.
 */
@RestController
@RequestMapping("/api/goods")
@RequiredArgsConstructor
public class GoodsController {

    private final GoodsService goodsService;

    /**
     * 역할: 등록된 모든 상품 목록을 조회합니다.
     * 엔드포인트: GET /api/goods
     */
    @GetMapping
    public ResponseEntity<List<GoodsResponse>> getGoods() {
        // 핵심: GoodsService에 상품 목록 조회 로직을 위임하고 그 결과를 반환합니다.
        return ResponseEntity.ok(goodsService.getAllGoods());
    }

    /**
     * 역할: 상품의 전체 개수와 총 가격 합계를 조회합니다.
     * 엔드포인트: GET /api/goods/summary
     */
    @GetMapping("/summary")
    public ResponseEntity<GoodsSummaryResponse> getSummary() {
        // 핵심: GoodsService에 요약 정보 조회 로직을 위임하고 그 결과를 반환합니다.
        return ResponseEntity.ok(goodsService.getSummary());
    }
}
