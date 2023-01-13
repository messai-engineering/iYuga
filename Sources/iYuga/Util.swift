import Foundation
func isHour(_ c1 : Character,_ c2 : Character) -> Bool {
    return (((c1 == "0" || c1 == "1") && c2.isNumber) || (c1 == "2" && (c2 == "0" || c2 == "1" || c2 == "2" || c2 == "3" || c2 == "4")));
}

func isDateOperator(_ c : Character) -> Bool {
    return c.asciiValue == Constants.CH_SLSH || c.asciiValue == Constants.CH_HYPH || c.asciiValue == Constants.CH_SPACE;
}

func isDelimiter(_ c : Character) -> Bool {
    return c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_FSTP || c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_RBKT;
}

func meridienTimeAhead(_ str: String, _ i: Int) -> Bool {
    let amOrPmStartAhead: Bool = i+1 < str.count && (str[i]=="a" || str[i]=="p") && str[i+1]=="m" ;
    if (amOrPmStartAhead == false) {
        return false;
    }
    let isWordEndAtMeridien: Bool = ( i+2 >= str.count );
    if (isWordEndAtMeridien) {
        return true;
    }
    let c : Character = str[i+2];
    let checkIfJustWordStart : Bool = (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_FSTP || c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_RBKT ||  c.asciiValue == Constants.CH_HYPH || c.asciiValue == Constants.CH_NLINE) ;  //am or pm ahead but just a  word starting with am/pm like amp
    return checkIfJustWordStart;
}

func isTimeOperator(_ c : Character) -> Bool {
    return c.asciiValue == Constants.CH_COLN; //colon
}

func utilCheckTypes(_ root : RootTrie, _ type : String, _ word : String) -> Pair<Int, String>? {
    var i : Int = 0;
    var t : GenTrie = root.next[type]!;
    while i < word.count {
        let ch = word[i]
        if (t.leaf && !(t.next[ch] != nil) && isTypeEnd(ch: ch)) {
            return Pair(i - 1, t.token!);
        }
        if (t.child && t.next[ch] != nil) {
            t = t.next[ch]!;
        } else{
            break;
        }
        i = i + 1
    }
    if (t.leaf && i == word.count) {
        return Pair(i - 1, t.token!);
    }

    // All months across languages start with same alphabet.While supporting new language,review this condition.
    // if the 1st char doesnt match the trie,its not a month. Save further overhead.
    if(type == "FSA_MONTHS" && i<1){
        return nil;
    }

    if(type == "FSA_MONTHS" || type  == "FSA_DAYS"){
        return checkNonEngMonth(i, word, type);
    }

    return nil;
}

func checkNonEngMonth(_ i : Int, _ word : String, _ type : String) -> Pair<Int, String>? {
    var j = i;
    let map : Dictionary = type == "FSA_MONTHS" ? Constants.month : Constants.day;
    var ch : Character? = nil;
    if (j != word.count) {
        while (j < word.count && (ch == nil || !isTypeEnd(ch: ch!))) {
            ch = word[j];
            j = j + 1;
        }
    }
    // It could be just "June" Or "June, 31".
    let toCheck : String = (j == word.count && (ch == nil || !isTypeEnd(ch: ch!))) ? word.substring(with: 0..<j) : word.substring(with: 0..<j-1);
    for (key, value) in map {
        if (key.contains(toCheck)) {
            return Pair(j - 1, value)
        }
    }
   
    return nil;
}

func isTypeEnd(ch : Character) -> Bool {
    return (ch.isNumber || ch.asciiValue == Constants.CH_FSTP || ch.asciiValue == Constants.CH_SPACE || ch.asciiValue == Constants.CH_HYPH || ch.asciiValue == Constants.CH_COMA || ch.asciiValue == Constants.CH_SLSH || ch.asciiValue == Constants.CH_RBKT || ch.asciiValue == Constants.CH_EXCL || ch.asciiValue == Constants.CH_PLUS || ch.asciiValue == Constants.CH_STAR || ch == "\r" || ch == "\n" || ch == "\'");
}

func isUpperAlpha(str : String?) -> Bool {
    if (str == nil || str?.count == 0) {
        return false;
    }
    for ch in (str!) {
        if (!ch.isLetter || (ch.isLetter && !ch.isUppercase)) {
            return false;
        }
    }
    return true;
}

func isLowerAlpha(str : String?) -> Bool {
    if (str == nil || str?.count == 0) {
        return false;
    }
    for ch in (str!) {
        if (!ch.isLetter || (ch.isLetter && !ch.isLowercase)) {
            return false;
        }
    }
    return true;
}

func isAlpha(str : String?) -> Bool {
    if (str == nil || str?.count == 0) {
        return false;
    }
    for ch in (str!) {
        if (!ch.isLetter) {
            return false;
        }
    }
    return true;
}

func parseStrToInt(text : String?) -> Int? {
    if(text == nil) {
        return nil
    }
    if(text != nil && (text!.isEmpty || text!.length() > 9)) {
        return nil
    }
    return Int(text!)
}

func checkForTimeRange(val : String?) -> Bool {
    if(val == nil) {
        return false
    }
    if(val != nil && (!val!.isNumber() || val!.length() < 7)) {
        return false
    }
    var fromTimeHour : Int = parseStrToInt(text: val!.substring(0,2))!
    var toTimeHour : Int = parseStrToInt(text: val!.substring(4,6))!
    if(fromTimeHour == nil || toTimeHour == nil) {
        return false
    }
    if(fromTimeHour < 24 && toTimeHour < 24) {
        return true
    }
    return false;
}

func checkForNumRange(val : String?) -> Bool {
    if(val == nil) {
        return false
    }
    if(val != nil && (val!.length() < 3 || !val!.contains("-") || val!.startsWith("00"))) {
        return false
    }
    let parts = val!.components(separatedBy: "-")
    if(parts.count != 2) {
        return false
    }
    if((parts[0].length() == 0 || parts[0].length() > 6) || (parts[1].length() == 0 || parts[1].length() > 6)) {
        return false
    }
    var lengthRelatedChecks : Bool = (parts[1].length() >= parts[0].length()) && (parts[1].length()-parts[0].length() < 2)
    var valChecks : Bool = (parts[0].isNumber() && parts[1].isNumber()) && ( parseStrToInt(text: parts[1])! - parseStrToInt(text: parts[0])! ) > 0
    if(lengthRelatedChecks && valChecks) {
        return true
    }
    return false
}

func addDaysToDate(date : Date, days : Int) -> String {
    var timeInterval = DateComponents(
      day: days,
      hour: 0,
      minute: 0,
      second: 0
    )
    let resDate = Calendar.current.date(byAdding: timeInterval, to: date)!
    return DateFormatter().string(from: resDate)
}

func addTimeStampSuffix(_ hour: String) -> String {
    return hour + ":00"
}

func getDateObject(dateStr : String) -> Date? {
    if let dt = Constants.dateTimeFormatter().date(from: dateStr) {
        return dt
    } else {
        return nil
    }
}



