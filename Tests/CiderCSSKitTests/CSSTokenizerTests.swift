import XCTest
@testable import CiderCSSKit

final class CSSTokenizerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidTokens() throws {
        let buffer = "#test {\nbackground: rgba(1, 1, 1, 0.5);\ncolor: #ff9900;\n}"
        let tokens = try CSSTokenizer.tokenize(buffer: buffer)
        XCTAssertEqual(tokens.count, 24)
        
        XCTAssertEqual(tokens[0], CSSToken(type: .sharp))
        XCTAssertEqual(tokens[1], CSSToken(type: .stringToken, value: "test"))
        XCTAssertEqual(tokens[2], CSSToken(type: .openingBrace))
        XCTAssertEqual(tokens[3], CSSToken(type: .stringToken, value: "background"))
        XCTAssertEqual(tokens[4], CSSToken(type: .colon))
        XCTAssertEqual(tokens[5], CSSToken(type: .stringToken, value: "rgba"))
        XCTAssertEqual(tokens[6], CSSToken(type: .openingParenthesis))
        XCTAssertEqual(tokens[7], CSSToken(type: .stringToken, value: "1"))
        XCTAssertEqual(tokens[8], CSSToken(type: .comma))
        XCTAssertEqual(tokens[9], CSSToken(type: .stringToken, value: "1"))
        XCTAssertEqual(tokens[10], CSSToken(type: .comma))
        XCTAssertEqual(tokens[11], CSSToken(type: .stringToken, value: "1"))
        XCTAssertEqual(tokens[12], CSSToken(type: .comma))
        XCTAssertEqual(tokens[13], CSSToken(type: .stringToken, value: "0"))
        XCTAssertEqual(tokens[14], CSSToken(type: .dot))
        XCTAssertEqual(tokens[15], CSSToken(type: .stringToken, value: "5"))
        XCTAssertEqual(tokens[16], CSSToken(type: .closingParenthesis))
        XCTAssertEqual(tokens[17], CSSToken(type: .semiColon))
        XCTAssertEqual(tokens[18], CSSToken(type: .stringToken, value: "color"))
        XCTAssertEqual(tokens[19], CSSToken(type: .colon))
        XCTAssertEqual(tokens[20], CSSToken(type: .sharp))
        XCTAssertEqual(tokens[21], CSSToken(type: .stringToken, value: "ff9900"))
        XCTAssertEqual(tokens[22], CSSToken(type: .semiColon))
        XCTAssertEqual(tokens[23], CSSToken(type: .closingBrace))
    }

}
