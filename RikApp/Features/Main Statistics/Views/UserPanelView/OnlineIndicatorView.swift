
import UIKit

public class OnlineIndicatorView: UIView {
    
    public var isOnline = false { didSet { setNeedsDisplay() } }
    public var spaceBetweenCircles: CGFloat = 2 { didSet { setNeedsDisplay() } }
    
    private var radius: CGFloat {
        return min(bounds.width, bounds.height) / 2
    }
    
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        alpha = isOnline ? 1 : 0
        drawBackground()
        drawOnlineIndicator()
    }
    
    private func drawBackground() {
        let rect = CGRect(x: Int(bounds.midX - radius), y: Int(bounds.midY - radius), width: Int(radius)*2, height: Int(radius)*2)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        backgroundColor?.setFill()
        path.fill()
    }
    
    private func drawOnlineIndicator() {
        let radius = radius - spaceBetweenCircles/2
        let rect = CGRect(x: Int(bounds.midX - radius), y: Int(bounds.midY - radius), width: Int(radius)*2, height: Int(radius)*2)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        tintColor.setFill()
        path.fill()
    }
    
}
