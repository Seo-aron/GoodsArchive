package com.jeonshijang.api.api.goods;

import com.jeonshijang.api.api.goods.dto.GoodsResponse;
import com.jeonshijang.api.api.goods.dto.GoodsSummaryResponse;
import com.jeonshijang.api.domain.goods.Goods;
import com.jeonshijang.api.domain.goods.GoodsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class GoodsService {

    private final GoodsRepository goodsRepository;

    // TODO: 인증 연동 후 findByUserId(currentUserId)로 교체
    public List<GoodsResponse> getAllGoods() {
        return goodsRepository.findAll().stream()
                .map(GoodsResponse::from)
                .toList();
    }

    public GoodsSummaryResponse getSummary() {
        List<Goods> goods = goodsRepository.findAll();
        BigDecimal totalValue = goods.stream()
                .map(g -> g.getPrice() != null ? g.getPrice() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return new GoodsSummaryResponse(goods.size(), totalValue);
    }
}
