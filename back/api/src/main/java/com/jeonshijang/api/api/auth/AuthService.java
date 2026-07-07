package com.jeonshijang.api.api.auth;

import com.jeonshijang.api.api.auth.dto.LoginRequest;
import com.jeonshijang.api.api.auth.dto.RegisterRequest;
import com.jeonshijang.api.api.auth.dto.TokenResponse;
import com.jeonshijang.api.domain.user.User;
import com.jeonshijang.api.domain.user.UserRepository;
import com.jeonshijang.api.global.exception.ApiException;
import com.jeonshijang.api.global.exception.ErrorCode;
import com.jeonshijang.api.infra.kakao.KakaoTokenVerifier;
import com.jeonshijang.api.infra.kakao.dto.KakaoUserInfo;
import com.jeonshijang.api.security.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 역할: 인증(Authentication) 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 */
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final KakaoTokenVerifier kakaoTokenVerifier;
    private final JwtProvider jwtProvider;
    private final BCryptPasswordEncoder passwordEncoder;

    /**
     * 역할: 카카오 액세스 토큰을 이용해 로그인 또는 회원가입을 처리하고, 서비스 자체의 JWT(Access/Refresh Token)를 발급합니다.
     */
    @Transactional
    public TokenResponse kakaoLogin(String kakaoAccessToken) {
        // 핵심: 카카오 서버에 토큰 유효성을 검증하고, 카카오 사용자 정보를 받아옵니다.
        KakaoUserInfo kakaoUser = kakaoTokenVerifier.verify(kakaoAccessToken);

        // 핵심: 카카오 ID로 우리 서비스에 이미 가입된 회원인지 조회합니다.
        User user = userRepository.findByKakaoId(kakaoUser.kakaoId())
                .map(existing -> {
                    // 이미 가입된 경우: 카카오 프로필 정보(닉네임, 이미지)가 변경되었을 수 있으므로 최신 정보로 업데이트합니다.
                    existing.updateProfile(kakaoUser.nickname(), kakaoUser.profileImageUrl());
                    return existing;
                })
                .orElseGet(() -> userRepository.save(
                        User.ofKakao(kakaoUser.kakaoId(), kakaoUser.nickname(), kakaoUser.profileImageUrl())
                ));

        // 핵심: 회원 정보를 기반으로 우리 서비스의 Access Token과 Refresh Token을 생성하여 반환합니다.
        String role = user.getRole().name();
        return TokenResponse.of(
                jwtProvider.generateAccessToken(user.getId(), role),
                jwtProvider.generateRefreshToken(user.getId(), role)
        );
    }

    @Transactional
    public TokenResponse register(RegisterRequest request) {
        if (userRepository.existsByLoginId(request.loginId())) {
            throw new ApiException(ErrorCode.DUPLICATE_LOGIN_ID);
        }
        User user = userRepository.save(
                User.ofLocal(request.loginId(), passwordEncoder.encode(request.password()), request.nickname())
        );
        String role = user.getRole().name();
        return TokenResponse.of(
                jwtProvider.generateAccessToken(user.getId(), role),
                jwtProvider.generateRefreshToken(user.getId(), role)
        );
    }

    public TokenResponse login(LoginRequest request) {
        User user = userRepository.findByLoginId(request.loginId())
                .orElseThrow(() -> new ApiException(ErrorCode.INVALID_CREDENTIALS));
        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new ApiException(ErrorCode.INVALID_CREDENTIALS);
        }
        String role = user.getRole().name();
        return TokenResponse.of(
                jwtProvider.generateAccessToken(user.getId(), role),
                jwtProvider.generateRefreshToken(user.getId(), role)
        );
    }

    /**
     * 역할: 만료된 Access Token을 Refresh Token을 이용해 재발급합니다.
     */
    public TokenResponse refresh(String refreshToken) {
        // 핵심: 전달받은 Refresh Token이 유효한지, 그리고 타입이 'refresh'가 맞는지 검증합니다.
        if (!jwtProvider.validate(refreshToken)) {
            throw new ApiException(ErrorCode.INVALID_TOKEN);
        }
        if (!"refresh".equals(jwtProvider.getTokenType(refreshToken))) {
            throw new ApiException(ErrorCode.INVALID_TOKEN);
        }

        // 핵심: Refresh Token에서 사용자 ID를 추출하여 DB에서 회원 정보를 조회합니다.
        Long userId = jwtProvider.getUserId(refreshToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(ErrorCode.USER_NOT_FOUND));

        // 핵심: 새로운 Access Token과 Refresh Token을 모두 재발급하여 반환합니다. (Refresh Token Rotation)
        String role = user.getRole().name();
        return TokenResponse.of(
                jwtProvider.generateAccessToken(user.getId(), role),
                jwtProvider.generateRefreshToken(user.getId(), role)
        );
    }
}
