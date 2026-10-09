package com.sba301.englishcenter.service;

import com.sba301.englishcenter.dto.request.LoginRequest;
import com.sba301.englishcenter.dto.request.RefreshTokenRequest;
import com.sba301.englishcenter.dto.request.RegisterRequest;
import com.sba301.englishcenter.dto.response.TokenResponse;
import com.sba301.englishcenter.dto.response.UserResponse;

public interface AuthService {
    UserResponse register(RegisterRequest request);
    TokenResponse login(LoginRequest request);
    TokenResponse refreshToken(RefreshTokenRequest request);
}
