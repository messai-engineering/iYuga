import Foundation

extension Dictionary where Key == String, Value: GenTrie {
    func containsKey(k: String) -> Bool {
        return self[k] != nil
    }
    
    func size() -> Int {
        return self.count
    }
    
    func get(k: String) -> GenTrie? {
        return self[k]
    }
}


public class Yuga {

    let root : RootTrie = RootTrie();
    private static let D_DEBUG : Bool = false;
    
    public init() {
        createRoot();
    }

    private func getRoot() -> RootTrie {
        return root;
    }

    private func createRoot() {
        root.next["FSA_MONTHS"] =  GenTrie();
        root.next["FSA_DAYS"] = GenTrie();
        root.next["FSA_TIMEPRFX"] = GenTrie();
        root.next["FSA_AMT"] = GenTrie();
        root.next["FSA_TIMES"] = GenTrie();
        root.next["FSA_TZ"] = GenTrie();
        root.next["FSA_DAYSFFX"] = GenTrie();
        root.next["FSA_UPI"] = GenTrie();
        
        seeding(type: Constants.FSA_MONTHS, root: root.next["FSA_MONTHS"]!);
        seeding(type: Constants.FSA_DAYS, root: root.next["FSA_DAYS"]!);
        seeding(type: Constants.FSA_TIMEPRFX, root: root.next["FSA_TIMEPRFX"]!);
        seeding(type: Constants.FSA_AMT, root: root.next["FSA_AMT"]!);
        seeding(type: Constants.FSA_TIMES, root: root.next["FSA_TIMES"]!);
        seeding(type: Constants.FSA_TZ, root: root.next["FSA_TZ"]!);
        seeding(type: Constants.FSA_DAYSFFX, root: root.next["FSA_DAYSFFX"]!);
        seeding(type: Constants.FSA_UPI, root: root.next["FSA_UPI"]!);
    }

    private func seeding(type : String, root : GenTrie) {
        var t : GenTrie;
        var c : Int = 0;
        for data in type.split(separator: ",") {
            let fsaCldr = String(data)
            c = c+1;
            t = root;
            let len : Int = fsaCldr.count;
            var i = 0
            while i < len {
                let ch : Character = fsaCldr[i];
                t.child = true;
                if (t.next[ch] == nil) {
                    t.next[ch] = GenTrie();
                }
                t = t.next[ch]!;
                if (i == len - 1) {
                    t.leaf = true;
                    t.token = fsaCldr.replacingOccurrences(of: ";", with: "")
                } else if (i < (len - 1) && fsaCldr[i + 1].asciiValue == UInt8(59)) { //semicolon
                    t.leaf = true;
                    t.token = fsaCldr.replacingOccurrences(of:";", with:"");
                    i = i + 1;//to skip semicolon
                }
                i = i + 1;
            }
        }
    }
    
    public func parseDate(str : String, config : Dictionary<String, String>) -> Pair<Int, Date> {
        return getIntegerDatePair(str, config)!;
    }
    
    private func getIntegerDatePair(_ str : String, _ configMap : Dictionary<String, String>) -> Pair<Int, Date>? {
        let p : Pair<Int, FsaContextMap>? =  parseInternal(str, configMap);
        if (p == nil) {
            return nil;
        }
        let d : Date? = p!.getB().getDate(config: configMap);
        if (d == nil) {
            return nil;
        }
        return Pair(Int((p?.getA())!) , d!);
    }


    public func parse(str : String, config : Dictionary<String, String>) -> Response? {
        return getResponse(str: str, config: config);
    }

    private func getResponse(str : String, config : Dictionary<String, String>) -> Response? {
        let p : Pair<Int, FsaContextMap>? = parseInternal(str, config);
        if (p == nil) {
            return nil;
        }
        let pr : Pair<String, Any>? = prepareResult(str: str, p: p!, config: config);
        
        return Response(type: (pr?.getA())!, valMap: p!.getB().getValMap(), inDate: pr?.getB() as Any, index: p!.getA())
    }
    
    private func prepareResult(str : String, p : Pair<Int, FsaContextMap>, config : Dictionary<String, String>) -> Pair<String, Any> {
        let index : Int = p.getA();
        let map : FsaContextMap = p.getB();
        if (map.getType()! == Constants.TY_DTE) {
            if (map.contains(Constants.DT_MMM) && map.size() < 3) {//may fix
                return Pair(Constants.TY_STR, str.substring(with: (0..<index)));
            }
            if (map.contains(Constants.DT_HH) && map.contains(Constants.DT_mm) && !map.contains(Constants.DT_D) && !map.contains(Constants.DT_DD) && !map.contains( Constants.DT_MM) && !map.contains(Constants.DT_MMM) && !map.contains(Constants.DT_YY) && !map.contains( Constants.DT_YYYY)) {
                map.setType(Constants.TY_TME, nil);
                // TODO check this
                map.setVal(
                    name: "time",
                    val: (map.getFromMap(key: Constants.DT_HH)! + ":" + map.getFromMap(key: Constants.DT_mm)!)
                );
                return Pair(Constants.TY_TME, str.substring(with: (0..<index)));
            }
            let d: Date? = map.getDate(config: config);
            if (d != nil) {
                return Pair(p.getB().getType()!, d!);
            } else {
                return Pair(Constants.TY_STR, str.substring(with: (0..<index)));
            }
        } else {
            if (map.getFromMap(key: map.getType()!) != nil) {
                if (map.getType() == Constants.TY_ACC && configContextIsCURR(config)) {
                    return Pair(Constants.TY_AMT, map.getFromMap(key: map.getType()!)?.replacingOccurrences(of: "X", with: "") as Any);
                }
                return Pair(p.getB().getType()!, map.getFromMap(key: map.getType()!) as Any);
            } else {
                return Pair(p.getB().getType()!, str.substring(with: (0..<index)));
            }
        }
    }

    public func parse(str : String) -> Response? {
        let configMap : Dictionary<String, String> = generateDefaultConfig();
        return getResponse(str: str, config: configMap);
    }
    
    private func generateDefaultConfig() -> Dictionary<String, String> {
        var config : Dictionary<String, String> = Dictionary();
        config[Constants.YUGA_CONF_DATE] = Constants.dateTimeFormatter().string(from: Date());
        return config;
    }
    
    public func checkTypes(_ type : String, _ word : String) -> Pair<Int, String>? {
        return utilCheckTypes(getRoot(), type, word);
    }
    
    private func configContextIsCURR(_ config : Dictionary<String, String>) -> Bool {
       return config[Constants.YUGA_SOURCE_CONTEXT] != nil && config[Constants.YUGA_SOURCE_CONTEXT] == Constants.YUGA_SC_CURR;
    }
    
    
    private func skipForTZ(_ str : String, _ map : FsaContextMap) -> Int {
        var state : Int = 1, i : Int = 0;
        var c : Character;
        while state > 0 && i < str.length() {
            c = str.charAt(i);
            switch (state) {
                case 1:
                    if (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_PLUS || c.isNumber) {
                        state = 1;
                    } else if (c.asciiValue == Constants.CH_COLN) {
                        state = 2;
                    } else {
                        let s_ : String = str.substring(with: 0..<i).trimmingCharacters(in: .whitespaces)
                        if (s_.length() == 4 && s_.isNumber()) {//we captured a year after IST Mon Sep 04 13:47:13 IST 2017
                            map.put(Constants.DT_YYYY, s_);
                            state = -2;
                        } else {
                            state = -1;
                        }
                    }
                    break;
                case 2:
                    //todo re-adjust GMT time, current default +5:30 for IST
                    if (c.isNumber) {
                        state = 3;
                    } else {
                        state = -1;
                    }
                    break;
                case 3:
                    if (c.isNumber) {
                            state = 4;
                    } else {
                            state = -1;
                    }
                    break;
                case 4:
                    if (c.asciiValue == Constants.CH_SPACE) {
                            state = 5;
                    } else {
                            state = -2;
                    }
                    break;
                case 5:
                let sy : String = str.substring(with: i..<(i + 4));
                    if ((i + 3) < str.length() && sy.isNumber()) {
                        map.put(Constants.DT_YYYY, sy);
                        i = i + 3;
                    }
                    state = -2;
                    break;
                default:
                    break;
            }
            i+=1;
        }
        let s_ : String = str.substring(with: 0..<i).trimmingCharacters(in: .whitespaces);
        if (state == 1 && s_.length() == 4 && s_.isNumber()) {//we captured a year after IST Mon Sep 04 13:47:13 IST 2017
            map.put(Constants.DT_YYYY, s_);
        }
        return (state == -1) ? 0 : i;
    }
    
    private func skip(str : String) -> Int {
        var i : Int = 0;
        while i < str.count {
            if (str.charAt(i) == " " || str.charAt(i) == "," || str.charAt(i) == "(" || str.charAt(i) == ":") {
                i+=1;
            } else {
                break;
            }
        }
        return i;
    }

    private func nextSpace(_ str : String) -> Int {
        var i : Int = 0;
        while i < str.length() {
            if (str.charAt(i) == " ") {
                return i;
            } else {
                i += 1;
            }
        }
        return i;
    }

    private func accAmtNumPct(_ str : String, _ i : Int, _ map : FsaContextMap, _ config : Dictionary<String, String>) -> Int {
        //acc num amt pct
        var p : Pair<Int, String>?;
        let c : Character = str.charAt(i);
        let subStr = str.substring(i);
        if (c.asciiValue == Constants.CH_FSTP) { //dot
            if (i == 0 && configContextIsCURR(config)) {
                map.setType(Constants.TY_AMT, Constants.TY_AMT);
            }
            map.append(c);
            return 10;
        } else if (isInstrNumStart(c) && (lookAheadForInstr(str, i+2) != -1)) {//*Xx
            map.setType(Constants.TY_ACC, Constants.TY_ACC);
            map.append("X");
            return 11;
        } else if (c.asciiValue == Constants.CH_COMA) { //comma
            return 12;
        } else if (c.asciiValue == Constants.CH_PCT || (c.asciiValue == Constants.CH_SPACE && (i + 1) < str.length() && str.charAt(i + 1).asciiValue == Constants.CH_PCT)) { //pct
            map.setType(Constants.TY_PCT, Constants.TY_PCT);
            return -1;
        } else if (c.asciiValue == Constants.CH_PLUS) {
            if (configContextIsCURR(config)) {
                return -1;
            }
            map.setType(Constants.TY_STR, Constants.TY_STR);
            return 36;
        } else if (i > 0 && utilCheckTypes(getRoot(), "FSA_AMT", subStr) != nil) {
            p = utilCheckTypes(getRoot(), "FSA_AMT", subStr)
            if (p != nil) {
                map.setIndex(p!.getA());
                map.setType(Constants.TY_AMT, Constants.TY_AMT);
                map.append(getAmt(type: p!.getB()));
            }
            return 38;
        } else if (i > 0 && utilCheckTypes(getRoot(), "FSA_TIMES", subStr) != nil) {
            p = utilCheckTypes(getRoot(), "FSA_TIMES", subStr)
            if (p != nil) {
                let ind : Int = i + p!.getA();
                map.setIndex(ind);
                map.setType(Constants.TY_TME, nil);
                var s : String = str.substring(with: 0..<i);
                if (p!.getB() == "mins") {
                    s = "00" + s;
                }
                var valMap = map.getValMap()
                extractTime(s, &valMap);
                return 38;
            }
        }
        return -1;
    }

    private func getAmt(type : String) -> String {
        switch (type) {
            case "lakh":
                return "00000";
            case "lac":
                return "00000";
            case "k":
                return "000";
            default:
                return "";
        }
    }

    private func isInstrNumStart(_ c : Character) -> Bool {
        return (c.asciiValue == 42 || c.asciiValue == 88 || c.asciiValue == 120); //*xX
    }

    private func extractTime(_ str : String, _ valMap : inout Dictionary<String, String>, _ prefix: String...) {
        var pre : String = "";
        if (prefix.count > 0) {
            pre = prefix[0] + "_";
        }
        let pattern = "([0-9]{2})([0-9]{2})?([0-9]{2})?"
        let m = str.groups(for: pattern)
        let value = m[0] + ((m.count > 1) ? (":" + m[2]) : ":00")
        valMap[pre + "time"] = value
    }

    private func lookAheadForInstr(_ str : String, _ index : Int) -> Int {
        var c : Character;
        var i = index
        while i < str.length() {
            c = str.charAt(i);
            if (c.asciiValue == Constants.CH_FSTP) {
            }
            else if (c.asciiValue == 42 || c.asciiValue == 88 || c.asciiValue == 120 || c.isNumber) {
                return i;
            } else {
                return -1;
            }
            i+=1
        }
        return -1;
    }

    private func lookAheadForNum(_ str : String, _ index : Int) -> Int {
        var c : Character;
        var i = index+1
        while i < str.length() {
            c = str.charAt(i);
            if (c.asciiValue == Constants.CH_SPACE) {
            } else if (c.isNumber) {
                return i-1; //Assuming the index will get incremented by the loop to get to the num
            } else {
                return -1;
            }
            i+=1
        }
        return -1;
    }

    // for cases like 18th Jun, 12 pm
    private func lookAheadForMerid(_ str : String, _ index : Int) -> Bool {
        if ( index+4>=str.length()) {
            return false;
        }
        var i = index+1
        while i < index+4 {
            if(meridienTimeAhead(str,i) == true) {
                return true
            }
            i+=1
        }
        return false;
    }

    private func getPrevState(prevStates : Array<Int>) -> Int {
        let res : Int = prevStates.count-2;
        return ( res<0 ) ? 1: prevStates[res];
    }
    
    private func parseInternal(_ input : String, _ config : Dictionary<String, String>) -> Pair<Int, FsaContextMap>? {
        var state : Int = 1, i : Int = 0, comma_count : Int = 1;
        var p : Pair<Int, String>?;
        var c : Character;
        var map : FsaContextMap = FsaContextMap();
        let delimiterStack : DelimiterStack = DelimiterStack();
        // check
        var str = input.lowercased()
        var counter : Int = 0, insi : Int;
        var prevStates = [Int]();
        prevStates.append(state)
        while state > 0 && i < str.length() {
            c = str.charAt(i);
            if(prevStates[prevStates.count - 1] != state) {
                prevStates.append(state);
            }
            switch (state) {
                case 1:
                    if (c.isNumber) {
                        map.setType(Constants.TY_NUM, nil);
                        map.put(Constants.TY_NUM, c);
                        state = 2;
                    } else if ( utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))
                        if (p != nil) {
                            map.setType(Constants.TY_DTE, nil);
                            map.put(Constants.DT_MMM, p!.getB());
                            i += p!.getA();
                            state = 33;
                        }
                    } else if (utilCheckTypes(getRoot(), "FSA_DAYS", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_DAYS", str.substring(i))
                        if (p != nil) {
                            map.setType(Constants.TY_DTE, nil);
                            map.put(Constants.DT_DD, p!.getB());
                            i += p!.getA();
                            state = 30;
                        }
                    } else if (c.asciiValue == Constants.CH_HYPH) {//it could be a negative number
                        state = 37;
                    } else if (c.asciiValue == Constants.CH_LSBT) {//it could be an OTP
                        state = 1;
                    } else {
                        state = accAmtNumPct(str, i, map, config);
                        if (map.getType() == nil) {
                            return nil;
                        }
                        if (state == -1 && !(map.getType() == Constants.TY_PCT)) {
                            i = i - 1;
                        }
                    }
                    break;
                case 2:
                    if (c.isNumber) {
                        map.append(c);
                        state = 3;
                    } else if (isTimeOperator(c)) {
                        delimiterStack.push(c);
                        map.setType(Constants.TY_DTE, Constants.DT_HH);
                        state = 4;
                    } else if (isDateOperator(c) || c.asciiValue == Constants.CH_COMA) {
                        if (c.asciiValue == Constants.CH_SPACE && meridienTimeAhead(str, i + 1)){ //am or pm ahead
                            map.setType(Constants.TY_DTE, Constants.DT_HH);
                            map.put(Constants.DT_mm,"00");
                            state = 7;
                        } else {
                            delimiterStack.push(c);
                            map.setType(Constants.TY_DTE, Constants.DT_D);
                            state = 16;
                        }
                   } else if (utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i)) != nil) {
                       p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))
                       if (p != nil) {
                            map.setType(Constants.TY_DTE, Constants.DT_D);
                            map.put(Constants.DT_MMM, p!.getB());
                            i += p!.getA();
                            state = 24;
                       }
                    } else if(meridienTimeAhead(str,i)){ //am or pm ahead
                        map.setType(Constants.TY_DTE, Constants.DT_HH);
                        map.put(Constants.DT_mm,"00");
                        i-=1;
                        state = 7;
                    } else {
                        state = accAmtNumPct(str, i, map, config);
                        if (state == -1 && !(map.getType() == Constants.TY_PCT)) {
                            i = i - 1;
                        }
                    }
                    break;
                case 3:
                    if (c.isNumber) {
                        map.append(c);
                        state = 8;
                    } else if (isTimeOperator(c)) {
                        delimiterStack.push(c);
                        map.setType(Constants.TY_DTE, Constants.DT_HH);
                        state = 4;
                    }// [IL-77]. Rs 20 at msg end becomes currency Date instead of AMT in absence of extra newline character.
                    else if ((isDateOperator(c) && !configContextIsCURR(config)  ) || c.asciiValue == Constants.CH_COMA) {
                        if(c.asciiValue == Constants.CH_SPACE && meridienTimeAhead(str, i+1) ){ //am or pm ahead
                            map.setType(Constants.TY_DTE, Constants.DT_HH);
                            map.put(Constants.DT_mm,"00");
                            state = 7;
                        } else {
                            delimiterStack.push(c);
                            map.setType(Constants.TY_DTE, Constants.DT_D);
                            state = 16;
                        }
                    } else if (utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))
                        if (p != nil) {
                            map.setType(Constants.TY_DTE, Constants.DT_D);
                            map.put(Constants.DT_MMM, p!.getB());
                            i += p!.getA();
                            state = 24;
                        }
                    } else if(meridienTimeAhead(str,i)){ //am or pm ahead
                        map.setType(Constants.TY_DTE, Constants.DT_HH);
                        map.put(Constants.DT_mm,"00");
                        i-=1;
                        state = 7;
                    }else if (utilCheckTypes(getRoot(), "FSA_DAYSFFX", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_DAYSFFX", str.substring(i))
                        if (p != nil) {
                            map.setType(Constants.TY_DTE, Constants.DT_D);
                            i += p!.getA();
                            state = 32;
                        }
                    } else {
                        state = accAmtNumPct(str, i, map, config);
                        if (state == -1 && !(map.getType() == Constants.TY_PCT)) {
                            i = i - 1;
                        }
                    }
                    break;
                case 4: //hours to mins
                    if (c.isNumber) {
                        map.upgrade(c);//hh to mm
                        state = 5;
                    } else { //saw a colon randomly, switch back to num from hours
                        if (!map.contains(Constants.DT_MMM)) {
                            map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        }
                        i = i - 2; //move back so that colon is omitted
                        state = -1;
                    }
                    break;
                case 5:
                    if (c.isNumber) {
                        map.append(c);
                        state = 5;
                    } else if (c.asciiValue == Constants.CH_COLN) {
                        state = 6;
                    } else if (c == "a" && (i + 1) < str.length() && str.charAt(i + 1) == "m") {
                        i = i + 1;
                        state = -1;
                    } else if (c == "p" && (i + 1) < str.length() && str.charAt(i + 1) == "m") {
                        map.put(Constants.DT_HH, String(Int(map.get(Constants.DT_HH)!)! + 12));
                        i = i + 1;
                        state = -1;
                    } else if (utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i))
                        if (p != nil) {
                            i += p!.getA();
                            state = -1;
                        }
                    } else {
                        state = 7;
                    }
                    break;
                case 6: //for seconds
                    if (c.isNumber) {
                        map.upgrade(c);
                        if ((i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                            map.append(str.charAt(i + 1));
                            i = i + 1;
                            state = -1;
                        } else {
                            state = -1;
                        }
                    }
                    break;
                case 7:
                    if (c == "a" && (i + 1) < str.length() && str.charAt(i + 1) == "m") {
                        i = i + 1;
                        let hh : Int = Int(map.get(Constants.DT_HH)!)!;
                        if (hh == 12) {
                            map.put(Constants.DT_HH, String(0));
                        }
                    } else if (c == "p" && (i + 1) < str.length() && str.charAt(i + 1) == "m") {
                        let hh : Int = Int(map.get(Constants.DT_HH)!)!;
                        if (hh != 12) {
                            map.put(Constants.DT_HH, String(hh + 12));
                        }
                        i = i + 1;
                    } else if (utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i))
                        if (p != nil) {
                            i += p!.getA();
                        }
                    } else {
                        i = i - 2;
                    }
                    state = -1;
                    break;
                case 8:
                    if (c.isNumber) {
                        map.append(c);
                        state = 9;
                    } else {
                        state = accAmtNumPct(str, i, map, config);
                        if (c.asciiValue == Constants.CH_SPACE && state == -1 && (i + 1) < str.length() && str.charAt(i + 1).isNumber && !configContextIsCURR(config)) {
                            // Stop Rs 234 45 from becoming 23445
                            state = 12;
                        } else if (c.asciiValue == Constants.CH_HYPH && state == -1 && (i + 1) < str.length() && str.charAt(i + 1).isNumber && !configContextIsCURR(config) ) {
                            // currency check for case like "Rs 247-30D-25GB"
                            state = 45;
                        } else if (state == -1 && !(map.getType() == Constants.TY_PCT)) {
                            i = i - 1;
                        }
                    }
                    break;
                case 9:
                    if (isDateOperator(c)) {
                        // case like Rs 2687 23 jan
                        if(!configContextIsCURR(config)) {
                            delimiterStack.push(c);
                            state = 25;
                        }
                        else{
                            state = -1;
                        }
                    }
                    //handle for num case
                    else if (c.isNumber) {
                        map.append(c);
                        counter = 5;
                        state = 15;
                    } else {
                        // Case like "2687, 22 dec", the comma is used later to break at space
                        if(c.asciiValue == Constants.CH_COMA){
                            delimiterStack.push(c);
                        }
                        state = accAmtNumPct(str, i, map, config);
                        if (state == -1 && !(map.getType() == Constants.TY_PCT)) {//NUM
                            i = i - 1;
                        }
                    }
                    break;
                case 10:
                    if (c.isNumber) {
                        map.append(c);
                        map.setType(Constants.TY_AMT, Constants.TY_AMT);
                        state = 14;
                    } else { //saw a fullstop randomly
                        print(map.pop());//remove the dot which was appended
                        i = i - 2;
                        state = -1;
                    }
                    break;
                case 11:
                    if (c.asciiValue == 42 || c.asciiValue == 88 || c.asciiValue == 120) {//*Xx
                            map.append("X");
                    } else if (c.asciiValue == Constants.CH_HYPH) {
                            state = 11;
                    } else if (c.isNumber) {
                            map.append(c);
                            state = 13;
                    } else if (c == " " && ((i + 1) < str.length() && (str.charAt(i + 1).asciiValue == 42 || str.charAt(i + 1).asciiValue == 88 || str.charAt(i + 1).asciiValue == 120 || str.charAt(i + 1).isNumber))) {
                            state = 11;
                    } else if (c.asciiValue == Constants.CH_FSTP) {
                        insi = lookAheadForInstr(str, i)
                        if (insi > 0) {
                            var x : Int = insi-i;
                            while x>0 {
                                map.append("X");
                                x-=1;
                            }
                            i = (str.charAt(insi).isNumber) ? insi-1 : insi;
                        }
                    } else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 12:
                    if (c.isNumber) {
                        // case like "729 613 is your Instagram code" Where the num was captured as AMT.
                        if(i > 2 && str.charAt(i-1).asciiValue == Constants.CH_SPACE && str.charAt(i-2).isNumber) {
                            map.append(c);
                            state=15;
                        } else {
                            map.setType(Constants.TY_AMT, Constants.TY_AMT);
                            map.append(c);
                        }
                    } else if (c.asciiValue == Constants.CH_COMA) {//comma
                        comma_count += 1;
                        state = 12;
                    } else if (c.asciiValue == Constants.CH_FSTP) { //dot
                        map.append(c);
                        state = 10;
                    } else if (c.asciiValue == Constants.CH_HYPH && (i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                        state = 39;
                    } else if (getPrevState(prevStates: prevStates) == 37 && c.asciiValue == Constants.CH_HYPH && utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i + 1)) != nil) { // possibly date: -31-May-2021
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i + 1))
                        if (p != nil) {
                            i = -1;
                            map = FsaContextMap();
                            str=str.substring(1);
                            state=1;
                        }
                    }   else if(c.asciiValue == Constants.CH_SPACE && lookAheadForNum(str,i) != -1 ){
                        // BLNC: NUM MOBNUM case like "25,011 868886999"
                        if(delimiterStack.pop().asciiValue == Constants.CH_COMA) {
                            state = -1;
                        } else {
                            state=15;
                        }
                    } else {
                        if (i - 1 > 0 && str.charAt(i - 1).asciiValue == Constants.CH_COMA) {
                            i = i - 2;
                            
                        } else if (i - 3 > 0 &&  str.charAt(i - 3).asciiValue == Constants.CH_COMA && comma_count == 1) { //handling 370,60
                            let c1 = map.pop();
                            let c2 = map.pop();
                            map.append(".");
                            map.append(c2);
                            map.append(c1);
                        }  else {
                            i = i - 1;
                        }
                        if(comma_count > 1 && (map.getType() == Constants.TY_AMT)) {
                            map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        }
                        state = -1;
                    }
                    break;
                case 13:
                    if (c.isNumber) {
                        map.append(c);
                    } else if (c.asciiValue == 42 || c.asciiValue == 88 || c.asciiValue == 120) {//*Xx
                        map.append("X");
                    }else if (c.asciiValue == Constants.CH_FSTP && configContextIsCURR(config)) { //LIC **150.00 fix
                        map.setType(Constants.TY_AMT, Constants.TY_AMT);
                        map.put(Constants.TY_AMT, (map.getFromMap(key: Constants.TY_AMT)?.replacingOccurrences(of: "X", with: ""))!);
                        map.append(c);
                        state = 10;
                    } else if (c.asciiValue == Constants.CH_FSTP) {
                        insi = lookAheadForInstr(str, i)
                        if (insi > 0) {
                            var x = insi-i;
                            while x > 0 {
                                map.append("X");
                                x -= 1
                            }
                            i = (str.charAt(insi).isNumber) ? (insi-1) : insi;
                        }
                    }
                    // USSD codes start with * and end with #. Second condition check for string like "*334# for"
                    else if(c.asciiValue == Constants.CH_HASH && ((i == str.length()-1) || str.charAt(i+1).asciiValue == Constants.CH_SPACE)) {
                        map.setType(type: Constants.TY_USSD);
                    }  else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 14:
                    if (c.isNumber) {
                        map.append(c);
                    } else if (c.asciiValue == Constants.CH_PCT) {
                        map.setType(Constants.TY_PCT, Constants.TY_PCT);
                        state = -1;
                    } else if ((c == "k" || c == "c") && (i + 1) < str.length() && str.charAt(i + 1) == "m") {
                        map.setType(Constants.TY_DST, Constants.TY_DST);
                        i += 1;
                        state = -1;
                    } else if ((c == "k" || c == "m") && (i + 1) < str.length() && str.charAt(i + 1) == "g") {
                        map.setType(Constants.TY_WGT, Constants.TY_WGT);
                        i += 1;
                        state = -1;
                    } else {
                        if (c.asciiValue == Constants.CH_FSTP && ((i + 1) < str.length() && str.charAt(i + 1).isNumber)) {
                            let samt : String = map.get(map.getType()!)!;
                            if (samt.contains(".")) {
                                let samtarr = samt.components(separatedBy: "\\.");
                                if (samtarr.count == 2) {
                                    map.setType(type: Constants.TY_DTE);
                                    map.put(Constants.DT_D, samtarr[0]);
                                    map.put(Constants.DT_MM, samtarr[1]);
                                    state = 19;
                                    break;
                                }
                            }
                        }
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 15:
                    if (c.isNumber) {
                        counter += 1;
                        map.append(c);
                    } else if (c.asciiValue == Constants.CH_COMA && counter < 10) { //comma  :condition altered for case : "9633535665, 04872426313"
                        state = 12;
                    } else if (c.asciiValue == Constants.CH_FSTP) { //dot
                        map.append(c);
                        state = 10;
                    } else if ((c.asciiValue == 42 || c.asciiValue == 88 || c.asciiValue == 120) && (i + 1) < str.length() && ((str.charAt(i + 1).isNumber || str.charAt(i + 1).asciiValue == Constants.CH_HYPH) || str.charAt(i + 1).asciiValue == 42 || str.charAt(i + 1).asciiValue == 88 || str.charAt(i + 1).asciiValue == 120)) {//*Xx
                        map.setType(Constants.TY_ACC, Constants.TY_ACC);
                        map.append("X");
                        state = 11;
                    }
                    // Condition changed to seperate two mob nums seperated by space "8289957757 9388566777"
                else if (c.asciiValue == Constants.CH_SPACE && counter < 10 && (i + 2) < str.length() && str.charAt(i + 1).isNumber && str.charAt(i + 2).isNumber) {
                        state = 41;
                    }

                    else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 16:
                    if (c.isNumber) {
                        map.upgrade(c);
                        state = 17;
                    } else if (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_COMA) {
                        state = 16;
                    } else if (utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))
                        if (p != nil) {
                            map.put(Constants.DT_MMM, p!.getB());
                            i += p!.getA();
                            state = 24;
                        }
                    }
                    //we should handle amt case, where comma led to 16 as opposed to 12
                    else if (c.asciiValue == Constants.CH_FSTP) { //dot
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        map.append(c);
                        state = 10;
                    } else if (i > 0 && utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i))
                        if (p != nil) {
                            map.setType(Constants.TY_TME, nil);
                            var s : String = str.substring(0, i);
                            if (p!.getB() == "mins" || p!.getB() == "minutes") {
                                s = "00" + s;
                            }
                            extractTime(s, &(map.valMap));
                            i = i + p!.getA();
                            state = -1;
                        }
                    } else {//this is just a number, not a date
                        //to cater to 16 -Nov -17
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i + 1))
                        if (delimiterStack.pop().asciiValue == Constants.CH_SPACE && c.asciiValue == Constants.CH_HYPH && i + 1 < str.length() && (str.charAt(i + 1).isNumber || p != nil)) {
                            state = 16;
                        } else {
                            map.setType(Constants.TY_NUM, Constants.TY_NUM);
                            var j : Int = i;
                            while !(str.charAt(j).isNumber) {
                                j -= 1;
                            }
                            i = j;
                            state = -1;
                        }
                    }
                    break;
                case 17:
                    if (c.isNumber) {
                        map.append(c);
                        state = 18;
                    } else if (isDateOperator(c)) {
                        delimiterStack.push(c);
                        state = 19;
                    }
                    //we should handle amt case, where comma led to 16,17 as opposed to 12
                else if (c.asciiValue == Constants.CH_COMA && delimiterStack.pop().asciiValue == Constants.CH_COMA) { //comma
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        state = 12;
                    } else if (c.asciiValue == Constants.CH_FSTP && delimiterStack.pop().asciiValue == Constants.CH_COMA) { //dot
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        map.append(c);
                        state = 10;
                    } else {
                        map.setType(Constants.TY_STR, Constants.TY_STR);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 18:
                    if (isDateOperator(c)) {
                        delimiterStack.push(c);
                        state = 19;
                    }
                    //we should handle amt case, where comma led to 16,17 as opposed to 12
                    else if (c.isNumber && delimiterStack.pop().asciiValue == Constants.CH_COMA) {
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        state = 12;
                        map.append(c);
                    } else if (c.isNumber && delimiterStack.pop().asciiValue == Constants.CH_HYPH) {
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        state = 42;
                        map.append(c);
                    } else if (c.asciiValue == Constants.CH_COMA && delimiterStack.pop().asciiValue == Constants.CH_COMA) { //comma
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        state = 12;
                    } else if (c.asciiValue == Constants.CH_FSTP && delimiterStack.pop().asciiValue == Constants.CH_COMA) { //dot
                        map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        map.append(c);
                        state = 10;
                    } else if (c.asciiValue == Constants.CH_FSTP && map.contains(Constants.DT_D) && map.contains(Constants.DT_MM)) { //dot
                        state = -1;
                    }else {
                        map.setType(Constants.TY_STR, Constants.TY_STR);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 19: //year
                    if (c.isNumber) {
                        map.upgrade(c);
                        state = 20;
                    }
                    // Handle case like 05 -08 -2017 18:33:55. where - present before year
                    else if(c.asciiValue == Constants.CH_HYPH && i + 1 < str.length() && str.charAt(i + 1).isNumber){
                        state=19;
                    }
                    else {
                        let day : Bool = (nextSpace(str.substring(i)) >= 3) && str.substring(with: i..<i+3) == "day" ;
                        let working : Bool = (nextSpace(str.substring(i)) >= 4) && str.substring(with: i..<i+4) == "work";
                        let business : Bool = (nextSpace(str.substring(i)) >= 8) && str.substring(with: i..<i+8) == "business";
                        // 1-2 Days, 3-4 working days, 2-3 business days
                        if(c.isLetter && (day || working || business) ){
                            let laterDay : String = map.get("MM")!;
                            map = FsaContextMap();
                            map.setType(Constants.TY_NUM, Constants.TY_NUM);
                            map.put(Constants.TY_NUM,laterDay);
                            i = i-2;
                            state = -1;
                            break;
                        }
                        i = i - 2;
                        state = -1;
                    }
                    break;
                case 20: //year++
                    if (c.isNumber) {
                        map.append(c);
                        state = 21;
                    } else if (c == ":") {
                        if(map.contains(Constants.DT_YY)) {
                            map.convert(Constants.DT_YY, Constants.DT_HH);
                        } else if(map.contains(Constants.DT_YYYY)) {
                            map.convert(Constants.DT_YYYY, Constants.DT_HH);
                        }
                        state = 4;
                    } else {
                        map.remove(Constants.DT_YY);//since there is no one number year
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 21:
                    if (c.isNumber) {
                        map.upgrade(c);
                        state = 22;
                    } else if (c == ":") {
                        if(map.contains(Constants.DT_YY)) {
                            map.convert(Constants.DT_YY, Constants.DT_HH);
                        } else if(map.contains(Constants.DT_YYYY)) {
                            map.convert(Constants.DT_YYYY, Constants.DT_HH);
                        }
                        state = 4;
                    } else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 22:
                    if (c.isNumber) {
                        map.append(c);
                        state = -1;
                    } else {
                        map.remove(Constants.DT_YYYY);//since there is no three number year
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 24:
                    if (isDateOperator(c) || c.asciiValue == Constants.CH_COMA) {
                        delimiterStack.push(c);
                        state = 24;
                    } else if (c.isNumber) {
                        // IL-190
                        if(lookAheadForMerid(str,i)){
                            state = -1;
                            i=i-2;
                        }else{
                            map.upgrade(c);
                            state = 20;
                        }
                    } else if (c.asciiValue == Constants.CH_SQOT && (i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                        state = 24;
                    } else if (c == "|") {
                        state = 24;
                    } else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 25://potential year start comes here
                    if (c.isNumber) {
                        map.setType(Constants.TY_DTE, Constants.DT_YYYY);
                        map.put(Constants.DT_MM, c);
                        state = 26;
                    } else if (i > 0 && utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_TIMES", str.substring(i))
                        if (p != nil) {
                            map.setType(Constants.TY_TME, nil);
                            var s : String = str.substring(0, i);
                            if (p!.getB() == "mins") {
                                s = "00" + s;
                            }
                            extractTime(s, &(map.valMap));
                            i = i + p!.getA();
                            state = -1;
                        }
                    } else {
                        //it wasn"t year, it was just a number
                        i = i - 2;
                        state = -1;
                    }
                    break;
                case 26:
                    if (c.isNumber) {
                        map.append(c);
                        state = 27;
                    } else {
                        map.setType(Constants.TY_STR, Constants.TY_STR);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 27:
                    if (isDateOperator(c)) {
                        delimiterStack.push(c);
                        state = 28;
                    } else if (c.isNumber) {//it was a number, most probably telephone number
                        if ((map.getType() == Constants.TY_DTE)) {
                            map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        }
                        map.append(c);
                        if ((delimiterStack.pop().asciiValue == Constants.CH_SLSH || delimiterStack.pop().asciiValue == Constants.CH_HYPH) && i + 1 < str.length() && str.charAt(i + 1).isNumber && (i + 2 == str.length() || isDelimiter(str.charAt(i + 2)) || str.charAt(i + 2) == "/" )) {//flight time 0820/0950
                            map.setType(Constants.TY_TMS, Constants.TY_TMS);
                            map.append(str.charAt(i + 1));
                            i = i + 1;
                            state = -1;
                        } else if (delimiterStack.pop().asciiValue == Constants.CH_SPACE) {
                            state = 41;
                        } else {
                            state = 12;
                        }
                    } else if (c.asciiValue == 42 || c.asciiValue == 88 || c.asciiValue == 120) {//*Xx
                        map.setType(Constants.TY_ACC, Constants.TY_ACC);
                        map.append("X");
                        state = 11;
                    } else {
                        map.setType(Constants.TY_STR, Constants.TY_STR);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 28:
                    if (c.isNumber) {
                        map.put(Constants.DT_D, c);
                        state = 29;
                    } else {
                        map.setType(Constants.TY_STR, Constants.TY_STR);
                        i = i - 2;
                        state = -1;
                    }
                    break;
                case 29:
                    if (c.isNumber) {
                        map.append(c);
                    } else {
                        i = i - 1;
                    }
                    state = -1;
                    break;
                case 30:
                    if (c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_SPACE) {
                        state = 30;
                    } else if (c.isNumber) {
                        map.put(Constants.DT_D, c);
                        state = 31;
                    } else {
                        map.setType(type: Constants.TY_DTE);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 31:
                    if (c.isNumber) {
                        map.append(c);
                        state = 32;
                    } else if (utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i)) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))
                        if (p != nil) {
                            map.put(Constants.DT_MMM, p!.getB());
                            i += p!.getA();
                            state = 24;
                        }
                    } else if (c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_SPACE) {
                        state = 32;
                    } else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 32:
                    if ((utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_MONTHS", str.substring(i))
                        if (p != nil) {
                            map.put(Constants.DT_MMM, p!.getB());
                            i += p!.getA();
                            state = 24;
                        }
                    } else if (c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_SPACE) {
                        state = 32;
                    } else if ((utilCheckTypes(getRoot(), "FSA_DAYSFFX", str.substring(i))) != nil) {
                        p = utilCheckTypes(getRoot(), "FSA_DAYSFFX", str.substring(i))
                        if (p != nil) {
                            i += p!.getA();
                            state = 32;
                        }
                    } else {
                        var j : Int = i;
                        while !(str.charAt(j).isNumber)
                        {
                            j-=1;
                        }
                        i = j;
                        state = -1;
                    }
                    break;
                case 33:
                    if (c.isNumber) {
                        map.put(Constants.DT_D, c);
                        state = 34;
                    } else if (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_COMA || c.asciiValue == Constants.CH_HYPH){
                        state = 33;
                    } else if (getPrevState(prevStates: prevStates)==1 && c.asciiValue == Constants.CH_FSTP && lookAheadForNum(str,i) != -1 ) {
                        // case like "Dec. 31, 2017"
                        state=33;
                        i=lookAheadForNum(str,i);
                    } else {
                        map.setType(type: Constants.TY_DTE);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 34:
                    if (c.isNumber) {
                        map.append(c);
                        state = 35;
                    } else if (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_COMA) {
                        state = 35;
                    } else {
                        map.setType(type: Constants.TY_DTE);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 35:
                    if (c.isNumber) {
                        if(i>1 && str.charAt(i-1).isNumber) {
                            map.convert(Constants.DT_D, Constants.DT_YYYY);
                            map.append(c);
                        }
                        else {
                            map.put(Constants.DT_YY, c);
                        }
                        state = 20;
                    } else if (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_COMA) {
                        state = 40;
                    } else {
                        map.setType(type: Constants.TY_DTE);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 36:
                    if (c.isNumber) {
                        map.append(c);
                        counter+=1;
                    } else if (c.asciiValue == Constants.CH_FSTP && (i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                        map.append(c);
                        state = 10;
                    } else if (c.asciiValue == Constants.CH_HYPH && (i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                        delimiterStack.push(c);
                        map.append(c);
                        state = 16;
                    } else {
                        if (counter == 12 || str.substring(1, i).isNumber()){
                            map.setType(Constants.TY_NUM, Constants.TY_NUM);
                        } else {
                            return nil;
                        }
                        state = -1;
                    }
                    break;
                case 37:
                    if (c.isNumber) {
                        map.setType(Constants.TY_AMT, Constants.TY_AMT);
                        map.put(Constants.TY_AMT, "-");
                        map.append(c);
                        state = 12;
                    } else if (c.asciiValue == Constants.CH_FSTP) {
                        map.put(Constants.TY_AMT, "-");
                        map.append(c);
                        state = 10;
                    } else {
                        state = -1;
                    }
                    break;
                case 38:
                    i = map.getIndex()!;
                    state = -1;
                    break;
                case 39://instrno
                    if (c.isNumber) {
                        map.append(c);
                    } else {
                        map.setType(Constants.TY_ACC, Constants.TY_ACC);
                        state = -1;
                    }
                    break;
                case 40:
                    if (c.isNumber) {
                        map.put(Constants.DT_YY, c);
                        state = 20;
                    } else if (c.asciiValue == Constants.CH_SPACE || c.asciiValue == Constants.CH_COMA) {
                        state = 40;
                    } else {
                        map.setType(type: Constants.TY_DTE);
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 41://for phone numbers; same as 12 + space; coming from 27
                    if (c.isNumber) {
                        map.append(c);
                    } else if (c.asciiValue == Constants.CH_SPACE) {
                        // Seperate two mobile nums
                        if ( i>=11 && i+1 < str.length() && str.charAt(i + 1).isNumber) {
                            state = -1;
                            i-=1;
                        } else {
                            state = 41;
                        }
                    } else {
                        if ((i - 1) > 0 && str.charAt(i - 1).asciiValue == Constants.CH_SPACE) {
                            i = i - 2;
                        } else {
                            i = i - 1;
                        }
                        state = -1;
                    }
                    break;
                case 42: //18=12 case, where 7-2209 was becoming amt as part of phn support
                    if (c.isNumber) {
                        map.append(c);
                    } else if (c.asciiValue == Constants.CH_HYPH && (i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                        state = 39;
                    } else {
                        i = i - 1;
                        state = -1;
                    }
                    break;
                case 43: //1234567890@ybl
                    if (c.isLowercase || c.isNumber) {
                        map.setType(Constants.TY_VPD, Constants.TY_VPD);
                        map.append(delimiterStack.pop());
                        map.append(c);
                        state = 44;
                    } else {
                        state = -1;
                    }
                    break;
                case 44:
                    if (c.isLowercase || c.isNumber || c.asciiValue == Constants.CH_FSTP) {
                        map.append(c);
                        state = 44;
                    } else {
                        state = -1;
                    }
                    break;
                case 45:
                    if (c.isNumber) {
                        map.append(c);
                    } else if (c.asciiValue == Constants.CH_HYPH && (i + 1) < str.length() && str.charAt(i + 1).isNumber) {
                        state = 39;
                    } else {
                        if (i - 1 > 0 && str.charAt(i - 1).asciiValue == Constants.CH_COMA) {
                            i = i - 2;
                        } else {
                            i = i - 1;
                        }
                        state = -1;
                    }
                    break;
                default:
                    break;
            }
            i+=1;
            if (Yuga.D_DEBUG) {
                L.msg(str: "ch:" + String(c) + " state:" + String(state) + " map:" +  map.serializeValMap());
            }
        }
        if (map.getType() == nil) {
            return nil;
        }
        //sentence end cases
        if (state == 10) {
            print(map.pop());
            i = i - 1;
        } else if (state == 36) {
            if ((counter == 12 || str.substring(1, i).isNumber())) {
                map.setType(Constants.TY_NUM, Constants.TY_NUM);
            } else {
                return nil;
            }
        }

        if ((map.getType() == Constants.TY_AMT)) {
            if (
                !map.contains(map.getType()!) ||
                (
                    (map.get(map.getType()!)!.contains(".") && map.get(map.getType()!)!.components(separatedBy: ".")[0].length() > 8) ||
                    (!map.get(map.getType()!)!.contains(".") && map.get(map.getType()!)!.length() > 8)
                )
            ) {
                map.setType(Constants.TY_NUM, Constants.TY_NUM);
            }

            if (i - 3 > 0 && str.charAt(i-3).asciiValue == Constants.CH_COMA) {//handling 370,60
                let c1 = map.pop();
                let c2 = map.pop();
                map.append(".");
                map.append(c2);
                map.append(c1);
            }

            let j : Int = i + skip(str: str.substring(i));
            if(j<str.length()) {
                if ((str.charAt(j) == "k" || str.charAt(j) == "m" || str.charAt(j) == "g") && (j + 1) < str.length() && str.charAt(j + 1) == "b") {
                    map.setVal(name: "data", val: map.get(map.getType()!)!);
                    var sData : String = "";
                    switch (str.charAt(j)){
                        case "k":
                            map.setVal(name: "data_type",val: "KB");
                            sData = " KB";
                            break;
                        case "m":
                            map.setVal(name: "data_type",val: "MB");
                            sData = " MB";
                            break;
                        case "g":
                            map.setVal(name: "data_type",val: "GB");
                            sData = " GB";
                            break;
                        default:
                            break;
                    }
                    map.setType(Constants.TY_DTA, Constants.TY_DTA);
                    map.append(sData);
                    i = j+2;
                }else if (str.charAt(j) == "k"  && (j + 1) < str.length() && str.charAt(j + 1) == "g"){
                    map.setVal(name: "data",val: map.get(map.getType()!)!);
                    let sData : String = " KG";
                    map.setType(Constants.TY_WGT, Constants.TY_WGT);
                    map.append(sData);
                    i = j+2;
                }
                //TCANDROID-38937
                else if ((j + 2) < str.length() && str.charAt(j) == "t"  && str.charAt(j + 1) == "o" && str.charAt(j + 2) == "n"){
                    let sData : String = " ton";
                    map.setType(Constants.TY_WGT, Constants.TY_WGT);
                    map.append(sData);
                    i = j+2;
                }
                else if (str.charAt(j) == "x" && ((j + 1) == str.length() || ((j + 1) < str.length() && (str.charAt(j + 1) == " " || str.charAt(j + 1) == "." || str.charAt(j + 1) == ","))) ) {
                    map.setType(Constants.TY_MLT, Constants.TY_MLT);
                    map.append(str.substring(i,j+1));
                    i = j;
                }
            }
        }

        if ((map.getType() == Constants.TY_NUM)) {
            // Added last char is not space check that prevents "num" becoming a "str". Ex: "+919057235089 pin"
            if (
                i < str.length() &&
                str.charAt(i-1) != " " &&
                str.charAt(i).isLetter &&
                (config[Constants.YUGA_SOURCE_CONTEXT] == nil || !(Constants.YUGA_SC_CURR == config[Constants.YUGA_SOURCE_CONTEXT]) &&
                !(Constants.YUGA_SC_TRANSID == config[Constants.YUGA_SOURCE_CONTEXT]))
            ) {
                var j : Int = i;
                while (j < str.length() && str.charAt(j) != " ")
                    { j+=1; }
                map.setType(Constants.TY_STR, Constants.TY_STR);
                i = j;
            } else if(i+1 < str.length() && str.charAt(i).asciiValue == Constants.CH_SLSH && str.charAt(i+1).asciiValue == Constants.CH_HYPH ) {
                map.setType(Constants.TY_AMT, Constants.TY_AMT);
            } else if (map.get(Constants.TY_NUM) != nil) {
                if (map.get(Constants.TY_NUM)?.length() == 10 && (map.get(Constants.TY_NUM)?.charAt(0) == "9" || map.get(Constants.TY_NUM)?.charAt(0) == "8" || map.get(Constants.TY_NUM)?.charAt(0) == "7")) {
                    map.setVal(name: "num_class", val: Constants.TY_PHN);
                } else if (map.get(Constants.TY_NUM)?.length() == 12 && map.get(Constants.TY_NUM)!.startsWith("91")) {
                    map.setVal(name: "num_class", val: Constants.TY_PHN);
                } else if (map.get(Constants.TY_NUM)?.length() == 11 && map.get(Constants.TY_NUM)!.startsWith("18")) {
                    map.setVal(name: "num_class", val: Constants.TY_PHN);
                } else if (map.get(Constants.TY_NUM)?.length() == 11 && map.get(Constants.TY_NUM)!.charAt(0) == "0") {
                    map.setVal(name: "num_class", val: Constants.TY_PHN);
                } else {
                    if(map.get(Constants.TY_NUM) != nil && (map.get(Constants.TY_NUM)!.length() == 6 || map.get(Constants.TY_NUM)!.length() == 8) && config[Constants.YUGA_SOURCE_CONTEXT] != nil && config[Constants.YUGA_SOURCE_CONTEXT] == (Constants.YUGA_SC_ON) && (i >= str.length() || (str.charAt(i).asciiValue==Constants.CH_SPACE || str.charAt(i).asciiValue==Constants.CH_FSTP || str.charAt(i).asciiValue==Constants.CH_COMA))) {
                        if(map.get(Constants.TY_NUM)!.length() == 6) {
                            let pattern = "([0-3][0-9])([0-1][0-9])([1-3][0-9])"
                            let m = str.groups(for: pattern)
                            if (m.count > 0) {
                                let p_ : Pair<Int, FsaContextMap>? = parseInternal(m[1] + "-" + m[2] + "-" + m[3], config);
                                if (p_ != nil) {
                                    i = p_!.getA()-2;//to makeup for two additional -
                                    map = p_!.getB();
                                }
                            } else {
                                map.setVal(name: "num_class", val: Constants.TY_NUM);
                            }
                        } else if(map.get(Constants.TY_NUM)!.length() == 8) {
                            let pattern = "([0-3][0-9])([0-1][0-9])([2][0-1][1-5][0-9])"
                            let m = str.groups(for: pattern)
                            if (m.count > 0) {
                                let nsString: NSString = str as NSString
                                let p_ : Pair<Int, FsaContextMap>? = parseInternal(m[1] + "-" + m[2] + "-" + m[3], config);
                                if (p_ != nil) {
                                    i = p_!.getA()-2;//to makeup for two additional -
                                    map = p_!.getB();
                                }
                            } else {
                                map.setVal(name: "num_class", val: Constants.TY_NUM);
                            }
                        }
                    }
                    else {
                        map.setVal(name: "num_class", val: Constants.TY_NUM);
                    }
                }
            }
        } else if ((map.getType() == Constants.TY_DTE) && (i + 1) < str.length()) {
            var pTime : Pair<Int, String>? = nil;
            let inside = i + skip(str: str.substring(i));
            let sub : String = str.substring(inside);
            if (inside < str.length()) {
                if (str.charAt(inside).isNumber || utilCheckTypes(getRoot(), "FSA_MONTHS", sub) != nil || utilCheckTypes(getRoot(), "FSA_DAYS", sub) != nil) {
                    let p_ : Pair<Int, FsaContextMap>? = parseInternal(sub, config);
                    if (p_ != nil && p_!.getB().getType() == (Constants.TY_DTE)) {
                        map.putAll(p_!.getB());
                        i = inside + p_!.getA();
                    }
                } else if (utilCheckTypes(getRoot(), "FSA_TIMEPRFX", sub) != nil) {
                    pTime = utilCheckTypes(getRoot(), "FSA_TIMEPRFX", sub)
                    let iTime : Int = inside + pTime!.getA() + 1 + skip(str: str.substring(inside + pTime!.getA() + 1));
                    if (iTime < str.length() && (str.charAt(iTime).isNumber || utilCheckTypes(getRoot(), "FSA_DAYS", str.substring(iTime)) != nil)) {
                        let p_ : Pair<Int, FsaContextMap>? = parseInternal(str.substring(iTime), config);
                        if (p_ != nil && p_!.getB().getType() == (Constants.TY_DTE)) {
                            map.putAll(p_!.getB());
                            i = iTime + p_!.getA();
                        }
                    }
                } else if (utilCheckTypes(getRoot(), "FSA_TZ", sub) != nil) {
                    pTime = utilCheckTypes(getRoot(), "FSA_TZ", sub)
                    let j : Int = skipForTZ(str.substring(inside + pTime!.getA() + 1), map);
                    i = inside + pTime!.getA() + 1 + j;
                } else if (sub.lowercased().startsWith("pm") || sub.lowercased().startsWith("am")) {
                    //todo handle appropriately for pm
                    if((sub.length()>=3 && isDelimiter(sub.charAt(2))) || (sub.length() == 2) ) {
                        // second if condition added to move index to pm in case like : 11/01/2021:10:09:47PM
                        i = inside + 2;
                    }
                }
            }
        } else if ((map.getType() == Constants.TY_TMS)) {
            let v = map.get(map.getType()!);
            if (v != nil && v!.length() == 8 && isHour(v!.charAt(0), v!.charAt(1)) && isHour(v!.charAt(4), v!.charAt(5))) {
                extractTime(v!.substring(with: 0..<4), &map.valMap, "dept");
                extractTime(v!.substring(with: 0..<8), &map.valMap, "arrv");
            }
        }
        return Pair<Int, FsaContextMap>(i, map);
    }
}

class DelimiterStack {
    final var stack = [Character]();

    init() {
        stack = [Character]();
    }

    func push(_ ch : Character) {
        stack.append(ch);
    }

    func pop() -> Character {
        if (stack.count > 0) {
            return stack[stack.count - 1];
        }
        return "~";
    }
}

