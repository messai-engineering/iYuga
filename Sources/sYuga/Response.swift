import Foundation

public class Response {
    private var type : String;
    private var valMap : Dictionary<String, String>;
    private var str : String;
    private var index : Int;
    private var date : Date? = nil;
    
    
    public init(
        type : String,
        valMap : Dictionary<String, String>,
        inDate: Any,
        index : Int
    ) {
        self.type = type;
        self.valMap = valMap;
        if inDate is String {
            self.str = inDate as! String
        } else {
            self.date = (inDate as! Date)
            self.str = Constants.dateTimeFormatter().string(from: (date)!);
        }
        self.index = index;
    }


    public func getType() -> String {
        return type;
    }

    public func setType(type : String) {
        self.type = type;
    }

    public func getStr() -> String {
        return str;
    }

    public func setStr(str : String) {
        self.str = str;
    }

    public func getIndex() -> Int {
        return index;
    }

    public func setIndex(index : Int) {
        self.index = index;
    }

    public func getValMap() -> Dictionary<String, String> {
        return valMap;
    }

    public func setValMap(valMap : Dictionary<String, String>) {
        self.valMap = valMap;
    }

    public func getDate() -> Date? {
        return date;
    }

    public func setDate(date : Date) {
        self.date = date;
    }
}

