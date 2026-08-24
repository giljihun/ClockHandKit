[English](CONTRIBUTING.md) · **한국어**

# ClockHandKit에 기여하기

WidgetKit의 시계 바늘 회전 동작을 조사하고 문서화하는 데
도움을 주셔서 감사합니다.

ClockHandKit은 WidgetKit의 비공개 동작에 의존합니다. 재현 가능한 호환성 보고,
진단, 테스트 및 문서 기여를 환영합니다.

## 이슈를 작성하기 전에

먼저 기존 이슈를 검색하고, 어느 단계에서 문제가 발생했는지 구분해 주세요.

1. 패키지 컴파일 또는 링크
2. 런타임 타입 조회, payload 디코딩 또는 modifier 생성
3. 홈 화면에 설치한 위젯의 애니메이션
4. App Store Connect 처리, TestFlight 또는 App Review

빌드 성공만으로 런타임 동작을 확인할 수는 없습니다.

무엇을 어디에서 테스트했으며 어떤 결과가 나타났는지 설명해 주세요.

## 호환성 보고

다음 정보를 포함해 주세요.

- ClockHandKit 릴리스 또는 커밋
- Xcode 버전, 빌드 번호 및 링크된 iOS SDK
- iOS 버전, 빌드 번호 및 실제 기기 또는 Simulator 모델
- 결과를 확인한 환경: 프리뷰, Simulator 앱, 위젯 갤러리 또는 홈 화면 위젯
- 테스트 앱과 위젯의 번들 식별자. 프로덕션용 식별자는 사용하지 마세요.
- 예상한 동작, 실제 동작 및 실패한 단계
- 관련 `com.clockhandkit` / `runtime-bridge` 로그
- 가능하다면 최소 재현 프로젝트 또는 짧은 화면 녹화

버전은 다음 명령어로 확인할 수 있습니다.

```shell
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
```

ClockHandKit 로그는 다음 명령어로 확인할 수 있습니다.

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## 로컬 개발

ClockHandKit은 iOS 전용 Swift 패키지입니다. 사용할 수 있는 destination을 확인한
다음 설치된 iOS Simulator를 대상으로 빌드하고 테스트하세요.

```shell
xcodebuild -scheme ClockHandKit -showdestinations

xcodebuild \
  -scheme ClockHandKit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  build

xcodebuild \
  -scheme ClockHandKit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  test
```

destination은 현재 Mac에 설치된 항목으로 바꿔 주세요. 패키지 매니페스트도
정상적으로 불러올 수 있는지 확인합니다.

```shell
swift package dump-package
```

런타임 브리지 테스트만으로는 충분하지 않습니다. 예제 위젯을 설치하고 위젯
호스트에서 애니메이션이 동작하는지도 확인해 주세요.

## Pull Request

Pull Request를 제출하기 전에 다음 사항을 확인해 주세요.

1. 동작을 변경하거나 공개 API를 크게 변경하려면 먼저 이슈를 작성합니다.
2. 변경 범위를 명확하게 유지합니다.
3. 관련 테스트를 추가하거나 수정합니다.
4. iOS Simulator를 대상으로 빌드하고 테스트합니다.
5. 영문 문서와 한국어 문서를 함께 수정합니다.
6. 사용한 Xcode, SDK, 런타임 및 테스트 환경을 포함해 검증한 내용을 정확히
   설명합니다.

## 구현 지침

- Fail-open 동작을 유지합니다. 비공개 런타임 단계가 실패하면 원본 View를
  반환합니다.
- 런타임 브리지 실패를 구조화된 로그로 확인할 수 있게 유지합니다.
- 타입 이름, Codable 구조 및 비공개 프로토콜 적합성은 변경될 수 있다고
  가정합니다.
- 비공개 프레임워크 동작에 관한 주장은 재현 가능한 프로브나 바이너리 근거로
  뒷받침합니다.
- 공개 API는 작게 유지하고 리버스 엔지니어링 세부 사항은 내부에 둡니다.
- 텔레메트리를 추가하거나 사용자 데이터를 수집하지 않습니다.

## 문서와 출처 표기

중립적이고 근거에 기반한 표현을 사용합니다. 확인된 동작, 메인테이너의 보고,
독립적으로 재현한 결과 및 추론을 명확히 구분해 주세요.

[octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)에 대한
출처 표기를 유지하고, 변경의 기반이 된 연구나 코드를 제공한 기여자를 명시해
주세요.

## 라이선스

기여 내용을 제출하면 프로젝트의 [MIT License](LICENSE)에 따라 배포될 수 있다는
데 동의하는 것으로 간주합니다.
