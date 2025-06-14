
import UIKit
import RxSwift
import RxCocoa
import PinLayout

class MainStatisticsViewController: UIViewController, Coordinatable {
    
    var model: MainStatisticsModel!
    var coordinator: (any Coordinator)?
    
    let disposeBag = DisposeBag()
    private var fetchViewsForDatesRelay = BehaviorRelay<DateIntervalForVisitors>(value: .days)
    private var fetchSexStatisticsRelay = BehaviorRelay<DateInterval>(value: DateInterval.currentDay)
    private var fetchSexAndAgeStatisticsRelay = BehaviorRelay<([Range<Int>], DateInterval)>(value: (DateIntervalForSexAndAge.days.ages, DateInterval.currentDay))
    private var refreshRelay = PublishRelay<Void>()
    
    private var mainStackView = UIStackView()
    private let refreshControl = UIRefreshControl()
    private let monthVisitorsVolumeView = VolumeChangeView()
    private let graphView = GraphicView()
    private var topUsersDashStackView = UIStackView()
    private let sexStatisticView = SexStatisticsView()
    private var sexAndAgeStatisticStackView = UIStackView()
    private let newSubscribersVolumeView = VolumeChangeView()
    private let leavedSubscribersVolumeView = VolumeChangeView()
    
    convenience init(model: MainStatisticsModel) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setup()
    }
    
    private func setup() {
        self.navigationItem.title = "Статистика"
        setupMainStackView()
        setupVisitorsSection()
        addSpaceView(height: DC.interSectionSpacing)
        setupTopVisitorsSection()
        addSpaceView(height: DC.interSectionSpacing)
        setupSexAndAgeStatisticsSection()
        addSpaceView(height: DC.interSectionSpacing)
        setupViewersVolumeSection()
        setupBindings()
    }
    
    private func setupMainStackView() {
        //Scroll
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.showsVerticalScrollIndicator = false
        //Stack
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        
        mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        mainStackView.distribution = .equalSpacing
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: DC.standartMargin, bottom: 30, right: DC.standartMargin)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        
        scrollView.addSubview(refreshControl)
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        refreshControl.addAction(UIAction(handler: { [weak self] _ in
            if self?.refreshControl.isRefreshing ?? false {
                self?.refreshRelay.accept(())
            }
        }), for: .valueChanged)
    }
    
    //MARK: - Visitors section
    private func setupVisitorsSection() {
        addTitle("Посетители")
        setupVisitorsVolume()
        addSpaceView(height: 10)
        setupVisitorsDateIntervalPicker()
        setupVisitorsGraphView()
    }
    
    private func setupVisitorsVolume() {
        monthVisitorsVolumeView.heightAnchor.constraint(equalToConstant: 98).isActive = true
        monthVisitorsVolumeView.item = VolumeChangeItem(type: .increase, value: 150)

        addViewsAsStack(monthVisitorsVolumeView)
    }
    
    private func setupVisitorsDateIntervalPicker() {
        let picker = ActionsLineView()
        picker.spacing = 0
        DateIntervalForVisitors.allCases.forEach { interval in
            picker.addAction(title: interval.title, action: { [weak self] in
                self?.fetchViewsForDatesRelay.accept(interval)
            })
        }
        picker.selectAction(index: 0)
        
        mainStackView.addArrangedSubview(picker)
    }
    
    private func setupVisitorsGraphView() {
        graphView.heightAnchor.constraint(equalToConstant: 208).isActive = true
        graphView.backgroundColor = .systemBackground
        graphView.insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        graphView.backgroundLineWidth = 1

        addViewsAsStack(graphView)
    }
    
    //MARK: - Top Users sectoin
    private func setupTopVisitorsSection() {
        addTitle("Чаще всех посещают ваш профиль")
        setupTopVisitorsDash()
    }
    
    private func setupTopVisitorsDash() {
        topUsersDashStackView = addViewsAsStack([])
    }
    
    private func setTopUsers(_ items: [UserPanelItem]) {
        topUsersDashStackView.arrangedSubviews.forEach { topUsersDashStackView.removeArrangedSubview($0) }
        var viewsToAdd: [UIView] = []
        
        for (index, item) in items.enumerated() {
            let userView = UserPlanelView()
            userView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            userView.backgroundColor = .systemBackground
            userView.item = item
            viewsToAdd.append(userView)
            
            if index < items.count - 1 {
                userView.addSeparator(type: .fractional(0.8))
            }
        }
        viewsToAdd.forEach { topUsersDashStackView.addArrangedSubview($0) }
    }
    
    //MARK: - Sex and Age Statitics Section
    private func setupSexAndAgeStatisticsSection() {
        addTitle("Пол и возраст")
        setupSexAndAgeIntervalPicker()
        setupSexAndAgeStatistics()
    }
    
    private func setupSexAndAgeIntervalPicker() {
        let picker = ActionsLineView()
        picker.spacing = 0
        DateIntervalForSexAndAge.allCases.forEach { [weak self] interval in
            guard let self else { return }
            picker.addAction(title: interval.title, action: {
                self.fetchSexStatisticsRelay.accept(interval.interval)
                self.fetchSexAndAgeStatisticsRelay.accept((interval.ages, interval.interval))
            })
        }
        picker.selectAction(index: 0)
        
        mainStackView.addArrangedSubview(picker)
    }
    
    private func setupSexAndAgeStatistics() {
        let sex = getSexStatisticsView()
        sex.addSeparator(type: .full)
        sexAndAgeStatisticStackView = addViewsAsStack(sex)
    }
    
    private func getSexStatisticsView() -> UIView {
        sexStatisticView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        sexStatisticView.item = SexStatisticsItem(man: 5, woman: 19)
        return sexStatisticView
    }
    
    private func setSexAndAgeStatisticsBars(_ items: [SexAndAgeStatistic]) {
        sexAndAgeStatisticStackView.arrangedSubviews.forEach { view in
            if view != sexStatisticView { sexAndAgeStatisticStackView.removeArrangedSubview(view) }
        }
        
        for item in items {
            let chart = DoubleBarChart()
            chart.heightAnchor.constraint(equalToConstant: 50).isActive = true
            let dMan = Double(item.man)
            let dWoman = Double(item.woman)
            let totalCount = max(dMan + dWoman, 1.0)
            let manPercentage =  (dMan/totalCount).formatted(.percent.precision(.significantDigits(2)))
            let womanPercentage = (dWoman/totalCount).formatted(.percent.precision(.significantDigits(2)))
            let manItem = DoubleBarItem(title: manPercentage, color: .manStatistic, percentage: Double(dMan/totalCount))
            let womanItem = DoubleBarItem(title: womanPercentage, color: .womanStatistics, percentage: Double(dWoman/totalCount))
            chart.item = DoubleBarChartItem(title: item.age.text, firstItem: manItem, secondItem: womanItem)
            sexAndAgeStatisticStackView.addArrangedSubview(chart)
        }
    }
    
    //MARK: - Viewers volume section
    private func setupViewersVolumeSection() {
        addTitle("Наблюдатели")
        let newViewersVolume = getNewSubscribersVolumeView()
        newViewersVolume.addSeparator(type: .full)
        let leavedViewersVolume = getLeavedSubscribersVolumeView()
        addViewsAsStack(newViewersVolume, leavedViewersVolume)
    }
    
    private func getNewSubscribersVolumeView() -> UIView {
        
        newSubscribersVolumeView.heightAnchor.constraint(equalToConstant: 98).isActive = true
        newSubscribersVolumeView.item = VolumeChangeItem(type: .increase, value: 156)
        return newSubscribersVolumeView
    }
    
    private func getLeavedSubscribersVolumeView() -> UIView {
        leavedSubscribersVolumeView.heightAnchor.constraint(equalToConstant: 98).isActive = true
        leavedSubscribersVolumeView.item = VolumeChangeItem(type: .decrease, value: 6)
        return leavedSubscribersVolumeView
    }
    
    //MARK: - RXBinding
    private func setupBindings() {
        let input = getModelInput()
        let output = model.transform(input: input)
        bindOutputViewsForLastMonth(output.viewsForLastMonth)
        bindOutputViewsForDateIntervals(output.viewsForDateIntervals)
        bindOutputForTopUsers(output.topUsers)
        bindOutputForSexStatistics(output.sexStatistics)
        bindOutputForAgeStatistics(output.ageStatistics)
        bindOutputNewSubscribers(output.newSubscribers)
        bindOutputLeavedSubscribers(output.leavedSubscribers)
        bindOutputRefresh(output.refreshDone)
    }
    
    private func getModelInput() -> ModelStatisticInput{
        var modelInput = ModelStatisticInput.empty
        let monthInterval = Calendar.current.dateInterval(of: .month, for: Date()) ?? DateInterval()
        modelInput.fetchViewsForLastMonth = Observable.just(())
        modelInput.fetchViewsForDateIntervals = fetchViewsForDatesRelay.asObservable()
        modelInput.fetchTopUsers = Observable.just(3)
        modelInput.fetchSexStatistics = fetchSexStatisticsRelay.asObservable()
        modelInput.fetchAgeStatistics = fetchSexAndAgeStatisticsRelay.asObservable()
        modelInput.fetchNewSubscribers = Observable.just(monthInterval)
        modelInput.fetchLeavedSubscribers = Observable.just(monthInterval)
        modelInput.fetchRefresh = refreshRelay.asObservable()
        return modelInput
    }
    
    private func bindOutputViewsForLastMonth(_ output: BehaviorRelay<Int>) {
        output
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                let type: VolumeChangeItem.ChangeType = value > 0 ? .increase : .decrease
                self?.monthVisitorsVolumeView.item = VolumeChangeItem(type: type, value: abs(value), subtitle: type.visitorsSubtitle)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputViewsForDateIntervals(_ output: BehaviorRelay<[ViewsForDateIntervalStatistic]>) {
        output
            .observe(on: MainScheduler.instance)
            .map { $0.map { [weak self] in
                GraphicItem(value: CGFloat($0.views), graphicTitle: $0.numericInterval, title: self?.getVisitorTitle(count: $0.views) ?? "", subtitle: $0.compactInterval)
            } }
            .subscribe(onNext: { [weak self] statistics in
                self?.graphView.items = statistics
            })
            .disposed(by: disposeBag)
    }
    
    private func getVisitorTitle(count: Int) -> String {
        var visitorsWord = "посетител"
        switch count % 10 {
        case 1: visitorsWord += "ь"
        case 2, 3, 4: visitorsWord += "я"
        default: visitorsWord += "ей"
        }
        return "\(count) \(visitorsWord)"
    }
    
    private func bindOutputForTopUsers(_ output: BehaviorRelay<[StatisticUser]>) {
        output
            .observe(on: MainScheduler.instance)
            .map { $0.map { UserPanelItem(name: "\($0.name), \($0.age)", image: $0.image, isOnline: $0.isOnline) } }
            .subscribe(onNext: { [weak self] users in
                self?.setTopUsers(users)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputForSexStatistics(_ output: BehaviorRelay<SexStatistic>) {
        output
            .observe(on: MainScheduler.instance)
            .map { SexStatisticsItem(man: $0.man, woman: $0.woman) }
            .subscribe(onNext: { [weak self] value in
                self?.sexStatisticView.item = value
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputForAgeStatistics(_ output: BehaviorRelay<[SexAndAgeStatistic]>) {
        output
            .observe(on: MainScheduler.instance)
            .map { $0.map { SexAndAgeStatistic(age: $0.age, man: $0.man, woman: $0.woman) } }
            .subscribe(onNext: { [weak self] statistic in
                self?.setSexAndAgeStatisticsBars(statistic)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputNewSubscribers(_ output: BehaviorRelay<Int>) {
        output
            .observe(on: MainScheduler.instance)
            .map { VolumeChangeItem(type: .increase, value: $0) }
            .subscribe(onNext: { [weak self] volume in
                self?.newSubscribersVolumeView.item = volume
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputLeavedSubscribers(_ output: BehaviorRelay<Int>) {
        output
            .observe(on: MainScheduler.instance)
            .map { VolumeChangeItem(type: .decrease, value: $0) }
            .subscribe(onNext: { [weak self] volume in
                self?.leavedSubscribersVolumeView.item = volume
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputRefresh(_ output: BehaviorRelay<Void>) {
        output
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Helpers
    @discardableResult private func addViewsAsStack(_ views: UIView...) -> UIStackView {
        let stack = getPatternStackView()
        views.forEach { stack.addArrangedSubview($0) }
        mainStackView.addArrangedSubview(stack)
        return stack
    }
    
    @discardableResult private func addViewsAsStack(_ views: [UIView]) -> UIStackView {
        let stack = getPatternStackView()
        views.forEach { stack.addArrangedSubview($0) }
        mainStackView.addArrangedSubview(stack)
        return stack
    }
    
    private func getPatternStackView(insets: UIEdgeInsets = .zero) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.backgroundColor = .systemBackground
        stack.layer.cornerRadius = DC.cornerRadius
        stack.clipsToBounds = true
        return stack
    }
    
    private func addTitle(_ string: String) {
        let label = UILabel()
        label.font = UIFont(name: "Gilroy-Bold", size: 20)
        label.text = string
        mainStackView.addArrangedSubview(label)
    }
    
    private func addSpaceView(height: CGFloat) {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        mainStackView.addArrangedSubview(v)
    }
    
}

