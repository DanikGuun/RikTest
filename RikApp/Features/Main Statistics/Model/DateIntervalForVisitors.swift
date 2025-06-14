
import Foundation
import RikAPI

public enum DateIntervalForVisitors {
    case days
    case weeks
    case months
    
    static let allCases: [DateIntervalForVisitors] = [.days, .weeks, .months]
    
    var title: String {
        switch self {
        case .days: "По дням"
        case .weeks: "По неделям"
        case .months: "По месяцам"
        }
    }
    
    var intervals: [DateInterval] {
        switch self {
        case .days: return getIntervalsForDayVisitors()
        case .weeks: return getIntervalsForWeekVisitors()
        case .months: return getIntervalsForMonthVisitors()
        }
    }
    
    private func getIntervalsForDayVisitors() -> [DateInterval] {
        return getIntervalsForDateComponent(.day, count: 7)
    }
    
    private func getIntervalsForWeekVisitors() -> [DateInterval] {
        return getIntervalsForDateComponent(.weekOfYear, count: 4)
    }
    
    private func getIntervalsForMonthVisitors() -> [DateInterval] {
        return getIntervalsForDateComponent(.month, count: 6)
    }
    
    private func getIntervalsForDateComponent(_ component: Calendar.Component, count: Int) -> [DateInterval] {
        var intervals: [DateInterval] = []
        //Смещение на сентябрь, тк в апишке данные за сентябрь
        let date = RikApi.originDate
        
        for offset in 0..<count {
            let date = Calendar.current.date(byAdding: component, value: -offset, to: date) ?? Date()
            let interval = Calendar.current.dateInterval(of: component, for: date) ?? DateInterval()
            intervals.append(interval)
        }
        return intervals
    }
    
    private var numericFormat: String {
        switch self {
        case .days: return "dd.MM"
        case .weeks: return "dd.MMM"
        case .months: return "MM.yy"
        }
    }
    
    private var textFormat: String {
        switch self {
        case .days: return "d MMMM"
        case .weeks: return "d MMMM"
        case .months: return "MMMM yyyy"
        }
    }
    
    func numericFormatted(_ interval: DateInterval) -> String {
        switch self {
        case .days: formattedDate(interval.start, format: self.numericFormat)
        case .weeks: formattedInterval(interval, format: self.numericFormat)
        case .months: formattedDate(interval.start, format: self.numericFormat)
        }
    }
    
    func textFormatted(_ interval: DateInterval) -> String {
        switch self {
        case .days: formattedDate(interval.start, format: self.textFormat)
        case .weeks: formattedInterval(interval, format: self.textFormat)
        case .months: formattedDate(interval.start, format: self.textFormat)
        }
    }
    
    private func formattedDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        let systemLanguage = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: systemLanguage)
        formatter.locale = locale
        
        let string = formatter.string(from: date)
        return string
    }
    
    private func formattedInterval(_ interval: DateInterval, format: String) -> String {
        let formatter = DateIntervalFormatter()
        formatter.locale = Locale.current
        formatter.dateTemplate = format
        
        let systemLanguage = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: systemLanguage)
        formatter.locale = locale
        
        let string = formatter.string(from: interval)
        return string ?? "None"
    }
}
