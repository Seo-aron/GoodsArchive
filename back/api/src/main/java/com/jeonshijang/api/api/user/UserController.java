package com.jeonshijang.api.api.user;

import com.jeonshijang.api.api.user.dto.UserResponse;
import com.jeonshijang.api.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 역할: 클라이언트로부터 들어오는 '회원(User)' 관련 HTTP 요청을 받아 처리하는 컨트롤러입니다.
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * 역할: 현재 로그인한 사용자의 프로필(내 정보)을 조회합니다.
     * 엔드포인트: GET /api/users/me
     */
    @GetMapping("/me")
    public ResponseEntity<UserResponse> getMe(@AuthenticationPrincipal UserPrincipal principal) {
        // 핵심: @AuthenticationPrincipal을 통해 Spring Security 컨텍스트에 저장된 현재 로그인한 사용자의 정보(principal)를 가져와서 ID를 추출합니다.
        return ResponseEntity.ok(userService.getMe(principal.getUserId()));
    }
}
