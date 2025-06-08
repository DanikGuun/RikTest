
import UIKit
import PinLayout

public class DoubleBarChart: UIView {
    
    var item: DoubleBarChartItem = DoubleBarChartItem(title: "18-25") { didSet { itemHasUpdated() } }
    public var titleFont: UIFont = UIFont(name: "Gilroy-Semibold", size: 16)! { didSet { updateTitleLabel() } }
    public var barTitlesFont: UIFont = UIFont(name: "Gilroy-Regular", size: 10)! { didSet { itemHasUpdated() } }
    
    private let titleLabel = UILabel()
    private let doubleBar = DoubleBar()
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.pin.start().vertically().width(25%)
        doubleBar.pin.after(of: titleLabel).vertically().end()
    }
    
    private func setup() {
        setupTitleLabel()
        setupDoubleBar()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        updateTitleLabel()
    }
    
    private func setupDoubleBar() {
        addSubview(doubleBar)
        doubleBar.backgroundColor = .clear
        updateDoubleBar()
    }
    
    private func itemHasUpdated() {
        updateTitleLabel()
        updateDoubleBar()
    }
    
    private func updateTitleLabel() {
        titleLabel.text = item.title
        titleLabel.font = titleFont
    }
    
    private func updateDoubleBar() {
        doubleBar.titlesFont = barTitlesFont
        doubleBar.firstItem = item.firstItem
        doubleBar.secondItem = item.secondItem
    }
    
}

public struct DoubleBarChartItem {
    public var title: String
    public var firstItem: DoubleBarItem
    public var secondItem: DoubleBarItem
    
    init(title: String = "", firstItem: DoubleBarItem = DoubleBarItem(), secondItem: DoubleBarItem = DoubleBarItem()) {
        self.title = title
        self.firstItem = firstItem
        self.secondItem = secondItem
    }
}
