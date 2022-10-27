import Foundation
@testable import iYuga

public class YugaTest {
    
    func testYugaClassifier() {
        let c = Classifier()
        var configMap = Dictionary<String, String>()
        configMap[Constants.YUGA_CONF_DATE] = Constants.dateTimeFormatter().string(from: Date(milliseconds: 1527811200000))
        configMap[Constants.YUGA_SOURCE_CONTEXT] = Constants.YUGA_SC_ON
        let message: String = "The order amount is Rs. 120. Check later at https://flipkart.co.in."
        c.getYugaTokens(message, configMap, IndexTrack(next: 0))
    }
}
