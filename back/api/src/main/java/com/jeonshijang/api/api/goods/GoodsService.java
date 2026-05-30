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

/**
 * 역할: 상품(Goods) 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 */
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class GoodsService {

    private final GoodsRepository goodsRepository;

    /**
     * 역할: 현재 등록된 모든 상품 목록을 조회합니다.
     * TODO: 추후 인증 기능이 연동되면 전체 조회가 아닌, 로그인한 사용자(currentUserId)의 상품만 조회하도록 수정해야 합니다.
     */
    public List<GoodsResponse> getAllGoods() {
        return goodsRepository.findAll().stream()
                .map(GoodsResponse::from) // Entity 객체를 API 응답용 DTO 객체로 변환합니다.
                .toList();
    }

    /**
     * 역할: 사용자가 가진 전체 상품의 개수와 총 가치(가격의 합)를 계산하여 요약 정보를 제공합니다.
     */
    public GoodsSummaryResponse getSummary() {
        List<Goods> goods = goodsRepository.findAll();
        
        // 핵심: 모든 상품의 가격을 순회하며 하나의 총합(Total Value)으로 누적 합산합니다. 가격이 null인 경우 0으로 취급합니다.
        BigDecimal totalValue = goods.stream()
                .map(g -> g.getPrice() != null ? g.getPrice() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
                
        return new GoodsSummaryResponse(goods.size(), totalValue);
    }
}