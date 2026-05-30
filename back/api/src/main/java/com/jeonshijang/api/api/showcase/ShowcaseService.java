package com.jeonshijang.api.api.showcase;

import com.jeonshijang.api.api.showcase.dto.PlaceItemsRequest;
import com.jeonshijang.api.api.showcase.dto.ShowcaseResponse;
import com.jeonshijang.api.domain.goods.Goods;
import com.jeonshijang.api.domain.goods.GoodsRepository;
import com.jeonshijang.api.domain.showcase.Showcase;
import com.jeonshijang.api.domain.showcase.ShowcaseItem;
import com.jeonshijang.api.domain.showcase.ShowcaseRepository;
import com.jeonshijang.api.domain.user.User;
import com.jeonshijang.api.domain.user.UserRepository;
import com.jeonshijang.api.global.exception.ApiException;
import com.jeonshijang.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class ShowcaseService {

    private final ShowcaseRepository showcaseRepository;
    private final GoodsRepository goodsRepository;
    private final UserRepository userRepository;

    /**
     * 역할: 사용자의 전시장이 있으면 반환하고, 없으면 새로 생성하여 반환합니다.
     */
    @Transactional
    public ShowcaseResponse getOrCreateMyShowcase(Long userId) {
        return showcaseRepository.findByUser_Id(userId) // 핵심: 기존 전시장 조회
                .map(ShowcaseResponse::from)
                .orElseGet(() -> { // 핵심: 전시장이 없으면 예외 발생 처리 및 새 전시장 저장
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ApiException(ErrorCode.USER_NOT_FOUND));
                    Showcase created = showcaseRepository.save(
                            Showcase.builder().user(user).name("나의 전시장").build()
                    );
                    return ShowcaseResponse.from(created);
                });
    }

    /**
     * 역할: 전시장 내부에 아이템들을 배치(저장/수정)합니다.
     */
    @Transactional
    public ShowcaseResponse placeItems(Long showcaseId, PlaceItemsRequest request, Long userId) {
        Showcase showcase = showcaseRepository.findByIdWithItems(showcaseId)
                .orElseThrow(() -> new ApiException(ErrorCode.SHOWCASE_NOT_FOUND));

        if (!showcase.getUser().getId().equals(userId)) { // 핵심: 본인의 전시장인지 권한 검증
            throw new ApiException(ErrorCode.FORBIDDEN);
        }

        List<ShowcaseItem> newItems = request.items().stream()
                .map(req -> {
                    Goods goods = goodsRepository.findById(req.goodsId()) // 핵심: 배치할 상품이 실제 존재하는지 검증
                            .orElseThrow(() -> new ApiException(ErrorCode.GOODS_NOT_FOUND));
                    return ShowcaseItem.builder()
                            .showcase(showcase)
                            .goods(goods)
                            .positionX(req.positionX())
                            .positionY(req.positionY())
                            .scale(req.scale())
                            .build();
                })
                .toList();

        showcase.replaceItems(newItems); // 핵심: 기존 아이템을 모두 지우고 새 아이템 목록으로 대체 (고아 객체 제거 등 영속성 전이 활용 추측)
        // saveAndFlush: DB INSERT로 아이템 ID 확정 후 재조회하여 반환
        showcaseRepository.saveAndFlush(showcase);
        return showcaseRepository.findByIdWithItems(showcaseId)
                .map(ShowcaseResponse::from)
                .orElseThrow(() -> new ApiException(ErrorCode.SHOWCASE_NOT_FOUND));
    }
}
