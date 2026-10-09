package com.sba301.englishcenter.controller;

import com.sba301.englishcenter.common.response.ApiResponse;
import com.sba301.englishcenter.dto.request.LoginRequest;
import com.sba301.englishcenter.dto.request.RefreshTokenRequest;
import com.sba301.englishcenter.dto.request.RegisterRequest;
import com.sba301.englishcenter.dto.response.TokenResponse;
import com.sba301.englishcenter.dto.response.UserResponse;
import com.sba301.englishcenter.service.AuthService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuthController {

    AuthService authService;

    @PostMapping("/register")
    public ApiResponse<UserResponse> register(@RequestBody RegisterRequest request) {
        return ApiResponse.<UserResponse>builder()
                .result(authService.register(request))
                .build();
    }

    @PostMapping("/login")
    public ApiResponse<TokenResponse> login(@RequestBody LoginRequest request) {
        return ApiResponse.<TokenResponse>builder()
                .result(authService.login(request))
                .build();
    }

    @PostMapping("/refresh")
    public ApiResponse<TokenResponse> refreshToken(@RequestBody RefreshTokenRequest request) {
        return ApiResponse.<TokenResponse>builder()
                .result(authService.refreshToken(request))
                .build();
    }
}
