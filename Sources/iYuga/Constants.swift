import Foundation

public class Constants {

    public static  var DT_D : String = "d";
    public static  var DT_DD : String = "dd";
    public static  var DT_MM : String = "MM";
    public static  var DT_MMM : String = "MMM";
    public static  var DT_YY : String = "yy";
    public static  var DT_YYYY : String = "yyyy";
    public static  var DT_HH : String = "HH";
    public static  var DT_mm : String = "mm";
    public static  var DT_ss : String = "ss";

    public static  var TY_NUM : String = "NUM";
    public static  var TY_AMT : String = "AMT";
    public static  var TY_PCT : String = "PCT";
    public static  var TY_DST : String = "DST";
    public static  var TY_WGT : String = "WGT";
    public static  var TY_ACC : String = "INSTRNO";
    public static  var TY_TYP : String = "TYP";
    public static  var TY_DTE : String = "DATE";
    public static  var TY_TME : String = "TIME";
    public static  var TY_STR : String = "STR";
    public static  var TY_PHN : String = "PHN";
    public static  var TY_TMS : String = "TIMES";
    public static  var TY_OTP : String = "OTP";
    public static  var TY_DTA : String = "DATA";
    public static  var TY_MLT : String = "MLTPL";
    public static  var TY_VPD : String = "VPD"; //VPA-ID
    public static  var TY_USSD : String = "USSD";
    //public static  String TY_DCT = "DCT"; //date context like sunday,today,tomorrow

    public static  var FSA_MONTHS : String = "jan;uary,feb;r;uary,mar;ch,apr;il,may,jun;e,jul;y,aug;ust,sep;t;ember,oct;ober,nov;ember,dec;ember";
    public static  var FSA_DAYS : String = "sun;day,mon;day,tue;sday,wed;nesday,thu;rsday,thur;sday,fri;day,sat;urday";
    public static  var FSA_TIMEPRFX : String = "at,on,before,by";
    public static  var FSA_AMT : String = "lac,lakh,k";
    public static  var FSA_TIMES : String = "hours,hrs,hr,mins,minutes";
    public static  var FSA_TZ : String = "gmt,ist";
    public static  var FSA_DAYSFFX : String = "st,nd,rd,th";
    public static  var FSA_UPI : String = "UPI,MMT,NEFT";
    
    public static var upi: [String] = ["airtel", "airtelpaymentsbank", "albk", "allahabadbank", "allbank", "andb", "apb", "apl", "axis", "axisb", "axisbank",
                "axisgo", "bandhan", "barodampay", "barodapay", "birla", "boi", "cbin", "cboi", "centralbank", "cmsidfc", "cnrb", "csbcash", "csbpay",
                "cub", "dbs", "dcb", "dcbbank", "denabank", "dlb", "eazypay", "equitas", "ezeepay", "fbl", "federal", "finobank",
                "hdfcbank", "hdfcbankjd", "hsbc", "icici", "icicibank", "idbi", "idbibank", "idfc", "idfcbank", "idfcnetc", "ikwik", "imobile",
                "indbank", "indianbank", "indianbk", "icicipay", "indus", "iob", "jkb", "jsbp", "karb", "karurvysyabank", "kaypay", "kbl",
                "kbl052", "kmb", "kmbl", "kotak", "kvb", "kvbank", "lime", "lvb", "lvbank", "mahb", "myicici", "obc", "okbizaxis", "okaxis",
                "okhdfcbank", "okicici", "oksbi", "paytm", "payzapp", "pingpay", "pockets", "pnb", "psb", "purz", "rajgovhdfcbank", "sbi",
                "sc", "scb", "scbl", "scmobile", "sib", "srcb", "synd", "syndbank", "syndicate", "tjsb", "ubi", "uboi",
                "uco", "unionbank", "unionbankofindia", "united", "utbi", "vijayabank", "vijb", "vjb", "ybl", "yesbank", "yesbankltd", "upi", "ibl"];
    public static var curr: [String] = ["rs", "inr", "cny", "amt", "amount", "ngn", "usd", "cad", "eur", "gbp", "aed", "jpy", "aud", "s$", "lkr", "ksh", "egp"];
    public static var instr: [String] = ["card", "no", "a/c"];
    public static var fltid: [String] = ["6e", "indigo", "ai", "airindia", "sg", "spicejet", "g8", "goair", "uk", "vistara", "ix",
                "airindiaexpress", "2t", "trujet", "9w", "jetairways"];
    public static var unmaskTokenSet: Set<String> = ["INSTRNO", "NUM", "IDVAL", "AMT", "URL", "EMAILADDRESS"]
    
    
    public static  var CH_NLINE: UInt8 = 10;
    public static  var CH_SPACE : UInt8 = 32;
    public static  var CH_EXCL : UInt8 = 33;
    public static  var CH_DQOT : UInt8 = 34;
    public static  var CH_HASH : UInt8 = 35;
    public static  var CH_PCT : UInt8 = 37;
    public static  var CH_SQOT : UInt8 = 39;
    public static  var CH_LBKT : UInt8 = 41;
    public static  var CH_RBKT : UInt8 = 41;
    public static  var CH_STAR : UInt8 = 42;
    public static  var CH_PLUS : UInt8 = 43;
    public static  var CH_COMA : UInt8 = 44;
    public static  var CH_HYPH : UInt8 = 45;
    public static  var CH_FSTP : UInt8 = 46;
    public static  var CH_SLSH : UInt8 = 47;
    public static  var CH_COLN : UInt8 = 58;
    public static  var CH_SCLN : UInt8 = 59;
    public static  var CH_LSTN : UInt8 = 60;
    public static  var CH_EQLS : UInt8 = 61;
    public static  var CH_GTTN : UInt8 = 62;
    public static  var CH_QUEST : UInt8 = 63;
    public static  var CH_ATRT : UInt8 = 64;
    public static  var CH_LSBT : UInt8 = 91;
    public static  var CH_BKSLSH : UInt8 = 92;
    public static  var CH_LSBTE : UInt8 = 93;
    public static  var CH_UNSC : UInt8 = 95;

    public static  var INDEX : String = "INDEX";

    public static  var YUGA_CONF_DATE : String = "YUGA_CONF_DATE";
    public static  var YUGA_SOURCE_CONTEXT : String = "YUGA_SOURCE_CONTEXT";
    public static  var YUGA_SC_CURR : String = "YUGA_SC_CURR";
    public static  var YUGA_SC_ON : String = "YUGA_SC_ON";
    public static  var YUGA_SC_TRANSID : String = "YUGA_SC_TRANSID";
    private static  var DATE_TIME_FORMAT_STR : String = "yyyy-MM-dd HH:mm:ss";
    private static  var DATE_FORMAT_STR : String = "yyyy-MM-dd";

    public static  var month : Dictionary<Set<String>,String> = mapMonths();
    public static  var day : Dictionary<Set<String>,String> = mapDays();
    public static var tokens: Dictionary<String, String> = mapTokens()
    public static var possiblePrevTokens: Dictionary<String, String> = setPrevTokenPossibleList()
    // TODO add tests for this
    public class func formatDateTimeToDate(date: String, _ inputFormat: String) -> String {
        let formatter = DateFormatter();
        formatter.dateFormat = inputFormat
        let properDate = formatter.date(from: date)!
        return dateFormatter().string(from: properDate);
    }

    public class func dateTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter();
        formatter.dateFormat = DATE_TIME_FORMAT_STR
        return formatter
    }

    public class func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter();
        formatter.dateFormat = DATE_FORMAT_STR
        return formatter
    }

    private class func mapMonths() -> Dictionary<Set<String>,String>{
        // Add months in non-english language to these String arrays for support
        let jan : Set = ["januari"];
        let feb : Set = ["februari"];
        let mar : Set = ["mars"];
        //String[] apr = {};
        let may : Set = ["maj"];
        let jun : Set = ["juni"];
        let jul : Set = ["juli"];
        let aug : Set = ["augusti"];
        //String[] sep = {};
        let oct : Set = ["okt"];
        //String[] nov = {};
        //String[] dec = {};


        var months : Dictionary<Set<String>,String> = Dictionary();
        months[jan] = "january";
        months[feb] = "february";
        months[mar] = "march";
        months[may] = "may";
        months[jun] = "june";
        months[jul] = "july";
        months[aug] = "august";
        months[oct] = "october";
        return months;
    }

    private class func mapDays() -> Dictionary<Set<String>,String>{
        // Add days in non-english language to these String arrays for support
        let mond : Set = ["måndag"];
        let tues : Set = ["tisdag"];
        let wedn : Set = ["onsdag"];
        let thur : Set = ["torsdag"];
        let frid : Set = ["fredag"];
        let satu : Set = ["lördag"];
        let sund : Set = ["söndag"];

        var days : Dictionary<Set<String>,String> = Dictionary();
        days[mond] = "monday";
        days[tues] = "tuesday";
        days[wedn] = "wednesday";
        days[thur] = "thursday";
        days[frid] = "friday";
        days[satu] = "saturday";
        days[sund] = "sunday";

        return days;
    }
    
    private class func mapTokens() -> Dictionary<String, String> {
        var getTokens: Dictionary<String, String> = Dictionary()
        getTokens["upi"] = "TRANSFER"
        getTokens["neft"] = "TRANSFER"
        getTokens["mmt"] = "TRANSFER"
        getTokens["sms"] = "SMS"
        getTokens["www"] = "WWW"
        getTokens["crn"] = "IDPRX"
        getTokens["krn"] = "IDPRX"
        getTokens["http"] = "HTTP"
        getTokens["https"] = "HTTP"
        return getTokens
    }
    
    private class func setPrevTokenPossibleList() -> Dictionary<String, String> {
        var getTokenList: Dictionary<String, String> = Dictionary()
        getTokenList["no"] = "ID"
        getTokenList["pnr"] = "ID"
        getTokenList["id"] = "ID"
        getTokenList["promo"] = "ID"
        getTokenList["awb"] = "ID"
        getTokenList["utr"] = "ID"
        getTokenList["code"] = "ID"
        getTokenList["number"] = "ID"
        getTokenList["order"] = "ID"
        getTokenList["a/c"] = "INS"
        getTokenList["account"] = "INS"
        getTokenList["loan"] = "INS"
        return getTokenList
    }

}

