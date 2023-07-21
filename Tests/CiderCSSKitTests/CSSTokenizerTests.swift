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
            CSSToken(line: 2, type: .string, value: "border-image-source"),
            CSSToken(line: 2, type: .colon),
            CSSToken(line: 2, type: .string, value: "url"),
            CSSToken(line: 2, type: .openingParenthesis),
            CSSToken(line: 2, type: .string, value: "http://www.example.com/test.png", literalString: true),
            CSSToken(line: 2, type: .closingParenthesis),
            CSSToken(line: 2, type: .semiColon),
            CSSToken(line: 3, type: .closingBrace),
            CSSToken(line: 5, type: .sharp),
            CSSToken(line: 5, type: .string, value: "test"),
            CSSToken(line: 5, type: .openingBrace),
            CSSToken(line: 6, type: .string, value: "background-color"),
            CSSToken(line: 6, type: .colon),
            CSSToken(line: 6, type: .string, value: "rgba"),
            CSSToken(line: 6, type: .openingParenthesis),
            CSSToken(line: 6, type: .number, value: Float(1.0)),
            CSSToken(line: 6, type: .comma),
            CSSToken(line: 6, type: .number, value: Float(1.0)),
            CSSToken(line: 6, type: .comma),
            CSSToken(line: 6, type: .number, value: Float(1.0)),
            CSSToken(line: 6, type: .comma),
            CSSToken(line: 6, type: .number, value: Float(0.5)),
            CSSToken(line: 6, type: .closingParenthesis),
            CSSToken(line: 6, type: .semiColon),
            CSSToken(line: 7, type: .string, value: "color"),
            CSSToken(line: 7, type: .colon),
            CSSToken(line: 7, type: .sharp),
            CSSToken(line: 7, type: .string, value: "ff9900"),
            CSSToken(line: 7, type: .semiColon),
            CSSToken(line: 8, type: .string, value: "name"),
            CSSToken(line: 8, type: .colon),
            CSSToken(line: 8, type: .string, value: "A \"super\" name", literalString: true),
            CSSToken(line: 8, type: .semiColon),
            CSSToken(line: 9, type: .string, value: "font"),
            CSSToken(line: 9, type: .colon),
            CSSToken(line: 9, type: .number, value: Float(12)),
            CSSToken(line: 9, type: .string, value: "px"),
            CSSToken(line: 9, type: .forwardSlash),
            CSSToken(line: 9, type: .number, value: Float(18)),
            CSSToken(line: 9, type: .string, value: "px"),
            CSSToken(line: 9, type: .whitespace),
            CSSToken(line: 9, type: .string, value: "Arial", literalString: true),
            CSSToken(line: 9, type: .semiColon),
            CSSToken(line: 10, type: .closingBrace),
            CSSToken(line: 12, type: .string, value: "button"),
            CSSToken(line: 12, type: .comma),
            CSSToken(line: 12, type: .dot),
            CSSToken(line: 12, type: .string, value: "youpi"),
            CSSToken(line: 12, type: .whitespace),
            CSSToken(line: 12, type: .string, value: "img"),
            CSSToken(line: 12, type: .openingBrace),
            CSSToken(line: 13, type: .string, value: "background-image"),
            CSSToken(line: 13, type: .colon),
            CSSToken(line: 13, type: .string, value: "background", literalString: true),
            CSSToken(line: 13, type: .semiColon),
            CSSToken(line: 14, type: .string, value: "color"),
            CSSToken(line: 14, type: .colon),
            CSSToken(line: 14, type: .string, value: "black"),
            CSSToken(line: 14, type: .semiColon),
            CSSToken(line: 15, type: .string, value: "transform-origin"),
            CSSToken(line: 15, type: .colon),
            CSSToken(line: 15, type: .number, value: Float(50)),
            CSSToken(line: 15, type: .percent),
            CSSToken(line: 15, type: .whitespace),
            CSSToken(line: 15, type: .number, value: Float(50)),
            CSSToken(line: 15, type: .percent),
            CSSToken(line: 15, type: .semiColon),
            CSSToken(line: 16, type: .closingBrace),
            CSSToken(line: 18, type: .string, value: "button"),
            CSSToken(line: 18, type: .colon),
            CSSToken(line: 18, type: .string, value: "hover"),
            CSSToken(line: 18, type: .openingBrace),
            CSSToken(line: 19, type: .string, value: "color"),
            CSSToken(line: 19, type: .colon),
            CSSToken(line: 19, type: .string, value: "red"),
            CSSToken(line: 19, type: .semiColon),
            CSSToken(line: 20, type: .closingBrace)
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
