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
        XCTAssertEqual(tokens.count, 33)
        
        let expectedTokens = [
            CSSToken(type: .sharp),
            CSSToken(type: .string, value: "test"),
            CSSToken(type: .whitespace),
            CSSToken(type: .openingBrace),
            CSSToken(type: .whitespace),
            CSSToken(type: .string, value: "background"),
            CSSToken(type: .colon),
            CSSToken(type: .whitespace),
            CSSToken(type: .string, value: "rgba"),
            CSSToken(type: .openingParenthesis),
            CSSToken(type: .string, value: "1"),
            CSSToken(type: .comma),
            CSSToken(type: .whitespace),
            CSSToken(type: .string, value: "1"),
            CSSToken(type: .comma),
            CSSToken(type: .whitespace),
            CSSToken(type: .string, value: "1"),
            CSSToken(type: .comma),
            CSSToken(type: .whitespace),
            CSSToken(type: .string, value: "0"),
            CSSToken(type: .dot),
            CSSToken(type: .string, value: "5"),
            CSSToken(type: .closingParenthesis),
            CSSToken(type: .semiColon),
            CSSToken(type: .whitespace),
            CSSToken(type: .string, value: "color"),
            CSSToken(type: .colon),
            CSSToken(type: .whitespace),
            CSSToken(type: .sharp),
            CSSToken(type: .string, value: "ff9900"),
            CSSToken(type: .semiColon),
            CSSToken(type: .whitespace),
            CSSToken(type: .closingBrace)
        ]
        XCTAssertEqual(tokens, expectedTokens)
    }

}
