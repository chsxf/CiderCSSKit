import Foundation
import XCTest
@testable import CiderCSSKit

final class CSSTokenizerTests: XCTestCase {

    private static var buffer: String!

    override class func setUp() {
        // swiftlint:disable force_try
        let dataURL = Bundle.module.url(forResource: "TokenizerTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)
        // swiftlint:enable force_try
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
            CSSToken(line: 8, type: .string, value: "font"),
            CSSToken(line: 8, type: .colon),
            CSSToken(line: 8, type: .number, value: Float(12)),
            CSSToken(line: 8, type: .string, value: "px"),
            CSSToken(line: 8, type: .forwardSlash),
            CSSToken(line: 8, type: .number, value: Float(18)),
            CSSToken(line: 8, type: .string, value: "px"),
            CSSToken(line: 8, type: .whitespace),
            CSSToken(line: 8, type: .string, value: "Arial", literalString: true),
            CSSToken(line: 8, type: .semiColon),
            CSSToken(line: 9, type: .closingBrace),
            CSSToken(line: 11, type: .string, value: "button"),
            CSSToken(line: 11, type: .comma),
            CSSToken(line: 11, type: .dot),
            CSSToken(line: 11, type: .string, value: "youpi"),
            CSSToken(line: 11, type: .whitespace),
            CSSToken(line: 11, type: .string, value: "img"),
            CSSToken(line: 11, type: .openingBrace),
            CSSToken(line: 12, type: .string, value: "background-image"),
            CSSToken(line: 12, type: .colon),
            CSSToken(line: 12, type: .string, value: "background", literalString: true),
            CSSToken(line: 12, type: .semiColon),
            CSSToken(line: 13, type: .string, value: "color"),
            CSSToken(line: 13, type: .colon),
            CSSToken(line: 13, type: .string, value: "black"),
            CSSToken(line: 13, type: .semiColon),
            CSSToken(line: 14, type: .string, value: "transform-origin"),
            CSSToken(line: 14, type: .colon),
            CSSToken(line: 14, type: .number, value: Float(50)),
            CSSToken(line: 14, type: .percent),
            CSSToken(line: 14, type: .whitespace),
            CSSToken(line: 14, type: .number, value: Float(50)),
            CSSToken(line: 14, type: .percent),
            CSSToken(line: 14, type: .semiColon),
            CSSToken(line: 15, type: .closingBrace),
            CSSToken(line: 17, type: .string, value: "button"),
            CSSToken(line: 17, type: .colon),
            CSSToken(line: 17, type: .string, value: "hover"),
            CSSToken(line: 17, type: .openingBrace),
            CSSToken(line: 18, type: .string, value: "color"),
            CSSToken(line: 18, type: .colon),
            CSSToken(line: 18, type: .string, value: "red"),
            CSSToken(line: 18, type: .semiColon),
            CSSToken(line: 19, type: .closingBrace)
        ]

        XCTAssertEqual(tokens.count, expectedTokens.count)

        for index in 0..<expectedTokens.count {
            print(tokens[index])
            XCTAssertEqual(tokens[index], expectedTokens[index])
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

        for index in 0..<expectedTokens.count {
            XCTAssertEqual(tokens[index], expectedTokens[index])
        }
    }

}
