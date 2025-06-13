
import UIKit
import PinLayout

public class ActionsLineView: UIView{
    
    public var spacing: CGFloat = 8 { didSet { buttonsStackView.spacing = spacing } }
    
    private var scrollView = UIScrollView()
    private var buttonsStackView = UIStackView()
    
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
        buttonsStackView.arrangedSubviews.forEach { $0.layer.cornerRadius = self.frame.height/2 }
    }
    
    private func setup() {
        setupScrollView()
        setupStackView()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func setupStackView() {
        scrollView.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        buttonsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        buttonsStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        buttonsStackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .equalSpacing
    }
    
    public func selectAction(index: Int) {
        let button = buttonsStackView.arrangedSubviews[index] as? UIControl
        button?.isSelected = true
        button?.sendActions(for: .touchUpInside)
    }

    public func addAction(title: String, action: @escaping () -> ()) {
        let button = UIButton(configuration: .filled())
        button.changesSelectionAsPrimaryAction = true
        button.configurationUpdateHandler = handleButtonConfigurationUpdate
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = self.frame.height / 2
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.addAction(UIAction(handler: { [weak self] _ in
            if button.isSelected == false { //чтобы не выключалась нажатая кнопка при повторном нажатии
                button.isSelected = true
                return
            }
            action()
            self?.deselectButtonsDistinct(button)
        }), for: .touchUpInside)
        buttonsStackView.addArrangedSubview(button)
    }
    
    private func deselectButtonsDistinct(_ distinctedButton: UIButton) {
        for button in buttonsStackView.arrangedSubviews {
            guard let button = button as? UIButton else { continue }
            button.isSelected = button == distinctedButton
        }
    }
    
    private func handleButtonConfigurationUpdate(_ button: UIButton) {
        let backgroundColor: UIColor = button.isSelected ? .accent : .clear
        let title = button.title(for: .normal) ?? ""
        let titleColor: UIColor = button.isSelected ? .systemBackground : .label
        let titleAttribuutes = AttributeContainer([
            .font: UIFont(name: "Gilroy-SemiBold", size: 16)!,
            .foregroundColor: titleColor
        ])
        
        var conf = button.configuration
        conf?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        conf?.attributedTitle = AttributedString(title, attributes: titleAttribuutes)
        conf?.baseBackgroundColor = backgroundColor
        button.configuration = conf
        button.layer.borderColor = button.isSelected ? UIColor.clear.cgColor : UIColor.systemGray4.cgColor
    }
    
    public func removeActions() {
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
