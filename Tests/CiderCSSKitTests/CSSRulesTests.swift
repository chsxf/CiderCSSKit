import XCTest
@testable import CiderCSSKit

final class CSSRulesTests: XCTestCase {

    func testExample() throws {
        let rules = CSSRules()
        
        let attributes: [String: [CSSValue]] = [ "color": [.color(1, 0, 0, 1)] ]
        
        var clause = try CSSClause(clauseTokens: [
            CSSToken(line: 0, type: .string, value: "button")
        ])
        var rule = CSSRule(clause: clause, attributes: attributes)
        rules.addRule(rule)
        
        clause = try CSSClause(clauseTokens: [
            CSSToken(line: 0, type: .string, value: "button"),
            CSSToken(line: 0, type: .colon),
            CSSToken(line: 0, type: .string, value: "hover")
        ])
        rule = CSSRule(clause: clause, attributes: attributes)
        rules.addRule(rule)
        
        clause = try CSSClause(clauseTokens: [
            CSSToken(line: 0, type: .colon),
            CSSToken(line: 0, type: .string, value: "hover")
        ])
        rule = CSSRule(clause: clause, attributes: attributes)
        rules.addRule(rule)
        
        XCTAssertEqual(rules.count, 3)
        
        let rulesForColorAttribute = try XCTUnwrap(rules.rulesByAttribute["color"])
        
        rule = rulesForColorAttribute[0]
        XCTAssertEqual(rule.clause.score, 1010)
        var clauseMembers = rule.clause.members
        XCTAssertEqual(clauseMembers.count, 1)
        XCTAssertEqual(clauseMembers[0], .combinedIdentifier([.typeIdentifier("button"), .pseudoClassIdentifier("hover")]))
        
        rule = rulesForColorAttribute[1]
        XCTAssertEqual(rule.clause.score, 1000)
        clauseMembers = rule.clause.members
        XCTAssertEqual(clauseMembers.count, 1)
        XCTAssertEqual(clauseMembers[0], .pseudoClassIdentifier("hover"))
        
        rule = rulesForColorAttribute[2]
        XCTAssertEqual(rule.clause.score, 10)
        clauseMembers = rule.clause.members
        XCTAssertEqual(clauseMembers.count, 1)
        XCTAssertEqual(clauseMembers[0], .typeIdentifier("button"))
    }
    
    func testChaining() throws {
        let lowerProrityRules = try CSSParser.parse(buffer: "button { color: red; background-color: yellow; }")
        let higherProrityRules = try CSSParser.parse(buffer: "button { color: green; }")
        
        let stub = StubCSSConsumer(type: "button")
        var allAttributes = lowerProrityRules.getAllValues(for: stub)
        XCTAssertEqual(allAttributes.count, 2)
        
        var values = allAttributes["color"]
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "red"))
        
        values = allAttributes["background-color"]
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "yellow"))
        
        values = lowerProrityRules.getValue(with: "color", for: stub)
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "red"))
        
        values = lowerProrityRules.getValue(with: "background-color", for: stub)
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "yellow"))

        allAttributes = higherProrityRules.getAllValues(for: stub)
        XCTAssertEqual(allAttributes.count, 1)
        
        values = allAttributes["color"]
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "green"))

        values = allAttributes["background-color"]
        XCTAssertNil(values)
        
        values = higherProrityRules.getValue(with: "color", for: stub)
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "green"))
        
        values = higherProrityRules.getValue(with: "background-color", for: stub)
        XCTAssertNil(values)
        
        higherProrityRules.chainedLowerPriorityRules = lowerProrityRules
        allAttributes = higherProrityRules.getAllValues(for: stub)
        XCTAssertEqual(allAttributes.count, 2)
        
        values = allAttributes["color"]
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "green"))
        
        values = allAttributes["background-color"]
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "yellow"))
        
        values = higherProrityRules.getValue(with: "color", for: stub)
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "green"))
        
        values = higherProrityRules.getValue(with: "background-color", for: stub)
        try CSSTestHelpers.assertColorValue(values: values, expectedValue: CSSValueKeywords.getValue(for: "yellow"))
    }

}
