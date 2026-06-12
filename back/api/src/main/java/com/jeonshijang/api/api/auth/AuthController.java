package com.jeonshijang.api.api.auth;

import com.jeonshijang.api.api.auth.dto.KakaoLoginRequest;
import com.jeonshijang.api.api.auth.dto.RefreshRequest;
import com.jeonshijang.api.api.auth.dto.TokenResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 역할: 클라이언트(프론트엔드/앱)로부터 들어오는 '인증(회원가입/로그인)' 관련 HTTP 요청을 받아 처리하는 컨트롤러입니다.
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * 역할: 클라이언트가 카카오 로그인을 통해 얻은 액세스 토큰을 서버로 보내면, 우리 서비스용 JWT 토큰을 발급하여 응답합니다.
     * 엔드포인트: POST /api/auth/kakao
     * 요청 본문(Body): { "accessToken": "카카오에서 발급받은 액세스 토큰 문자열" }
     */
    @PostMapping("/kakao")
    public ResponseEntity<TokenResponse> kakaoLogin(@Valid @RequestBody KakaoLoginRequest request) {
        // 핵심: AuthService에 실제 로그인 비즈니스 로직 처리를 위임하고 그 결과(JWT 토큰들)를 반환합니다.
        return ResponseEntity.ok(authService.kakaoLogin(request.accessToken()));
    }

    /**
     * 역할: 클라이언트의 액세스 토큰(Access Token)이 만료되었을 때, 리프레시 토큰(Refresh Token)을 사용해 새로운 토큰 세트를 재발급받습니다.
     * 엔드포인트: POST /api/auth/refresh
     * 요청 본문(Body): { "refreshToken": "기존에 발급받았던 리프레시 토큰 문자열" }
     */
    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        // 핵심: AuthService에 토큰 재발급 로직을 위임하고 새 토큰들을 반환합니다.
        return ResponseEntity.ok(authService.refresh(request.refreshToken()));
    }
}
