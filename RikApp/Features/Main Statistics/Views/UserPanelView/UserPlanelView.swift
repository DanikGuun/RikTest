
import UIKit
import PinLayout

public class UserPlanelView: UIView {
    
    public var item = UserPanelItem() { didSet { itemHasBeenUpdated() } }
    
    private var imageView = UIImageView()
    private var onlineIndicatorView = OnlineIndicatorView()
    private var nameLabel = UILabel()
    private var disclosureView = UIImageView()
    
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
        layoutImageView()
        layoutOnlineIndicatorView()
        layoutDisclosureView()
        layoutNameLabel()
    }
    
    private func layoutImageView() {
        imageView.pin.left(20).vertically(20%).aspectRatio(1)
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    private func layoutOnlineIndicatorView() {
        let radius = imageView.frame.width / 3.5
        let size = CGSize(width: radius, height: radius)
        onlineIndicatorView.pin.bottomEnd(to: imageView.anchor.bottomEnd).size(size)
        onlineIndicatorView.backgroundColor = backgroundColor
    }
    
    private func layoutDisclosureView() {
        disclosureView.pin.right(20).vertically(40%).aspectRatio(1)
    }
    
    private func layoutNameLabel() {
        let margin = PEdgeInsets(top: 0, left: 12, bottom: 0, right: 6)
        nameLabel.pin.horizontallyBetween(imageView, and: disclosureView).vertically(15).margin(margin)
    }
    
    private func setup(){
        setupImageView()
        setupOnlineIndicatorView()
        setupDisclosureView()
        setupNameLabel()
        itemHasBeenUpdated()
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemBlue
    }
    
    private func setupOnlineIndicatorView() {
        addSubview(onlineIndicatorView)
        onlineIndicatorView.backgroundColor = .systemRed
        onlineIndicatorView.tintColor = .lime
    }
    
    private func setupDisclosureView() {
        addSubview(disclosureView)
        disclosureView.image = UIImage(systemName: "chevron.right")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .bold))
        disclosureView.tintColor = .systemGray2
        disclosureView.contentMode = .center
    }
    
    private func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.font = UIFont(name: "Gilroy-Semibold", size: 16)
    }
    
    private func itemHasBeenUpdated() {
        imageView.image = item.image
        nameLabel.text = item.name
        onlineIndicatorView.isOnline = item.isOnline
    }
    
}

public struct UserPanelItem {
    public var name: String
    public var image: UIImage
    public var isOnline: Bool
    
    public init(name: String = "", image: UIImage? = nil, isOnline: Bool = false) {
        self.name = name
        self.image = image ?? UIImage(resource: ImageResource(name: "NoUserImage", bundle: .main))
        self.isOnline = isOnline
    }
}
