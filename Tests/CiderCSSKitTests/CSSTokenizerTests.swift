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
        
        XCTAssertEqual(tokens[0], CSSToken.sharp)
        XCTAssertEqual(tokens[1], CSSToken.stringToken("test"))
        XCTAssertEqual(tokens[2], CSSToken.openingBrace)
        XCTAssertEqual(tokens[3], CSSToken.stringToken("background"))
        XCTAssertEqual(tokens[4], CSSToken.colon)
        XCTAssertEqual(tokens[5], CSSToken.stringToken("rgba"))
        XCTAssertEqual(tokens[6], CSSToken.openingParenthesis)
        XCTAssertEqual(tokens[7], CSSToken.stringToken("1"))
        XCTAssertEqual(tokens[8], CSSToken.comma)
        XCTAssertEqual(tokens[9], CSSToken.stringToken("1"))
        XCTAssertEqual(tokens[10], CSSToken.comma)
        XCTAssertEqual(tokens[11], CSSToken.stringToken("1"))
        XCTAssertEqual(tokens[12], CSSToken.comma)
        XCTAssertEqual(tokens[13], CSSToken.stringToken("0"))
        XCTAssertEqual(tokens[14], CSSToken.dot)
        XCTAssertEqual(tokens[15], CSSToken.stringToken("5"))
        XCTAssertEqual(tokens[16], CSSToken.closingParenthesis)
        XCTAssertEqual(tokens[17], CSSToken.semiColon)
        XCTAssertEqual(tokens[18], CSSToken.stringToken("color"))
        XCTAssertEqual(tokens[19], CSSToken.colon)
        XCTAssertEqual(tokens[20], CSSToken.sharp)
        XCTAssertEqual(tokens[21], CSSToken.stringToken("ff9900"))
        XCTAssertEqual(tokens[22], CSSToken.semiColon)
        XCTAssertEqual(tokens[23], CSSToken.closingBrace)
    }

}
