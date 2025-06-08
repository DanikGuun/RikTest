
import UIKit
import PinLayout

public class VolumeChangeView: UIView {
    
    public var item = VolumeChangeItem() { didSet { itemHasUpdated() } }
    public var valueLabelFont = UIFont(name: "Gilroy-Bold", size: 20) { didSet { valueLabel.font = valueLabelFont } }
    public var subtitleLabelFont = UIFont(name: "Gilroy-Medium", size: 15) { didSet { subtitleLabel.font = subtitleLabelFont } }
    
    private let graphImageView = UIImageView()
    private let valueLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let subtitleLabel = UILabel()
    
    public convenience init(){
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
        graphImageView.pin.start().vertically().aspectRatio(1.9).margin(PEdgeInsets(top: 15, left: 10, bottom: 15, right: 0))
        valueLabel.pin.start(to: graphImageView.edge.end).top().sizeToFit().margin(PEdgeInsets(top: 15, left: 15, bottom: 0, right: 10))
        arrowImageView.pin.topStart(to: valueLabel.anchor.topEnd).bottom(to: valueLabel.edge.bottom).aspectRatio(1)
        subtitleLabel.pin.topStart(to: valueLabel.anchor.bottomStart).bottomEnd().margin(PEdgeInsets(top: 7, left: 0, bottom: 15, right: 0))
    }
    
    private func setup() {
        setupGraphImageView()
        setupValueLabel()
        setupArrowImageView()
        setupSubtitleLabel()
    }
    
    private func setupGraphImageView() {
        addSubview(graphImageView)
    }
    
    private func setupValueLabel() {
        addSubview(valueLabel)
        valueLabel.font = valueLabelFont
    }
    
    private func setupArrowImageView() {
        addSubview(arrowImageView)
    }
    
    private func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.font = subtitleLabelFont
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.numberOfLines = 3
    }
    
    private func itemHasUpdated() {
        valueLabel.text = "\(item.value)"
        subtitleLabel.text = item.type.subtitle
        graphImageView.image = item.type.graphImage
        arrowImageView.image = item.type.arrowImage
    }
}

public struct VolumeChangeItem {
    public var type: ChangeType
    public var value: Int
    
    public init(type: ChangeType = .increase, value: Int = 0) {
        self.type = type
        self.value = value
    }
    
    public enum ChangeType {
        case increase
        case decrease
        
        public var graphImage: UIImage {
            var name = ""
            switch self {
            case .increase: name = "IncreaseGraphic"
            case .decrease: name = "DecreaseGraphic"
            }
            return UIImage(resource: ImageResource(name: name, bundle: .main))
        }
        
        public var subtitle: String {
            switch self {
            case .increase: return "Новые наблюдатели в этом месяце"
            case .decrease: return "Пользователей перестали за Вами наблюдать"
            }
        }
        
        public var arrowImage: UIImage {
            var name = ""
            switch self {
            case .increase: name = "IncreaseArrow"
            case .decrease: name = "DecreaseArrow"
            }
            return UIImage(resource: ImageResource(name: name, bundle: .main))
        }
        
    }
}
