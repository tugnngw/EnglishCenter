package com.sba301.englishcenter.mapper;

import com.sba301.englishcenter.dto.request.RegisterRequest;
import com.sba301.englishcenter.dto.response.UserResponse;
import com.sba301.englishcenter.entity.User;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class UserMapper {

    public User toUser(RegisterRequest request) {
        if (request == null) return null;
        return User.builder()
                .email(request.getEmail())
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .build();
    }

    public UserResponse toUserResponse(User user) {
        if (user == null) return null;
        return UserResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .roles(user.getRoles() == null ? null :
                        user.getRoles().stream()
                                .map(r -> r.getRoleName())
                                .collect(Collectors.toSet()))
                .build();
    }
}
