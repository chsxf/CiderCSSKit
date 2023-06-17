import XCTest
@testable import CiderCSSKit

final class CSSParserTests: XCTestCase {

    private static var buffer: String!
    private static var bufferCustom: String!
    
    override class func setUp() {
        let dataURL = Bundle.module.url(forResource: "ParserTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)
        
        let customDataURL = Bundle.module.url(forResource: "ParserCustomTests", withExtension: "ckcss")
        XCTAssertNotNil(customDataURL)
        Self.bufferCustom = try! String(contentsOf: customDataURL!)
    }
    
    override class func tearDown() {
        Self.buffer = nil
    }

    func testBasicParsing() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        XCTAssertEqual(parsedRules.count, 5)
    }

    func testAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "button")
        let value = parsedRules.getValue(with: "color", for: stub1)
        let unwrappedValue = try XCTUnwrap(value)
        XCTAssertEqual(unwrappedValue.count, 1)
        
        let yellowColor = CSSValueKeywords.getValue(for: "yellow")
        XCTAssertEqual(unwrappedValue[0], yellowColor)
    }
    
    func testHierarchicalAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        var stubChild = StubCSSConsumer(type: "img")
        let value1 = parsedRules.getValue(with: "color", for: stubChild)
        XCTAssertNil(value1)
        
        let stubParent = StubCSSConsumer(type: "dummy", classes: ["youpi"])
        stubChild.parent = stubParent
        let value2 = parsedRules.getValue(with: "color", for: stubChild)
        let unwrappedValue2 = try XCTUnwrap(value2)
        XCTAssertEqual(unwrappedValue2.count, 1)
        
        let yellowColor = CSSValueKeywords.getValue(for: "yellow")
        XCTAssertEqual(unwrappedValue2[0], yellowColor)
    }
    
    func testClauseScore() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "dummy", classes: ["first", "second"])
        let value1 = parsedRules.getValue(with: "color", for: stub1)
        let unwrappedValue1 = try XCTUnwrap(value1)
        
        guard case CSSValue.color(_, _, _, _) = unwrappedValue1[0] else {
            XCTFail("Value must a color");
            return
        }
        XCTAssertEqual(unwrappedValue1[0], CSSValue.color(1, 0, 0, 1))
        
        let stub2 = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let value2 = parsedRules.getValue(with: "color", for: stub2)
        let unwrappedValue2 = try XCTUnwrap(value2)
        
        guard case CSSValue.color(_, _, _, _) = unwrappedValue2[0] else {
            XCTFail("Value must a color");
            return
        }
        XCTAssertEqual(unwrappedValue2[0], CSSValue.color(0, 0, 0, 1))
    }
    
    func testAllValues() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let values = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(values.count, 2)
        
        let color = try XCTUnwrap(values["color"])[0]
        guard case CSSValue.color(_, _, _, _) = color else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(color, CSSValue.color(0, 0, 0, 1))
        
        let textColor = try XCTUnwrap(values["text-color"])[0]
        guard case CSSValue.color(_, _, _, _) = textColor else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(textColor, CSSValue.color(0, 0.502, 0, 1))
    }
    
    func testStandaloneAttributeValueParsing() throws {
        let attributeValue = "green"
        let values = try CSSParser.parse(attributeValue: attributeValue)
        XCTAssertEqual(values.count, 1)
        
        let greenColor = CSSValueKeywords.getValue(for: "green")
        XCTAssertEqual(values[0], greenColor)
    }
    
    func testValuesValidation() throws {
        let _ = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())
    }
    
    func testCustomValidation() throws {
        let _ = try CSSParser.parse(buffer: Self.bufferCustom, validationConfiguration: StubCSSValidationConfiguration())
    }
    
    func testValuesValidationFailing() throws {
        do {
            let _ = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubInvalidCSSValidationConfiguration())
            XCTFail("Error should be raised")
        }
        catch CSSParserErrors.invalidAttributeValue(let token, let value) {
            XCTAssertEqual(token, CSSToken(line: 8, type: .string, value: "background"))
            XCTAssertEqual(value, CSSValue.color(1, 0, 0, 1))
        }
    }
    
    func testCustomValidationFailing() throws {
        do {
            let _ = try CSSParser.parse(buffer: Self.bufferCustom, validationConfiguration: StubInvalidCSSValidationConfiguration())
            XCTFail("Error should be raised")
        }
        catch CSSParserErrors.unknownFunction(let functionToken) {
            XCTAssertEqual(functionToken, CSSToken(line: 1, type: .string, value: "color"))
        }
    }
    
}
