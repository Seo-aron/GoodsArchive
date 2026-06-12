package com.jeonshijang.api.infra.kakao;

import com.jeonshijang.api.global.exception.ApiException;
import com.jeonshijang.api.global.exception.ErrorCode;
import com.jeonshijang.api.infra.kakao.dto.KakaoApiResponse;
import com.jeonshijang.api.infra.kakao.dto.KakaoUserInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

/**
 * 역할: 클라이언트로부터 받은 카카오 액세스 토큰의 유효성을 카카오 서버에 직접 확인하고, 사용자 정보를 가져오는 역할을 합니다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class KakaoTokenVerifier {

    private final RestClient kakaoRestClient; // 외부 API(카카오)와 통신하기 위한 RestClient

    /**
     * 역할: 카카오 액세스 토큰을 검증하고, 유효하다면 해당 사용자의 정보를 반환합니다.
     */
    public KakaoUserInfo verify(String kakaoAccessToken) {
        KakaoApiResponse response;
        try {
            // 핵심: RestClient를 사용하여 카카오 API(/v2/user/me)를 호출합니다.
            // HTTP 헤더에 "Authorization: Bearer {카카오 액세스 토큰}"을 담아 보냅니다.
            response = kakaoRestClient.get()
                    .uri("/v2/user/me")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + kakaoAccessToken)
                    .retrieve() // API 호출을 실행하고 응답을 받아옵니다.
                    .body(KakaoApiResponse.class); // 응답 본문을 KakaoApiResponse 객체로 변환합니다.
        } catch (RestClientResponseException e) {
            // 카카오 서버로부터 4xx, 5xx 등의 에러 응답이 온 경우 (예: 유효하지 않은 토큰)
            log.warn("Kakao token verification rejected: status={}", e.getStatusCode());
            throw new ApiException(ErrorCode.INVALID_KAKAO_TOKEN);
        } catch (Exception e) {
            // 네트워크 문제 등 카카오 API 호출 자체에 실패한 경우
            log.error("Kakao API call failed", e);
            throw new ApiException(ErrorCode.KAKAO_API_ERROR);
        }

        // 핵심: API 응답이 비어있거나, 사용자 ID(id)가 없는 비정상적인 경우를 방어합니다.
        if (response == null || response.id() == null) {
            throw new ApiException(ErrorCode.INVALID_KAKAO_TOKEN);
        }

        // 최종적으로 응답받은 데이터를 우리 시스템에서 사용할 KakaoUserInfo 객체로 변환하여 반환합니다.
        return KakaoUserInfo.from(response);
    }
}
