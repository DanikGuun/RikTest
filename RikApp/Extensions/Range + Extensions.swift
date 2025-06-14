
extension Range<Int> {
    var text: String {
        let secondValue = upperBound == Int.max ? "+" : "-\(upperBound - 1)"
        return "\(lowerBound)\(secondValue)"
    }
}
