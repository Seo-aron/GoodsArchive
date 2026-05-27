package com.jeonshijang.api.api.auth;

import com.jeonshijang.api.api.auth.dto.TokenResponse;
import com.jeonshijang.api.domain.user.User;
import com.jeonshijang.api.domain.user.UserRepository;
import com.jeonshijang.api.global.exception.ApiException;
import com.jeonshijang.api.global.exception.ErrorCode;
import com.jeonshijang.api.infra.kakao.KakaoTokenVerifier;
import com.jeonshijang.api.infra.kakao.dto.KakaoUserInfo;
import com.jeonshijang.api.security.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final KakaoTokenVerifier kakaoTokenVerifier;
    private final JwtProvider jwtProvider;

    @Transactional
    public TokenResponse kakaoLogin(String kakaoAccessToken) {
        KakaoUserInfo kakaoUser = kakaoTokenVerifier.verify(kakaoAccessToken);

        User user = userRepository.findByKakaoId(kakaoUser.kakaoId())
                .map(existing -> {
                    // 닉네임/프로필은 카카오 최신값으로 갱신
                    existing.updateProfile(kakaoUser.nickname(), kakaoUser.profileImageUrl());
                    return existing;
                })
                .orElseGet(() -> userRepository.save(
                        User.builder()
                                .kakaoId(kakaoUser.kakaoId())
                                .nickname(kakaoUser.nickname())
                                .profileImageUrl(kakaoUser.profileImageUrl())
                                .build()
                ));

        String role = user.getRole().name();
        return TokenResponse.of(
                jwtProvider.generateAccessToken(user.getId(), role),
                jwtProvider.generateRefreshToken(user.getId(), role)
        );
    }

    public TokenResponse refresh(String refreshToken) {
        if (!jwtProvider.validate(refreshToken)) {
            throw new ApiException(ErrorCode.INVALID_TOKEN);
        }
        if (!"refresh".equals(jwtProvider.getTokenType(refreshToken))) {
            throw new ApiException(ErrorCode.INVALID_TOKEN);
        }

        Long userId = jwtProvider.getUserId(refreshToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(ErrorCode.USER_NOT_FOUND));

        String role = user.getRole().name();
        return TokenResponse.of(
                jwtProvider.generateAccessToken(user.getId(), role),
                jwtProvider.generateRefreshToken(user.getId(), role)
        );
    }
}
