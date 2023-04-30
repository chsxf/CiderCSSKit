import XCTest
@testable import CiderCSSKit

final class CSSParserTests: XCTestCase {

    private static var buffer: String!
    
    override class func setUp() {
        let dataURL = Bundle.module.url(forResource: "ParserTests", withExtension: "ckcss")
        XCTAssertNotNil(dataURL)
        Self.buffer = try! String(contentsOf: dataURL!)
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
        let value = parsedRules.getValue(with: "background-image", for: stub1)
        let unwrappedValue = try XCTUnwrap(value)
        XCTAssertEqual(unwrappedValue.count, 1)
        
        guard case let CSSValue.string(str) = unwrappedValue[0] else {
            XCTFail("Value must a string");
            return
        }
        XCTAssertEqual(str, "background")
    }
    
    func testHierarchicalAttributeRetrieval() throws {
        let parsedRules = try CSSParser.parse(buffer: Self.buffer)
        
        var stubChild = StubCSSConsumer(type: "img")
        let value1 = parsedRules.getValue(with: "background-image", for: stubChild)
        XCTAssertNil(value1)
        
        let stubParent = StubCSSConsumer(type: "dummy", classes: ["youpi"])
        stubChild.parent = stubParent
        let value2 = parsedRules.getValue(with: "background-image", for: stubChild)
        let unwrappedValue2 = try XCTUnwrap(value2)
        XCTAssertEqual(unwrappedValue2.count, 1)
        
        guard case let CSSValue.string(str) = unwrappedValue2[0] else {
            XCTFail("Value must a string");
            return
        }
        XCTAssertEqual(str, "background")
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
        XCTAssertEqual(values.count, 3)
        
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
        
        let backgroundImage = try XCTUnwrap(values["background-image"])[0]
        guard case let CSSValue.sprite(spriteName, scalingMethod, float1, float2, float3, float4) = backgroundImage else {
            XCTFail("Value must be a sprite")
            return
        }
        XCTAssertEqual(spriteName, "test")
        XCTAssertEqual(scalingMethod, .sliced)
        XCTAssertEqual(float1, 0.2)
        XCTAssertEqual(float2, 0.3)
        XCTAssertEqual(float3, 0.8)
        XCTAssertEqual(float4, 1)
    }
    
}
