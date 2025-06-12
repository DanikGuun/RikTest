
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
    var fetchViewsForDateIntervals: Observable<[DateInterval]>
    var fetchTopUsers: Observable<Int>
    var fetchSexStatistics: Observable<DateInterval>
    var fetchAgeStatistics: Observable<([Range<Int>], DateInterval)>
    var fetchNewSubscribers: Observable<DateInterval>
    var fetchLeavedSubscribers: Observable<DateInterval>
    var fetchRefresh: Observable<Void>
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
    var interval: DateInterval
    var views: Int
}
