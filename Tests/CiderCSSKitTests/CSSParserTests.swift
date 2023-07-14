import XCTest
@testable import CiderCSSKit

final class CSSParserTests: XCTestCase {

    private static var buffer: String!
    private static var bufferCustom: String!
    private static var bufferRuleBlock: String!
    
    override class func setUp() {
        let dataURL = Bundle.module.url(forResource: "ParserTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)
        
        let customDataURL = Bundle.module.url(forResource: "ParserCustomTests", withExtension: "ckcss")
        XCTAssertNotNil(customDataURL)
        Self.bufferCustom = try! String(contentsOf: customDataURL!)
        
        let ruleBlockDataURL = Bundle.module.url(forResource: "ParserRuleBlockTests", withExtension: "ckcss")
        XCTAssertNotNil(ruleBlockDataURL)
        Self.bufferRuleBlock = try! String(contentsOf: ruleBlockDataURL!)
    }
    
    override class func tearDown() {
        Self.buffer = nil
        Self.bufferCustom = nil
        Self.bufferRuleBlock = nil
    }

    func testBasicParsing() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        XCTAssertEqual(parsedRules.count, 10)
    }

    func testAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "button")
        let value = parsedRules.getValue(with: "color", for: stub1)
        let unwrappedValue = try XCTUnwrap(value)
        XCTAssertEqual(unwrappedValue.count, 1)
        
        XCTAssertEqual(unwrappedValue[0], CSSValueKeywords.getValue(for: "yellow"))
    }
    
    func testHierarchicalAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        var stubChild = StubCSSConsumer(type: "img")
        let value1 = parsedRules.getValue(with: "color", for: stubChild)
        XCTAssertNil(value1)
        
        let stubParent = StubCSSConsumer(type: "dummy", classes: ["youpi"])
        stubChild.ancestor = stubParent
        let value2 = parsedRules.getValue(with: "color", for: stubChild)
        let unwrappedValue2 = try XCTUnwrap(value2)
        XCTAssertEqual(unwrappedValue2.count, 1)
        
        XCTAssertEqual(unwrappedValue2[0], CSSValueKeywords.getValue(for: "yellow"))
    }
    
    func testColors() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stubChild = StubCSSConsumer(type: "button")
        let colors = parsedRules.getValue(with: "background", for: stubChild)
        let unwrappedColors = try XCTUnwrap(colors)
        
        let expectedColors = [
            CSSValueKeywords.getValue(for: "red"),
            CSSValue.color(1, 0, 0.502, 1),
            CSSValue.color(0.5, 0.5, 0.5, 1.0),
            CSSValue.color(0.6667, 0, 0.7333, 1),
            CSSValue.color(0.6667, 0.6667, 0.6667, 0.6667),
            CSSValue.color(1, 0.502, 0, 1)
        ]
        XCTAssertEqual(unwrappedColors.count, expectedColors.count)
        for i in 0..<expectedColors.count {
            XCTAssertEqual(unwrappedColors[i], expectedColors[i])
        }
    }
    
    func testClauseScore() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "dummy", classes: ["first", "second"])
        let value1 = parsedRules.getValue(with: "color", for: stub1)
        let unwrappedValue1 = try XCTUnwrap(value1)
        
        guard case CSSValue.color = unwrappedValue1[0] else {
            XCTFail("Value must be a color");
            return
        }
        XCTAssertEqual(unwrappedValue1[0], CSSValueKeywords.getValue(for: "red"))
        
        let stub2 = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let value2 = parsedRules.getValue(with: "color", for: stub2)
        let unwrappedValue2 = try XCTUnwrap(value2)
        
        guard case CSSValue.color = unwrappedValue2[0] else {
            XCTFail("Value must be a color");
            return
        }
        XCTAssertEqual(unwrappedValue2[0], CSSValueKeywords.getValue(for: "black"))
    }
    
    func testAllValues() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let values = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(values.count, 4)
        
        let color = try XCTUnwrap(values["color"])[0]
        guard case CSSValue.color = color else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(color, CSSValueKeywords.getValue(for: "black"))
        
        let textColor = try XCTUnwrap(values["text-color"])[0]
        guard case CSSValue.color = textColor else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(textColor, CSSValueKeywords.getValue(for: "green"))
    }
    
    func testUniversalSelector() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "a", pseudoClasses: ["visited"])
        let color = parsedRules.getValue(with: "color", for: stub1)
        let unwrappedColor = try XCTUnwrap(color)
        
        guard case CSSValue.color = unwrappedColor[0] else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(unwrappedColor[0], CSSValueKeywords.getValue(for: "black"))
        
        let stub2 = StubCSSConsumer(type: "select", classes: ["custom"], pseudoClasses: ["selected"])
        let bgColor = parsedRules.getValue(with: "background-color", for: stub2)
        let unwrappedBgColor = try XCTUnwrap(bgColor)
        
        guard case CSSValue.color = unwrappedBgColor[0] else {
            XCTFail("Value must be a color")
            return
        }
        XCTAssertEqual(unwrappedBgColor[0], CSSValue.color(1, 1, 1, 0.5))
    }
    
    func testPseudoClasses() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "button")
        let color1 = parsedRules.getValue(with: "color", for: stub1)
        let unwrappedColor1 = try XCTUnwrap(color1)
        
        guard case CSSValue.color = unwrappedColor1[0] else {
            XCTFail("Value must be a color");
            return
        }
        XCTAssertEqual(unwrappedColor1[0], CSSValueKeywords.getValue(for: "yellow"))
        
        let stub2 = StubCSSConsumer(type: "button", pseudoClasses: ["hover"])
        let color2 = parsedRules.getValue(with: "color", for: stub2)
        let unwrappedColor2 = try XCTUnwrap(color2)
        
        guard case CSSValue.color = unwrappedColor2[0] else {
            XCTFail("Value must be a color");
            return
        }
        XCTAssertEqual(unwrappedColor2[0], CSSValueKeywords.getValue(for: "red"))
        
        let stub3 = StubCSSConsumer(type: "button", pseudoClasses: ["missing-pseudo-class"])
        let color3 = parsedRules.getValue(with: "color", for: stub3)
        let unwrappedColor3 = try XCTUnwrap(color3)
        
        guard case CSSValue.color = unwrappedColor3[0] else {
            XCTFail("Value must be a color");
            return
        }
        XCTAssertEqual(unwrappedColor3[0], CSSValueKeywords.getValue(for: "yellow"))
        
        let stub4 = StubCSSConsumer(type: "input", pseudoClasses: ["hover"])
        let color4 = parsedRules.getValue(with: "color", for: stub4)
        let unwrappedColor4 = try XCTUnwrap(color4)
        
        guard case CSSValue.color = unwrappedColor4[0] else {
            XCTFail("Value must be a color");
            return
        }
        XCTAssertEqual(unwrappedColor4[0], CSSValueKeywords.getValue(for: "red"))
    }
    
    func testShorthandAttributes() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())
        
        let stub = StubCSSConsumer(type: "button")
        let allValues = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(allValues.count, 9)
        
        let expectedAttributes: [String: [CSSValue]] = [
            "padding": [ .number(10, .px), .number(20, .px) ],
            "padding-top": [ .number(10, .px) ],
            "padding-right": [ .number(20, .px) ],
            "padding-bottom": [ .number(10, .px) ],
            "padding-left": [ .number(20, .px) ]
        ]
        for expectedAttribute in expectedAttributes {
            let attributeValue = allValues[expectedAttribute.key]
            XCTAssertNotNil(attributeValue)
            XCTAssertEqual(attributeValue, expectedAttribute.value)
        }
    }
    
    func testStandaloneAttributeValueParsing() throws {
        let attributeValue = "green"
        let values = try CSSParser.parse(attributeValue: attributeValue)
        XCTAssertEqual(values.count, 1)
        
        XCTAssertEqual(values[0], CSSValueKeywords.getValue(for: "green"))
    }
    
    func testStandaloneRuleBlockParsing() throws {
        let parsedRuleBlock = try CSSParser.parse(ruleBlock: Self.bufferRuleBlock, validationConfiguration: StubCSSValidationConfiguration())
        let colorValues = parsedRuleBlock["color"]
        XCTAssertNotNil(colorValues)
        
        let colorValue = colorValues![0]
        XCTAssertEqual(colorValue, CSSValueKeywords.getValue(for: "black"))
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
            XCTAssertEqual(token, CSSToken(line: 7, type: .string, value: "background"))
            XCTAssertEqual(value, CSSValueKeywords.getValue(for: "red"))
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
