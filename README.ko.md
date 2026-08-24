[English](README.md) · **한국어**

# ClockHandKit

Xcode 26.1 이상에서 빌드한 iOS 홈 화면 위젯의 시침·분침·초침을 실제 시간에 맞춰
회전시키는 Swift 패키지입니다.

> [!CAUTION]
> ClockHandKit은 문서화되지 않은 WidgetKit API를 사용하며, 예고 없이 동작이 바뀌거나 App Review를 통과하지 못할 수 있습니다.

## 사용법

```swift
import SwiftUI
import ClockHandKit

Image(systemName: "arrow.up")
    .clockHandRotationEffect(period: .secondHand)
```

지원하는 회전 주기는 다음과 같습니다.

| 값 | 회전 주기 |
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

## ClockHandKit을 만든 이유

[ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)은
WidgetKit의 문서화되지 않은 시계바늘 효과를 Swift에서 사용할 수 있게 만든
패키지입니다. iOS 26.1부터 링크 SDK와 실행 OS가 모두 iOS 26.1 이상인 서드파티
앱에서는 이 진입점이 회전 효과를 적용하지 않습니다. 코드는 정상적으로 빌드되지만
WidgetKit은 회전 modifier가 없는 원본 View를 반환합니다.

| 빌드 환경 | 실행 환경 | 기존 진입점의 결과 |
| --- | --- | --- |
| Xcode 26.0.1 | iOS 26.1 | 회전 효과 적용 |
| Xcode 26.1 | iOS 26.0.x | 회전 효과 적용 |
| Xcode 26.1 | iOS 26.1 | 회전하지 않음 |

**마지막 조합에서만 문제가 발생합니다.** 새 SDK로 빌드한 앱을 새 OS에서 실행할
때 iOS 26.1의 새로운 WidgetKit 동작이 적용됩니다.

이는 Swift 버전이나 JSON 형식의 문제가 아니라 WidgetKit에 추가된 런타임
제한입니다. ClockHandKit은 제한된 진입점을 호출하지 않고 내부 modifier를 직접
구성해 적용합니다.

최초 [iOS 26.1 호환성 리포트](https://github.com/octree/ClockHandRotationKit/issues/11)와
[WidgetKit 바이너리 diff](https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304)도
참고할 수 있습니다.

## 동작 방식

ClockHandKit은 다음 방식으로 동작합니다.

1. `WidgetKit._ClockHandRotationEffect` 타입을 런타임에 찾습니다.
2. 확인된 Codable 구조를 사용해 modifier를 생성합니다.
3. 생성한 값을 SwiftUI `ViewModifier`로 적용합니다.

중간 단계가 실패하면 원본 View를 그대로 반환하고 실패 내용을 `OSLog`에
기록합니다.

## 요구 사항

- iOS 16 이상
- Swift tools 6.2
- Xcode 26.1 이상
- SwiftUI 및 WidgetKit

## 테스트 환경

ClockHandKit은 다음 환경에서 테스트했습니다.

| 범위 | 테스트 환경 |
| --- | --- |
| 패키지 빌드 | Xcode 26.1, 26.4, 26.5 |
| 예제 앱 및 두 Widget Extension | Xcode 26.5 |
| 런타임 modifier 브리지 | iOS 26.1 및 iOS 26.5 Simulator |

원인을 분석하는 과정에서는 최소 ClockHandRotationKit consumer를 다음 전체
조합에서 compile하고 link했습니다.

| 구분 | 테스트 값 |
| --- | --- |
| ClockHandRotationKit 릴리스 | 1.0.0, 1.0.1, 1.1.0 |
| Xcode | 26.0.1 (17A400), 26.1.1 (17B100), 26.5 (17F42) |
| 타깃 | iOS device arm64, iOS Simulator arm64, iOS Simulator x86_64 |
| 구성 | Debug, Release |

총 **3개 릴리스 × 3개 Xcode 버전 × 3개 타깃 × 2개 구성 = 54개 consumer
compile/link 조합**이며, 54개 모두 성공했습니다. 이를 통해 원인이 컴파일 실패가
아닌 런타임 동작임을 확인했습니다.

## ClockHandRotationKit에서 이전하기

import를 다음과 같이 바꿉니다.

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

ClockHandKit은 iOS 16 이상이 필요하고 ClockHandRotationKit은 iOS 14 이상을
선언합니다. extension method가 충돌할 수 있으므로 같은 타깃에 두 모듈을 함께
import하지 마세요.

## 한계와 진단

- WidgetKit의 비공개 타입 이름과 Codable 구조는 변경될 수 있습니다.
- 런타임 브리지가 실패하면 위젯은 표시되지만 회전 효과는 적용되지 않습니다.

런타임 실패는 subsystem `com.clockhandkit`, category `runtime-bridge`로
기록됩니다.

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## 기여하기

Issue 또는 Pull Request를 열기 전에 [CONTRIBUTING.md](CONTRIBUTING.md)를 읽어
주세요.

## 감사의 말

ClockHandKit은 최초 구현과 API 형태를 제시한
[octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)에서
영감을 받았습니다.

## 라이선스

ClockHandKit은 [MIT License](LICENSE)로 제공됩니다.
