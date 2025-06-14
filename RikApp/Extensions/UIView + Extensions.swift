
import UIKit

extension UIView {
    func addSeparator(type: SeparatorType) {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        switch type {
        case .fixed(let width):
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        case .fractional(let percantage):
            view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: percantage).isActive = true
        case .full:
            view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        }
    }
    
    enum SeparatorType {
        case fixed(_ width: CGFloat)
        case fractional(_ percentage: CGFloat)
        case full
    }
}
