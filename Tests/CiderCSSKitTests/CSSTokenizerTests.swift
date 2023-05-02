import Foundation
import XCTest
@testable import CiderCSSKit

final class CSSTokenizerTests: XCTestCase {

    private static var buffer: String!
    
    override class func setUp() {
        let dataURL = Bundle.module.url(forResource: "TokenizerTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)
    }
    
    override class func tearDown() {
        Self.buffer = nil
    }
    
    func testValidTokens() throws {
        let tokens = try CSSTokenizer.tokenize(buffer: Self.buffer)
        
        let expectedTokens = [
            CSSToken(line: 0, type: .sharp),
            CSSToken(line: 0, type: .string, value: "test"),
            CSSToken(line: 0, type: .openingBrace),
            CSSToken(line: 1, type: .string, value: "background-color"),
            CSSToken(line: 1, type: .colon),
            CSSToken(line: 1, type: .string, value: "rgba"),
            CSSToken(line: 1, type: .openingParenthesis),
            CSSToken(line: 1, type: .number, value: Float(1.0)),
            CSSToken(line: 1, type: .comma),
            CSSToken(line: 1, type: .number, value: Float(1.0)),
            CSSToken(line: 1, type: .comma),
            CSSToken(line: 1, type: .number, value: Float(1.0)),
            CSSToken(line: 1, type: .comma),
            CSSToken(line: 1, type: .number, value: Float(0.5)),
            CSSToken(line: 1, type: .closingParenthesis),
            CSSToken(line: 1, type: .semiColon),
            CSSToken(line: 2, type: .string, value: "color"),
            CSSToken(line: 2, type: .colon),
            CSSToken(line: 2, type: .sharp),
            CSSToken(line: 2, type: .string, value: "ff9900"),
            CSSToken(line: 2, type: .semiColon),
            CSSToken(line: 3, type: .string, value: "name"),
            CSSToken(line: 3, type: .colon),
            CSSToken(line: 3, type: .string, value: "A \"super\" name", literalString: true),
            CSSToken(line: 3, type: .semiColon),
            CSSToken(line: 4, type: .closingBrace),
            CSSToken(line: 6, type: .string, value: "button"),
            CSSToken(line: 6, type: .comma),
            CSSToken(line: 6, type: .dot),
            CSSToken(line: 6, type: .string, value: "youpi"),
            CSSToken(line: 6, type: .whitespace),
            CSSToken(line: 6, type: .string, value: "img"),
            CSSToken(line: 6, type: .openingBrace),
            CSSToken(line: 7, type: .string, value: "background-image"),
            CSSToken(line: 7, type: .colon),
            CSSToken(line: 7, type: .string, value: "background", literalString: true),
            CSSToken(line: 7, type: .semiColon),
            CSSToken(line: 8, type: .closingBrace)
        ]
        
        XCTAssertEqual(tokens.count, expectedTokens.count)

        for i in 0..<expectedTokens.count {
            XCTAssertEqual(tokens[i], expectedTokens[i])
        }
    }
    
    func testStandaloneAttributeValueTokenization() throws {
        let attributeValue = "sprite(\"test\", \"fill\")"
        let tokens = try CSSTokenizer.tokenize(buffer: attributeValue)
        
        let expectedTokens = [
            CSSToken(line: 0, type: .string, value: "sprite"),
            CSSToken(line: 0, type: .openingParenthesis),
            CSSToken(line: 0, type: .string, value: "test", literalString: true),
            CSSToken(line: 0, type: .comma),
            CSSToken(line: 0, type: .string, value: "fill", literalString: true),
            CSSToken(line: 0, type: .closingParenthesis)
        ]
        
        XCTAssertEqual(tokens.count, expectedTokens.count)

        for i in 0..<expectedTokens.count {
            XCTAssertEqual(tokens[i], expectedTokens[i])
        }
    }

}
