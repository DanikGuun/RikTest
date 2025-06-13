
import UIKit
import PinLayout

class MainStatisticsViewController: UIViewController {

    var model: MainStatisticsModel!
    var mainStackView = UIStackView()
    
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
        setupMainStackView()
        setupVisitorsSection()
        addSpaceView(height: DC.interSectionSpacing)
        setupTopVisitorsSection()
        addSpaceView(height: DC.interSectionSpacing)
        setupSexAndAgeStatisticsSection()
        addSpaceView(height: DC.interSectionSpacing)
        setupViewersVolumeSection()
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
        let visitorsVolume = VolumeChangeView()
        visitorsVolume.heightAnchor.constraint(equalToConstant: 98).isActive = true
        visitorsVolume.item = VolumeChangeItem(type: .increase, value: 150)

        addViewsAsStack(visitorsVolume)
    }
    
    private func setupVisitorsDateIntervalPicker() {
        let picker = ActionsLineView()
        picker.spacing = 0
        picker.addAction(title: "По дням", action: {})
        picker.addAction(title: "По неделям", action: {})
        picker.addAction(title: "По месяцам", action: {})
        picker.selectAction(index: 0)
        
        mainStackView.addArrangedSubview(picker)
    }
    
    private func setupVisitorsGraphView() {
        let graphView = GraphicView()
        graphView.heightAnchor.constraint(equalToConstant: 208).isActive = true
        graphView.backgroundColor = .systemBackground
        graphView.insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        graphView.backgroundLineWidth = 1
        graphView.items = [
            GraphicItem(value: 30, graphicTitle: "1 valutare", title: "title", subtitle: "subtitle"),
            GraphicItem(value: 50, graphicTitle: "1 valutare", title: "title12", subtitle: "subtitle"),
            GraphicItem(value: 10, graphicTitle: "1 valutare", title: "title4", subtitle: "subtitle"),
        ]
        
        addViewsAsStack(graphView)
    }
    
    //MARK: - Top Users sectoin
    private func setupTopVisitorsSection() {
        addTitle("Чаще всех посещают ваш профиль")
        setupTopVisitorsDash()
    }
    
    private func setupTopVisitorsDash() {
        let user1 = UserPanelItem(name: "Tanya", image: nil, isOnline: true)
        let user2 = UserPanelItem(name: "Egor", image: nil, isOnline: false)
        let user3 = UserPanelItem(name: "Stepan", image: nil, isOnline: true)
        var viewsToAdd: [UIView] = []
        for user in [user1, user2, user3] {
            let userView = UserPlanelView()
            userView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            userView.backgroundColor = .systemBackground
            viewsToAdd.append(userView)
            userView.item = user
        }
        addViewsAsStack(viewsToAdd)
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
        picker.addAction(title: "Сегодня", action: {})
        picker.addAction(title: "Месяц", action: {})
        picker.addAction(title: "Неделя", action: {})
        picker.addAction(title: "Всё время", action: {})
        picker.selectAction(index: 0)
        
        mainStackView.addArrangedSubview(picker)
    }
    
    private func setupSexAndAgeStatistics() {
        let sex = getSexStatisticsView()
        let sexAndAge = getSexAndAgeStatisticsViews()
        addViewsAsStack([sex] + sexAndAge)
    }
    
    private func getSexStatisticsView() -> UIView {
        let view = SexStatisticsView()
        view.heightAnchor.constraint(equalToConstant: 240).isActive = true
        view.item = SexStatisticsItem(man: 5, woman: 19)
        return view
    }
    
    private func getSexAndAgeStatisticsViews() -> [UIView] {
        var views: [DoubleBarChart] = []
        for _ in 0..<3 {
            let chart = DoubleBarChart()
            chart.heightAnchor.constraint(equalToConstant: 50).isActive = true
            chart.item = DoubleBarChartItem(title: "18-19", firstItem: DoubleBarItem(title: "10%", color: .manStatistic, percentage: 0.1), secondItem: DoubleBarItem(title: "5%", color: .womanStatistics, percentage: 0.05))
            views.append(chart)
        }
        return views
    }
    
    //MARK: - Viewers volume section
    private func setupViewersVolumeSection() {
        addTitle("Наблюдатели")
        let newViewersVolume = getNewViewersVolumeView()
        let leavedViewersVolume = getLeavedViewersVolumeView()
        addViewsAsStack(newViewersVolume, leavedViewersVolume)
    }
    
    private func getNewViewersVolumeView() -> UIView {
        let view = VolumeChangeView()
        view.heightAnchor.constraint(equalToConstant: 98).isActive = true
        view.item = VolumeChangeItem(type: .increase, value: 156)
        return view
    }
    
    private func getLeavedViewersVolumeView() -> UIView {
        let view = VolumeChangeView()
        view.heightAnchor.constraint(equalToConstant: 98).isActive = true
        view.item = VolumeChangeItem(type: .decrease, value: 6)
        return view
    }
    
    //MARK: - Helpers
    private func addViewsAsStack(_ views: UIView...) {
        let stack = getPatternStackView()
        views.forEach { stack.addArrangedSubview($0) }
        mainStackView.addArrangedSubview(stack)
    }
    
    private func addViewsAsStack(_ views: [UIView]) {
        let stack = getPatternStackView()
        views.forEach { stack.addArrangedSubview($0) }
        mainStackView.addArrangedSubview(stack)
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
