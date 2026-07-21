package com.jeonshijang.api.api.goods;

import com.jeonshijang.api.api.goods.dto.GoodsRegisterRequest;
import com.jeonshijang.api.api.goods.dto.GoodsResponse;
import com.jeonshijang.api.api.goods.dto.GoodsSummaryResponse;
import com.jeonshijang.api.api.goods.dto.GoodsUpdateRequest;
import com.jeonshijang.api.domain.goods.Goods;
import com.jeonshijang.api.domain.goods.GoodsRepository;
import com.jeonshijang.api.domain.user.User;
import com.jeonshijang.api.domain.user.UserRepository;
import com.jeonshijang.api.global.exception.ApiException;
import com.jeonshijang.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class GoodsService {

    private final GoodsRepository goodsRepository;
    private final UserRepository userRepository;

    @Value("${app.upload-dir:./uploads}")
    private String uploadDir;

    public List<GoodsResponse> getMyGoods(Long userId) {
        return goodsRepository.findByUserId(userId).stream()
                .map(GoodsResponse::from)
                .toList();
    }

    public GoodsSummaryResponse getMySummary(Long userId) {
        List<Goods> goods = goodsRepository.findByUserId(userId);
        BigDecimal totalValue = goods.stream()
                .map(g -> g.getPrice() != null ? g.getPrice() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return new GoodsSummaryResponse(goods.size(), totalValue);
    }

    @Transactional
    public GoodsResponse registerGoods(Long userId, MultipartFile image, GoodsRegisterRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(ErrorCode.USER_NOT_FOUND));

        String imageUrl = saveImage(image);

        Goods goods = Goods.builder()
                .user(user)
                .name(request.name())
                .imageUrl(imageUrl)
                .price(request.price())
                .purchasedAt(request.purchasedAt())
                .memo(request.memo())
                .build();

        return GoodsResponse.from(goodsRepository.save(goods));
    }

    @Transactional
    public GoodsResponse updateGoods(Long goodsId, Long userId, MultipartFile image, GoodsUpdateRequest request) {
        Goods goods = goodsRepository.findById(goodsId)
                .orElseThrow(() -> new ApiException(ErrorCode.GOODS_NOT_FOUND));
        if (!goods.getUser().getId().equals(userId)) {
            throw new ApiException(ErrorCode.FORBIDDEN);
        }
        if (image != null && !image.isEmpty()) {
            goods.updateImageUrl(saveImage(image));
        }
        LocalDate purchasedAt = request.purchasedAt() != null ? request.purchasedAt() : goods.getPurchasedAt();
        goods.updateDetails(request.name(), purchasedAt, request.price(), request.memo());
        return GoodsResponse.from(goods);
    }

    @Transactional
    public void deleteGoods(Long goodsId, Long userId) {
        Goods goods = goodsRepository.findById(goodsId)
                .orElseThrow(() -> new ApiException(ErrorCode.GOODS_NOT_FOUND));
        if (!goods.getUser().getId().equals(userId)) {
            throw new ApiException(ErrorCode.FORBIDDEN);
        }
        goods.softDelete();
    }

    private String saveImage(MultipartFile image) {
        try {
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath();
            Files.createDirectories(uploadPath);

            String ext = getExtension(image.getOriginalFilename());
            String filename = UUID.randomUUID() + ext;
            image.transferTo(uploadPath.resolve(filename));

            return "/uploads/" + filename;
        } catch (IOException e) {
            throw new ApiException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf('.'));
    }
}
