package com.jeonshijang.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * 역할: JWT(JSON Web Token)의 생성, 검증, 정보 추출 등 토큰 관련 모든 로직을 처리하는 클래스입니다.
 */
@Slf4j
@Component
public class JwtProvider {

    private final SecretKey key; // JWT 서명에 사용할 비밀키 (HMAC-SHA 알고리즘 기반)
    private final long accessTokenExpiryMs; // 액세스 토큰의 유효 기간 (밀리초)
    private final long refreshTokenExpiryMs; // 리프레시 토큰의 유효 기간 (밀리초)

    public JwtProvider(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.access-token-expiry-ms}") long accessTokenExpiryMs,
            @Value("${jwt.refresh-token-expiry-ms}") long refreshTokenExpiryMs) {

        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        // 핵심: JWT 서명에 사용되는 비밀키는 보안상 일정 길이(256비트 = 32바이트) 이상이어야 합니다.
        if (keyBytes.length < 32) {
            throw new IllegalArgumentException("jwt.secret must be at least 32 bytes (256 bits)");
        }
        this.key = Keys.hmacShaKeyFor(keyBytes); // 문자열 비밀키를 기반으로 SecretKey 객체를 생성합니다.
        this.accessTokenExpiryMs = accessTokenExpiryMs;
        this.refreshTokenExpiryMs = refreshTokenExpiryMs;
    }

    /**
     * 역할: 사용자를 위한 Access Token을 생성합니다.
     */
    public String generateAccessToken(Long userId, String role) {
        return buildToken(userId, role, "access", accessTokenExpiryMs);
    }

    /**
     * 역할: Access Token 재발급을 위한 Refresh Token을 생성합니다.
     */
    public String generateRefreshToken(Long userId, String role) {
        return buildToken(userId, role, "refresh", refreshTokenExpiryMs);
    }

    /**
     * 역할: 주어진 토큰의 유효성을 검증합니다. (서명 확인, 만료 시간 확인 등)
     */
    public boolean validate(String token) {
        try {
            parseClaims(token); // 핵심: 토큰 파싱 과정에서 예외가 발생하지 않으면 유효한 토큰으로 간주합니다.
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.debug("Invalid JWT token: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 역할: 토큰에서 사용자 ID(subject)를 추출합니다.
     */
    public Long getUserId(String token) {
        return Long.parseLong(parseClaims(token).getSubject());
    }

    /**
     * 역할: 토큰에서 사용자 권한(role) 정보를 추출합니다.
     */
    public String getRole(String token) {
        return parseClaims(token).get("role", String.class);
    }

    /**
     * 역할: 토큰의 종류(type) 정보(access/refresh)를 추출합니다.
     */
    public String getTokenType(String token) {
        return parseClaims(token).get("type", String.class);
    }

    /**
     * 역할: JWT 토큰을 생성하는 내부 헬퍼 메서드입니다.
     */
    private String buildToken(Long userId, String role, String type, long expiryMs) {
        Date now = new Date();
        return Jwts.builder()
                .subject(String.valueOf(userId)) // 토큰의 주체(주로 사용자 ID)
                .claim("role", role)           // 비공개 클레임: 사용자 권한
                .claim("type", type)           // 비공개 클레임: 토큰 종류
                .issuedAt(now)                   // 토큰 발급 시간
                .expiration(new Date(now.getTime() + expiryMs)) // 토큰 만료 시간
                .signWith(key)                   // 서명에 사용할 비밀키
                .compact();                      // 최종적으로 문자열 형태의 토큰을 생성
    }

    /**
     * 역할: 토큰을 파싱하여 포함된 클레임(Claims) 정보를 반환합니다.
     */
    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key) // 제공된 비밀키로 서명을 검증합니다.
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
