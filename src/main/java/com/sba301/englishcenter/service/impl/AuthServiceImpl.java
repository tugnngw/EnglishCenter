package com.sba301.englishcenter.service.impl;

import com.sba301.englishcenter.dto.request.LoginRequest;
import com.sba301.englishcenter.dto.request.RefreshTokenRequest;
import com.sba301.englishcenter.dto.request.RegisterRequest;
import com.sba301.englishcenter.dto.response.TokenResponse;
import com.sba301.englishcenter.dto.response.UserResponse;
import com.sba301.englishcenter.repository.RoleRepository;
import com.sba301.englishcenter.repository.UserRepository;
import com.sba301.englishcenter.service.AuthService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuthServiceImpl implements AuthService {

    UserRepository userRepository;
    RoleRepository roleRepository;

    @Override
    public UserResponse register(RegisterRequest request) {
        // TODO: Implement user registration logic
        return null;
    }

    @Override
    public TokenResponse login(LoginRequest request) {
        // TODO: Implement authentication logic
        return null;
    }

    @Override
    public TokenResponse refreshToken(RefreshTokenRequest request) {
        // TODO: Implement refresh token logic
        return null;
    }
}
