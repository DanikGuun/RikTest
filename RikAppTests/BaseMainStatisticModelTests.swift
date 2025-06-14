

import XCTest
import RxTest
import RxSwift
import RxBlocking

@testable import RikApp

final class BaseMainStatisticModelTests: XCTestCase {
    
    var model: BaseMainStatisticModel!
    var mockApi: MockApi!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        mockApi = MockApi()
        model = BaseMainStatisticModel(api: mockApi)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        super.setUp()
    }
    
    override func tearDown() {
        mockApi = nil
        model = nil
        scheduler = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func testViewsForLastMonth() {
        let exp = expectation(description: "ViewsForLastMonth")
        let views = 10
        let lastMonthInterval = Calendar.current.dateInterval(of: .month, for: Date())
        mockApi.viewsForDateIntervals = Dictionary<DateInterval?, Int>(uniqueKeysWithValues: [(lastMonthInterval, views)])
        
        let observer = scheduler.createObserver(Int.self)
        let mockInputStream = scheduler.createColdObservable<Void>([.next(10, ())])
        var input = ModelStatisticInput.empty
        input.fetchViewsForLastMonth = mockInputStream.asObservable()
        
        let output = model.transform(input: input).viewsForLastMonth
        output
            .do(onNext: {val in if val == views { exp.fulfill() } })
            .subscribe(observer).disposed(by: disposeBag)
        
        scheduler.start()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(observer.events, [.next(0, 0), .next(10, views)])
    }
    
    func testViewsForDateIntervals() {
        let exp = expectation(description: "ViewForDateIntreval")
        let interval1 = DateInterval(start: Date(), end: Date().addingTimeInterval(100))
        let interval2 = DateInterval(start: Date().addingTimeInterval(100), end: Date().addingTimeInterval(200))
        let views1 = 10
        let views2 = 20
        mockApi.viewsForDateIntervals = Dictionary<DateInterval?, Int>(uniqueKeysWithValues: [(interval1, views1), (interval2, views2)])
        
        let observer = scheduler.createObserver([ViewsForDateIntervalStatistic].self)
        let mockInput = scheduler.createColdObservable([.next(10, [interval1, interval2])])
        var input = ModelStatisticInput.empty
        input.fetchViewsForDateIntervals = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.viewsForDateIntervals
            .do(onNext: { arr in if arr.isEmpty == false { exp.fulfill() } })
            .subscribe(observer)
            .disposed(by: disposeBag)

        scheduler.start()
        
        wait(for: [exp], timeout: 1)
        let stat1 = ViewsForDateIntervalStatistic(interval: interval1, views: views1)
        let stat2 = ViewsForDateIntervalStatistic(interval: interval2, views: views2)
        XCTAssertEqual(observer.events, [.next(0, []), .next(10, [stat1, stat2])])
    }
    
    func testTopUsers() {
        let exp = expectation(description: "TopUsers")
        
        let users: [User] = [
            User(name: "Tanya", isOnline: true, age: 9),
            User(name: "Egorf", isOnline: false, age: 1),
            User(name: "Zahar", isOnline: false, age: 5)
        ]
        mockApi.topUsers = users
        let expectedUsers = users.map { $0.statisticUser }
        
        let observer = scheduler.createObserver([StatisticUser].self)
        let mockInput = scheduler.createColdObservable([.next(10, 3)])
        var input = ModelStatisticInput.empty
        input.fetchTopUsers = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.topUsers
            .do(onNext: { users in if users.isEmpty == false { exp.fulfill() } })
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(observer.events, [.next(0, []), .next(10, expectedUsers)])
    }
    
    func testSexStatistic() {
        let exp = expectation(description: "SexStatistics")
        
        let statistic = SexStatistic(man: 10, woman: 9)
        mockApi.sexStatistic = statistic
        
        let observer = scheduler.createObserver(SexStatistic.self)
        let mockInput = scheduler.createColdObservable([.next(10, DateInterval())])
        var input = ModelStatisticInput.empty
        input.fetchSexStatistics = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.sexStatistics
            .do(onNext: { statistic in if statistic.woman != 0 && statistic.woman != 0 { exp.fulfill() } })
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(observer.events, [.next(0, SexStatistic(man: 0, woman: 0)), .next(10, statistic)])
    }
    
    func testAgeStatistic() {
        let exp = expectation(description: "AgeStatistics")
        let statistics = [
            SexAndAgeStatistic(age: 0..<18, man: 9, woman: 15),
            SexAndAgeStatistic(age: 18..<25, man: 15, woman: 5),
            SexAndAgeStatistic(age: 25..<100, man: 0, woman: 15)
        ]
        mockApi.sexAndAgeStatistic = statistics
        
        let observer = scheduler.createObserver([SexAndAgeStatistic].self)
        let mockInput = scheduler.createColdObservable([.next(10, ([0..<18, 18..<25, 25..<100], DateInterval()))])
        var input = ModelStatisticInput.empty
        input.fetchAgeStatistics = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.ageStatistics
            .do(onNext: { arr in if !arr.isEmpty { exp.fulfill() } })
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(observer.events, [.next(0, []), .next(10, statistics)])
    }
    
    func testNewSubscribers() {
        let exp = expectation(description: "NewSubscribers")
        let newSubscribers = 15
        mockApi.newSubscribers = newSubscribers
        
        let observer = scheduler.createObserver(Int.self)
        let mockInput = scheduler.createColdObservable([.next(10, (DateInterval()))])
        var input = ModelStatisticInput.empty
        input.fetchNewSubscribers = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.newSubscribers
            .do(onNext: { val in if val != 0 { exp.fulfill() } })
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(observer.events, [.next(0, 0), .next(10, newSubscribers)])
    }
    
    func testLeavedSubscribers() {
        let exp = expectation(description: "LeavedSubscribers")
        let leavedSubscribers = 15
        mockApi.leavedSubscribers = leavedSubscribers
        
        let observer = scheduler.createObserver(Int.self)
        let mockInput = scheduler.createColdObservable([.next(10, DateInterval())])
        var input = ModelStatisticInput.empty
        input.fetchLeavedSubscribers = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.leavedSubscribers
            .do(onNext: { val in if val != 0 { exp.fulfill() } })
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(observer.events, [.next(0, 0), .next(10, leavedSubscribers)])
    }
    
    func testRefresh() {
        let exp = expectation(description: "Refresh")
        exp.expectedFulfillmentCount = 2
        
        let viewsCountForMonthObserver = scheduler.createObserver(Int.self)
        let viewCountForDateIntrevalObserver = scheduler.createObserver([ViewsForDateIntervalStatistic].self)
        let topUsersObserver = scheduler.createObserver([StatisticUser].self)
        let sexStatisticObserver = scheduler.createObserver(SexStatistic.self)
        let ageStatisticObserver = scheduler.createObserver([SexAndAgeStatistic].self)
        let newSubscribersObserver = scheduler.createObserver(Int.self)
        let leavedSubscribers = scheduler.createObserver(Int.self)
        
        let mockInput = scheduler.createColdObservable([.next(10, ())])
        var input = ModelStatisticInput.empty
        input.fetchRefresh = mockInput.asObservable()
        
        let output = model.transform(input: input)
        output.viewsForLastMonth.subscribe(viewsCountForMonthObserver).disposed(by: disposeBag)
        output.viewsForDateIntervals.subscribe(viewCountForDateIntrevalObserver).disposed(by: disposeBag)
        output.topUsers.subscribe(topUsersObserver).disposed(by: disposeBag)
        output.sexStatistics.subscribe(sexStatisticObserver).disposed(by: disposeBag)
        output.ageStatistics.subscribe(ageStatisticObserver).disposed(by: disposeBag)
        output.newSubscribers.subscribe(newSubscribersObserver).disposed(by: disposeBag)
        output.leavedSubscribers.subscribe(leavedSubscribers).disposed(by: disposeBag)
        
        output.refreshDone
            .subscribe(onNext: { exp.fulfill() })
            .disposed(by: disposeBag)
        
        scheduler.start()
        wait(for: [exp], timeout: 1)
        
        XCTAssertTrue(mockApi.isRefreshed)
        XCTAssertEqual(viewsCountForMonthObserver.events.count, 2)
        XCTAssertEqual(viewCountForDateIntrevalObserver.events.count, 2)
        XCTAssertEqual(topUsersObserver.events.count, 2)
        XCTAssertEqual(sexStatisticObserver.events.count, 2)
        XCTAssertEqual(ageStatisticObserver.events.count, 2)
        XCTAssertEqual(newSubscribersObserver.events.count, 2)
        XCTAssertEqual(leavedSubscribers.events.count, 2)
    }
    
}

extension User {
    var statisticUser: StatisticUser {
        return StatisticUser(name: name, isOnline: isOnline, age: age)
    }
}

class MockApi: StatisticsAPI {
    
    var viewsForDateIntervals: [DateInterval?: Int] = [:]
    var topUsers: [User] = []
    var sexStatistic = SexStatistic(man: 0, woman: 0)
    var sexAndAgeStatistic: [SexAndAgeStatistic] = []
    var newSubscribers = 0
    var leavedSubscribers = 0
    var isRefreshed = false
    
    func getViewsCount(dateInterval: DateInterval) async -> Int {
        return viewsForDateIntervals[dateInterval] ?? -1
    }
    
    func getMostInterestedUsers(count: Int, dateInterval: DateInterval) async -> [User] {
        return topUsers
    }
    
    func loadImageData(stringURL: String) async -> Data? {
        return nil
    }
    
    func getSexStatistic(dateInterval: DateInterval) async -> SexStatistic {
        return sexStatistic
    }
    
    func getSexAndAgeStatistic(ages: [Range<Int>], dateInterval: DateInterval) async -> [SexAndAgeStatistic] {
        return sexAndAgeStatistic
    }
    
    func getNewSubscribers(interval: DateInterval) async -> [User] {
        return Array(repeating: User(), count: newSubscribers)
    }
    
    func getLeavedSubscribers(interval: DateInterval) async -> [User] {
        return Array(repeating: User(), count: leavedSubscribers)
    }
    
    func refresh() async {
        isRefreshed = true
    }
    
}
