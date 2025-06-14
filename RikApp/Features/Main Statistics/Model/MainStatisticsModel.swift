
import Foundation
import RikAPI
import UIKit
import RxSwift
import RxCocoa

public protocol MainStatisticsModel {
    func transform(input: ModelStatisticInput) -> ModelStatisticOutput
}

public struct ModelStatisticInput {
    var fetchViewsForLastMonth: Observable<Void>
    var fetchViewsForDateIntervals: Observable<DateIntervalForVisitors>
    var fetchTopUsers: Observable<Int>
    var fetchSexStatistics: Observable<DateInterval>
    var fetchAgeStatistics: Observable<([Range<Int>], DateInterval)>
    var fetchNewSubscribers: Observable<DateInterval>
    var fetchLeavedSubscribers: Observable<DateInterval>
    var fetchRefresh: Observable<Void>
    
    static var empty: ModelStatisticInput {
        return ModelStatisticInput(
            fetchViewsForLastMonth: BehaviorSubject<Void>(value: ()),
            fetchViewsForDateIntervals: BehaviorSubject<DateIntervalForVisitors>(value: .days),
            fetchTopUsers: BehaviorSubject<Int>(value: 0),
            fetchSexStatistics: BehaviorSubject(value: DateInterval()),
            fetchAgeStatistics: BehaviorSubject(value: ([], DateInterval())),
            fetchNewSubscribers: BehaviorSubject<DateInterval>(value: DateInterval()),
            fetchLeavedSubscribers: BehaviorSubject<DateInterval>(value: DateInterval()),
            fetchRefresh: Observable<Void>.empty()
        )
    }

}

public struct ModelStatisticOutput {
    var viewsForLastMonth: BehaviorRelay<Int>
    var viewsForDateIntervals: BehaviorRelay<[ViewsForDateIntervalStatistic]>
    var topUsers: BehaviorRelay<[StatisticUser]>
    var sexStatistics: BehaviorRelay<SexStatistic>
    var ageStatistics: BehaviorRelay<[SexAndAgeStatistic]>
    var newSubscribers: BehaviorRelay<Int>
    var leavedSubscribers: BehaviorRelay<Int>
    var refreshDone: BehaviorRelay<Void>
    
    static var empty: ModelStatisticOutput {
        return ModelStatisticOutput(
            viewsForLastMonth: BehaviorRelay(value: 0),
            viewsForDateIntervals: BehaviorRelay(value: []),
            topUsers: BehaviorRelay(value: []),
            sexStatistics: BehaviorRelay(value: SexStatistic(man: 0, woman: 0)),
            ageStatistics: BehaviorRelay(value: []),
            newSubscribers: BehaviorRelay(value: 0),
            leavedSubscribers: BehaviorRelay(value: 0),
            refreshDone: BehaviorRelay(value: ())
            )
    }
}

public struct StatisticUser: Equatable {
    public var name: String
    public var isOnline: Bool
    public var age: Int
    public var image: UIImage?
}

public struct SexStatistic: Equatable  {
    var man: Int
    var woman: Int
}

public struct SexAndAgeStatistic: Equatable  {
    var age: Range<Int>
    var man: Int
    var woman: Int
}

public struct ViewsForDateIntervalStatistic: Equatable  {
    var numericInterval: String
    var compactInterval: String
    var views: Int
}
