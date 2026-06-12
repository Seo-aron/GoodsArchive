package com.jeonshijang.api.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * 역할: Spring Security의 인증 컨텍스트(SecurityContext)에 저장될 사용자 정보를 나타내는 클래스입니다.
 * UserDetails 인터페이스를 구현하여 Spring Security가 필요로 하는 사용자 정보(권한, ID 등)를 제공합니다.
 */
public class UserPrincipal implements UserDetails {

    private final Long userId; // 우리 시스템의 사용자 ID
    private final Collection<? extends GrantedAuthority> authorities; // 사용자의 권한 목록

    public UserPrincipal(Long userId, String role) {
        this.userId = userId;
        // 핵심: Spring Security는 권한 앞에 'ROLE_' 접두사가 붙는 것을 기본으로 합니다. (e.g., "ROLE_USER", "ROLE_ADMIN")
        this.authorities = List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    public Long getUserId() {
        return userId;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    // 아래 메서드들은 UserDetails 인터페이스의 일부이지만, JWT 기반 인증에서는 직접 사용되지 않는 경우가 많습니다.
    @Override public String getPassword()  { return null; } // JWT에서는 비밀번호를 사용하지 않으므로 null 반환
    @Override public String getUsername()  { return String.valueOf(userId); } // Spring Security의 'username'을 우리 시스템의 'userId'로 사용
}
