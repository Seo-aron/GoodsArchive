package com.jeonshijang.api.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * 역할: 모든 HTTP 요청이 들어올 때마다 실행되어, 요청 헤더에 포함된 JWT 토큰을 검증하고,
 * 유효한 토큰일 경우 Spring Security 컨텍스트에 인증 정보를 저장하는 필터입니다.
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter { // OncePerRequestFilter를 상속받아 한 번의 요청당 한 번만 실행되도록 보장합니다.

    private final JwtProvider jwtProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 1. 요청 헤더에서 JWT 토큰을 추출합니다.
        String token = resolveToken(request);

        // 2. 토큰이 존재하고, 유효하며, 타입이 'access' 토큰인 경우에만 인증을 진행합니다.
        if (token != null && jwtProvider.validate(token)
                && "access".equals(jwtProvider.getTokenType(token))) {

            // 3. 유효한 토큰에서 사용자 ID와 권한(role) 정보를 꺼냅니다.
            Long userId = jwtProvider.getUserId(token);
            String role  = jwtProvider.getRole(token);

            // 4. 추출한 정보로 Spring Security가 이해할 수 있는 인증 객체(UserPrincipal, UsernamePasswordAuthenticationToken)를 생성합니다.
            UserPrincipal principal = new UserPrincipal(userId, role);
            UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
            auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            // 5. 생성한 인증 객체를 SecurityContextHolder에 저장합니다. 이제 이 요청은 '인증된 사용자'의 요청으로 취급됩니다.
            SecurityContextHolder.getContext().setAuthentication(auth);
        }

        // 6. 다음 필터(혹은 컨트롤러)로 요청을 넘깁니다. 토큰이 없거나 유효하지 않아도 다음으로 넘기며, 권한이 필요한 곳에서는 SecurityConfig의 설정에 따라 접근이 차단됩니다.
        filterChain.doFilter(request, response);
    }

    /**
     * 역할: HTTP 요청 헤더(Authorization)에서 "Bearer {토큰}" 형태의 문자열을 찾아 실제 토큰 부분만 잘라내어 반환합니다.
     */
    private String resolveToken(HttpServletRequest request) {
        String bearer = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(bearer) && bearer.startsWith("Bearer ")) {
            return bearer.substring(7); // "Bearer " 이후의 문자열(실제 토큰)만 반환
        }
        return null;
    }
}
