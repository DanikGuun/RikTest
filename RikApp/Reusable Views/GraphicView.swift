
import UIKit

class GraphicView: UIControl {
    
    var items: [GraphicItem] = [] { didSet { setNeedsDisplay() } }
    var insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    //Graph
    let pointRadius: CGFloat = 5
    let graphLineWidth: CGFloat = 3
    
    //Titles
    var graphTitleFont = UIFont(name: "Gilroy-Medium", size: 13)!
    var graphTitleColor: UIColor = .secondaryLabel
    var spaceBetweenTitlesAndGraph: CGFloat = 10

    //BackgroundLines
    var backgroundLineWidth: CGFloat = 2
    var backgroundLineLength: CGFloat = 12
    var spaceBetweenBackgroundLines: CGFloat = 8
    var backgroundLineColor: UIColor = .systemGray4
    
    //DescriptionPanel
    var descriptionContentInset: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    var descriptionTitleFont = UIFont(name: "Gilroy-Semibold", size: 15)!
    var descriptionSubtitleFont = UIFont(name: "Gilroy-Medium", size: 13)!
    var spaceBetweenDescriptionItems: CGFloat = 8
    var descriptionStrokeColor: UIColor = .systemGray4
    var descriptionSubtitleColor: UIColor = .secondaryLabel
    var descriptionPanelCornerRadius: CGFloat = 12
    
    //Other
    private var graphFrame: CGRect {
        let contentFrame = layoutMarginsGuide.layoutFrame
        let titlesHeight: CGFloat = NSString("Font").size(withAttributes: [.font : graphTitleFont]).height + spaceBetweenTitlesAndGraph
        let x = contentFrame.minX
        let y = contentFrame.minY + graphLineWidth/2 + pointRadius
        let width = contentFrame.width
        let height = contentFrame.height - titlesHeight - graphLineWidth/2 - pointRadius
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return rect
    }
    private var shouldDrawDescription: Bool = false
    private var lastTouchX: CGFloat = 0
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shouldDrawDescription = true
        lastTouchX = touches.first?.location(in: self).x ?? 0
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchX = touches.first?.location(in: self).x ?? 0
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        shouldDrawDescription = false
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layoutMargins = insets

        drawBackgroundLines()
        drawDescriptionBackgroundLineIfNeeded()
        drawTitles()
        drawGraphLine()
        drawGraphPoints()
        drawDescriptionPanelIfNeeded()
    }
    
    private func drawBackgroundLines() {
        guard backgroundLineLength != 0 else { return }
        let graphFrame = graphFrame
        let linesY: [CGFloat] = [
            graphFrame.minY,
            graphFrame.midY,
            graphFrame.maxY
        ]
        linesY.forEach { drawBackgrounLine(y: $0) }
    }
    
    private func drawBackgrounLine(y: CGFloat) {
        let contentFrame = layoutMarginsGuide.layoutFrame
        var x = contentFrame.minX
        
        while (x < contentFrame.maxX) {
            let y =  y - backgroundLineWidth/2
            let width = min(backgroundLineLength, graphFrame.maxX - x)
            let rect = CGRect(x: x, y: y, width: width, height: backgroundLineWidth)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: backgroundLineWidth/2)
            
            path.lineWidth = backgroundLineWidth
            backgroundLineColor.setFill()
            path.fill()
            
            x += backgroundLineLength + spaceBetweenBackgroundLines
        }
    }
    
    private func drawTitles() {
        let contentFrame = layoutMarginsGuide.layoutFrame
        let sectorWidth = contentFrame.width / CGFloat(items.count)
        
        for (index, item) in items.enumerated() {
            let string = NSString(string: item.graphicTitle)
            let stringSize = string.size()
            let x = contentFrame.minY + sectorWidth * CGFloat(index) + sectorWidth / 2 - stringSize.width / 2
            let y = contentFrame.maxY - stringSize.height
            let point = CGPoint(x: x, y: y)
            string.draw(at: point, withAttributes: [.font: graphTitleFont, .foregroundColor: graphTitleColor])
        }
    }
    
    private func drawGraphLine() {
        let points = getGraphPoints()
        let graphPath = UIBezierPath()
        graphPath.lineWidth = graphLineWidth
        for (index, point) in points.enumerated() {
            if index == 0 { graphPath.move(to: point) }
            else { graphPath.addLine(to: point) }
        }
        tintColor.setStroke()
        graphPath.stroke()
    }
    
    private func drawGraphPoints() {
        let points = getGraphPoints()
        for point in points {
            let pointPath = UIBezierPath()
            pointPath.lineWidth = graphLineWidth
            pointPath.addArc(withCenter: point, radius: pointRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            tintColor.setStroke()
            backgroundColor?.setFill()
            pointPath.fill()
            pointPath.stroke()
        }
    }
    
    private func getGraphPoints() -> [CGPoint] {
        let graphFrame = graphFrame
        let sectorWidth = graphFrame.width / CGFloat(items.count)
        let maxItemValue: CGFloat = items.max { $0.value < $1.value }?.value ?? 0
        var points: [CGPoint] = []
        //x - левый край контента + расстояние до нужного сектора + полсектора, чтобы был посередине
        //y - от верхнего края конента отступаем радиус точки (с обводкой) и смещаем на инвертированный процент значения * высоту графика
        for (index, item) in items.enumerated() {
            let x = graphFrame.minX + sectorWidth * CGFloat(index) + sectorWidth / 2
            var y = graphFrame.minY + ( 1 - item.value / maxItemValue ) * graphFrame.height
            y = y.isNormal ? y : 0
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    private func drawDescriptionBackgroundLineIfNeeded() {
        guard shouldDrawDescription else { return }
        let graphFrame = graphFrame
        let x = getNearestToTouchGraphPointX()
        var y = graphFrame.minY
        while ( y < graphFrame.maxY ) {
            let x = x - backgroundLineWidth/2
            let width = backgroundLineWidth
            let height = min(backgroundLineLength, graphFrame.maxY - y)
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: backgroundLineWidth/2)
            path.lineWidth = backgroundLineWidth
            tintColor.setFill()
            path.fill()
            y += backgroundLineLength + spaceBetweenBackgroundLines
        }
    }
    
    private func drawDescriptionPanelIfNeeded() {
        guard shouldDrawDescription else { return }
        let rect = getDescriptionPanelFrame()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: descriptionPanelCornerRadius)
        path.lineWidth = backgroundLineWidth
        descriptionStrokeColor.setStroke()
        backgroundColor?.setFill()
        path.stroke()
        path.fill()
        
        let item = getNearToTouchGraphItem()
        let title = NSAttributedString(string: item.title, attributes: [.foregroundColor: tintColor ?? .label, .font: descriptionTitleFont])
        let subtitle = NSAttributedString(string: item.subtitle, attributes: [.foregroundColor: descriptionSubtitleColor, .font: descriptionSubtitleFont])
        let x = rect.minX + descriptionContentInset.left
        let y =  rect.minY + descriptionContentInset.top
        let titlePoint = CGPoint(x: x, y: y)
        let subtitlePoint = CGPoint(x: x, y: y + title.size().height + spaceBetweenDescriptionItems)
        title.draw(at: titlePoint)
        subtitle.draw(at: subtitlePoint)
        
        
    }
    
    private func getDescriptionPanelFrame() -> CGRect {
        let contentFrame = layoutMarginsGuide.layoutFrame
        let item = getNearToTouchGraphItem()
        let title = NSAttributedString(string: item.title, attributes: [.font: descriptionTitleFont])
        let subtitle = NSAttributedString(string: item.subtitle, attributes: [.font: descriptionSubtitleFont])
        let titleSize = title.size()
        let subtitleSize = subtitle.size()
        
        let panelWidth = max(titleSize.width, subtitleSize.width) + descriptionContentInset.left + descriptionContentInset.right
        let panelHeight = titleSize.height + subtitleSize.height + spaceBetweenDescriptionItems + descriptionContentInset.top + descriptionContentInset.bottom
        let targetX = getNearestToTouchGraphPointX() - panelWidth/2
        
        let y = contentFrame.minY
        var x = max(targetX, contentFrame.minX) //для удержания Х внутри вьюшки, чтобы не бегал через край
        x = min(x, contentFrame.maxX - panelWidth)
        let rect = CGRect(x: x, y: y, width: panelWidth, height: panelHeight)
        return rect
    }
    
    private func getNearestToTouchGraphPointX() -> CGFloat {
        let graphPointsX = getGraphPoints().map { $0.x }
        let touchX = lastTouchX
        let nearestX = graphPointsX.min { abs($0 - touchX) <= abs($1 - touchX) } ?? 0
        return nearestX
    }
    
    private func getNearToTouchGraphItem() -> GraphicItem {
        let points = getGraphPoints().map { $0.x }
        let nearestX = getNearestToTouchGraphPointX()
        let nearestIndex = points.firstIndex(of: nearestX) ?? 0
        return items[nearestIndex]
    }
}

public struct GraphicItem {
    var value: CGFloat
    var graphicTitle: String
    var title: String
    var subtitle: String
    
    public init(value: CGFloat = 0, graphicTitle: String = "", title: String = "", subtitle: String = "") {
        self.value = value
        self.graphicTitle = graphicTitle
        self.title = title
        self.subtitle = subtitle
    }
}
