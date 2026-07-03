# {프로젝트명}

> 덕질 라이프를 기록하는 굿즈 아카이빙 서비스의 백엔드 시스템

[사진첨부 — 앱 대표 스크린샷 또는 배너]

---

## Overview

{프로젝트명}은 사용자가 구매한 다양한 굿즈(덕질 용품) 정보를 등록·관리하고, 나만의 가상 전시장에 배치하여 컬렉션을 시각적으로 아카이빙할 수 있는 모바일 애플리케이션의 백엔드 시스템입니다.

단순한 목록 관리를 넘어, 소비 패턴 분석과 컬렉션 큐레이션 기능을 통해 사용자가 자신의 덕질 라이프를 체계적으로 기록할 수 있도록 설계되었습니다.

---

## Tech Stack

| 분류 | 기술 |
|---|---|
| **Language** | Java 17 |
| **Framework** | Spring Boot 3.3.5 |
| **ORM** | Spring Data JPA, Hibernate 6, QueryDSL 5.1 |
| **Security** | Spring Security 6, JWT (JJWT 0.12.6) |
| **Database** | H2 (개발) / MySQL (프로덕션) |
| **Storage** | 로컬 파일 시스템 (개발) / AWS S3 (프로덕션) |
| **Build** | Gradle 8.8 |
| **Social Login** | Kakao OAuth 2.0 |

---

## Architecture & Project Structure

[사진첨부 — 시스템 아키텍처 다이어그램]

```text
{프로젝트}/
├── src/main/java/com/{프로젝트}/
│   ├── api/
│   │   ├── auth/           # 인증 (카카오 로그인, JWT 발급)
│   │   ├── goods/          # 굿즈 CRUD API
│   │   ├── showcase/       # 전시장 저장·조회 API
│   │   └── user/           # 사용자 프로필 API
│   ├── domain/             # JPA Entity, Repository
│   ├── security/           # JWT Filter, Spring Security 설정
│   ├── config/             # Web 설정, 정적 리소스 서빙
│   ├── global/             # 공통 응답 형식, 예외 처리
│   └── infra/              # 외부 서비스 연동 (Kakao API 등)
└── src/main/resources/
    └── application.yml
```

---

## Key Features

### 1. Collection — 굿즈 컬렉션 관리

사용자가 구매한 굿즈의 상세 정보를 등록·조회·수정·삭제할 수 있습니다.

- 굿즈명, 구매가격, 구매일, 메모, 대표 이미지 등록
- 이미지 업로드: Multipart 요청으로 수신 후 UUID 기반 파일명으로 저장 (AWS S3 전환 용이하도록 저장 로직 분리)
- 소프트 딜리트(`deleted_at`) 방식으로 데이터 무결성 보존
- `@SQLRestriction`을 통해 삭제된 데이터는 모든 조회 쿼리에서 자동 제외

### 2. Showroom — 가상 전시장

등록된 굿즈를 나만의 2D 가상 공간에 자유롭게 배치하고 저장합니다.

- 굿즈별 배치 좌표(`positionX`, `positionY`)와 크기(`scale`)를 0.0~1.0 상대값으로 저장, 화면 크기에 독립적으로 동작
- 전시장 아이템 전체 교체 방식(`CascadeType.ALL` + `orphanRemoval`)으로 배치 저장 처리
- `@EntityGraph`를 통한 N+1 쿼리 방지
- 전시장 최초 접근 시 자동 생성 (유저당 1개 보장)

### 3. Analytics — 수집 통계

사용자의 컬렉션 데이터를 집계하여 소비 패턴을 파악할 수 있는 통계 API를 제공합니다.

- 총 굿즈 수, 총 자산 가치 집계
- (예정) 월별·카테고리별 소비 금액 통계
- (예정) 선호 장르·캐릭터 분석

통계 쿼리는 QueryDSL 기반으로 구성되어 조건 변경에 유연하게 대응하며, 대용량 데이터 환경에서는 필요 컬럼에 대한 인덱스 추가 및 집계 테이블 분리를 통해 응답 성능을 확보할 수 있도록 설계 방향을 정의하였습니다.

---

## API Endpoints

> 인증이 필요한 API는 모두 `Authorization: Bearer {accessToken}` 헤더를 포함해야 합니다.

### Auth

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/kakao` | 카카오 액세스 토큰으로 JWT 발급 |
| `POST` | `/api/auth/refresh` | Refresh Token으로 토큰 재발급 |

### Goods

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/goods` | 내 굿즈 목록 조회 |
| `POST` | `/api/goods` | 굿즈 등록 (Multipart) |
| `PUT` | `/api/goods/{id}` | 굿즈 정보 수정 |
| `DELETE` | `/api/goods/{id}` | 굿즈 삭제 (소프트 딜리트) |
| `GET` | `/api/goods/summary` | 수집 통계 조회 |

### Showcase

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/showcases/mine` | 내 전시장 조회 |
| `PUT` | `/api/showcases/{id}/items` | 굿즈 배치 저장 |

### User

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users/me` | 내 프로필 조회 |

---

## Getting Started

### 요구 사항

- Java 17
- Gradle 8.8+

### 실행

```bash
cd back/api
./gradlew bootRun
```

| 항목 | 값 |
|---|---|
| 서버 포트 | `8080` |
| H2 콘솔 | `http://localhost:8080/h2-console` |
| JDBC URL | `jdbc:h2:file:./data/jeonshijangdb` |

### 환경변수

| 변수명 | 설명 |
|---|---|
| `JWT_SECRET` | HMAC-SHA256 서명키 (32바이트 이상) |
| `AWS_ACCESS_KEY` | S3 액세스 키 |
| `AWS_SECRET_KEY` | S3 시크릿 키 |
| `AWS_S3_BUCKET` | S3 버킷명 |

---

## Screenshots

[사진첨부 — 컬렉션 화면]

[사진첨부 — 전시장 화면]

[사진첨부 — 기록/통계 화면]

---

## Version

`v0.1.0` — 핵심 기능 구현 완료, 내부 테스트 단계
