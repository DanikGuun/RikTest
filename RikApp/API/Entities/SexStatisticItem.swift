import Foundation

public struct SexStatisticItem {
    var range: Range<Int>
    var maleCount: Int
    var femaleCount: Int
    
    init(range: Range<Int> = 0..<1, maleCount: Int = 0, femaleCount: Int = 0) {
        self.range = range
        self.maleCount = maleCount
        self.femaleCount = femaleCount
    }
}
