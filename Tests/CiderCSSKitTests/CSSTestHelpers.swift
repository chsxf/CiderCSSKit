import XCTest
import CiderCSSKit

final class CSSTestHelpers {

    static func assertColorValue(values: [CSSValue]?, expectedValue: CSSValue?, expectedCount: Int = 1, checkedIndex: Int = 0) throws {
        let unwrappedValue = try XCTUnwrap(values)
        XCTAssertEqual(unwrappedValue.count, expectedCount)
        guard case .color = unwrappedValue[checkedIndex] else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(unwrappedValue[checkedIndex], expectedValue)
    }

}
