
import UIKit
import RikAPI
import RxSwift
import RxCocoa
import Foundation

public class BaseMainStatisticModel: MainStatisticsModel {
    
    let api: StatisticsAPI
    let disposeBag = DisposeBag()
    
    private var output: ModelStatisticOutput?
    private var lastInputValues = LastInputValues() //чтобы послать события с теми же значениями при обновлении в refresh()
    
    init(api: StatisticsAPI) {
        self.api = api
    }
    
    //MARK: - Rx
    public func transform(input: ModelStatisticInput) -> ModelStatisticOutput {
        let viewsCount = getViewsCountRelay(input: input.fetchViewsForLastMonth)
        let viewsByDate = getViewsByDateRelay(input: input.fetchViewsForDateIntervals)
        let topUsers = getTopUsersRelay(input: input.fetchTopUsers)
        let sexStatistics = getSexStatisticRelay(input: input.fetchSexStatistics)
        let ageStatistic = getAgeStatisticRelay(input: input.fetchAgeStatistics)
        let newSubscribers = getNewSubscribersRelay(input: input.fetchNewSubscribers)
        let leavedSubscribers = getLeavedSubscribersRelay(input: input.fetchLeavedSubscribers)
        let refresh = getRefresh(input: input.fetchRefresh)
        let output = ModelStatisticOutput(
            viewsForLastMonth: viewsCount,
            viewsForDateIntervals: viewsByDate,
            topUsers: topUsers,
            sexStatistics: sexStatistics,
            ageStatistics: ageStatistic,
            newSubscribers: newSubscribers,
            leavedSubscribers: leavedSubscribers,
            refreshDone: refresh
        )
        self.output = output
        return output
    }
    
    private func getViewsCountRelay(input: Observable<Void>) -> BehaviorRelay<Int> {
        let output = BehaviorRelay(value: 0)
        input.subscribe(onNext: { [weak self] in
            Task {
                await self?.emitViewsCountForLastMonth()
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitViewsCountForLastMonth() async {
        let interval = Calendar.current.dateInterval(of: .month, for: Date()) ?? DateInterval()
        let count = await api.getViewsCount(dateInterval: interval)
        output?.viewsForLastMonth.accept(count)
    }
    
    private func getViewsByDateRelay(input: Observable<DateIntervalForVisitors>) -> BehaviorRelay<[ViewsForDateIntervalStatistic]> {
        let output = BehaviorRelay<[ViewsForDateIntervalStatistic]>(value: [])
        input.subscribe(onNext: { [weak self] intervalType in
            Task {
                await self?.emitViewsByDate(intervalType: intervalType)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitViewsByDate(intervalType: DateIntervalForVisitors) async {
        var items: [ViewsForDateIntervalStatistic] = []
        for interval in intervalType.intervals.sorted { $0.start < $1.start } {
            let count = await api.getViewsCount(dateInterval: interval)
            let numeric = intervalType.numericFormatted(interval)
            let compact = intervalType.textFormatted(interval)
            items.append(ViewsForDateIntervalStatistic(numericInterval: numeric, compactInterval: compact, views: count))
        }
        output?.viewsForDateIntervals.accept(items)
        lastInputValues.viewsForDateIntervals = intervalType
    }
    
    private func getTopUsersRelay(input: Observable<Int>) -> BehaviorRelay<[StatisticUser]> {
        let output = BehaviorRelay<[StatisticUser]>(value: [])
        input.subscribe(onNext: { [weak self] count in
            Task {
                await self?.emitTopUsersRelay(count: count)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitTopUsersRelay(count: Int) async {
        let interval = Calendar.current.dateInterval(of: .year, for: RikApi.originDate) ?? DateInterval()
        let users = await api.getMostInterestedUsers(count: count, dateInterval: interval)
        let statisticUsers = await castUsersToStatisticUsers(users)
        output?.topUsers.accept(statisticUsers)
        lastInputValues.topUsers = count
    }

    private func castUsersToStatisticUsers(_ users: [User]) async -> [StatisticUser] {
        var statisticUsers: [StatisticUser] = []
        for user in users {
            let imageURL = user.files.first(where: {$0.type == .avatar})?.urlString ?? ""
            let imageData = await api.loadImageData(stringURL: imageURL) ?? Data()
            let image = UIImage(data: imageData)
            let statisticUser = StatisticUser(name: user.name, isOnline: user.isOnline, age: user.age, image: image)
            statisticUsers.append(statisticUser)
        }
        return statisticUsers
    }
    
    private func getSexStatisticRelay(input: Observable<DateInterval>) -> BehaviorRelay<SexStatistic> {
        let output = BehaviorRelay(value: SexStatistic(man: 0, woman: 0))
        input.subscribe(onNext: { [weak self] interval in
            Task {
                await self?.emitSexStatistic(interval: interval)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitSexStatistic(interval: DateInterval) async {
        let statistic = await api.getSexStatistic(dateInterval: interval)
        output?.sexStatistics.accept(statistic)
        lastInputValues.sexStatistics = interval
    }
    
    private func getAgeStatisticRelay(input: Observable<([Range<Int>], DateInterval)>) -> BehaviorRelay<[SexAndAgeStatistic]> {
        let output = BehaviorRelay<[SexAndAgeStatistic]>(value: [])
        input.subscribe(onNext: { [weak self] (ages, interval) in
            Task {
                await self?.emitAgeStatistic(ages: ages, interval: interval)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitAgeStatistic(ages: [Range<Int>], interval: DateInterval) async {
        let statistics = await api.getSexAndAgeStatistic(ages: ages, dateInterval: interval)
        output?.ageStatistics.accept(statistics)
        lastInputValues.ageStatistics = (ages, interval)
    }
    
    private func getNewSubscribersRelay(input: Observable<DateInterval>) -> BehaviorRelay<Int> {
        let output = BehaviorRelay(value: 0)
        input.subscribe(onNext: { [weak self] interval in
            Task {
                await self?.emitNewSubscribers(interval: interval)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitNewSubscribers(interval: DateInterval) async {
        let newSubscribers = await api.getNewSubscribers(interval: interval).count
        output?.newSubscribers.accept(newSubscribers)
        lastInputValues.newSubscribers = interval
    }
    
    private func getLeavedSubscribersRelay(input: Observable<DateInterval>) -> BehaviorRelay<Int> {
        let output = BehaviorRelay(value: 0)
        input.subscribe(onNext: { [weak self] interval in
            Task {
                await self?.emitLeavedSubscribers(interval: interval)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitLeavedSubscribers(interval: DateInterval) async {
        let leavedSubscribers = await api.getLeavedSubscribers(interval: interval).count
        output?.leavedSubscribers.accept(leavedSubscribers)
        lastInputValues.leavedSubscribers = interval
    }
    
    private func getRefresh(input: Observable<Void>) -> BehaviorRelay<Void> {
        let output = BehaviorRelay(value: ())
        input.subscribe(onNext: { [weak self] in
            guard let self else { return }
            Task {
                await self.api.refresh()
                await self.emitViewsCountForLastMonth()
                await self.emitViewsByDate(intervalType: self.lastInputValues.viewsForDateIntervals)
                await self.emitTopUsersRelay(count: self.lastInputValues.topUsers)
                await self.emitSexStatistic(interval: self.lastInputValues.sexStatistics)
                await self.emitAgeStatistic(ages: self.lastInputValues.ageStatistics.0, interval: self.lastInputValues.ageStatistics.1)
                await self.emitNewSubscribers(interval: self.lastInputValues.newSubscribers)
                await self.emitLeavedSubscribers(interval: self.lastInputValues.leavedSubscribers)
                output.accept(())
            }
        })
        .disposed(by: disposeBag)
        return output
    }
}

fileprivate struct LastInputValues {
    var viewsForDateIntervals: DateIntervalForVisitors = .days
    var topUsers: Int = 0
    var sexStatistics: DateInterval = DateInterval()
    var ageStatistics: ([Range<Int>], DateInterval) = ([], DateInterval())
    var newSubscribers: DateInterval = DateInterval()
    var leavedSubscribers: DateInterval = DateInterval()
}
