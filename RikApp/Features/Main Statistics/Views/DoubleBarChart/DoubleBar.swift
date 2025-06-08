
import UIKit

public class DoubleBar: UIView {
    
    public var firstItem = DoubleBarItem() { didSet { setNeedsDisplay() } }
    public var secondItem = DoubleBarItem() { didSet { setNeedsDisplay() } }
    public var titlesFont = UIFont(name: "Gilroy-Regular", size: 10)! { didSet { setNeedsDisplay() } }
    public var insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) { didSet { setNeedsDisplay() } }
    public var lineWdith: CGFloat = 5 { didSet { setNeedsDisplay() } }
    public var spaceBetweenBarAndTitle: CGFloat = 3 { didSet { setNeedsDisplay() } }
    
    private var contentFrame: CGRect { layoutMarginsGuide.layoutFrame }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        layoutMargins = insets
        drawTopBar()
        drawBottomBar()
    }
    
    private func drawTopBar() {
        let text = NSAttributedString(string: firstItem.title, attributes: [.font: titlesFont])
        let textMidY = contentFrame.minY + text.size().height/2
        let barMidY = contentFrame.minY + lineWdith/2
        let y = max(textMidY, barMidY) //берем нижнюю середину, чтобы элементы не выплывали за пределы вью
        drawBar(y: y, item: firstItem)
    }
    
    private func drawBottomBar() {
        let text = NSAttributedString(string: secondItem.title, attributes: [.font: titlesFont])
        let textMidY = contentFrame.maxY - text.size().height/2
        let barMidY = contentFrame.maxY - lineWdith/2
        let y = max(textMidY, barMidY) //берем нижнюю середину, чтобы элементы не выплывали за пределы вью
        drawBar(y: y, item: secondItem)
    }
    
    private func drawBar(y: CGFloat, item: DoubleBarItem) {
        let text = NSAttributedString(string: item.title, attributes: [.font: titlesFont])
        //если бар меньше lineWidth, берем lineWidth, чтобы была просто точка
        let barWidth = max((contentFrame.width - text.size().width - spaceBetweenBarAndTitle) * item.percentage, lineWdith)
        let rect = CGRect(x: 0, y: y - lineWdith/2, width: barWidth, height: lineWdith)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: lineWdith/2)
        item.color.setFill()
        path.fill()
        
        let textPoint = CGPoint(x: contentFrame.minX + barWidth + spaceBetweenBarAndTitle, y: y - text.size().height/2)
        text.draw(at: textPoint)
    }
}

public struct DoubleBarItem {
    public var title: String
    public var color: UIColor
    public var percentage: Double
    
    init(title: String = "", color: UIColor = .tintColor, percentage: Double = 0) {
        self.title = title
        self.color = color
        self.percentage = min(max(percentage, 0), 1)
    }

}
