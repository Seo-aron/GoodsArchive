# 전시장(Jeonshijang) 프로젝트 인수인계

> 디지털 굿즈/피규어를 등록하고 2D 가상 장식장에 배치하는 앱

**배포 전략**: 안드로이드(Google Play) 스토어 **우선 출시** — 최소 비용 전략. iOS 및 웹 버전은 런칭 후 트래픽/반응에 따라 단계적 확장 예정.

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
│       ├── theme.dart              ← 앱 전체 테마 (파스텔 하늘색, 동글동글)
│       ├── models/
│       │   ├── goods_item.dart     ← GoodsItem 모델 (imageUrl 상대경로 자동 절대변환)
│       │   ├── goods_summary.dart  ← GoodsSummary 모델
│       │   ├── showcase_data.dart  ← ShowcaseData, ShowcasePlacedItem 모델
│       │   └── user_info.dart      ← UserInfo 모델
│       ├── screens/
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart     ← 자체 회원가입 화면 (ID/PW)
│       │   ├── collection_screen.dart   ← 굿즈 목록, 등록(+버튼), 카드탭→상세
│       │   ├── goods_detail_screen.dart ← 굿즈 상세 + 수정/삭제
│       │   ├── showcase_screen.dart     ← 2D 드래그 배치 + 핀치 줌 + 저장
│       │   ├── record_screen.dart       ← 수집 통계 대시보드
│       │   └── my_info_screen.dart      ← 프로필 + 로그아웃
│       └── services/
│           ├── api_client.dart     ← 공통 HTTP 클라이언트 (JWT 헤더 자동 주입)
│           ├── token_storage.dart  ← 디바이스 보안 저장소 기반 JWT 토큰 관리 (flutter_secure_storage)
│           ├── auth_service.dart   ← 카카오 로그인 + 자체 로그인/회원가입, 로그아웃
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
            │   ├── auth/           ← 인증 (카카오 로그인, 자체 로그인/회원가입, JWT 발급)
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
| **보안** | Spring Security 6, JJWT 0.12.6, BCrypt (자체 로그인용) |
| **ORM** | Spring Data JPA, Hibernate 6, QueryDSL 5.1 |
| **DB** | H2 (파일모드, 개발용) → MySQL (운영) — Oracle Cloud VM 내 직접 설치 (RDS 미사용) |
| **스토리지** | 로컬 `./uploads/` 디렉토리 (개발) → 추후 AWS S3 전환 예정 |
| **인프라** | Oracle Cloud Always Free (백엔드 배포), Nginx + Let's Encrypt SSL, 도메인: 가비아 / 호스팅케이알 |
| **HTTP 클라이언트** | Spring 6 RestClient (카카오 API 호출용) |
| **프론트엔드** | Flutter (Dart), `kakao_flutter_sdk_user: ^1.9.7`, `http: ^1.2.2`, `image_picker: ^1.1.2`, `flutter_secure_storage: ^9.2.2`, `google_fonts: ^6.2.1` |

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
| `User` | `users` | `kakaoId` UNIQUE (nullable), `loginId`/`password` (자체 로그인용), `role` Enum |
| `Goods` | `goods` | `@SQLRestriction("deleted_at IS NULL")` 소프트 딜리트 |
| `Showcase` | `showcase` | User와 N:1, ShowcaseItem과 1:N (`CascadeType.ALL`, `orphanRemoval=true`) |
| `ShowcaseItem` | `showcase_item` | 굿즈별 `positionX`, `positionY`, `scale` 저장 |

### ✅ Step 3 — 인증 (카카오 소셜 로그인 + 자체 로그인/회원가입)

**카카오 로그인 플로우**:
```
Flutter (kakao_flutter_sdk_user로 카카오 토큰 발급)
  → POST /api/auth/kakao  { "accessToken": "카카오토큰" }
  → KakaoTokenVerifier (GET https://kapi.kakao.com/v2/user/me)
  → DB upsert (신규: INSERT, 기존: 닉네임/프로필 UPDATE)
  → JwtProvider → accessToken(30분) + refreshToken(14일) 발급
  → Flutter: TokenStorage에 저장 후 /home 이동
```

**자체 로그인/회원가입 엔드포인트**:
* `POST /api/auth/register` — loginId(4~20자), password(6~30자), nickname 입력 → BCrypt 해싱 후 저장
* `POST /api/auth/login` — loginId + password 검증 → JWT 발급

**주요 포인트**:
* `kakao_flutter_sdk_user 1.9.7`: 순수 Kotlin 구현체. Maven Kakao SDK 불필요
* 카카오 디벨로퍼스 Redirect URI: `http://localhost:8080/api/auth/kakao` (더미 HTTP URL) → 운영 시 실서버 주소로 변경 필요
* 커스텀 스킴(`kakao{앱키}://oauth`)은 AndroidManifest.xml에만 설정 (콘솔 등록 불필요)
* 카카오 네이티브 앱 키: `15ee0f3418efcadef9e9c5ab3676c584`
* Refresh Token: 현재 DB 미저장(stateless). 보안 강화 필요 시 `User` 엔티티에 컬럼 추가 또는 Redis 도입

### ✅ Step 4 — 굿즈 CRUD API (백엔드) + 컬렉션 UI (Flutter)

**구현된 엔드포인트** (모두 JWT 인증 필수):

| 메서드 | 경로 | 설명 |
| --- | --- | --- |
| `GET` | `/api/goods` | 내 굿즈 목록 조회 |
| `POST` | `/api/goods` | 굿즈 등록 (Multipart: image + name/price/purchasedAt/memo) |
| `PUT` | `/api/goods/{id}` | 굿즈 수정 (Multipart: image(선택) + name/price/purchasedAt/memo) |
| `DELETE` | `/api/goods/{id}` | 굿즈 소프트 딜리트 |
| `GET` | `/api/goods/summary` | 수집 통계 (총 개수, 총 자산가치) |

**이미지 저장 방식** (개발):
* 이미지를 서버 로컬 `./uploads/` 디렉토리에 UUID 파일명으로 저장
* DB에는 `/uploads/{uuid}.jpg` 상대경로 저장
* `WebMvcConfig`가 `/uploads/**` → 로컬 디렉토리 정적 서빙
* Flutter `GoodsItem.fromJson`에서 상대경로를 `ApiClient.baseUrl` 기반 절대 URL로 자동 변환
* 추후 S3 전환 시: `GoodsService.saveImage()` 내부만 교체하면 됨

**Flutter 컬렉션 화면**:
* `+` 버튼 → 바텀시트 (이미지 선택, 이름/가격/구매날짜/메모 입력)
* 이미지 선택: 카메라/갤러리 Dialog (`showModalBottomSheet` 중첩 시 Android 먹통 이슈 → `showDialog`로 해결)
* 카드 탭 → `GoodsDetailScreen`으로 이동
* 상세 화면에서 수정(이미지 교체 포함) / 삭제(확인 후 소프트딜리트) 후 목록 자동 갱신

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

### ✅ Step 7 — JWT 토큰 영속화

**변경 파일**: `token_storage.dart`, `main.dart`

* `flutter_secure_storage` 패키지로 디바이스 보안 저장소에 JWT 저장
* `main()` async화 → `TokenStorage.init()` 호출로 앱 시작 시 토큰 자동 복원
* `ShowcaseApp`: 토큰 존재 시 `/home`, 없으면 `/login`으로 자동 분기
* 로그아웃 시 메모리 초기화 → 보안 저장소에서도 완전 삭제

### ✅ Step 8 — 전시장 핀치 줌 (개별 아이템 크기 조절)

**변경 파일**: `showcase_screen.dart`

* `onPanUpdate` → `onScaleStart/Update`로 전환
* `Listener` 제거 → `GestureDetector`로 통합 (1손가락=드래그, 2손가락=핀치)
* `_scales: Map<int, double>` 상태 추가 — 아이템별 개별 scale 관리
* 아이템 시각 크기: `72 * scale` (0.3× ~ 3.0× 범위 제한)
* scale 값 DB 저장/복원: `PlaceItemDto` 연동, 앱 재시작 시 복원
* 에뮬레이터 핀치: `Ctrl+드래그` (화면 중앙 기준 대칭 터치 — 아이템을 중앙 근처에 놓고 테스트)

### ✅ Step 9 — 굿즈 이미지 수정

**변경 파일**: `Goods.java`, `GoodsService.java`, `GoodsController.java`, `goods_service.dart`, `goods_detail_screen.dart`

* 백엔드 `PUT /api/goods/{id}` multipart 방식으로 전환 (`@RequestPart image`, `required = false`)
* `Goods.updateImageUrl()` 메서드 추가
* Flutter 수정 다이얼로그 상단에 이미지 미리보기 영역 추가
* 탭 시 카메라/갤러리 선택 → 새 이미지 업로드 가능
* 이미지 미선택 시 기존 이미지 유지

---

## 4. 미완성 기능 (현재 기준)

| 기능 | 현재 상태 | 비고 |
| --- | --- | --- |
| 공지사항 | 탭만 있고 내용 없음 | 추후 기획 필요 |
| 통계 막대그래프 | 수치 요약만 표시 | Step 10-2에서 구현 예정 |
| 전시장 디자인 | 기본 배치만 구현 | Step 10-3에서 유리장 느낌으로 개선 예정 |

---

## 5. 남은 작업 (합의된 우선순위 순)

### 🔲 Step 10 — 디자인 작업

전체 UI/UX 개선. 하나씩 순차적으로 진행.

#### Step 10-0 — 앱 전체 테마 적용 ✅ 완료

* 파스텔 하늘색 테마: `ColorScheme.fromSeed(seedColor: Color(0xFF7EC8E3))`
* 배경: `#F4FBFF` (연한 하늘빛 흰색)
* 폰트: **Noto Sans KR** (`google_fonts: ^6.2.1`)
* 동글동글한 느낌: Card(r=20), Button(StadiumBorder), Input(r=16), Dialog(r=24), BottomSheet(r=28)
* 탭바: `BottomNavigationBar` → Material 3 `NavigationBar` 교체 (선택 시 pill 인디케이터)

#### Step 10-1 — 굿즈 구매날짜 입력/수정 ✅ 완료

* 등록 바텀시트(`collection_screen.dart`)에 날짜 입력 필드 추가 (`showDatePicker`, 한국어 로케일)
* 수정 다이얼로그(`goods_detail_screen.dart`)에도 날짜 변경 기능 추가
* 백엔드 `PUT /api/goods/{id}`에 `purchasedAt` 파라미터 추가 (`GoodsUpdateRequest` 확장)
* X 버튼으로 선택 날짜 초기화 가능

#### Step 10-2 — 통계 페이지 막대그래프 🔲

* 월별 지출 금액 + 굿즈 구입 개수를 막대그래프로 시각화 (`record_screen.dart`)
* 표시 형식: `20nn년 n월` 기준으로 월별 통계
* 구성:
  * 월별 막대그래프 (지출액 / 구입 개수 탭 전환 또는 이중 축)
  * 총 합계 요약 카드 (누적 지출, 총 굿즈 수)
* 가시성 최우선 — 한눈에 파악 가능한 레이아웃
* 백엔드: 월별 집계 API 추가 필요 (`GET /api/goods/monthly-stats`)
* 패키지 후보: `fl_chart` (Flutter 전용, 커스텀 쉬움)

#### Step 10-3 — 전시장 UI 개선 🔲 (기획 중)

* 유리 전시장 느낌으로 배경/프레임 디자인 변경
* 가로(landscape) 모드 전환 여부 고민 중
* 결정 후 구체적인 작업 범위 확정 예정

### 🔲 Step 11 — 인프라 / 배포 준비 (최소 비용 · 안드로이드 우선 전략)

> **목표**: Oracle Cloud Always Free + Google Play Console ($25 일회성) 조합으로 최소 비용 정식 출시

- [ ] 도메인 구매 (가비아 / 호스팅케이알) 및 카카오 디벨로퍼스 Redirect URI를 실서버 주소로 변경
- [ ] Oracle Cloud (Always Free) VM 인스턴스 생성 및 Ubuntu 환경 세팅
- [ ] 오라클 VM 내부에 MySQL 직접 설치 및 스키마 세팅 (RDS 미사용)
- [ ] H2 → MySQL 전환 (`application-prod.yml` 프로파일 분리)
- [ ] Nginx 설정 및 Let's Encrypt 무료 SSL(HTTPS) 인증서 발급
- [ ] GitHub Actions CI/CD 파이프라인 구축 (자동 배포)
- [ ] Android AAB 릴리즈 빌드: `flutter build appbundle --release`
- [ ] Google Play Console 개발자 등록 ($25 일회성) 및 앱 심사 제출

> ⚠️ **iOS 배포는 보류**: 안드로이드 런칭 후 시장 반응에 따라 추후 진행 (Apple Developer 계정 $99/년 비용 방어)

### 🔲 Step 12 — 이미지 처리 고도화 (배포 이후, 우선순위 낮음)

* AWS S3 업로드로 전환 (`GoodsService.saveImage()` 내부만 교체하면 됨)
* 환경변수 세팅: `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, `AWS_S3_BUCKET`
* 누끼(배경제거) AI API 연동 — **보류** (유료 API 비용 발생 문제로 미진행. 무료 대안인 rembg는 Oracle Free 인스턴스 성능 한계로 현실적으로 어려움. 사용자 규모 확인 후 재검토)

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
* **H2 컬럼 제약 변경**: `ddl-auto: update`는 기존 컬럼 제약을 수정하지 않음. 컬럼 nullable 변경 등은 H2 콘솔에서 직접 `ALTER TABLE` 실행 필요
* **카카오 Redirect URI**: 운영 배포 시 카카오 디벨로퍼스 콘솔에서 실서버 도메인으로 등록 필요
