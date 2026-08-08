import Foundation
import SwiftUI
import Testing
@testable import ClockHandKit

@Suite("Clock hand runtime payload")
struct ClockHandPayloadTests {
    @Test("Known periods map to seconds")
    func knownPeriodsMapToSeconds() {
        #expect(ClockHandPeriod.hourHand.duration == 43_200)
        #expect(ClockHandPeriod.minuteHand.duration == 3_600)
        #expect(ClockHandPeriod.secondHand.duration == 60)
        #expect(ClockHandPeriod.custom(7.5).duration == 7.5)
    }

    @Test("Payload matches WidgetKit's private Codable storage")
    func payloadMatchesPrivateStorage() throws {
        let payload = _ClockHandData(
            period: ClockHandPeriod.secondHand.duration,
            timeZone: try #require(TimeZone(identifier: "GMT")),
            anchor: .center
        )

        let data = try JSONEncoder().encode(payload)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let anchor = try #require(object["anchor"] as? [Double])
        let timeZone = try #require(object["timeZone"] as? [String: String])

        #expect(object["period"] as? Double == 60)
        #expect(anchor == [0.5, 0.5])
        #expect(timeZone["identifier"] == "GMT")
    }
}
