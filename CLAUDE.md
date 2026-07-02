# 전시장(Jeonshijang) 프로젝트 인수인계

> 디지털 굿즈/피규어를 등록하고 2D 가상 장식장에 배치하는 앱

---

## 1. 프로젝트 구조

```text
jeonshijang_app/
├── CLAUDE.md
├── front/                          ← Flutter 프론트엔드
│   ├── pubspec.yaml
│   ├── android/app/src/main/AndroidManifest.xml
│   └── lib/
│       ├── main.dart               ← Kakao SDK 초기화, 라우팅 (/login, /home)
│       ├── models/
│       │   ├── goods_item.dart     ← GoodsItem 모델 (imageUrl 상대경로 자동 절대변환)
│       │   ├── goods_summary.dart  ← GoodsSummary 모델
│       │   ├── showcase_data.dart  ← ShowcaseData, ShowcasePlacedItem 모델
│       │   └── user_info.dart      ← UserInfo 모델
│       ├── screens/
│       │   ├── login_screen.dart
│       │   ├── collection_screen.dart   ← 굿즈 목록, 등록(+버튼), 카드탭→상세
│       │   ├── goods_detail_screen.dart ← 굿즈 상세 + 수정/삭제
│       │   ├── showcase_screen.dart     ← 2D 드래그 배치 + 저장
│       │   ├── record_screen.dart       ← 수집 통계 대시보드
│       │   └── my_info_screen.dart      ← 프로필 + 로그아웃
│       └── services/
│           ├── api_client.dart     ← 공통 HTTP 클라이언트 (JWT 헤더 자동 주입)
│           ├── token_storage.dart  ← 인메모리 JWT 토큰 관리
│           ├── auth_service.dart   ← 카카오 로그인, 로그아웃
│           ├── goods_service.dart  ← 굿즈 CRUD + 이미지 멀티파트 업로드
│           ├── summary_service.dart
│           ├── showcase_service.dart
│           └── user_service.dart
└── back/
    └── api/                        ← Spring Boot 백엔드
        ├── build.gradle
        ├── gradlew / gradlew.bat
        └── src/main/java/com/jeonshijang/api/
            ├── ApiApplication.java
            ├── api/
            │   ├── auth/           ← 인증 (카카오 로그인, JWT 발급)
            │   ├── goods/          ← 굿즈 CRUD API
            │   ├── showcase/       ← 전시장 저장/조회 API
            │   └── user/           ← 사용자 프로필 API
            ├── config/
            │   └── WebMvcConfig.java  ← /uploads/** 정적 파일 서빙
            ├── domain/             ← JPA Entity + Repository
            ├── global/             ← 예외처리, 공통 응답
            ├── infra/kakao/        ← 카카오 API 연동
            └── security/           ← JWT, Spring Security
```

---

## 2. 기술 스택

| 영역 | 스택 |
| --- | --- |
| **백엔드** | Java 17, Spring Boot 3.3.5, Gradle 8.8 |
| **보안** | Spring Security 6, JJWT 0.12.6 |
| **ORM** | Spring Data JPA, Hibernate 6, QueryDSL 5.1 |
| **DB** | H2 (파일모드, 개발용) → 추후 MySQL 전환 예정 |
| **스토리지** | 로컬 `./uploads/` 디렉토리 (프로토타입) → 추후 AWS S3 전환 예정 |
| **HTTP 클라이언트** | Spring 6 RestClient (카카오 API 호출용) |
| **프론트엔드** | Flutter (Dart), `kakao_flutter_sdk_user: ^1.9.7`, `http: ^1.2.2`, `image_picker: ^1.1.2` |

### 백엔드 실행 방법

```powershell
cd back/api
$env:JAVA_HOME="C:\Program Files\Java\jdk-17"; .\gradlew.bat bootRun
```

* 서버 포트: `8080`
* H2 콘솔: `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:file:./data/jeonshijangdb`)
* DB 파일 경로: `back/api/data/jeonshijangdb.mv.db` (서버 재시작해도 데이터 유지)
* 업로드 파일 경로: `back/api/uploads/` (서버 실행 디렉토리 기준 자동 생성)

### 프론트엔드 실행 방법

```powershell
cd front
flutter pub get   # 최초 1회 또는 pubspec.yaml 변경 시
flutter run
```

* **외부 접근 (현재 방식)**: ngrok 고정 도메인 사용 중. `api_client.dart`의 `baseUrl`에 고정 도메인 세팅
* ngrok 실행: `ngrok http --domain=고정도메인 8080`
* `api_client.dart`는 `.gitignore` 처리됨 (baseUrl이 환경마다 다르기 때문)
* 에뮬레이터 로컬 테스트 시: `http://10.0.2.2:8080`으로 변경

---

## 3. 완료된 작업

### ✅ Step 1 — Spring Boot 프로젝트 초기 세팅

* `build.gradle`: JJWT, AWS SDK v2, QueryDSL, Lombok 등 전체 의존성 구성
* `application.yml`: H2, JWT, S3 설정 (환경변수 fallback 포함)

### ✅ Step 2 — JPA Entity 설계 (4개 테이블)

파일 위치: `back/api/src/main/java/com/jeonshijang/api/domain/`

| Entity | 테이블 | 핵심 사항 |
| --- | --- | --- |
| `User` | `users` | `kakaoId` UNIQUE, `role` Enum |
| `Goods` | `goods` | `@SQLRestriction("deleted_at IS NULL")` 소프트 딜리트 |
| `Showcase` | `showcase` | User와 N:1, ShowcaseItem과 1:N (`CascadeType.ALL`, `orphanRemoval=true`) |
| `ShowcaseItem` | `showcase_item` | 굿즈별 `positionX`, `positionY`, `scale` 저장 |

### ✅ Step 3 — 카카오 소셜 로그인 (백엔드 + 프론트엔드)

**플로우**:
```
Flutter (kakao_flutter_sdk_user 1.10.0으로 카카오 토큰 발급)
  → POST /api/auth/kakao  { "accessToken": "카카오토큰" }
  → KakaoTokenVerifier (GET https://kapi.kakao.com/v2/user/me)
  → DB upsert (신규: INSERT, 기존: 닉네임/프로필 UPDATE)
  → JwtProvider → accessToken(30분) + refreshToken(14일) 발급
  → Flutter: TokenStorage에 저장 후 /home 이동
```

**주요 포인트**:
* `kakao_flutter_sdk_user 1.9.7`: 순수 Kotlin 구현체. Maven Kakao SDK 불필요
* Android Manifest에는 `com.kakao.sdk.flutter.AuthCodeCustomTabsActivity` 사용 (1.9.7 기준)
* 카카오 디벨로퍼스 Redirect URI: `http://localhost:8080/api/auth/kakao` (더미 HTTP URL)
* 커스텀 스킴(`kakao{앱키}://oauth`)은 AndroidManifest.xml에만 설정 (콘솔 등록 불필요)
* 카카오 네이티브 앱 키: `15ee0f3418efcadef9e9c5ab3676c584`
* Refresh Token: 현재 DB 미저장(stateless). 보안 강화 필요 시 `User` 엔티티에 컬럼 추가 또는 Redis 도입

### ✅ Step 4 — 굿즈 CRUD API (백엔드) + 컬렉션 UI (Flutter)

**구현된 엔드포인트** (모두 JWT 인증 필수):

| 메서드 | 경로 | 설명 |
| --- | --- | --- |
| `GET` | `/api/goods` | 내 굿즈 목록 조회 |
| `POST` | `/api/goods` | 굿즈 등록 (Multipart: image + name/price/memo) |
| `PUT` | `/api/goods/{id}` | 굿즈 수정 (name/price/memo, JSON) |
| `DELETE` | `/api/goods/{id}` | 굿즈 소프트 딜리트 |
| `GET` | `/api/goods/summary` | 수집 통계 (총 개수, 총 자산가치) |

**이미지 저장 방식** (프로토타입):
* 이미지를 서버 로컬 `./uploads/` 디렉토리에 UUID 파일명으로 저장
* DB에는 `/uploads/{uuid}.jpg` 상대경로 저장
* `WebMvcConfig`가 `/uploads/**` → 로컬 디렉토리 정적 서빙
* Flutter `GoodsItem.fromJson`에서 상대경로를 `ApiClient.baseUrl` 기반 절대 URL로 자동 변환
* 추후 S3 전환 시: `GoodsService.saveImage()` 내부만 교체하면 됨

**Flutter 컬렉션 화면**:
* `+` 버튼 → 바텀시트 (이미지 선택, 이름/가격/메모 입력)
* 이미지 선택: 카메라/갤러리 Dialog (`showModalBottomSheet` 중첩 시 Android 먹통 이슈 → `showDialog`로 해결)
* 카드 탭 → `GoodsDetailScreen`으로 이동
* 상세 화면에서 수정(다이얼로그) / 삭제(확인 후 소프트딜리트) 후 목록 자동 갱신

### ✅ Step 5 — 전시장 API (백엔드) + 전시장 UI (Flutter)

**구현된 엔드포인트**:

| 메서드 | 경로 | 설명 |
| --- | --- | --- |
| `GET` | `/api/showcases/mine` | 내 전시장 조회 (없으면 자동 생성) |
| `PUT` | `/api/showcases/{id}/items` | 굿즈 배치 좌표 저장 (전체 교체) |

**배치 저장 포인트**:
* 좌표는 0.0~1.0 상대값으로 저장 (화면 크기 독립적)
* `saveAndFlush` + 재조회로 신규 아이템 ID null 문제 해결
* `@EntityGraph`로 N+1 방지

### ✅ Step 6 — 4대 핵심 탭 UI 전체 API 연동

| 탭 | 파일 | 연동 API |
| --- | --- | --- |
| 컬렉션 | `collection_screen.dart`, `goods_detail_screen.dart` | GET/POST/PUT/DELETE `/api/goods` |
| 전시장 | `showcase_screen.dart` | GET/PUT `/api/showcases` |
| 기록 | `record_screen.dart` | GET `/api/goods/summary` |
| 내정보 | `my_info_screen.dart` | GET `/api/users/me` |

---

## 4. 미완성 기능 (현재 기준)

| 기능 | 현재 상태 | 비고 |
| --- | --- | --- |
| 전시장 줌인/아웃 | 드래그만 가능, 크기 조절 없음 | `scale` 필드는 DB에 존재하나 UI 미구현 |
| 굿즈 이미지 수정 | 수정 시 이름/가격/메모만 변경 가능 | 이미지 교체 미구현 |
| 공지사항 | 탭만 있고 내용 없음 | 추후 기획 필요 |

---

## 5. 남은 작업 (합의된 우선순위 순)

### 🔲 Step 7 — JWT 토큰 영속화 ← 다음 작업

* 현재 `TokenStorage`는 인메모리 → 앱 재시작 시 로그인 풀림
* `flutter_secure_storage` 패키지로 디바이스 보안 저장소에 저장
* 로그인 시 저장, 앱 시작 시 토큰 자동 복원, 로그아웃 시 삭제

### 🔲 Step 8 — 전시장 줌인/아웃 (핀치 제스처)

* `showcase_screen.dart`에 핀치 줌 제스처 추가
* `ShowcaseItem.scale` 필드를 실제 UI에 반영하여 저장/복원

### 🔲 Step 9 — 굿즈 이미지 수정

* `goods_detail_screen.dart` 수정 다이얼로그에 이미지 교체 기능 추가
* 백엔드 `PUT /api/goods/{id}` multipart 지원으로 확장 필요

### 🔲 Step 10 — 디자인 작업

* 전체 UI/UX 개선 (기능 완성 및 실기기 테스트 후 진행)

### 🔲 Step 11 — 인프라 / 배포 준비

* H2 → MySQL 전환 (`application-prod.yml` 프로파일 분리)
* Docker + docker-compose 설정
* GitHub Actions CI/CD 파이프라인
* Android APK 빌드: `flutter build apk --release`
* iOS 배포: Apple Developer 계정($99/년) + Mac + TestFlight

### 🔲 Step 12 — 이미지 처리 고도화 (배포 이후)

* 누끼(배경제거) AI API 연동 — 벤더 미확정 (remove.bg, rembg 등)
* AWS S3 업로드로 전환 (`GoodsService.saveImage()` 내부만 교체)
* 환경변수 세팅: `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, `AWS_S3_BUCKET`

---

## 6. 환경변수 목록

| 변수명 | 설명 | 기본값(로컬) |
| --- | --- | --- |
| `JWT_SECRET` | HMAC-SHA256 서명키 (32바이트 이상) | 하드코딩 문자열 |
| `AWS_ACCESS_KEY` | S3 접근 키 | 빈 문자열 |
| `AWS_SECRET_KEY` | S3 시크릿 키 | 빈 문자열 |
| `AWS_S3_BUCKET` | S3 버킷명 | `local-bucket` |

---

## 7. 개발 시 유의사항

* **실기기 IP 변경**: `front/lib/services/api_client.dart`의 `baseUrl` Android 분기값을 PC 로컬 IP로 세팅
* **에뮬레이터 한글 입력**: 에뮬레이터 설정 → General management → Keyboard → Gboard → Languages → Korean 추가
* **소프트 딜리트**: `@SQLRestriction`이 Goods 조회에 자동 적용. 삭제된 굿즈 조회가 필요한 경우 네이티브 쿼리 필요
* **인증 필요 API**: 모든 `/api/goods/**`, `/api/showcases/**`, `/api/users/**`는 `Authorization: Bearer {accessToken}` 필수
* **이미지 URL 규칙**: 로컬 저장 이미지는 `/uploads/...` 상대경로로 DB 저장. `ApiClient.toAbsoluteUrl()`이 절대 URL 변환 담당
* **Spring Security OAuth2 자동설정**: `application.yml`의 `autoconfigure.exclude`로 비활성화. FE가 Kakao SDK로 토큰 직접 발급하는 방식이므로 Spring OAuth2 redirect 플로우 불필요
* **QueryDSL Q클래스**: `./gradlew compileJava` 실행 필요. 생성 경로: `build/generated/querydsl/`
