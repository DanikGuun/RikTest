
import Foundation
import RikAPI

public enum DateIntervalForSexAndAge {
    case days
    case weeks
    case months
    case allTime
    
    static let allCases: [DateIntervalForSexAndAge] = [.days, .weeks, .months, .allTime]
    
    var title: String {
        switch self {
        case .days: "Сегодня"
        case .weeks: "Неделя"
        case .months: "Месяц"
        case .allTime: "Все время"
        }
    }
    
    var ages: [Range<Int>] {
        [0..<18, 18..<22, 22..<26, 26..<31, 31..<36, 36..<41, 41..<51, 51..<Int.max]
    }
    
    var interval: DateInterval {
        switch self {
        case .days: return getTodayInterval()
        case .weeks: return getThisWeekInterval()
        case .months: return getThisMonthInterval()
        case .allTime: return getIntervalForAllTime()
        }
    }
    
    private func getTodayInterval() -> DateInterval {
        return getIntervalForDateComponent(.day)
    }
    
    private func getThisWeekInterval() -> DateInterval {
        return getIntervalForDateComponent(.weekOfYear)
    }
    
    private func getThisMonthInterval() -> DateInterval {
        return getIntervalForDateComponent(.month)
    }
    
    private func getIntervalForAllTime() -> DateInterval {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date()
        let interval = DateInterval(start: start, end: end)
        return interval
    }
    
    private func getIntervalForDateComponent(_ component: Calendar.Component) -> DateInterval {
        //Смещение на сентябрь, тк в апишке данные за сентябрь
        let date = RikApi.originDate
        
        let interval = Calendar.current.dateInterval(of: component, for: date) ?? DateInterval()
        return interval
    }

}
