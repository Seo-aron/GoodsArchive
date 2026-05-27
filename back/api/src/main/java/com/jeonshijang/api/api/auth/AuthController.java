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

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Flutter Kakao SDK로 발급받은 AccessToken을 전달받아 서비스 자체 JWT를 발급한다.
     * POST /api/auth/kakao
     * Body: { "accessToken": "kakao_access_token_value" }
     */
    @PostMapping("/kakao")
    public ResponseEntity<TokenResponse> kakaoLogin(@Valid @RequestBody KakaoLoginRequest request) {
        return ResponseEntity.ok(authService.kakaoLogin(request.accessToken()));
    }

    /**
     * 액세스 토큰 만료 시 리프레시 토큰으로 재발급한다.
     * POST /api/auth/refresh
     * Body: { "refreshToken": "..." }
     */
    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return ResponseEntity.ok(authService.refresh(request.refreshToken()));
    }
}
