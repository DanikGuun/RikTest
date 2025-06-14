
import Foundation
import RikAPI

public extension DateInterval {
    static var currentMonth: DateInterval {
        let date = Calendar.current.dateInterval(of: .month, for: RikApi.originDate) ?? DateInterval()
        return date
    }
    static var currentDay: DateInterval {
        let date = Calendar.current.dateInterval(of: .day, for: RikApi.originDate) ?? DateInterval()
        return date
    }
}
