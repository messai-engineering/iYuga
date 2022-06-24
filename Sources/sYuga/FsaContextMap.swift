import Foundation

public class FsaContextMap {
    var map : Dictionary<String, String> = Dictionary();
    var valMap : Dictionary<String, String> = Dictionary();
    private var prevKey : String = "";
    private var keys = [String]();

    public func contains(_ key : String) -> Bool {
        return map[key] != nil;
    }

    public func size() -> Int {
        return map.keys.count
    }

    public func put(_ key : String, _ value : Character) {
        if (!keys.contains(key)) {
            keys.append(key);
        }
        map[key] = String(value)
        prevKey = key;
    }

    public func put(_ key : String, _ value : Int) {
        if (!keys.contains(key)) {
            keys.append(key);
        }
        map[key] = String(value);
        prevKey = key;
    }

    public func put(_ key : String, _ value : String) {
        if (!keys.contains(key)) {
            keys.append(key);
        }
        map[key] = value;
        prevKey = key;
    }

    public func getType() -> String? {
        return map[Constants.TY_TYP];
    }

    public func setType(type : String) {
        map[Constants.TY_TYP] = type;
    }

    public func setType(_ type : String,_ convertType : String?) {
        map[Constants.TY_TYP] = type;
        if (convertType != nil) {
            convert(k: convertType!);
        }
    }

    public func getVal(name : String) -> String? {
        return valMap[name];
    }

    public func setVal(name : String, val : String) {
        valMap[name] = val;
    }

    public func getValMap() -> Dictionary<String, String> {
        return valMap;
    }

    public func getIndex() -> Int? {
        let value = map[Constants.INDEX]
        return value != nil ? Int(value!) : nil
    }

    public func setIndex(_ index : Int) {
        map[Constants.INDEX] =  String(index);
    }

    //appending to prev value
    public func append(_ value : Character) {
        let preVal: String = map[prevKey]!;
        put(prevKey, preVal + String(value));
    }

    public func append(_ value : String) {
        let preVal: String = map[prevKey]!;
        put(prevKey, preVal + value);
    }

    //removing last appended value
    public func pop() -> Character {
        let preVal : String = map[prevKey]!;
        let ret = preVal[preVal.count - 1];
        put(prevKey, preVal.substring(with: 0..<(preVal.count - 1)));
        return ret;
    }

    public func convert(_ kOld : String, _ kNew : String) {
        if (map[kOld] != nil) {
            if (map[kNew] == nil) {
                put(kNew, map.removeValue(forKey: kOld)!);
            } else {
                put(kNew, (map[kNew]! + map.removeValue(forKey: kOld)!));
            }
            prevKey = kNew;
        }
    }

    private func convert(k : String) {
        var sb = ""
        for key : String in keys {
            sb.append(map.removeValue(forKey: key)!);
        }
        keys = [String]();
        put(k, sb);
    }

    public func remove(_ key : String) {
        map.removeValue(forKey: key);
    }

    //upgrade for eg from yy to yyy
    public func upgrade(_ value : Character) {
        switch (prevKey) {
            case Constants.DT_HH:
                put(Constants.DT_mm, value);
                prevKey = Constants.DT_mm;
                break;
            case Constants.DT_mm:
                put(Constants.DT_ss, value);
                prevKey = Constants.DT_ss;
                break;
            case Constants.DT_D:
                put(Constants.DT_MM, value);
                prevKey = Constants.DT_MM;
                break;
            case Constants.DT_MM:
                put(Constants.DT_YY, value);
                prevKey = Constants.DT_YY;
                break;
            case Constants.DT_MMM:
                put(Constants.DT_YY, value);
                prevKey = Constants.DT_YY;
                break;
            case Constants.DT_YY:
                put(Constants.DT_YYYY, (map.removeValue(forKey: Constants.DT_YY)! + String(value)));
                prevKey = Constants.DT_YYYY;
                break;
            default:
                break;
        }
    }
    
    public func serializeValMap() -> String {
        var buffer = ""
        for (key, value) in map {
            buffer += " [" + key + " -> " + value + "] "
        }
        return buffer
    }

    public func getFromMap(key : String) -> String? {
        return map[key];
    }
    
    public func get(_ key : String) -> String? {
        return map[key];
    }


    public func putAll(_ fsaContextMap : FsaContextMap) {
        map.merge(fsaContextMap.map) {(current, _) in current };
    }

    public func getDate(config : Dictionary<String, String>) -> Date? {
        var sbf = "";
        var sbs = "";
        var _ : String;
        var ifYear : Bool = false;
        var ifMonth : Bool = false;
        var ifDay : Bool = false;
        var invalidDateContributors = [String]()
        //when year is not provided then we assume message year; we check for that when we have both day and month
            for (key, value) in map {
                if (allow(key: key)) {
                    sbf.append(key)
                    sbf.append(" ")
                    sbs.append(value)
                    sbs.append(" ");
                    switch (key) {
                        case Constants.DT_YY:
                            ifYear = true;
                            break;
                        case Constants.DT_YYYY:
                            ifYear = true;
                            break;
                        case Constants.DT_D:
                            ifDay = true;
                            break;
                        case Constants.DT_MM:
                            ifMonth = true;
                            break;
                        case Constants.DT_MMM:
                            ifMonth = true;
                            break;
                        default:
                            break;
                    }
                }
            }
            //date year defaulting
            if (!ifYear && config[Constants.YUGA_CONF_DATE] != nil) {
                sbf.append("yyyy ");
                sbs.append(contentsOf: (config[Constants.YUGA_CONF_DATE]!.split(separator: "-")[0]))
                        //assuming yyyy-MM-dd HH:mm:ss format
                sbs.append(" ");
            } else {
                let maxDate : Int = Calendar.current.component(.year, from: Date())
                if (map[Constants.DT_YY] != nil) {
                    let y : Int = Int(map[Constants.DT_YY]!)!;
                    if (!(y > 0 && y < ((maxDate % 1000) + 3))) {
                        invalidDateContributors.append(Constants.DT_YY);
                    }
                } else {
                    let y : Int = Int(map[Constants.DT_YYYY]!)!;
                    if (!(y > 1971 && y < (maxDate + 3))) {
                        invalidDateContributors.append(Constants.DT_YYYY);
                    }
                }

            }

            if (!ifMonth && config[Constants.YUGA_CONF_DATE] != nil) {
                sbf.append("MM ");
                sbs.append(contentsOf: (config[Constants.YUGA_CONF_DATE]!.split(separator: "-")[1]));
                //assuming yyyy-MM-dd HH:mm:ss format
                sbs.append(" ");
            } else {
                if (map[Constants.DT_MM] != nil) {
                    let m : Int = Int(map[Constants.DT_MM]!)!;
                    if (!(m >= 0 && m <= 12)) {
                        invalidDateContributors.append(Constants.DT_MM);
                    }
                }
            }

            if (!ifDay && config[Constants.YUGA_CONF_DATE] != nil) {
                sbf.append("dd ");
                sbs.append(contentsOf: (config[Constants.YUGA_CONF_DATE]!.split(separator: "-")[2].split(separator: " ")[0]));
                sbs.append(" ");//assuming yyyy-MM-dd HH:mm:ss format
            } else {
                if (map[Constants.DT_D] != nil) {
                    let d : Int = Int(map[Constants.DT_D]!)!;
                    if (!(d >= 0 && d <= 31)) {
                        invalidDateContributors.append(Constants.DT_D);
                    }
                }
            }

            if (invalidDateContributors.count > 0) {
                if (invalidDateContributors.count == 1 && invalidDateContributors[0] == Constants.DT_MM && ifDay && ifYear) {
                    let format : DateFormatter = DateFormatter();
                    format.dateFormat = Constants.DT_D + "/" + Constants.DT_MM + "/" + (map[Constants.DT_YY] != nil ? Constants.DT_YY : Constants.DT_YYYY)
                    return format.date(from: map[Constants.DT_MM]! + "/" + map[Constants.DT_D]! + "/" + (map[Constants.DT_YY] != nil ? map[Constants.DT_YY]! : map[Constants.DT_YYYY]!));
                } else {
                    return nil;
                }
            }
            let format : DateFormatter = DateFormatter();
            format.dateFormat = sbf
            return format.date(from: sbs);
    }

    private func allow(key : String) -> Bool {
        return (key == Constants.DT_D || key == Constants.DT_MM || key == Constants.DT_MMM || key == Constants.DT_YY || key == Constants.DT_YYYY || key == Constants.DT_HH || key == Constants.DT_mm || key == Constants.DT_ss);
    }
}

