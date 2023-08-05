import XCTest
@testable import CiderCSSKit

final class CSSUnitTests: XCTestCase {

    func testUnitParsing() throws {
        do {
            let _ = try CSSParser.parse(attributeName: "unit-tester", attributeValue: "10tt", validationConfiguration: StubCSSValidationConfiguration())
        }
        catch CSSParserErrors.invalidUnit(let unitToken) {
            XCTAssertEqual(unitToken, CSSToken(line: 0, type: .string, value: "tt"))
        }
        
        for unit in CSSLengthUnit.allCases {
            let values = try CSSParser.parse(attributeName: "unit-tester", attributeValue: "10\(unit.rawValue)", validationConfiguration: StubCSSValidationConfiguration())
            XCTAssertEqual(values, [ CSSValue.length(10, unit) ])
        }
        
        for unit in CSSAngleUnit.allCases {
            let values = try CSSParser.parse(attributeName: "unit-tester", attributeValue: "10\(unit.rawValue)", validationConfiguration: StubCSSValidationConfiguration())
            XCTAssertEqual(values, [ CSSValue.angle(10, unit) ])
        }
    }
    
    func testLengthUnitConversion() throws {
        let inchesInPixels = CSSLengthUnit.in.convert(to: .px)
        XCTAssertEqual(inchesInPixels, 96)
        
        let inchesInCentimeters = CSSLengthUnit.in.convert(to: .cm)
        XCTAssertEqual(inchesInCentimeters, 2.54)
        
        let centimetersInInches = CSSLengthUnit.cm.convert(to: .in)
        XCTAssertEqual(centimetersInInches, 1.0 / 2.54)
        
        let millimetersToCentimers = CSSLengthUnit.mm.convert(amount: 10, to: .cm)
        XCTAssertEqual(millimetersToCentimers, 1)
    }
    
    func testAngleUnitConversion() throws {
        let degreesInRadians = CSSAngleUnit.deg.convert(amount: 180, to: .rad)
        XCTAssertEqual(degreesInRadians, Float.pi, accuracy: 0.000001)
        
        let degreesInTurn = CSSAngleUnit.deg.convert(to: .turn)
        XCTAssertEqual(degreesInTurn, 1.0 / 360, accuracy: 0.000001)
        
        let turnInRadians = CSSAngleUnit.turn.convert(to: .rad)
        XCTAssertEqual(turnInRadians, Float.pi * 2, accuracy: 0.000001)
    }

}
