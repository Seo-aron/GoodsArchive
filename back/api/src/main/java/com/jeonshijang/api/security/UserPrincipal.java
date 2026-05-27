package com.jeonshijang.api.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public class UserPrincipal implements UserDetails {

    private final Long userId;
    private final Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(Long userId, String role) {
        this.userId = userId;
        this.authorities = List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    public Long getUserId() {
        return userId;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override public String getPassword()  { return null; }
    @Override public String getUsername()  { return String.valueOf(userId); }
}
