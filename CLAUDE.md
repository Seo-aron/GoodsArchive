# 전시장(Jeonshijang) 프로젝트 인수인계

> 디지털 굿즈/피규어를 등록하고 2D 가상 장식장에 배치하는 앱

---

## 1. 프로젝트 구조

```
jeonshijang_app/           ← VS Code 워크스페이스 루트 (현재 디렉토리)
├── CLAUDE.md              ← 이 파일
├── front/                 ← Flutter 프론트엔드
│   ├── pubspec.yaml
│   ├── android/app/src/main/AndroidManifest.xml
│   └── lib/
│       ├── main.dart              ← 앱 진입점, Kakao SDK 초기화, 라우팅
│       ├── screens/
│       │   └── login_screen.dart  ← 카카오 로그인 UI
│       └── services/
│           └── auth_service.dart  ← 백엔드 인증 API 호출
└── back/
    └── api/               ← Spring Boot 백엔드
        ├── build.gradle
        ├── gradlew / gradlew.bat
        └── src/main/java/com/jeonshijang/api/
            ├── ApiApplication.java
            ├── api/auth/          ← 인증 API 계층
            ├── config/            ← RestClient 등 설정
            ├── domain/            ← JPA Entity + Repository
            ├── global/            ← 예외처리, 공통 응답
            ├── infra/kakao/       ← 카카오 API 연동
            └── security/          ← JWT, Spring Security
```

---

## 2. 기술 스택

| 영역 | 스택 |
|---|---|
| **백엔드** | Java 17, Spring Boot 3.3.5, Gradle 8.8 |
| **보안** | Spring Security 6, JJWT 0.12.6 |
| **ORM** | Spring Data JPA, Hibernate 6, QueryDSL 5.1 |
| **DB** | H2 (인메모리, 개발용) → 추후 MySQL 전환 예정 |
| **스토리지** | AWS SDK v2 (S3) — 미구현 |
| **HTTP 클라이언트** | Spring 6 RestClient (카카오 API 호출용) |
| **프론트엔드** | Flutter (Dart), `kakao_flutter_sdk_user: ^1.9.7`, `http: ^1.2.2` |

### 백엔드 실행 방법

```powershell
cd back/api
$env:JAVA_HOME="C:\Program Files\Java\jdk-17"; .\gradlew.bat bootRun
```

- 서버 포트: `8080`
- H2 콘솔: `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:mem:jeonshijangdb`)

### 프론트엔드 실행 방법

```powershell
cd front
flutter pub get   # 최초 1회 또는 pubspec.yaml 변경 시
flutter run
```

- 에뮬레이터 → 백엔드 주소: `http://10.0.2.2:8080` (기본값, `auth_service.dart` 참고)
- 실기기 → 백엔드 주소: PC의 로컬 IP로 변경 필요 (예: `http://192.168.x.x:8080`)

---

## 3. 완료된 작업

### ✅ Step 1 — Spring Boot 프로젝트 초기 세팅

- `back/api/build.gradle` : JJWT, AWS SDK v2, QueryDSL, Lombok 등 전체 의존성 구성
- `back/api/src/main/resources/application.yml` : H2, JWT, S3 설정 (환경변수 fallback 포함)
- `gradle/wrapper/` : Gradle 8.8 Wrapper 구성 완료

### ✅ Step 2 — JPA Entity 설계 (4개 테이블)

파일 위치: `back/api/src/main/java/com/jeonshijang/api/domain/`

| Entity | 테이블 | 핵심 사항 |
|---|---|---|
| `User` | `users` | `kakaoId` UNIQUE, `role` Enum |
| `Goods` | `goods` | `@SQLRestriction("deleted_at IS NULL")` 소프트 딜리트 |
| `Showcase` | `showcase` | User와 N:1, ShowcaseItem과 1:N (`CascadeType.ALL`, `orphanRemoval=true`) |
| `ShowcaseItem` | `showcase_item` | 굿즈별 `positionX`, `positionY`, `scale` 저장 |

**굿즈 삭제 정책**: 하드 딜리트 대신 소프트 딜리트 채택.
`Goods.softDelete()` 호출 시 `deletedAt` 세팅. `@SQLRestriction`이 모든 조회 쿼리에 자동 적용됨.

### ✅ Step 3 — 카카오 소셜 로그인 (백엔드 + 프론트엔드)

**플로우 요약**:
```
Flutter (kakao_flutter_sdk_user로 카카오 토큰 발급)
  → POST /api/auth/kakao  { "accessToken": "카카오토큰" }
  → KakaoTokenVerifier  (GET https://kapi.kakao.com/v2/user/me)
  → DB upsert (신규: INSERT, 기존: 닉네임/프로필 UPDATE)
  → JwtProvider → accessToken(30분) + refreshToken(14일) 발급
  → { accessToken, refreshToken, tokenType: "Bearer" } 응답
  → Flutter: /home 라우트로 이동
```

**백엔드 구현된 엔드포인트**:
- `POST /api/auth/kakao` — 카카오 토큰 → 서비스 JWT 발급
- `POST /api/auth/refresh` — 리프레시 토큰 → 액세스 토큰 재발급

**JWT 설계 포인트**:
- claim: `sub`(userId), `role`, `type`("access"|"refresh")
- `JwtAuthenticationFilter`: 매 요청 DB 조회 없이 JWT claim만으로 인증 처리
- refresh 토큰으로 일반 API 호출 시 필터에서 차단 (`type` claim 검사)

**백엔드 주요 파일**:
```
security/
  JwtProvider.java           — 토큰 생성/검증 (JJWT 0.12.x API 사용)
  JwtAuthenticationFilter.java
  SecurityConfig.java        — CSRF 비활성, Stateless, H2콘솔 허용
  UserPrincipal.java         — UserDetails 구현체 (userId, role 보유)
infra/kakao/
  KakaoTokenVerifier.java    — RestClient로 카카오 프로필 API 호출
  dto/KakaoApiResponse.java  — 카카오 응답 매핑 (kakao_account.profile)
  dto/KakaoUserInfo.java
api/auth/
  AuthController.java
  AuthService.java
  dto/KakaoLoginRequest.java / RefreshRequest.java / TokenResponse.java
global/
  exception/ErrorCode.java   — HTTP 상태 + 메시지 enum
  exception/ApiException.java
  exception/GlobalExceptionHandler.java
  response/ApiErrorResponse.java
```

**프론트엔드 주요 파일**:
```
front/lib/
  main.dart                  — KakaoSdk.init(), /login · /home 라우팅
  screens/login_screen.dart  — 카카오 로그인 버튼 UI (카카오앱 설치 여부 분기)
  services/auth_service.dart — POST /api/auth/kakao 호출, TokenResponse 파싱
front/android/app/src/main/AndroidManifest.xml
                             — INTERNET 권한, com.kakao.sdk.AppKey 메타데이터,
                               AuthCodeHandlerActivity (웹 로그인 딥링크)
```

**⚠️ 카카오 네이티브 앱 키 세팅 필요** (발급 후 아래 2곳 교체):
1. `front/android/app/src/main/AndroidManifest.xml`
   - `android:value="YOUR_KAKAO_NATIVE_APP_KEY"`
   - `android:scheme="kakaoYOUR_KAKAO_NATIVE_APP_KEY"`
2. `front/lib/main.dart`
   - `KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY')`

**현재 Refresh Token 상태**: DB 미저장(stateless). 보안 강화가 필요하면
`User` 엔티티에 `refreshToken` 컬럼 추가 또는 Redis 도입 필요.

---

## 4. 남은 작업 (MVP 기준)

### 🔲 Step 4 — 굿즈 등록/조회 API (백엔드)

**목표**: Multipart 이미지 수신 → 외부 누끼 AI API → S3 업로드 → DB 저장

구현할 엔드포인트:
- `POST /api/goods` — 굿즈 등록 (Multipart: 이미지 + JSON 메타데이터)
- `GET  /api/goods` — 내 굿즈 목록 조회
- `GET  /api/goods/{goodsId}` — 굿즈 단건 조회
- `DELETE /api/goods/{goodsId}` — 굿즈 소프트 딜리트

구현 포인트:
1. `@RequestPart`로 이미지(`MultipartFile`)와 메타데이터 DTO 분리 수신
2. 외부 누끼 API 호출 (`RestClient` 또는 `WebClient`) — API 벤더 미확정
3. 누끼 처리 결과 PNG에 Bounding Box Crop 적용 (Java `ImageIO` 또는 외부 라이브러리)
4. AWS SDK v2로 S3 업로드 (`S3Client.putObject`)
5. S3 URL + 메타데이터 DB 저장

추가로 필요한 클래스:
```
api/goods/GoodsController.java
api/goods/GoodsService.java
api/goods/dto/GoodsRegisterRequest.java
api/goods/dto/GoodsResponse.java
infra/s3/S3Uploader.java
infra/rembg/RembgClient.java   (누끼 API 클라이언트 — 벤더 확정 후 명명)
```

환경변수 세팅 필요:
```
AWS_ACCESS_KEY=...
AWS_SECRET_KEY=...
AWS_S3_BUCKET=...
```

---

### 🔲 Step 5 — 장식장 저장/조회 API (백엔드)

**목표**: FE가 계산한 굿즈 배치 좌표/스케일을 Showcase + ShowcaseItem으로 저장

구현할 엔드포인트:
- `POST /api/showcases` — 장식장 생성
- `PUT  /api/showcases/{showcaseId}/items` — 배치 저장 (기존 아이템 전체 교체)
- `GET  /api/showcases/{showcaseId}` — 장식장 + 배치 아이템 조회

FE 전송 형식 (예시):
```json
{
  "items": [
    { "goodsId": 1, "positionX": 0.25, "positionY": 0.40, "scale": 1.2 },
    { "goodsId": 3, "positionX": 0.60, "positionY": 0.15, "scale": 0.8 }
  ]
}
```

구현 포인트:
- `Showcase.replaceItems()` 호출 시 `orphanRemoval`이 기존 아이템 자동 삭제
- 조회 시 `ShowcaseItem` N+1 문제 주의 → `@EntityGraph` 또는 fetch join 사용

---

### 🔲 Step 6 — Flutter UI 본격 구현

현재 `main.dart`의 `MainShowcaseScreen`은 임시 더미 데이터 기반. Step 4·5 백엔드 완료 후:
- 굿즈 등록 화면 (`screens/goods_register_screen.dart`)
- 굿즈 목록 → 장식장 배치 인터랙션
- JWT 토큰 저장 (`flutter_secure_storage` 등) 및 자동 로그인 처리

---

### 🔲 Step 7 — 인프라 / 배포 준비

- H2 → MySQL 전환 (`application-prod.yml` 프로파일 분리)
- Docker + docker-compose 설정
- GitHub Actions CI/CD 파이프라인

---

## 5. 환경변수 목록

| 변수명 | 설명 | 기본값(로컬) |
|---|---|---|
| `JWT_SECRET` | HMAC-SHA256 서명키 (32바이트 이상) | 긴 하드코딩 문자열 |
| `AWS_ACCESS_KEY` | S3 접근 키 | 빈 문자열 |
| `AWS_SECRET_KEY` | S3 시크릿 키 | 빈 문자열 |
| `AWS_S3_BUCKET` | S3 버킷명 | `local-bucket` |

---

## 6. 개발 시 유의사항

- **QueryDSL Q클래스 생성**: `./gradlew compileJava` 실행 필요. 생성 경로: `build/generated/querydsl/`
- **소프트 딜리트**: `@SQLRestriction`이 Goods 조회에 자동 적용되므로 삭제된 굿즈 조회가 필요한 경우 네이티브 쿼리 또는 `@Filter` 전환 필요
- **인증 필요 API**: `Authorization: Bearer {accessToken}` 헤더 필수. 미포함 시 401 반환
- **Spring Security OAuth2 자동설정**: `application.yml`의 `autoconfigure.exclude`로 비활성화됨. FE가 Kakao SDK로 토큰을 직접 발급하는 방식이므로 Spring의 redirect 기반 OAuth2 플로우 불필요
- **카카오 앱 키 플레이스홀더**: `YOUR_KAKAO_NATIVE_APP_KEY` 문자열로 검색하면 교체 필요한 위치 2곳을 바로 찾을 수 있음
