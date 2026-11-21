import UnscrollCore
import XCTest

final class FeedBudgetTests: XCTestCase {
    private let rome = TimeZone(identifier: "Europe/Rome")!
    private func date(_ s: String) -> Date { // "2026-11-21 10:00"
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm"; f.timeZone = rome
        return f.date(from: s)!
    }
    private func budget() -> FeedBudget { FeedBudget(limit: 900, timeZone: rome) }

    func testFreshBudgetHasFullLimit() {
        XCTAssertEqual(budget().remaining(at: date("2026-11-21 10:00")), 900)
    }

    func testUsageAccumulatesInTheSameDay() {
        var b = budget()
        b.add(300, at: date("2026-11-21 10:00"))
        b.add(200, at: date("2026-11-21 18:00"))
        XCTAssertEqual(b.remaining(at: date("2026-11-21 23:59")), 400)
    }

    func testNewDayStartsFromZero() {
        var b = budget()
        b.add(900, at: date("2026-11-21 23:50"))
        XCTAssertEqual(b.remaining(at: date("2026-11-21 23:55")), 0)
        XCTAssertEqual(b.remaining(at: date("2026-11-22 00:05")), 900)
        b.add(100, at: date("2026-11-22 00:10"))
        XCTAssertEqual(b.remaining(at: date("2026-11-22 00:15")), 800)
    }

    func testRemainingNeverGoesNegative() {
        var b = budget()
        b.add(5000, at: date("2026-11-21 10:00"))
        XCTAssertEqual(b.remaining(at: date("2026-11-21 10:01")), 0)
    }

    func testNegativeElapsedIsIgnored() { // orologio spostato indietro
        var b = budget()
        b.add(-300, at: date("2026-11-21 10:00"))
        XCTAssertEqual(b.remaining(at: date("2026-11-21 10:01")), 900)
    }

    func testSurvivesStorageRoundTrip() throws {
        var b = budget()
        b.add(120, at: date("2026-11-21 10:00"))
        let back = try JSONDecoder().decode(FeedBudget.self, from: JSONEncoder().encode(b))
        XCTAssertEqual(back.remaining(at: date("2026-11-21 11:00")), 780)
    }
}
