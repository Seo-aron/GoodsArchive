package com.jeonshijang.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.http.HttpHeaders;
import org.springframework.web.client.RestClient;

/**
 * 역할: 외부 서버(API)와 통신하기 위한 RestClient 객체를 설정하고 스프링 빈으로 등록하는 클래스입니다.
 */
@Configuration
public class RestClientConfig {

    /**
     * 역할: 카카오 API 서버와 통신하기 위해 미리 기본 설정(Base URL, 헤더 등)을 마친 RestClient 객체를 생성합니다.
     */
    @Bean
    public RestClient kakaoRestClient(RestClient.Builder builder) {
        return builder
                .baseUrl("https://kapi.kakao.com") // 핵심: 모든 요청의 기본 URL을 카카오 API 서버 주소로 설정합니다.
                .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE) // 기본 응답 포맷을 JSON으로 설정합니다.
                .build();
    }
}