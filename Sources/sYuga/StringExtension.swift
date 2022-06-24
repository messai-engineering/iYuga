import Foundation

extension StringProtocol {
    
subscript(offset: Int) -> Character {
    self[index(startIndex, offsetBy: offset)]
  }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func charAt(_ i: Int) -> Character {
        return self[i]
    }
    
    func length() -> Int {
        return self.count
    }
    
    func isNumber() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func startsWith(_ s: String) -> Bool {
        return false
    }
    
    func substring(_ i: Int) -> String {
        let startIndex = index(from: i)
        let endIndex = index(from: self.count)
        return String(self[startIndex..<endIndex])
    }
    
    func substring(_ start: Int, _ end: Int) -> String {
        let startIndex = index(from: start)
        let endIndex = index(from: end)
        return String(self[startIndex..<endIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func groups(for regexPattern: String) -> [String] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text as! String,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.flatMap { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
//                    guard let range = Range(rangeBounds, in: text) else {
//                        return ""
//                    }
                    if (rangeBounds.location > text.count || rangeBounds.length > text.count) {
                        return ""
                    } else {
                        return String((text as! NSString).substring(with: rangeBounds))
                    }
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

