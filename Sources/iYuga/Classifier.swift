import Foundation
extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
public class Classifier {
    
    let prefixTrie: Trie = Trie()
    let upiTrie: Trie = Trie()
    
    private lazy var initTrie: Void = {
        prefixTrie.loadTrie()
        upiTrie.insertUpis()
    }()
    
    public init() {}
    
    public func getYugaTokens(_ message: String) -> Pair<String, Dictionary<String, AnyObject>> {
        var configMap = Dictionary<String, String>()
        configMap[Constants.YUGA_CONF_DATE] = Constants.dateTimeFormatter().string(from: Date(milliseconds: 1527811200000))
        return getYugaTokens(message, configMap, IndexTrack(next: 0))
    }
    public func getYugaTokens(_ message: String, _ configMap: Dictionary<String, String>, _ indexTrack: IndexTrack) -> Pair<String, Dictionary<String, AnyObject>> {
        
        _ = initTrie
        let sentence = message + " "
        var prevToken: Pair<Int, String> = Pair(0, "")
        let unmaskTokenSet = Constants.unmaskTokenSet
        var tokenCount: Dictionary<String, Int> = Dictionary()
        var start: Int = 0
        var tokenEndIndex: Int = 0
        
        for key in unmaskTokenSet {
            tokenCount[key] = 0
        }
        
        var sb: String = String()
        var metaData = Dictionary<String, AnyObject>()
        
        while indexTrack.next < sentence.length() {
            var flag: Bool = false
            if skipCharacter(sentence, indexTrack.next, sentence.charAt(indexTrack.next)) {
                indexTrack.next += 1
                continue
            }
            var ch: Character = sentence.charAt(indexTrack.next)
            let res: Pair<Int, Pair?> = getTokenEndIndex(sentence, indexTrack.next, prefixTrie)
            tokenEndIndex = res.getA()
            start = indexTrack.next
            let p = classifyTokens(sentence.substring(indexTrack.next), sentence.substring(indexTrack.next, tokenEndIndex).lowercased(), indexTrack, configMap, prevToken, res.getB())
            if Constants.possiblePrevTokens.keys.contains(sentence.substring(start, tokenEndIndex).lowercased()) {
                prevToken.setB(Constants.possiblePrevTokens[sentence.substring(start, tokenEndIndex).lowercased()]!)
                flag = true
                prevToken.setA(1)
            }
            if p != nil {
                sb.append(sentence.substring(start, p!.getB()))
                prevToken = Pair(0, "")
                sb.append(p!.getA())
                if tokenCount.keys.contains(p!.getA()) {
                    var metValForToken: Dictionary<String, Int> = Dictionary()
                    metValForToken["INDEX"] = p!.getB()
                    if tokenCount[p!.getA()] == 0 {
                        metaData[p!.getA()] = metValForToken as AnyObject
                    } else {
                        metaData[p!.getA() + "_" + String(tokenCount[p!.getA()]!)] = metValForToken as AnyObject
                    }
                    tokenCount[(p?.getA())!] = tokenCount[(p?.getA())!]! + 1
                }
                sb.append(" ")
            } else {
                sb.append(sentence.substring(indexTrack.next, tokenEndIndex))
                sb.append(" ")
                indexTrack.next = tokenEndIndex + 1
                if prevToken != nil && flag == false {
                    prevToken.setA(prevToken.getA() + 1)
                }
            }
            sb.append("")
        }
        return Pair(sb.trim(), metaData)
    }
    
    public func generateOutput(_ sb: String, _ map: Dictionary<String, AnyObject>) {
        
        print("message : " + sb)
        print("METADATA : ")
        print(map)
    }
    
    public func skipCharacter(_ sentence: String, _ index: Int, _ ch: Character) -> Bool {
        return (goodEndings(sentence.charAt(index)) || ch.asciiValue == Constants.CH_PLUS) || ch.asciiValue == Constants.CH_BKSLSH
    }
    
    public func goodEndings(_ ch: Character) -> Bool {
        return ch.asciiValue == Constants.CH_SPACE || ch.asciiValue == Constants.CH_COMA || ch.asciiValue == Constants.CH_COLN || ch.asciiValue == Constants.CH_FSTP || ch.asciiValue == Constants.CH_RBKT || ch.asciiValue == Constants.CH_HYPH || ch.asciiValue == Constants.CH_LBKT || ch.asciiValue == Constants.CH_DQOT || ch.asciiValue == Constants.CH_EQLS || ch.asciiValue == Constants.CH_LSTN || ch.asciiValue == Constants.CH_GTTN || ch == "\r" || ch == "\n" || ch.asciiValue == Constants.CH_EXCL
    }
    
    private func getTokenEndIndex(_ sentence: String, _ index: Int, _ prefixTrie: Trie) -> Pair<Int, Pair<Int, String>?> {
        let subSentence = sentence.substring(index)
        let nextSpaceIndex: Pair<Int, Pair<Int, String>?> = nextDelimeterImmediate(subSentence, prefixTrie)
        let idx = nextSpaceIndex.getA() + index
        nextSpaceIndex.setA(idx)
        return nextSpaceIndex
    }
    private func nextDelimeterImmediate(_ str: String, _ prefixTrie: Trie) -> Pair<Int, Pair<Int, String>?> {
        var idx: Int = 0
        var len: Int = 0
        var label: String? = nil
        var flag: Bool = true
        var root: TrieNode = prefixTrie.root
        let sentence = str.lowercased()
        
        for i in 0...sentence.length() - 1 {
            let ch = sentence.charAt(i)
            if !root.hasNext(ch) {
                flag = false
            }
            if root.hasNext(ch) && flag {
                root = root.get(ch)
                len += 1
                if root.isEnd() {
                    label = root.getLabel()
                }
            }
            if goodEndings(sentence.charAt(i)) {
                if label != nil {
                    let p = Pair(len, label!)
                    return Pair(i, p)
                } else {
                    return Pair(i, nil)
                }
            }
            idx = i + 1
        }
        return Pair(idx, nil)
    }
    
    public func classifyTokens(_ sentence: String, _ word: String, _ indexTrack: IndexTrack, _ configMap: Dictionary<String, String>, _ prevToken: Pair<Int, String>?, _ prefix: Pair<Int, String>?) -> Pair<String, Int>?{
        if prefix != nil && prefix!.getB() == "CRNCY" {
                let p = lookAheadIntegerForAmt(sentence.substring(prefix!.getA()))
                if p.getA() >= 0 && p.getB() {
                    let start: Int = indexTrack.next
                    setNextIndex(p.getA() + prefix!.getA(), indexTrack)
                    return Pair("AMT", start)
                }
        } else if Constants.tokens.keys.contains(word) && Constants.tokens[word] == "TRANSFER"  {
            if checkForUpi(str: word) != nil {
                let start: Int = indexTrack.next;
                switch(word) {
                case "upi" :
                    return Pair("UPI", start)
                case "mmt" :
                    return Pair("IMPS", start)
                case "neft" :
                    return Pair("NEFT", start)
                default:
                    return nil
                }
            }
        } else if prefix != nil && prefix!.getB() == "FLTID" {
            let i = lookAheadInteger(sentence.substring(word.length()))
            let nextIsNumber: Bool = (i + 1 + word.length()) < sentence.length() && sentence.charAt(i + 1 + word.length()).isNumber
            if let t = numberParse(sentence.substring(i + word.length())) {
                if i >= 0 && i <= 5 && nextIsNumber {
                    let start: Int = indexTrack.next
                    setNextIndex(word.length() + i + t.getA(), indexTrack)
                    return Pair("FLTIDVAL", start)
                }
            }
        } else if Constants.tokens.keys.contains(word) && Constants.tokens[word] == "HTTP" {
            if let p = linkParse(sentence + " ", word.length()) {
                let start: Int = indexTrack.next
                setNextIndex(p.getA(), indexTrack)
                return Pair("URL", start)
            }
        } else if Constants.tokens.keys.contains(word) && Constants.tokens[word] == "SMS" {
            let res = smsCode(word, indexTrack.next)
            if res {
                 let start: Int = indexTrack.next
                return Pair("SMSCODE", start)
            }
        } else if Constants.tokens.keys.contains(word) && Constants.tokens[word] == "WWW" {
            if let p = wwwParse(sentence + " ", word.length()) {
                let start: Int = indexTrack.next
                setNextIndex(p, indexTrack)
                return Pair("URL", start)
            }
        } else if Constants.tokens.keys.contains(word) && Constants.tokens[word] == "IDPRX" {
            let i = lookAheadNumberForIdPrx(sentence.substring(indexTrack.next))
            if i >= 0 && i <= 2 {
                if numberParse(sentence.substring(i + indexTrack.next)) != nil {
                    let start: Int = indexTrack.next
                    return Pair("NUM", start)
                }
            }
        }
        return classifyTokensUsingNext(sentence, indexTrack, configMap, prevToken, prefix)
    }
    
    public func classifyTokensUsingNext(_ sentence: String, _ indexTrack: IndexTrack, _ configMap: Dictionary<String, String>, _ prevToken: Pair<Int, String>?, _ prefix: Pair<Int, String>?) -> Pair<String, Int>? {
        let yuga = Yuga()
        if sentence.charAt(0).asciiValue == Constants.CH_HASH {
            let i = lookAheadforHash(sentence)
            setNextIndex(i, indexTrack)
            if let t = yuga.parse(str: sentence.substring(i), config: configMap) {
                let start: Int = indexTrack.next
                setNextIndex(t.getIndex(), indexTrack)
                return Pair(t.getType(), start)
            }
        }
        return classifyInGeneral(sentence, configMap, indexTrack, prevToken, prefix)
    }
    
    public func classifyInGeneral(_ sentence: String, _ configMap: Dictionary<String, String>, _ indexTrack: IndexTrack, _ prevToken: Pair<Int, String>?, _ prefix: Pair<Int, String>?) -> Pair<String, Int>? {
        let yuga: Yuga = Yuga()
        var start: Int = 0
        if prefix != nil {
            if prefix?.getB() == "INSTR" {
                if let t = yuga.parse(str: sentence.substring((prefix?.getA())!), config: configMap) {
                    start = indexTrack.next
                    setNextIndex(t.getIndex() + prefix!.getA(), indexTrack)
                    return Pair("INSTRNO", start + (prefix?.getA())!)
                }
            }
        } else {
            if let t = yuga.parse(str: sentence, config: configMap) {
                if t.getType() == "NUM" {
                   if let idx = classifyUpiWrapper(sentence, t.getIndex()) {
                        
                        start = indexTrack.next
                        setNextIndex(idx + 1, indexTrack)
                        return Pair("UPI", start)
                    }
                }
                if t.getType() != "STR" {
                    start = indexTrack.next
                    setNextIndex(t.getIndex(), indexTrack)
                    return Pair(t.getType(), start)
                }
            }
        }
        if prevToken != nil {
            let prevTok: String = prevToken!.getB()
            if prevTok == "INS" && prevToken!.getA() <= 2 {
                if let p = reCheckForAccount(sentence) {
                    start = indexTrack.next
                    setNextIndex(p.getA(), indexTrack)
                    return Pair("INSTRNO", start)
                }
            }
        }
        if let p = checkForUrl(sentence + " ") {
            start = indexTrack.next
            setNextIndex(p.getA(), indexTrack)
            return Pair("URL", start)
        }
        if let i = mailIdParse(sentence) {
            start = indexTrack.next
            setNextIndex(i, indexTrack)
            return Pair("EMAILADDRESS", start)
        }
        if prevToken != nil {
            let prevTok: String = prevToken!.getB()
            if let p = checkForId(sentence, 0)  {
                if prevTok == "ID" && prevToken!.getA() <= 2 {
                    start = indexTrack.next
                    setNextIndex(p.getA() + 1, indexTrack)
                    return Pair("IDVAL", start)
                }
            }
        }
        return nil
    }
    
    public func lookAheadIntegerForAmt(_ sentence: String) -> Pair<Int, Bool> {
        var c: Character
        var flag: Bool = false
        for index in 0...sentence.length() - 1 {
            c = sentence.charAt(index)
            if flag != true && (c == " " || c == ":" || c == "<" || c == "?" || c == "|") {
                continue
            } else if c == "." && index == sentence.length() - 1 {
                return Pair(index, flag)
            } else if c == "." || c == "," {
                if index > 0 && sentence.charAt(index-1) == " " && (index + 1) < sentence.length() && sentence.charAt(index+1).isNumber {
                    break
                } else {
                    continue
                }
            } else if (c.isNumber && index + 1 < sentence.length()) || c == "-" || c == "*" {
                flag = true
                continue
            } else if (c.isNumber) && index + 1 == sentence.length() {
                flag = true
                return Pair(index + 1, flag)
            } else {
                return Pair(index, flag)
            }
        }
        return Pair(-1, false)
    }
    
    public func lookAheadNumberForIdPrx(_ sentence: String) -> Int {
        let i = 0
        var c: Character
        for i in 0...sentence.length() - 1 {
            c = sentence.charAt(i)
            if c == " " || c == "-" {
                continue
            } else if c.isNumber {
                break
            } else if i > 3 {
                break
            }
        }
        return i
    }
    
    public func setNextIndex(_ idx: Int, _ indexTrack: IndexTrack) {
        indexTrack.next += idx
    }
    
    private func lookAheadforHash(_ sentence: String) -> Int{
        let index = 1
        var c: Character
        for index in 1...sentence.length() - 1 {
            c = sentence.charAt(index)
            if c != " " {
                break
            }
        }
        return index
    }
    
    private func lookAheadInteger(_ sentence: String) -> Int {
        var c: Character
        var idx: Int = 0
        for index in 0...sentence.length() - 1 {
            idx = index
            c = sentence.charAt(index)
            if c == " " || c == "." || c == ":" || c == "-" || c == "," {
                continue
            } else if c.isNumber {
                break
            } else {
                return -1
            }
        }
        return idx
    }
    
    private func lookAheadDotForUpi(_ sentence: String) -> Int {
        let index = 1
        var c: Character
        for index in 1...sentence.length() {
            c = sentence.charAt(index)
            if c.isLetter || c.isNumber {
                continue
            } else if c == "." {
                return index
            } else {
                return -1
            }
        }
        return index
    }
    
    private func classifyUpi(_ handle: String) -> Int {
        var t: TrieNode = upiTrie.root
        var c: Character
        var x: Int = -1
        if handle.length() > 0 {
            for i in 0...handle.length() - 1 {
                c = handle.charAt(i)
                if t.hasNext(c) {
                    t = t.get(c)
                    x = checkIfsc(handle.substring(i + 1))
                    if t.isEnd() && (i + 1) < handle.length() && (handle.charAt(i + 1) == "." || handle.charAt(i + 1) == " " || handle.charAt(i + 1) == ")" || handle.charAt(i + 1) == "(" || x > 0) {
                        if x > 0 {
                            return i + x
                        }
                        return i
                    }
                } else {
                    let d: Int = lookAheadDotForUpi(handle.substring(i))
                    if d > 0 && (i + d + 10) < handle.length() && handle.substring(i + d + 1, i + d + 10) == "ifsc.npci" {
                        return i + d + 10
                    } else {
                        break
                    }
                }
            }
        } else {
            return -1
        }
        return -1
    }
    
    private func classifyUpiWrapper(_ sentence: String, _ index: Int) -> Int?{
        if index >= sentence.length() {
            return nil
        }
        var tempIdx: Int = index
        if sentence.charAt(index).asciiValue == Constants.CH_LBKT {
            tempIdx += 1
        }
        for i in index...sentence.length() - 1 {
            if sentence.charAt(i) == "@" || sentence.charAt(i) == "¡" {
                tempIdx  = i
                break
            } else if sentence.charAt(i).isNumber || sentence.charAt(i).isLetter || sentence.charAt(i) == "." || sentence.charAt(i) == "-" {
                continue
            } else {
                return nil
            }
        }
        let ind: Int = classifyUpi(sentence.substring(index + 1))
        if ind > 0 {
            return tempIdx + ind + 1
        }
        return nil
    }

}
