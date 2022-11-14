import XCTest
@testable import iYuga

struct TestInput {
    let input: String
    let responseType: String
    let responseStr: String
    let valMap: Dictionary<String, String>?
}

struct TestInputForClassifier {
    let date: String
    let message: String
    let addr: String
    let expected: String
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

final class YugaTests: XCTestCase {
    
    func testParseSimpleDate2() throws {
        let y: Yuga = Yuga()
        let out = y.parse(str: "22Jan'20")
        XCTAssertEqual(out?.getStr(), "2020-01-22 00:00:00")
        XCTAssertEqual(out?.getType(), "DATE")
    }
    
    func testRegexTest() {
        let str: String = "0820"
        let pattern = "([0-9]{2})([0-9]{2})?([0-9]{2})?"
        let m = str.groups(for: pattern)
        let value = (m[1] as String) + ((m.count > 1) ? (":" + m[2]) : ":00")
        XCTAssertEqual(value, "08:20")
    }
    
    func testYugaClassifier() {
        let c = Classifier()
        do {
            let testcases = try readTestInputDataForClassifier()
            for testcase in testcases {
                let p = c.getYugaTokens(testcase.message)
                print("message : " + p.getA())
                print("METADATA : ")
                print(p.getB())
            }
        } catch {
            XCTFail("Test failed with exception")
        }
    }
    
    func testYugaClassifierEndToEnd() {
        let c = Classifier()
        do {
          let testcases = try readTestInputDataForClassifier()
          for testcase in testcases {
            let result = c.getYugaTokens(testcase.message)
            let output = result.getA()
            XCTAssertEqual(output, testcase.expected)
          }
        } catch {
          XCTFail("Test failed with exception")
        }
      }
    
    func testYugaEndToEnd() {
        let y: Yuga = Yuga()
        var configMap = Dictionary<String, String>()
        configMap[Constants.YUGA_CONF_DATE] = Constants.dateTimeFormatter().string(from: Date(milliseconds: 1527811200000))
        configMap[Constants.YUGA_SOURCE_CONTEXT] = Constants.YUGA_SC_ON;
        
        do {
            let testcases = try readTestInputData()
            for testcase in testcases {
                let parse = y.parse(str: testcase.input, config: configMap)
                let str = parse?.getStr()
                let type = parse?.getType()
                XCTAssertEqual(str, testcase.responseStr)
                XCTAssertEqual(type, testcase.responseType)
            }
        } catch {
            XCTFail("Test failed with exception")
        }
    }
    
    func readTestInputData() throws -> [TestInput] {
        var testcaseList = [TestInput]()
        let url = Bundle.module.url(forResource: "yuga_tests", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, AnyObject>
            let testcases = (jsonResult?["data"] as? [Any]) as! [Dictionary<String, AnyObject>]
            for testcase in testcases {
                let response = testcase["response"] as! Dictionary<String, AnyObject>
                let valMap = response["valMap"] as? Dictionary<String, String>
                let type = response["type"] as? String
                let str = response["str"] as? String
                if (type != nil && str != nil) {
                    testcaseList.append(
                        TestInput(
                            input: testcase["input"] as! String,
                            responseType: type!,
                            responseStr: str!,
                            valMap: valMap
                        )
                    )
                }
            }
            return testcaseList
        } catch {
            throw ReadError.runtimeError("Deserialization error")
        }
    }
    
    func readTestInputDataForClassifier() throws -> [TestInputForClassifier] {
        var testcaseList = [TestInputForClassifier]()
        let url = Bundle.module.url(forResource: "current", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, AnyObject>
            let testcases = (jsonResult?["data"] as? [Any]) as! [Dictionary<String, AnyObject>]
            for testcase in testcases {
                let date = testcase["date"] as! String
                let message = testcase["body"] as! String
                let addr = testcase["addr"] as! String
                let expected = testcase["expected"] as! String
                testcaseList.append(
                    TestInputForClassifier(date: date, message: message, addr: addr, expected: expected)
                )
            }
            return testcaseList
        } catch {
            throw ReadError.runtimeError("Deserialization error")
        }
    }
}

enum ReadError : Error {
    case runtimeError(String)
}
