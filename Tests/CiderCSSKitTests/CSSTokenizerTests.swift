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
            CSSToken(line: 0, type: .star),
            CSSToken(line: 0, type: .openingBrace),
            CSSToken(line: 1, type: .string, value: "font-family"),
            CSSToken(line: 1, type: .colon),
            CSSToken(line: 1, type: .string, value: "Roboto", literalString: true),
            CSSToken(line: 1, type: .semiColon),
            CSSToken(line: 2, type: .closingBrace),
            CSSToken(line: 4, type: .sharp),
            CSSToken(line: 4, type: .string, value: "test"),
            CSSToken(line: 4, type: .openingBrace),
            CSSToken(line: 5, type: .string, value: "background-color"),
            CSSToken(line: 5, type: .colon),
            CSSToken(line: 5, type: .string, value: "rgba"),
            CSSToken(line: 5, type: .openingParenthesis),
            CSSToken(line: 5, type: .number, value: Float(1.0)),
            CSSToken(line: 5, type: .comma),
            CSSToken(line: 5, type: .number, value: Float(1.0)),
            CSSToken(line: 5, type: .comma),
            CSSToken(line: 5, type: .number, value: Float(1.0)),
            CSSToken(line: 5, type: .comma),
            CSSToken(line: 5, type: .number, value: Float(0.5)),
            CSSToken(line: 5, type: .closingParenthesis),
            CSSToken(line: 5, type: .semiColon),
            CSSToken(line: 6, type: .string, value: "color"),
            CSSToken(line: 6, type: .colon),
            CSSToken(line: 6, type: .sharp),
            CSSToken(line: 6, type: .string, value: "ff9900"),
            CSSToken(line: 6, type: .semiColon),
            CSSToken(line: 7, type: .string, value: "name"),
            CSSToken(line: 7, type: .colon),
            CSSToken(line: 7, type: .string, value: "A \"super\" name", literalString: true),
            CSSToken(line: 7, type: .semiColon),
            CSSToken(line: 8, type: .closingBrace),
            CSSToken(line: 10, type: .string, value: "button"),
            CSSToken(line: 10, type: .comma),
            CSSToken(line: 10, type: .dot),
            CSSToken(line: 10, type: .string, value: "youpi"),
            CSSToken(line: 10, type: .whitespace),
            CSSToken(line: 10, type: .string, value: "img"),
            CSSToken(line: 10, type: .openingBrace),
            CSSToken(line: 11, type: .string, value: "background-image"),
            CSSToken(line: 11, type: .colon),
            CSSToken(line: 11, type: .string, value: "background", literalString: true),
            CSSToken(line: 11, type: .semiColon),
            CSSToken(line: 12, type: .string, value: "color"),
            CSSToken(line: 12, type: .colon),
            CSSToken(line: 12, type: .string, value: "black"),
            CSSToken(line: 12, type: .semiColon),
            CSSToken(line: 13, type: .string, value: "transform-origin"),
            CSSToken(line: 13, type: .colon),
            CSSToken(line: 13, type: .number, value: Float(50)),
            CSSToken(line: 13, type: .percent),
            CSSToken(line: 13, type: .whitespace),
            CSSToken(line: 13, type: .number, value: Float(50)),
            CSSToken(line: 13, type: .percent),
            CSSToken(line: 13, type: .semiColon),
            CSSToken(line: 14, type: .closingBrace),
            CSSToken(line: 16, type: .string, value: "button"),
            CSSToken(line: 16, type: .colon),
            CSSToken(line: 16, type: .string, value: "hover"),
            CSSToken(line: 16, type: .openingBrace),
            CSSToken(line: 17, type: .string, value: "color"),
            CSSToken(line: 17, type: .colon),
            CSSToken(line: 17, type: .string, value: "red"),
            CSSToken(line: 17, type: .semiColon),
            CSSToken(line: 18, type: .closingBrace)
        ]
        
        XCTAssertEqual(tokens.count, expectedTokens.count)

        for i in 0..<expectedTokens.count {
            print(tokens[i])
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
