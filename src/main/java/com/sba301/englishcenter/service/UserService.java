package com.sba301.englishcenter.service;

import com.sba301.englishcenter.dto.response.UserResponse;

public interface UserService {
    UserResponse getMyProfile();
    UserResponse getUserById(Integer userId);
}
