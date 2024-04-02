import XCTest
@testable import CiderCSSKit

final class CSSParserTests: XCTestCase {

    private static var buffer: String!
    private static var bufferWithComments: String!
    private static var bufferWithInvalidComment: String!
    private static var bufferCustom: String!
    private static var bufferInvalidCustom: String!
    private static var bufferRuleBlock: String!

    override class func setUp() {
        // swiftlint:disable force_try
        let dataURL = Bundle.module.url(forResource: "ParserTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)

        let commentsDataURL = Bundle.module.url(forResource: "ParserTestsWithComments", withExtension: "ckcss")
        XCTAssertNotNil(commentsDataURL)
        Self.bufferWithComments = try! String(contentsOf: commentsDataURL!)

        let invalidCommentsDataURL = Bundle.module.url(forResource: "ParserTestsWithInvalidComment", withExtension: "ckcss")
        XCTAssertNotNil(invalidCommentsDataURL)
        Self.bufferWithInvalidComment = try! String(contentsOf: invalidCommentsDataURL!)

        let customDataURL = Bundle.module.url(forResource: "ParserCustomTests", withExtension: "ckcss")
        XCTAssertNotNil(customDataURL)
        Self.bufferCustom = try! String(contentsOf: customDataURL!)

        let invalidCustomDataURL = Bundle.module.url(forResource: "ParserInvalidCustomTests", withExtension: "ckcss")
        XCTAssertNotNil(invalidCustomDataURL)
        Self.bufferInvalidCustom = try! String(contentsOf: invalidCustomDataURL!)

        let ruleBlockDataURL = Bundle.module.url(forResource: "ParserRuleBlockTests", withExtension: "ckcss")
        XCTAssertNotNil(ruleBlockDataURL)
        Self.bufferRuleBlock = try! String(contentsOf: ruleBlockDataURL!)
        // swiftlint:enable force_try
    }

    override class func tearDown() {
        Self.buffer = nil
        Self.bufferCustom = nil
        Self.bufferRuleBlock = nil
    }

    func testBasicParsing() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())
        XCTAssertEqual(parsedRules.count, 10)
    }

    func testAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stub1 = StubCSSConsumer(type: "button")
        let value = parsedRules.getValue(with: CSSAttributes.color, for: stub1)
        let unwrappedValue = try XCTUnwrap(value)
        XCTAssertEqual(unwrappedValue.count, 1)

        XCTAssertEqual(unwrappedValue[0], CSSColorKeywords.getValue(for: "yellow"))
    }

    func testHierarchicalAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        var stubChild = StubCSSConsumer(type: "img")
        let value1 = parsedRules.getValue(with: CSSAttributes.color, for: stubChild)
        XCTAssertNil(value1)

        let stubParent = StubCSSConsumer(type: "dummy", classes: ["youpi"])
        stubChild.ancestor = stubParent
        let value2 = parsedRules.getValue(with: CSSAttributes.color, for: stubChild)
        let unwrappedValue2 = try XCTUnwrap(value2)
        XCTAssertEqual(unwrappedValue2.count, 1)

        XCTAssertEqual(unwrappedValue2[0], CSSColorKeywords.getValue(for: "yellow"))
    }

    func testColors() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stubChild = StubCSSConsumer(type: "button")
        let colors = parsedRules.getValue(with: "background", for: stubChild)
        let unwrappedColors = try XCTUnwrap(colors)

        let expectedColors = [
            CSSColorKeywords.getValue(for: "red"),
            CSSValue.color(CSSColorSpace.sRGB, [1, 0, 0.502, 1]),
            CSSValue.color(CSSColorSpace.sRGB, [0.502, 0.502, 0.502, 1.0]),
            CSSValue.color(CSSColorSpace.sRGB, [0.6667, 0, 0.7333, 1]),
            CSSValue.color(CSSColorSpace.sRGB, [0.6667, 0.6667, 0.6667, 0.6667]),
            CSSValue.color(CSSColorSpace.sRGB, [1, 0.502, 0, 1])
        ]
        XCTAssertEqual(unwrappedColors.count, expectedColors.count)
        for index in 0..<expectedColors.count {
            XCTAssertEqual(unwrappedColors[index], expectedColors[index])
        }
    }

    func testClauseScore() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stub1 = StubCSSConsumer(type: "dummy", classes: ["first", "second"])
        let value1 = parsedRules.getValue(with: CSSAttributes.color, for: stub1)
        try CSSTestHelpers.assertColorValue(values: value1, expectedValue: CSSColorKeywords.getValue(for: "red"))

        let stub2 = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let value2 = parsedRules.getValue(with: CSSAttributes.color, for: stub2)
        try CSSTestHelpers.assertColorValue(values: value2, expectedValue: CSSColorKeywords.getValue(for: "black"))
    }

    func testAllValues() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stub = StubCSSConsumer(type: "label", identifier: "id", classes: ["first", "second"])
        let values = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(values.count, 4)

        try CSSTestHelpers.assertColorValue(values: values[CSSAttributes.color], expectedValue: CSSColorKeywords.getValue(for: "black"))
        XCTAssertEqual(values[CSSAttributes.textAlign], [.keyword("center")])
    }

    func testUniversalSelector() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stub1 = StubCSSConsumer(type: "a", pseudoClasses: ["visited"])
        let color = parsedRules.getValue(with: CSSAttributes.color, for: stub1)
        try CSSTestHelpers.assertColorValue(values: color, expectedValue: CSSColorKeywords.getValue(for: "black"))

        let stub2 = StubCSSConsumer(type: "select", classes: ["custom"], pseudoClasses: ["selected"])
        let bgColor = parsedRules.getValue(with: CSSAttributes.backgroundColor, for: stub2)
        try CSSTestHelpers.assertColorValue(values: bgColor, expectedValue: CSSValue.color(CSSColorSpace.sRGB, [1, 1, 1, 0.5]))
    }

    func testPseudoClasses() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stub1 = StubCSSConsumer(type: "button")
        let color1 = parsedRules.getValue(with: CSSAttributes.color, for: stub1)
        try CSSTestHelpers.assertColorValue(values: color1, expectedValue: CSSColorKeywords.getValue(for: "yellow"))

        let stub2 = StubCSSConsumer(type: "button", pseudoClasses: ["hover"])
        let color2 = parsedRules.getValue(with: CSSAttributes.color, for: stub2)
        try CSSTestHelpers.assertColorValue(values: color2, expectedValue: CSSColorKeywords.getValue(for: "red"))

        let stub3 = StubCSSConsumer(type: "button", pseudoClasses: ["missing-pseudo-class"])
        let color3 = parsedRules.getValue(with: CSSAttributes.color, for: stub3)
        try CSSTestHelpers.assertColorValue(values: color3, expectedValue: CSSColorKeywords.getValue(for: "yellow"))

        let stub4 = StubCSSConsumer(type: "input", pseudoClasses: ["hover"])
        let color4 = parsedRules.getValue(with: CSSAttributes.color, for: stub4)
        try CSSTestHelpers.assertColorValue(values: color4, expectedValue: CSSColorKeywords.getValue(for: "red"))
    }

    func testShorthandAttributes() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.bufferCustom, validationConfiguration: StubCSSValidationConfiguration())

        let stub = StubCSSConsumer(type: "button", identifier: "test")
        var allValues = parsedRules.getAllValues(for: stub)
        XCTAssertEqual(allValues.count, 21)

        var expectedAttributes: [String: [CSSValue]] = [
            CSSAttributes.padding: [ .length(10, .px), .length(20, .px), .length(10, .px), .length(20, .px) ],
            CSSAttributes.paddingTop: [ .length(10, .px) ],
            CSSAttributes.paddingRight: [ .length(20, .px) ],
            CSSAttributes.paddingBottom: [ .length(10, .px) ],
            CSSAttributes.paddingLeft: [ .length(20, .px) ],

            CSSAttributes.font: [ .length(12, .px), .separator, .length(18, .px), .string("Arial") ],
            CSSAttributes.fontFamily: [ .string("Arial") ],
            CSSAttributes.fontSize: [ .length(12, .px) ],
            CSSAttributes.fontStretch: [ .percentage(100) ],
            CSSAttributes.fontStyle: [ .keyword("normal") ],
            CSSAttributes.fontVariant: [ .keyword("normal") ],
            CSSAttributes.fontWeight: [ .number(400) ],
            CSSAttributes.lineHeight: [ .length(18, .px) ],

            CSSAttributes.borderImage: [ .url(URL(string: "https://example.com/image.png")!), .number(27), .number(23), .separator, .length(50, .px), .length(30, .px), .separator, .length(1, .rem), .keyword("stretch") ],
            CSSAttributes.borderImageSource: [ .url(URL(string: "https://example.com/image.png")!) ],
            CSSAttributes.borderImageSlice: [ .number(27), .number(23), .number(27), .number(23) ],
            CSSAttributes.borderImageWidth: [ .length(50, .px), .length(30, .px), .length(50, .px), .length(30, .px) ],
            CSSAttributes.borderImageOutset: [ .length(1, .rem), .length(1, .rem), .length(1, .rem), .length(1, .rem) ],
            CSSAttributes.borderImageRepeat: [ .keyword("stretch"), .keyword("stretch") ]
        ]
        for expectedAttribute in expectedAttributes {
            let attributeValue = allValues[expectedAttribute.key]
            XCTAssertNotNil(attributeValue)
            XCTAssertEqual(attributeValue, expectedAttribute.value)
        }

        let stub2 = StubCSSConsumer(type: "button", identifier: "test2")
        allValues = parsedRules.getAllValues(for: stub2)
        XCTAssertEqual(allValues.count, 9)

        expectedAttributes = [
            CSSAttributes.font: [ .keyword("italic"), .keyword("small-caps"), .number(700), .percentage(75), .length(12, .px), .separator, .length(18, .px), .string("Times New Roman"), .keyword("serif") ],
            CSSAttributes.fontFamily: [ .string("Times New Roman"), .keyword("serif") ],
            CSSAttributes.fontSize: [ .length(12, .px) ],
            CSSAttributes.fontStretch: [ .percentage(75) ],
            CSSAttributes.fontStyle: [ .keyword("italic") ],
            CSSAttributes.fontVariant: [ .keyword("small-caps") ],
            CSSAttributes.fontWeight: [ .number(700) ],
            CSSAttributes.lineHeight: [ .length(18, .px) ],
            CSSAttributes.verticalAlign: [ .keyword("middle")]
        ]
        for expectedAttribute in expectedAttributes {
            let attributeValue = allValues[expectedAttribute.key]
            XCTAssertNotNil(attributeValue)
            XCTAssertEqual(attributeValue, expectedAttribute.value)
        }

        let parsedRules2 = try CSSParser.parse(buffer: "button { border-image: url(\"sprite://border-diamonds.png\") 30; }")
        let stub3 = StubCSSConsumer(type: "button")
        let borderImageValues = parsedRules2.getValue(with: CSSAttributes.borderImage, for: stub3)
        XCTAssertEqual(borderImageValues, [ .url(URL(string: "sprite://border-diamonds.png")!), .number(30) ])
    }

    func testStandaloneAttributeValueParsing() throws {
        let attributeValue = "green"
        let values = try CSSParser.parse(attributeName: CSSAttributes.color, attributeValue: attributeValue)
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSColorKeywords.getValue(for: "green"))
    }

    func testStandaloneRuleBlockParsing() throws {
        let parsedRuleBlock = try CSSParser.parse(ruleBlock: Self.bufferRuleBlock, validationConfiguration: StubCSSValidationConfiguration())
        XCTAssertEqual(parsedRuleBlock.count, 2)
        let colorValues = parsedRuleBlock[CSSAttributes.color]
        try CSSTestHelpers.assertColorValue(values: colorValues, expectedValue: CSSColorKeywords.getValue(for: "black"))
    }

    func testValuesValidation() throws {
        _ = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())
    }

    func testCustomValidation() throws {
        _ = try CSSParser.parse(buffer: Self.bufferCustom, validationConfiguration: StubCSSValidationConfiguration())
    }

    func testValuesValidationFailing() throws {
        do {
            _ = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubInvalidCSSValidationConfiguration())
            XCTFail("Error should be raised")
        }
        catch CSSParserErrors.invalidAttributeValues(let token, let values) {
            XCTAssertEqual(token, CSSToken(line: 7, type: .string, value: "background"))
            XCTAssertEqual(values[0], CSSColorKeywords.getValue(for: "red"))
        }
    }

    func testCustomValidationFailing() throws {
        do {
            _ = try CSSParser.parse(buffer: Self.bufferInvalidCustom, validationConfiguration: StubInvalidCSSValidationConfiguration())
            XCTFail("Error should be raised")
        }
        catch CSSParserErrors.unknownFunction(let functionToken) {
            XCTAssertEqual(functionToken, CSSToken(line: 1, type: .string, value: "foo"))
        }
    }

    func testEmptySheet() throws {
        _ = try CSSParser.parse(buffer: "")
    }

    func testEmptyRule() throws {
        _ = try CSSParser.parse(buffer: "* {}")
    }

    func testPercents() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer, validationConfiguration: StubCSSValidationConfiguration())

        let stub = StubCSSConsumer(type: "button", pseudoClasses: [ "hover" ])
        let values = parsedRules.getValue(with: CSSAttributes.transformOrigin, for: stub)
        XCTAssertEqual(values, [ .percentage(50), .percentage(75), .length(0, .px) ])
    }

    func testComments() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.bufferWithComments, validationConfiguration: StubCSSValidationConfiguration())

        let stub = StubCSSConsumer(type: "button", pseudoClasses: [ "hover" ])
        let values = parsedRules.getValue(with: CSSAttributes.fontFamily, for: stub)
        XCTAssertEqual(values, [ .string("Times /* False comment */ New Roman") ] )
    }

    func testInvalidComment() throws {
        do {
            _ = try CSSParser.parse(buffer: Self.bufferWithInvalidComment, validationConfiguration: StubCSSValidationConfiguration())
            XCTFail("Error should be raised")
        }
        catch CSSParserErrors.unexpectedEnd { }

        let ruleBlock = try CSSParser.parse(ruleBlock: "transform-origin: right bottom; background-color: black; /* border-image: url(\"sprite:///border-diamonds.png\") 30; */")
        XCTAssertEqual(ruleBlock.count, 2)
    }

}
