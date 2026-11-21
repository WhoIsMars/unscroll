import Foundation

/// Minuti di feed al giorno. Il conteggio riparte a mezzanotte (fuso del telefono).
public struct FeedBudget: Codable, Equatable {
    public let limit: TimeInterval
    private let timeZone: TimeZone
    private var day = ""
    private var used: TimeInterval = 0

    public init(limit: TimeInterval, timeZone: TimeZone = .current) {
        self.limit = limit
        self.timeZone = timeZone
    }

    public mutating func add(_ seconds: TimeInterval, at date: Date) {
        let today = dayKey(date)
        if today != day { day = today; used = 0 }
        used += max(0, seconds)
    }

    public func remaining(at date: Date) -> TimeInterval {
        dayKey(date) == day ? max(0, limit - used) : limit
    }

    private func dayKey(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return "\(c.year!)-\(c.month!)-\(c.day!)"
    }
}
