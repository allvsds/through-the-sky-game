# 모바일 빌드 및 배포 가이드

## Android 빌드 설정

### 1. Android SDK 설치
```bash
# Android Studio 또는 SDK만 설치
sudo apt install android-sdk
```

### 2. Godot에서 Android 템플릿 다운로드
1. Godot 에디터 열기
2. `Project > Export...` 메뉴 선택
3. `Add...` 버튼 클릭 → `Android` 선택
4. `Manage Export Templates` → `Download and Install` 클릭

### 3. 키스토어 생성 (릴리스용)
```bash
# 개발용 키스토어 생성
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999
```

### 4. Export 설정
- `Export Path`: `builds/through-the-sky.apk`
- `Debug Keystore`: 위에서 생성한 keystore 파일
- `Architecture`: `arm64-v8a` (현대적 안드로이드 기기용)

## iOS 빌드 (macOS 필요)
iOS 빌드는 macOS와 Xcode가 필요합니다.

## 웹 브라우저용 빌드
웹에서 테스트하려면:
1. `Project > Export...`
2. `Add...` → `Web` 선택
3. Export Path: `builds/web/index.html`
4. `Export Project` 클릭

## 빠른 테스트 방법

### 1. 데스크톱에서 모바일 시뮬레이션
현재 설정이 이미 모바일 터치를 에뮬레이션합니다:
- 마우스 클릭 = 터치
- 세로 화면 레이아웃
- 모바일 렌더링 설정

### 2. 웹 브라우저에서 테스트
가장 간단한 방법:
```bash
# 웹 빌드 후 로컬 서버로 테스트
python3 -m http.server 8000
# 브라우저에서 localhost:8000 접속
```

## 권장 테스트 순서
1. ✅ **데스크톱** - 현재 상태 (개발용)
2. **웹 브라우저** - 모바일 브라우저에서 테스트 가능
3. **Android APK** - 실제 기기에서 테스트
4. **iOS** - App Store 배포용 (macOS 필요)