import XCTest
@testable import CiderCSSKit

final class CSSParserTests: XCTestCase {

    private static var buffer: String!
    private static var bufferCustom: String!
    private static var bufferInvalidCustom: String!
    private static var bufferRuleBlock: String!
    
    override class func setUp() {
        let dataURL = Bundle.module.url(forResource: "ParserTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)
        
        let customDataURL = Bundle.module.url(forResource: "ParserCustomTests", withExtension: "ckcss")
        XCTAssertNotNil(customDataURL)
        Self.bufferCustom = try! String(contentsOf: customDataURL!)
        
        let invalidCustomDataURL = Bundle.module.url(forResource: "ParserInvalidCustomTests", withExtension: "ckcss")
        XCTAssertNotNil(invalidCustomDataURL)
        Self.bufferInvalidCustom = try! String(contentsOf: invalidCustomDataURL!)
        
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
        
        XCTAssertEqual(unwrappedValue[0], CSSColorKeywords.getValue(for: "yellow"))
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
        
        XCTAssertEqual(unwrappedValue2[0], CSSColorKeywords.getValue(for: "yellow"))
    }
    
    func testColors() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stubChild = StubCSSConsumer(type: "button")
        let colors = parsedRules.getValue(with: "background", for: stubChild)
        let unwrappedColors = try XCTUnwrap(colors)
        
        let expectedColors = [
            CSSColorKeywords.getValue(for: "red"),
            CSSValue.color(1, 0, 0.502, 1),
            CSSValue.color(0.502, 0.502, 0.502, 1.0),
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
        try CSSTestHelpers.assertColorValue(values: value1, expectedValue: CSSColorKeywords.getValue(for: "red"))
        
        let stub2 = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let value2 = parsedRules.getValue(with: "color", for: stub2)
        try CSSTestHelpers.assertColorValue(values: value2, expectedValue: CSSColorKeywords.getValue(for: "black"))
    }
    
    func testAllValues() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let values = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(values.count, 4)
        
        try CSSTestHelpers.assertColorValue(values: values["color"], expectedValue: CSSColorKeywords.getValue(for: "black"))
        try CSSTestHelpers.assertColorValue(values: values["text-color"], expectedValue: CSSColorKeywords.getValue(for: "green"))
    }
    
    func testUniversalSelector() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "a", pseudoClasses: ["visited"])
        let color = parsedRules.getValue(with: "color", for: stub1)
        try CSSTestHelpers.assertColorValue(values: color, expectedValue: CSSColorKeywords.getValue(for: "black"))
        
        let stub2 = StubCSSConsumer(type: "select", classes: ["custom"], pseudoClasses: ["selected"])
        let bgColor = parsedRules.getValue(with: "background-color", for: stub2)
        try CSSTestHelpers.assertColorValue(values: bgColor, expectedValue:CSSValue.color(1, 1, 1, 0.5))
    }
    
    func testPseudoClasses() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub1 = StubCSSConsumer(type: "button")
        let color1 = parsedRules.getValue(with: "color", for: stub1)
        try CSSTestHelpers.assertColorValue(values: color1, expectedValue: CSSColorKeywords.getValue(for: "yellow"))
        
        let stub2 = StubCSSConsumer(type: "button", pseudoClasses: ["hover"])
        let color2 = parsedRules.getValue(with: "color", for: stub2)
        try CSSTestHelpers.assertColorValue(values: color2, expectedValue: CSSColorKeywords.getValue(for: "red"))
        
        let stub3 = StubCSSConsumer(type: "button", pseudoClasses: ["missing-pseudo-class"])
        let color3 = parsedRules.getValue(with: "color", for: stub3)
        try CSSTestHelpers.assertColorValue(values: color3, expectedValue: CSSColorKeywords.getValue(for: "yellow"))
        
        let stub4 = StubCSSConsumer(type: "input", pseudoClasses: ["hover"])
        let color4 = parsedRules.getValue(with: "color", for: stub4)
        try CSSTestHelpers.assertColorValue(values: color4, expectedValue: CSSColorKeywords.getValue(for: "red"))
    }
    
    func testShorthandAttributes() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.bufferCustom, validationConfiguration: StubCSSValidationConfiguration())
        
        let stub = StubCSSConsumer(type: "button", identifier: "test")
        let allValues = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(allValues.count, 18)
        
        let expectedAttributes: [String: [CSSValue]] = [
            "padding": [ .length(10, .px), .length(20, .px), .length(10, .px), .length(20, .px) ],
            "padding-top": [ .length(10, .px) ],
            "padding-right": [ .length(20, .px) ],
            "padding-bottom": [ .length(10, .px) ],
            "padding-left": [ .length(20, .px) ],
            
            "font": [ .length(12, .px), .separator, .length(18, .px), .string("Arial") ],
            "font-size": [ .length(12, .px) ],
            "line-height": [ .length(18, .px) ],
            "font-family": [ .string("Arial") ],
            
            "border-image": [ .url(URL(string: "https://example.com/image.png")!), .number(27), .number(23), .separator, .length(50, .px), .length(30, .px), .separator, .length(1, .rem), .keyword("stretch") ],
            "border-image-source": [ .url(URL(string: "https://example.com/image.png")!) ],
            "border-image-slice": [ .number(27), .number(23) ],
            "border-image-width": [ .length(50, .px), .length(30, .px) ],
            "border-image-outset": [ .length(1, .rem) ],
            "border-image-repeat": [ .keyword("stretch") ]
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
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSColorKeywords.getValue(for: "green"))
    }
    
    func testStandaloneRuleBlockParsing() throws {
        let parsedRuleBlock = try CSSParser.parse(ruleBlock: Self.bufferRuleBlock, validationConfiguration: StubCSSValidationConfiguration())
        let colorValues = parsedRuleBlock["color"]
        try CSSTestHelpers.assertColorValue(values: colorValues, expectedValue: CSSColorKeywords.getValue(for: "black"))
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
        catch CSSParserErrors.invalidAttributeValues(let token, let values) {
            XCTAssertEqual(token, CSSToken(line: 7, type: .string, value: "background"))
            XCTAssertEqual(values[0], CSSColorKeywords.getValue(for: "red"))
        }
    }
    
    func testCustomValidationFailing() throws {
        do {
            let _ = try CSSParser.parse(buffer: Self.bufferInvalidCustom, validationConfiguration: StubInvalidCSSValidationConfiguration())
            XCTFail("Error should be raised")
        }
        catch CSSParserErrors.unknownFunction(let functionToken) {
            XCTAssertEqual(functionToken, CSSToken(line: 1, type: .string, value: "foo"))
        }
    }
    
    func testUnits() throws {
        do {
            let _ = try CSSParser.parse(attributeValue: "10tt")
        }
        catch CSSParserErrors.invalidUnit(let unitToken) {
            XCTAssertEqual(unitToken, CSSToken(line: 0, type: .string, value: "tt"))
        }
        
        for unit in CSSLengthUnit.allCases {
            let values = try CSSParser.parse(attributeValue: "10\(unit.rawValue)")
            XCTAssertEqual(values, [ CSSValue.length(10, unit) ])
        }
        
        for unit in CSSAngleUnit.allCases {
            let values = try CSSParser.parse(attributeValue: "10\(unit.rawValue)")
            XCTAssertEqual(values, [ CSSValue.angle(10, unit) ])
        }
    }
    
    func testEmptySheet() throws {
        let _ = try CSSParser.parse(buffer: "")
    }
    
    func testEmptyRule() throws {
        let _ = try CSSParser.parse(buffer: "* {}")
    }
    
    func testPercents() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        let stub = StubCSSConsumer(type: "button", pseudoClasses: [ "hover" ])
        let values = parsedRules.getValue(with: "transform-origin", for: stub)
        XCTAssertEqual(values, [ .percentage(50), .percentage(75) ])
    }
    
}
