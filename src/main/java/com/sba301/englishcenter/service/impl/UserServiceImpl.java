package com.sba301.englishcenter.service.impl;

import com.sba301.englishcenter.dto.response.UserResponse;
import com.sba301.englishcenter.repository.UserRepository;
import com.sba301.englishcenter.service.UserService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class UserServiceImpl implements UserService {

    UserRepository userRepository;

    @Override
    public UserResponse getMyProfile() {
        // TODO: Implement get current logged-in user profile
        return null;
    }

    @Override
    public UserResponse getUserById(Integer userId) {
        // TODO: Implement get user by id
        return null;
    }
}
