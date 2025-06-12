
import Foundation

public protocol StatisticsAPI {
    func getViewsCount(dateInterval: DateInterval) async -> Int
    func getMostInterestedUsers(count: Int, dateInterval: DateInterval) async -> [User]
    func loadImageData(stringURL: String) async -> Data?
    func getSexStatistic(dateInterval: DateInterval) async -> SexStatistic
    func getSexAndAgeStatistic(ages: [Range<Int>], dateInterval: DateInterval) async -> [SexAndAgeStatistic]
    func getNewSubscribers(interval: DateInterval) async -> [User]
    func getLeavedSubscribers(interval: DateInterval) async -> [User]
    func refresh() async
}
