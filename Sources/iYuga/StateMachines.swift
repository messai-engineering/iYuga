import Foundation
    public func checkIfsc(_ str: String) -> Int {
        
        var ch: Character
        var state: Int = 1
        var i: Int = 0
        
        while state > 0 && i < str.length() {
            
            ch = str.charAt(i)
            
            switch state {
            case 1 :
                if ch.isNumber {
                    state = 1
                }
                else if ch == "." {
                    state = 2
                }
                else {
                    state = -1
                }
                break
            case 2 :
                if (i + 9) < str.length() && str.substring(i, i + 9) == "ifsc.npci" {
                    return i + 9
                }
                else {
                    state = -1
                }
                break
            default :
                state = -1
            }
            i += 1
        }
        
        return -1
    }
    
    public func cdrParse(_ str: String) -> Int {
        
        var state: Int = 1, i: Int = 0
        var c: Character
        var ret: Int = -1
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
            case 1 :
                if c == "C" {
                    ret = 1
                    state = 2
                } else if c == "D" {
                    ret = 0
                    state = 2
                } else {
                    state = -1
                }
                break
            case 2 :
                if c == "R" || c == "r" {
                    state = 3
                } else {
                    state = -1
                }
                break
            case 3 :
                if c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_FSTP || c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_SCLN {
                    return ret
                } else {
                    return -1
                }
            default :
                state = -1
            }
            i += 1
        }
        
        return -1
    }
    
    public func wwwParse(_ str: String, _ indRead: Int) -> Int? {
        
        var state: Int = 1
        var i: Int = indRead - 1
        var c: Character = Character("")
        var dotcounter: Int = 0
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
                
            case 1 :
                if c.asciiValue == Constants.CH_SPACE {
                    var x: Int = i
                    if i > 0 && (str.charAt(i - 1).asciiValue == Constants.CH_FSTP || str.charAt(i - 1).asciiValue == Constants.CH_RBKT) {
                        if i > 1 && str.charAt(i - 2).asciiValue == Constants.CH_RBKT {
                            x = i - 2
                        } else {
                            x = i - 1
                        }
                    }
                    if i != indRead && dotcounter > 1 {
                        return x
                    } else {
                        return nil
                    }
                } else if c.asciiValue == Constants.CH_FSTP {
                    dotcounter += 1
                    if i>3 && (str.substring(i-3,i) == "com" || str.substring(i-2,i) == "in") {
                        return i
                    }
                } else if c.asciiValue == Constants.CH_SLSH || c.asciiValue == Constants.CH_EQLS || c.asciiValue == Constants.CH_QUEST || c.asciiValue == Constants.CH_LSTN || c.asciiValue == Constants.CH_GTTN {
                    ()
                } else if !c.isLetter && !c.isNumber && c != "-" {
                    state = -1
                }
                break
            default :
                state = -1
            }
            i += 1
        }
        
        return nil
    }
    
    public func linkParse(_ str: String, _ indRead: Int) -> Pair<Int, String>? {
        
        var state: Int = 1
        var i: Int = indRead
        var c: Character
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            switch state {
            case 1 :
                if c.asciiValue == Constants.CH_COLN && (i + 1) < str.length() && str.charAt(i + 1).asciiValue == Constants.CH_SLSH {
                    state = 2
                } else {
                    state = -1
                }
                break
            case 2 :
                if c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_NLINE || (c.asciiValue == Constants.CH_BKSLSH && (i + 1) < str.length() && str.charAt(i + 1).asciiValue == 110) {
                    var x: Int = i
                    if i > 3 && i < str.length() && (str.substring(i-3,i) == "www" || str.substring(i-3,i) == "ww.") {
                        if let p = checkForUrl(str.substring(i + 1)) {
                            p.setA(i + 1 + p.getA())
                            return p
                        } else {
                            return nil
                        }
                    } else if c.asciiValue == Constants.CH_SPACE && (i + 5) < str.length() && (str.substring(i+1,i+4) == "in/" || str.substring(i+1,i+5) == "com/") {
                        i += 1
                        continue
                        
                    } else if i > 0 && (str.charAt(i-1).asciiValue == Constants.CH_FSTP || str.charAt(i-1).asciiValue == Constants.CH_RBKT) {
                        if i > 1 && str.charAt(i-2).asciiValue == Constants.CH_RBKT {
                            x = i - 2
                        } else {
                            x = i - 1
                        }
                    }
                    return Pair(x, str.substring(0, x))
                }
                break
            default :
                return nil
            }
            
            i += 1
        }
        
        return nil
    }
    
    public func checkForUrl(_ str: String) -> Pair<Int, String>? {
        var state: Int = 1, i: Int = 0
        var c: Character
        var dotCounter: Int = 0, slashCounter: Int = 0
        while state > 0 && i < str.length() {
            c = str.charAt(i)
            switch state {
            case 1 :
                if c.asciiValue == Constants.CH_FSTP && (i + 1) < str.length() && !isDelimiter(str.charAt(i + 1)) {
                    dotCounter += 1
                    if dotCounter >= 2 && i > 5 {
                        state = 2
                    }
                } else if c.asciiValue == Constants.CH_SLSH && i >= 5 && dotCounter > 0 {
                    slashCounter += 1
                    state = 2
                } else if !c.isLetter && !c.isNumber {
                    state = -1
                } else {
                    ()
                }
                break
            case 2 :
                if c.asciiValue == Constants.CH_SLSH {
                    slashCounter += 1
                } else if c.asciiValue == Constants.CH_FSTP {
                    dotCounter += 1
                } else if c.asciiValue == Constants.CH_COMA {
                    return nil
                } else if c.asciiValue == Constants.CH_SPACE {
                    if dotCounter >= 2 && slashCounter < 1 {
                        return nil
                    } else {
                        return Pair(i, str.substring(0, i))
                    }
                }
                break
            default : return nil
            }
            
            i += 1
        }
        
        return nil
    }
    
    public func checkForUpi(str: String) -> String? {
        
        var refId: String?, userId: String?
        var userMap: Dictionary<String, String> = Dictionary()
        var state: Int = 1, j: Int, i: Int = 0
        var c: Character
        var s: String = ""
        var wordCount: Int = -1
        var prefix: String = ""
        let yuga = Yuga.init()
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
            case 1:
                if let p = yuga.checkTypes("FSA_UPI", str.substring(i)) {
                    i = i + p.getA()
                    state = 2
                } else {
                    state = -1
                }
                break
            case 2 :
                j = lookAheadIntegerForUPI(str.substring(i))
                if j != -1 && j < 6 {
                    i += j
                    s += String(str.charAt(i))
                    state = 3
                } else {
                    state = -1
                }
                break
            case 3 :
                if c.isNumber {
                    s += String(c)
                    state = 3
                } else if isUPIDelimeter(c) {
                    refId = s
                    s = ""
                    state = 4
                } else {
                    state = -1
                }
                break
            case 4 :
                if c.isNumber || c.isUppercase || c.isLowercase {
                    if wordCount == -1 {
                        wordCount = 0
                    }
                    s.append(c)
                    state = 4
                    if i + 1 == str.length() {
                        userId = s
                        s = ""
                    } else if wordCount > -1 && wordCount < 2 && c.asciiValue == Constants.CH_SPACE {
                        wordCount += 1
                        s.append(c)
                        state = 4
                        if i + 1 == str.length() {
                            userId = s
                            s = ""
                        }
                    } else if c.asciiValue == Constants.CH_ATRT {
                        if !(prefix == "") {
                            userMap[prefix] = s
                        }
                        userId = s
                        s = ""
                        state = 5
                    } else {
                        let u: String = s
                        if "from" == u.lowercased() {
                            prefix = "from"
                            s = ""
                            state = 5
                        }
                    }
                    break
                }
            case 5 :
                if c.isUppercase || c.isLowercase || c.asciiValue == Constants.CH_FSTP || isUPIDelimeter(c) {
                    state = 5
                } else if c.isNumber {
                    if isUPIDelimeter(str.charAt(i - 1)) {
                        s.append(c)
                        state = 6
                    } else {
                        state = 5
                    }
                } else {
                    if i >= 2 && "to" == str.substring(i - 2, i).lowercased() {
                        prefix = "to"
                        s = String()
                        state = 4
                    } else {
                        i = -1
                        state = -1
                    }
                }
                break
            case 6 :
                if c.isNumber {
                    s.append(c)
                    state = 6
                } else {
                    if s.length() > 6 {
                        refId = s
                    }
                    s = String()
                    i = -1
                    state = -1
                }
                break
            default :
                return nil
            }
            i += 1
        }
        return refId
    }
    
    public func numberParse(_ str: String) -> Triplet<Int, String, String>? {
        var state: Int = 1, i: Int = 0
        var currencyPossible: Bool = false
        var num: String = String()
        var c: Character
        while state > 0 && i < str.length() {
            c = str.charAt(i)
            switch state {
            case 1 :
                if c.isNumber || c == "-" {
                    state = 2
                    num.append(c)
                } else {
                    state = -1
                }
                break
            case 2 :
                if c.isNumber {
                    num.append(c)
                } else if c.asciiValue == Constants.CH_COMA {
                    break
                } else if c.asciiValue == Constants.CH_FSTP {
                    num.append(c)
                    state = 3
                } else if c == "\n" {
                    break
                } else {
                    state = -1
                }
                break
            case 3 :
                if c.isNumber {
                    currencyPossible = true
                    num.append(c)
                } else {
                    if !currencyPossible && num.length() > 0 {
                        num.remove(at: num.index(before: num.endIndex))
                    }
                    state = -1
                }
                break
            default :
                return nil
            }
            i += 1
        }
        if i == str.length() {
            i += 1
        }
        if state == -1 && num.length() == 0 {
            return nil
        } else if currencyPossible {
            return Triplet(i - 1, b_: num, c_: Constants.TY_AMT)
        } else {
            return Triplet(i - 1, b_: num, c_: Constants.TY_NUM)
        }
    }
    
    public func smsCode(_ str: String, _ indRead: Int) -> Bool {
        
        var state: Int = 1, i: Int = indRead + 1
        var c: Character
        var smsCode: String = String("")
        var legit: Bool = false
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
            case 1 :
                if (c.asciiValue == Constants.CH_COLN || c.asciiValue == Constants.CH_HYPH) && i < indRead+3 {
                    state = 1
                } else if c.isUppercase || c.asciiValue == Constants.CH_SPACE {
                    smsCode.append(c)
                    state = 1
                } else if c.asciiValue == Constants.CH_LSTN || c.asciiValue == Constants.CH_RBKT {
                    smsCode.append(c)
                    state = 2
                } else {
                    if i > indRead + 4 {
                        legit = true
                    }
                    state = -1
                }
                break
            case 2 :
                if c.isLetter || c.asciiValue == Constants.CH_SPACE || c.isNumber {
                    smsCode.append(c)
                    state = 2
                } else if c.asciiValue == Constants.CH_GTTN || c.asciiValue == Constants.CH_LBKT {
                    smsCode.append(c)
                    state = 1
                } else {
                    state = -1
                }
                break
            default :
                return legit
            }
            i += 1
        }
        return legit
    }
    
    public func mailIdParse(_ str: String) -> Int? {
        
        var state: Int = 1, i: Int = 0
        var c: Character
        var countBefAtrt: Int = 0, labelCounter: Int = 0, atrtIdx: Int = 0, dotCountAfterAtrt: Int = 0
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
            case 1 :
                if c.asciiValue == Constants.CH_ATRT && (i-countBefAtrt > 1) {
                    state = 2
                    atrtIdx = i
                } else if c.asciiValue == Constants.CH_FSTP {
                    if (i - 1 > 0 && str.charAt(i-1).asciiValue ==  Constants.CH_FSTP) || (i + 1 < str.length() && str.charAt(i+1).asciiValue == Constants.CH_ATRT) {
                        state = -1
                    }
                } else if c.asciiValue == Constants.CH_SPACE {
                    state = -1
                }
                break
            case 2 :
                if c.asciiValue == Constants.CH_SPACE || i == str.length()-1 || c.asciiValue == Constants.CH_LSBTE || c.asciiValue == Constants.CH_GTTN {
                    if (str.charAt(i-1).asciiValue == Constants.CH_HYPH || dotCountAfterAtrt == 0) || labelCounter <= 2 {
                        state = -1
                        break
                    }
                    return i
                } else if c.asciiValue == Constants.CH_SLSH || c.asciiValue == Constants.CH_EQLS || c.asciiValue == Constants.CH_QUEST || c.asciiValue == Constants.CH_LSTN || c.asciiValue == Constants.CH_GTTN || c.asciiValue == Constants.CH_ATRT {
                    state = -1
                    break
                } else if c.asciiValue == Constants.CH_HYPH {
                    if i-1 == atrtIdx {
                        state = -1
                    }
                } else if c.asciiValue == Constants.CH_FSTP {
                    labelCounter = 1
                    if i + 1 < str.length() && str.charAt(i+1).asciiValue != Constants.CH_SPACE {
                        dotCountAfterAtrt += 1
                    }
                    if i + 1 < str.length() && str.charAt(i+1).asciiValue == Constants.CH_SPACE && dotCountAfterAtrt > 0 {
                        labelCounter = 3
                    }
                } else if !c.isLetter && !c.isNumber && c.asciiValue != Constants.CH_FSTP {
                    state = -1
                } else if labelCounter > 63 {
                    state = -1
                }
                labelCounter += 1
                break
            default :
                return i
            }
            i += 1
        }
        return nil
    }
    
    public func reCheckForAccount(_ str: String) -> Pair<Int, String?>? {
        
        var state: Int = 1, i: Int = 0, num: Int = 0
        var c: Character
        var account: Bool = false
        var sb: String = String("")
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
            case 1 :
                if c.isLetter {
                    state = 2
                } else if c.isNumber {
                    sb.append(c)
                    num += 1
                    state = 2
                } else {
                    state = -1
                }
                break
            case 2 :
                if c.isLetter || c.asciiValue == Constants.CH_SLSH || c.asciiValue == Constants.CH_HYPH {
                    num = 0
                    state = 2
                } else if c.isNumber {
                    sb.append(c)
                    num += 1
                    state = 2
                } else {
                    num = 0
                    state = -1
                }
                break
            default :
                return nil
            }
            if num >= 4 {
                account = true
            }
            i += 1
        }
        if account {
            if let p = instrnoValidate(sb) {
                return Pair(i - 1, p)
            } else {
                return Pair(i - 1, nil)
            }
        }
        return nil
    }
    
    private func instrnoValidate(_ numString: String) -> String? {
        var res: String = numString
        if numString.length() < 4 {
            return nil
        } else {
            res = numString.substring(numString.length() - 4)
        }
        return res
    }
    
    public func checkForId(_ str: String, _ startIndex: Int) -> Pair<Int, String>? {
        
        var state: Int = 1, i: Int = 0
        var c: Character
        var haveSeenUpper: Bool = false, haveSeenLower: Bool = false, haveSeenNumber: Bool = false
        var validID: Bool = false
        var sb: String = String("")
        
        if i < str.length() && str.charAt(i).asciiValue == Constants.CH_SQOT {
            i += 1
        }
        
        while state > 0 && i < str.length() {
            
            c = str.charAt(i)
            
            switch state {
            case 1 :
                if c.isNumber || c.isLetter {
                    if c.isUppercase {
                        haveSeenUpper = true
                    } else if c.isLowercase {
                        haveSeenLower = true
                    } else {
                        haveSeenNumber = true
                    }
                    sb.append(c)
                    state = 2
                } else {
                    state = -1
                }
                break
            case 2 :
                if c.isNumber || c.isLetter || c.asciiValue == Constants.CH_UNSC {
                    if c.isUppercase {
                        haveSeenUpper = true
                    } else if c.isLowercase {
                        haveSeenLower = true
                    } else {
                        haveSeenNumber = true
                    }
                    sb.append(c)
                    state = 2
                } else if c.asciiValue == Constants.CH_SQOT || (c.asciiValue == Constants.CH_HYPH && !(i + 1 < str.length() && str.charAt(i+1).asciiValue == Constants.CH_SPACE) ) {
                    state = 2
                } else if i + 3 < str.length() && str.substring(i, i + 3) == " - " && (str.charAt(i + 3).isLetter || str.charAt(i + 3).isNumber) {
                    if let id = checkForId(str.substring(i + 3), startIndex + i) {
                        sb.append(id.getB())
                        state = -1
                    } else {
                        state = -1
                    }
                } else {
                    state = -1
                }
                break
            default :
                return nil
            }
            i += 1
        }
        if haveSeenUpper {
            if !haveSeenNumber {
                validID = !haveSeenLower
            } else {
                
                validID = true
            }
        } else {
            if !haveSeenNumber {
                validID = false
            } else {
                validID = haveSeenLower
            }
        }
        if sb.length() > 0 && validID {
            return Pair(i - 1, sb)
        }
        return nil
    }
    
     private func lookAheadIntegerForUPI(_ sentence: String) -> Int {
        
        let index: Int = 0
        var c: Character
        
        for index in 0...sentence.length() {
            
            c = sentence.charAt(index)
            
            if isUPIDelimeter(c) || c.isLowercase || c.isUppercase {
                continue
            } else if c.isNumber {
                if (index + 1) < sentence.length() && sentence.charAt(index + 1).isNumber {
                    break
                } else {
                    continue
                }
            } else {
                return -1
            }
        }
        return index
    }
    
    private func isUPIDelimeter(_ c: Character) -> Bool {
        return c.asciiValue == Constants.CH_HYPH || c.asciiValue == Constants.CH_SLSH || c.asciiValue == Constants.CH_STAR
    }
