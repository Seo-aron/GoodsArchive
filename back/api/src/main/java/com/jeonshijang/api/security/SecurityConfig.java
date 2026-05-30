package com.jeonshijang.api.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import jakarta.servlet.http.HttpServletResponse;

/**
 * 역할: Spring Security 관련 설정을 총괄하는 클래스입니다.
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                // [1] REST API이므로 기본 설정들을 비활성화합니다.
                .csrf(AbstractHttpConfigurer::disable) // CSRF 보호 비활성화 (JWT 사용 시 불필요)
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 세션을 사용하지 않음 (상태 비저장)

                // [2] 개발 편의를 위한 H2 콘솔 접근 허용 설정입니다.
                .headers(h -> h.frameOptions(HeadersConfigurer.FrameOptionsConfig::sameOrigin))

                // [3] URL별로 접근 권한을 설정합니다.
                .authorizeHttpRequests(auth -> auth
                        // 아래 URL들은 인증 없이 누구나 접근 가능합니다.
                        .requestMatchers("/api/auth/**").permitAll() // 로그인/회원가입 API
                        .requestMatchers("/h2-console/**").permitAll() // H2 콘솔 (개발용)
                        .requestMatchers(HttpMethod.GET, "/actuator/health").permitAll() // 서버 상태 체크 API
                        .requestMatchers(HttpMethod.GET, "/api/goods", "/api/goods/summary").permitAll() // 상품 목록 및 요약 조회 API
                        // 그 외의 모든 요청은 반드시 인증(로그인)이 필요합니다.
                        .anyRequest().authenticated()
                )

                // [4] 우리가 직접 만든 JWT 인증 필터를 Spring Security 필터 체인에 추가합니다.
                // UsernamePasswordAuthenticationFilter 앞에 추가하여 먼저 JWT를 검증하도록 합니다.
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)

                // [5] 인증/인가 과정에서 발생하는 예외를 처리합니다.
                .exceptionHandling(ex -> ex
                        // 인증되지 않은 사용자가 보호된 리소스에 접근했을 때의 처리
                        .authenticationEntryPoint((req, res, e) -> {
                            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                            res.getWriter().write("{\"code\":\"UNAUTHORIZED\",\"message\":\"인증이 필요합니다.\"}");
                        })
                        // 인증은 되었지만, 해당 리소스에 접근할 권한이 없을 때의 처리
                        .accessDeniedHandler((req, res, e) -> {
                            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                            res.getWriter().write("{\"code\":\"FORBIDDEN\",\"message\":\"접근 권한이 없습니다.\"}");
                        })
                )
                .build();
    }
}
