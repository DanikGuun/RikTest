
import UIKit
import RxSwift
import RxCocoa
import Foundation

public class BaseMainStatisticModel: MainStatisticsModel {
    
    let api: StatisticsAPI
    let disposeBag = DisposeBag()
    
    private var output: ModelStatisticOutput?
    private var lastValues = LastEmittedValues() //чтобы послать события с теми же значениями при обновлении в refresh()
    
    init(api: StatisticsAPI) {
        self.api = api
    }
    
    public func transform(input: ModelStatisticInput) -> ModelStatisticOutput {
        let viewsCount = getViewsCount(input: input.fetchViewsForLastMonth)
        let viewsByDate = getViewsByDate(input: input.fetchViewsForDateIntervals)
        let topUsers = getTopUsers(input: input.fetchTopUsers)
        let sexStatistics = getSexStatistic(input: input.fetchSexStatistics)
        let ageStatistic = getAgeStatistic(input: input.fetchAgeStatistics)
        let newSubscribers = getNewSubscribers(input: input.fetchNewSubscribers)
        let leavedSubscribers = getLeavedSubscribers(input: input.fetchLeavedSubscribers)
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
    
    private func getViewsCount(input: Observable<Void>) -> BehaviorRelay<Int> {
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
    
    private func getViewsByDate(input: Observable<[DateInterval]>) -> BehaviorRelay<[ViewsForDateIntervalStatistic]> {
        let output = BehaviorRelay<[ViewsForDateIntervalStatistic]>(value: [])
        input.subscribe(onNext: { [weak self] intervals in
            Task {
                await self?.emitViewsByDate(intervals: intervals)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitViewsByDate(intervals: [DateInterval]) async {
        var items: [ViewsForDateIntervalStatistic] = []
        for interval in intervals {
            let count = await api.getViewsCount(dateInterval: interval)
            items.append(ViewsForDateIntervalStatistic(interval: interval, views: count))
        }
        output?.viewsForDateIntervals.accept(items)
        lastValues.viewsForDateIntervals = intervals
    }
    
    private func getTopUsers(input: Observable<Int>) -> BehaviorRelay<[StatisticUser]> {
        let output = BehaviorRelay<[StatisticUser]>(value: [])
        input.subscribe(onNext: { [weak self] count in
            Task {
                await self?.emitTopUsers(count: count)
            }
        })
        .disposed(by: disposeBag)
        return output
    }
    
    private func emitTopUsers(count: Int) async {
        let interval = Calendar.current.dateInterval(of: .month, for: Date()) ?? DateInterval()
        let users = await api.getMostInterestedUsers(count: count, dateInterval: interval)
        let statisticUsers = await castUsersToStatisticUsers(users)
        output?.topUsers.accept(statisticUsers)
        lastValues.topUsers = count
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
    
    private func getSexStatistic(input: Observable<DateInterval>) -> BehaviorRelay<SexStatistic> {
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
        lastValues.sexStatistics = interval
    }
    
    private func getAgeStatistic(input: Observable<([Range<Int>], DateInterval)>) -> BehaviorRelay<[SexAndAgeStatistic]> {
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
        lastValues.ageStatistics = (ages, interval)
    }
    
    private func getNewSubscribers(input: Observable<DateInterval>) -> BehaviorRelay<Int> {
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
        lastValues.newSubscribers = interval
    }
    
    private func getLeavedSubscribers(input: Observable<DateInterval>) -> BehaviorRelay<Int> {
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
        lastValues.leavedSubscribers = interval
    }
    
    private func getRefresh(input: Observable<Void>) -> BehaviorRelay<Void> {
        let output = BehaviorRelay(value: ())
        input.subscribe(onNext: { [weak self] in
            guard let self else { return }
            Task {
                await self.api.refresh()
                await self.emitViewsCountForLastMonth()
                await self.emitViewsByDate(intervals: self.lastValues.viewsForDateIntervals)
                await self.emitTopUsers(count: self.lastValues.topUsers)
                await self.emitSexStatistic(interval: self.lastValues.sexStatistics)
                await self.emitAgeStatistic(ages: self.lastValues.ageStatistics.0, interval: self.lastValues.ageStatistics.1)
                await self.emitNewSubscribers(interval: self.lastValues.newSubscribers)
                await self.emitLeavedSubscribers(interval: self.lastValues.leavedSubscribers)
                output.accept(())
            }
        })
        .disposed(by: disposeBag)
        return output
    }
}

fileprivate struct LastEmittedValues {
    var viewsForDateIntervals: [DateInterval] = []
    var topUsers: Int = 0
    var sexStatistics: DateInterval = DateInterval()
    var ageStatistics: ([Range<Int>], DateInterval) = ([], DateInterval())
    var newSubscribers: DateInterval = DateInterval()
    var leavedSubscribers: DateInterval = DateInterval()
}
