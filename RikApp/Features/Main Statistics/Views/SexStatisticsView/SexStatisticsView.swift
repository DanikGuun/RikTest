
import UIKit
import ChartKit
import PinLayout

public class SexStatisticsView: UIView {
    
    public var item = SexStatisticsItem(man: 1, woman: 6) { didSet { itemHasUpdated() } }
    public var font = UIFont(name: "Gilroy-Medium", size: 13)! { didSet { itemHasUpdated() } }
    public var manColor: UIColor = .manStatistic { didSet { itemHasUpdated() } }
    public var womanColor: UIColor = .womanStatistics { didSet { itemHasUpdated() } }
    
    private let pieChartView = PieChart()
    private let manAdditionalInfo = AdditionalChartInfo()
    private let womanAdditionalInfo = AdditionalChartInfo()
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        pieChartView.pin.horizontally().top(25).height(70%)
        manAdditionalInfo.pin.below(of: pieChartView, aligned: .start).end(to: edge.hCenter).bottom()
        womanAdditionalInfo.pin.below(of: pieChartView, aligned: .end).start(to: edge.hCenter).bottom()
    }
    
    private func setup() {
        setupPieChart()
        setupManAdditionalInfo()
        setupWomanAdditionalInfo()
    }
    
    private func setupPieChart() {
        addSubview(pieChartView)
        pieChartView.inset = .fromOuter(value: 10)
        pieChartView.spaceBetweenSlices = 3
        pieChartView.innerCornerRadius = 5
        pieChartView.outerCornerRadius = 5
        updatePieChart()
    }
    
    private func setupManAdditionalInfo() {
        addSubview(manAdditionalInfo)
        updateManAdditionalInfo()
    }
    
    private func setupWomanAdditionalInfo() {
        addSubview(womanAdditionalInfo)
        updateWomanAdditionalInfo()
    }
    
    private func itemHasUpdated() {
        updatePieChart()
        updateManAdditionalInfo()
        updateWomanAdditionalInfo()
    }
    
    private func updatePieChart() {
        let manItem = ChartElement(value: Double(item.man), color: manColor)
        let womanItem = ChartElement(value: Double(item.woman), color: womanColor)
        pieChartView.setElements([manItem, womanItem])
    }
    
    private func updateManAdditionalInfo() {
        let percantage = Double(item.man) / Double(item.man + item.woman)
        manAdditionalInfo.text = "Мужчины " + percantage.formatted(.percent.precision(.significantDigits(2)))
        manAdditionalInfo.font = font
        manAdditionalInfo.tintColor = manColor
    }
    
    private func updateWomanAdditionalInfo() {
        let percantage = Double(item.woman) / Double(item.man + item.woman)
        womanAdditionalInfo.text = "Женщины " + percantage.formatted(.percent.precision(.significantDigits(2)))
        womanAdditionalInfo.font = font
        womanAdditionalInfo.tintColor = womanColor
    }
}

public struct SexStatisticsItem {
    var man: Int
    var woman: Int
}
