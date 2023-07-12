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

}
