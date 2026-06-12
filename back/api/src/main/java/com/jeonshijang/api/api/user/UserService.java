package com.jeonshijang.api.api.user;

import com.jeonshijang.api.api.user.dto.UserResponse;
import com.jeonshijang.api.domain.user.UserRepository;
import com.jeonshijang.api.global.exception.ApiException;
import com.jeonshijang.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 역할: 회원(User) 관련 비즈니스 로직을 처리하는 서비스 클래스입니다.
 */
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    /**
     * 역할: 현재 로그인한 사용자(ID 기반)의 상세 정보를 조회합니다.
     */
    public UserResponse getMe(Long userId) {
        // 핵심: 전달받은 userId로 DB에서 사용자를 찾아 응답용 DTO로 변환하여 반환합니다.
        return userRepository.findById(userId)
                .map(UserResponse::from)
                // 핵심: 만약 해당 ID의 사용자가 존재하지 않으면, 'USER_NOT_FOUND' 예외를 발생시킵니다.
                .orElseThrow(() -> new ApiException(ErrorCode.USER_NOT_FOUND));
    }
}
