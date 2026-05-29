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

    @Transactional
    public ShowcaseResponse getOrCreateMyShowcase(Long userId) {
        return showcaseRepository.findByUser_Id(userId)
                .map(ShowcaseResponse::from)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ApiException(ErrorCode.USER_NOT_FOUND));
                    Showcase created = showcaseRepository.save(
                            Showcase.builder().user(user).name("나의 전시장").build()
                    );
                    return ShowcaseResponse.from(created);
                });
    }

    @Transactional
    public ShowcaseResponse placeItems(Long showcaseId, PlaceItemsRequest request, Long userId) {
        Showcase showcase = showcaseRepository.findByIdWithItems(showcaseId)
                .orElseThrow(() -> new ApiException(ErrorCode.SHOWCASE_NOT_FOUND));

        if (!showcase.getUser().getId().equals(userId)) {
            throw new ApiException(ErrorCode.FORBIDDEN);
        }

        List<ShowcaseItem> newItems = request.items().stream()
                .map(req -> {
                    Goods goods = goodsRepository.findById(req.goodsId())
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

        showcase.replaceItems(newItems);
        // saveAndFlush: DB INSERT로 아이템 ID 확정 후 재조회하여 반환
        showcaseRepository.saveAndFlush(showcase);
        return showcaseRepository.findByIdWithItems(showcaseId)
                .map(ShowcaseResponse::from)
                .orElseThrow(() -> new ApiException(ErrorCode.SHOWCASE_NOT_FOUND));
    }
}
