[English](README.md) · **한국어**

> [!CAUTION]
> **비공개 API를 연구하기 위한 실험적 프로젝트입니다.**
>
> ClockHandKit은 문서화되지 않은 WidgetKit 내부 구현과 밑줄이 붙은 Swift
> 런타임 조회 기능에 의존합니다. Apple은 이를 예고 없이 변경하거나 제거할 수
> 있습니다. 또한 [App 심사 지침 2.5.1](https://developer.apple.com/app-store/review/guidelines/#software-requirements)은
> 공개 API만 사용하도록 요구합니다. 이 패키지를 포함한 앱은 거절될 수 있으며,
> 로컬 빌드 또는 TestFlight 업로드 성공이 App Store 규정 준수를 뜻하지 않습니다.
>
> 실제 기기, TestFlight 및 App Store 검증은 아직 완료되지 않았습니다. 현재
> 버전을 프로덕션 준비 상태로 간주하지 마십시오.

# ClockHandKit

WidgetKit의 문서화되지 않은 시계바늘 회전 modifier를 위젯 View에 적용하기 위한
소스 기반 실험적 Swift 패키지입니다.

ClockHandKit은 iOS 26.1의 동작 변화에 대응하기 위해 만들었습니다.
[ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)이 사용하던
비공개 `_clockHandRotationEffect` 진입점은 링크 SDK와 런타임의 특정 조합에서
서드파티 앱에 원본 View를 반환하며 사실상 no-op이 됩니다.

ClockHandKit은 독립적으로 만든 구현이며 Apple 또는 ClockHandRotationKit
메인테이너와 관련이 없고 이들의 승인이나 보증을 받지 않았습니다.

## 이 프로젝트를 만든 이유

iOS 26.1부터 WidgetKit 바이너리 분석과 런타임 프로브에서 비공개 진입점의 동작이
앱의 링크 SDK 및 번들 식별자에 따라 달라지는 것이 확인됐습니다. iOS 26.1 SDK로
링크한 서드파티 앱을 iOS 26.1에서 실행하면 이 진입점은 modifier를 적용하지 않고
원본 View를 반환합니다.

기존 진입점의 동작은 다음과 같이 재현했습니다.

| 런타임 | 링크 SDK | 번들 | 결과 |
| --- | --- | --- | --- |
| iOS 26.0 | iOS 26.0 또는 26.1 | 서드파티 | modifier 반환 |
| iOS 26.1 | iOS 26.0 | 서드파티 | modifier 반환 |
| iOS 26.1 | iOS 26.1 | 서드파티 | 원본 View 반환 |
| iOS 26.1 | iOS 26.1 | Apple 시계 앱 번들 prefix | modifier 반환 |

이 현상은 일반적인 컴파일 실패나 Swift 언어 버전 불일치, iOS 26.1의 JSON 형식
변경이 아닙니다. 링크된 SDK와 실행 OS가 함께 작용하는 비공개 진입점의 런타임
동작 변경입니다. Xcode 26.1이 문제를 일으킨 것처럼 보이는 이유는 iOS 26.1 SDK에
링크하기 때문이며, 근본적인 변화는 iOS 26.1 WidgetKit 구현 내부에 있습니다.

최초 [iOS 26.1 호환성 리포트](https://github.com/octree/ClockHandRotationKit/issues/11)와
[WidgetKit 바이너리 diff](https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304)도
참고할 수 있습니다.

## 동작 방식

ClockHandKit은 제한 조건이 추가된 비공개 진입점을 호출하지 않습니다. 대신 다음
단계를 거칩니다.

1. `_typeByName`으로 `WidgetKit._ClockHandRotationEffect`를 런타임에 찾습니다.
2. 관찰된 비공개 타입의 Codable 표현에 맞춰 주기, 타임존, anchor를 인코딩합니다.
3. payload를 동적으로 찾은 타입으로 디코딩합니다.
4. 생성한 값을 `any ViewModifier`로 캐스팅합니다.
5. Swift existential opening을 통해 modifier를 적용합니다.

이 경로는 body가 없는 비공개 `some View` 함수를 `@_silgen_name`으로 선언할 때
발생한 Swift 6.2 IRGen 실패도 피합니다.

[Pull request #1](https://github.com/giljihun/ClockHandKit/pull/1)의 payload 수정은
ClockHandKit이 처음에 추측했던 표현을 실제 구조에 맞게 바로잡은 것입니다.
`period`는 `TimeInterval`이고 `timeZone`과 `anchor`는 각각 `TimeZone`과
`UnitPoint`가 합성하는 Codable 형식을 사용합니다. 이는 ClockHandKit 초기 구현의
오류를 고친 것이지 iOS 26.1에서 JSON 형식이 바뀌었다는 증거가 아닙니다.

타입 조회, 디코딩 또는 캐스팅 중 하나라도 실패하면 회전 효과 없이 원본 View를
반환하고 실패한 단계를 `OSLog`에 기록합니다.

## 요구 사항

- iOS 16 이상
- Swift tools 6.2, 즉 Xcode 26 이상
- SwiftUI 및 WidgetKit

이 패키지는 위젯 View를 대상으로 합니다. 최소 배포 버전이 iOS 16이라는 사실이
모든 OS 조합에서 end-to-end 테스트를 마쳤다는 뜻은 아닙니다.

## 설치

아직 태그로 배포한 릴리스가 없습니다. Xcode에서 **File → Add Package
Dependencies**를 선택하고 아래 주소를 입력한 뒤 `main` 브랜치를 선택합니다.

```text
https://github.com/giljihun/ClockHandKit.git
```

Package.swift에서는 다음과 같이 추가할 수 있습니다.

```swift
dependencies: [
    .package(
        url: "https://github.com/giljihun/ClockHandKit.git",
        branch: "main"
    )
]
```

실험 단계의 `main`은 바뀔 수 있으므로 재현성이 중요하다면 특정 revision으로
고정하는 것을 권장합니다.

## 사용법

```swift
import SwiftUI
import ClockHandKit

Image(systemName: "arrow.up")
    .clockHandRotationEffect(period: .secondHand)
```

지원하는 주기는 다음과 같습니다.

| 값 | 인코딩되는 주기 |
| --- | ---: |
| `.hourHand` | 43,200초 |
| `.minuteHand` | 3,600초 |
| `.secondHand` | 60초 |
| `.custom(seconds)` | 전달한 초 단위 값 |

타임존과 회전 기준점도 지정할 수 있습니다.

```swift
hand.clockHandRotationEffect(
    period: .minuteHand,
    in: TimeZone(identifier: "Asia/Seoul")!,
    anchor: .bottom
)
```

## 검증 상태

빌드 성공, 런타임 modifier 생성, 실제 위젯 애니메이션, 배포 승인은 서로 다른 검증
단계입니다.

| 범위 | 환경 | 상태 |
| --- | --- | --- |
| 패키지 빌드 | Xcode 26.1, 26.4, 26.5 | 통과 — 메인테이너 확인 |
| 예제 앱과 두 위젯 extension | Xcode 26.5 | 통과 — 독립 재현 |
| 동적 modifier 생성 | Xcode 26.1 SDK → iOS 26.1 시뮬레이터, 서드파티 번들 ID | 통과 — 생성된 `ModifiedContent` 확인 |
| 비공개 타입 및 Codable payload | iOS 26.5 시뮬레이터 | 통과 — 조회, 디코딩, conformance 확인 |
| 실제 홈 화면 위젯 애니메이션 | 설치된 위젯 | 미검증 |
| 실제 기기 | iOS 기기 | 미검증 |
| TestFlight 처리 및 테스트 | App Store Connect | 미검증 |
| App Store 심사 | App Review | App Store-safe하지 않으며 거절 위험이 높음 |

`ModifiedContent` 생성 확인은 런타임 브리지에 대한 강한 근거지만, 실제 홈 화면
애니메이션이나 App Store 승인까지 증명하는 것은 아닙니다.

## ClockHandRotationKit에서 이전하기

1. 타깃에서 `ClockHandRotationKit` 패키지 또는 XCFramework를 제거합니다.
2. ClockHandKit을 추가합니다.
3. import를 바꿉니다.

```diff
-import ClockHandRotationKit
+import ClockHandKit
```

소스 호환 이전을 위해 `TimeInterval` 오버로드를 제공합니다.

```swift
.clockHandRotationEffect(period: 60)
```

새 코드에는 typed API를 권장합니다.

```swift
.clockHandRotationEffect(period: .secondHand)
```

ClockHandKit은 iOS 16 이상이 필요하고 원본 패키지는 iOS 14 이상을 선언합니다.
extension method가 충돌할 수 있으므로 같은 타깃에 두 모듈을 함께 import하지 마세요.

## 한계와 진단

- 비공개 타입 이름, conformance, Codable 저장 구조는 언제든 바뀔 수 있습니다.
- 내부 단계가 실패하면 widget은 표시되지만 회전이 사라지는 fail-open 방식입니다.
- 애니메이션 스케줄, snapshot, 저전력 모드 동작, refresh는 WidgetKit이 제어합니다.
- 구현 과정에서 `AnyView` type erasure를 사용합니다.
- 첫 stable release 전까지 public API가 바뀔 수 있습니다.
- App Store 승인은 테스트하지 않았고 보장할 수 없습니다.

ClockHandKit은 각 브리지 단계를 subsystem `com.clockhandkit`, category
`runtime-bridge`로 기록합니다. Console.app에서 subsystem을 필터링하거나 다음
명령을 사용할 수 있습니다.

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## TestFlight 및 App Store 배포

Apple의 [App 심사 지침 2.5.1](https://developer.apple.com/app-store/review/guidelines/#software-requirements)은
public API만 사용하도록 규정합니다.
[Apple Developer Program License Agreement](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/)도
문서화된 API를 정해진 방식으로 사용할 것을 요구합니다. 런타임 조회 방식을
사용해도 private type이 public API로 바뀌지는 않습니다.

실제 배포 단계는 다음과 구분해야 합니다.

- Archive가 정상 빌드되고 App Store Connect processing을 통과할 수도 있지만,
  자동 검증에서 non-public API usage로 거절될 수도 있습니다.
- processing에 성공하면 내부 TestFlight 배포가 가능할 수 있지만, 이것이 정책
  준수를 뜻하지는 않습니다.
- [첫 외부 TestFlight 빌드](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview)는
  Beta App Review 대상이고 App Store 제출은 정식 App Review 대상입니다. 둘 다
  거절 위험이 높습니다.
- 이전 심사를 한 번 통과해도 이후 업데이트, 재검사, OS 릴리스 통과를 보장하지
  않습니다.

심사에서 이 동작을 숨기면 안 됩니다. 제출 실험을 한다면 위젯 추가 방법, 필요한
OS·기기, 기대하는 애니메이션을 Review Notes에 적어야 합니다. 투명한 공개는 검토
재현성에는 도움이 되지만 private API 문제 자체를 해소하지는 않습니다.

## 기여하기

Issue 또는 Pull Request를 열기 전에 [CONTRIBUTING.md](CONTRIBUTING.md)를 읽어
주세요. 재현 가능한 호환성 리포트와 실제 기기 테스트 결과가 특히 큰 도움이 됩니다.

## 감사의 말

- 최초 프로젝트와 API 형태를 만든
  [octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)
- [Pull request #1](https://github.com/giljihun/ClockHandKit/pull/1)에서 올바른 런타임
  payload 표현을 찾아 수정한 [@b5nt](https://github.com/b5nt)
- 빌드·런타임 호환성 표를 기록한 upstream issue #11의 참여자들

## 라이선스

ClockHandKit은 [MIT License](LICENSE)로 제공됩니다.
