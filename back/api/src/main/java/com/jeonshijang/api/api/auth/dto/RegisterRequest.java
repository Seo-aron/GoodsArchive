package com.jeonshijang.api.api.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank @Size(min = 4, max = 20) String loginId,
        @NotBlank @Size(min = 6, max = 30) String password,
        @NotBlank @Size(max = 20) String nickname
) {}
