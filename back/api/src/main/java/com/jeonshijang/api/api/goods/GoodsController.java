package com.jeonshijang.api.api.goods;

import com.jeonshijang.api.api.goods.dto.GoodsResponse;
import com.jeonshijang.api.api.goods.dto.GoodsSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/goods")
@RequiredArgsConstructor
public class GoodsController {

    private final GoodsService goodsService;

    @GetMapping
    public ResponseEntity<List<GoodsResponse>> getGoods() {
        return ResponseEntity.ok(goodsService.getAllGoods());
    }

    @GetMapping("/summary")
    public ResponseEntity<GoodsSummaryResponse> getSummary() {
        return ResponseEntity.ok(goodsService.getSummary());
    }
}
