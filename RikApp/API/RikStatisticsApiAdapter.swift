
import RikAPI
import Foundation

final public class RikStatisticsApiAdapter: StatisticsAPI {
    
    let api: RikApi
    
    init(api: RikApi) {
        self.api = api
    }
    
    public func getViewsCount(dateInterval: DateInterval) async -> Int {
        return await api.getViewsCount(dateInterval: dateInterval)
    }
    
    public func getMostInterestedUsers(count: Int, dateInterval: DateInterval) async -> [User] {
        let rikUsers = await api.getMostInterestedUsers(count: count, dateInterval: dateInterval)
        let users = rikUsers.map { castRikUserToUser($0) }
        return users
    }
    
    private func castRikUserToUser(_ rikUser: RikUser) -> User {
        let files = rikUser.files.map {  UserFile(id: $0.id, type: $0.type.userFileType, urlString: $0.urlString) }
        let user = User(id: rikUser.id, sex: rikUser.sex.userSex, name: rikUser.name, isOnline: rikUser.isOnline, age: rikUser.age, files: files)
        return user
    }
    
    public func loadImageData(stringURL: String) async -> Data? {
        return await api.loadImageData(stringURL: stringURL)
    }
    
    public func getSexStatistic(dateInterval: DateInterval) async -> SexStatistic {
        let rikStatistic = await api.getSexStatistic(ages: [0..<1000], dateInterval: dateInterval).first
        let statistic = SexStatistic(man: rikStatistic?.maleCount ?? 0, woman: rikStatistic?.femaleCount ?? 0)
        return statistic
    }
    
    public func getSexAndAgeStatistic(ages: [Range<Int>], dateInterval: DateInterval) async -> [SexAndAgeStatistic] {
        let rikStatistics = await api.getSexStatistic(ages: ages, dateInterval: dateInterval)
        let statistic = rikStatistics.map { SexAndAgeStatistic(age: $0.range, man: $0.maleCount, woman: $0.femaleCount) }
        return statistic
    }
    
    public func getNewSubscribers(interval: DateInterval) async -> [User] {
        let rikUsers = await api.getNewSubscribers(interval: interval)
        let users = rikUsers.map { castRikUserToUser($0) }
        return users
    }
    
    public func getLeavedSubscribers(interval: DateInterval) async -> [User] {
        let rikUsers = await api.getLeavedSubscribers(interval: interval)
        let users = rikUsers.map { castRikUserToUser($0) }
        return users
    }
    
    public func refresh() async {
        await api.refresh()
    }
    
    
}

fileprivate extension RikUserFile.RikFileType {
    var userFileType: UserFile.FileType {
        switch self {
        case .avatar:
            return .avatar
        }
    }
}

fileprivate extension RikSex {
    var userSex: UserSex {
        switch self {
        case .male:
            return .male
        case .female:
            return .female
        }
    }
}
