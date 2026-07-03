# 실행 가이드

> 3개 터미널을 각각 띄워서 실행

---

## 1. 백엔드 (터미널 1)

```powershell
cd back/api
$env:JAVA_HOME="C:\Program Files\Java\jdk-17"; .\gradlew.bat bootRun
```

`Started ApiApplication` 뜨면 완료

---

## 2. ngrok (터미널 2)

```powershell
ngrok http --domain=tubeless-hamburger-shock.ngrok-free.dev 8080
```

`Forwarding https://tubeless-hamburger-shock.ngrok-free.dev` 뜨면 완료

---

## 3. 프론트엔드 (터미널 3)

```powershell
cd front
flutter run
```

---

## 기타

| 목적 | 명령어 |
|---|---|
| APK 빌드 | `cd front && flutter build apk --release` |
| APK 위치 | `front\build\app\outputs\flutter-apk\app-release.apk` |
| H2 콘솔 | 브라우저 → `http://localhost:8080/h2-console` |
| H2 JDBC URL | `jdbc:h2:file:./data/jeonshijangdb` |
| 포트 충돌 시 | `netstat -ano \| findstr :8080` 후 `taskkill /PID {숫자} /F` |
