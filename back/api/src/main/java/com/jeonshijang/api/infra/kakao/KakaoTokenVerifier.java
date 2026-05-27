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

@Slf4j
@Component
@RequiredArgsConstructor
public class KakaoTokenVerifier {

    private final RestClient kakaoRestClient;

    public KakaoUserInfo verify(String kakaoAccessToken) {
        KakaoApiResponse response;
        try {
            response = kakaoRestClient.get()
                    .uri("/v2/user/me")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + kakaoAccessToken)
                    .retrieve()
                    .body(KakaoApiResponse.class);
        } catch (RestClientResponseException e) {
            log.warn("Kakao token verification rejected: status={}", e.getStatusCode());
            throw new ApiException(ErrorCode.INVALID_KAKAO_TOKEN);
        } catch (Exception e) {
            log.error("Kakao API call failed", e);
            throw new ApiException(ErrorCode.KAKAO_API_ERROR);
        }

        if (response == null || response.id() == null) {
            throw new ApiException(ErrorCode.INVALID_KAKAO_TOKEN);
        }

        return KakaoUserInfo.from(response);
    }
}
