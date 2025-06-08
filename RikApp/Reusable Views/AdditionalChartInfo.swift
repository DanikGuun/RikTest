
import UIKit

public class AdditionalChartInfo: UIView {
    
    public var text: String = "" { didSet { setNeedsDisplay() } }
    public var font: UIFont = .systemFont(ofSize: 13) { didSet { setNeedsDisplay() } }
    
    private let spaceBetweenCircleAndText: CGFloat = 5
    private var contentWidth: CGFloat {
        let textSize = NSString(string: text).size(withAttributes: [.font: font])
        return textSize.height*2 + spaceBetweenCircleAndText + textSize.width
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawCircle()
        drawText()
        DispatchQueue.main.async {
            self.backgroundColor = .clear
        }
    }
    
    private func drawCircle() {
        let textHeight = NSString("Text").size(withAttributes: [.font: font]).height
        let radius: CGFloat = textHeight / 2
        let point = CGPoint(x: bounds.midX - contentWidth/2 + textHeight/2, y: bounds.midY)
        let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        tintColor.setFill()
        path.fill()
    }
    
    private func drawText() {
        let textHeight = NSString(string: text).size(withAttributes: [.font: font]).height
        let point = CGPoint(x: bounds.midX - contentWidth/2 + textHeight + spaceBetweenCircleAndText, y: bounds.midY - textHeight/2)
        let text = NSString(string: text)
        text.draw(at: point, withAttributes: [.font: font])
    }
    
}
