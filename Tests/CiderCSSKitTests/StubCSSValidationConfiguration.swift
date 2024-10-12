@testable import CiderCSSKit

struct StubCustomValueHolder: Equatable {
    let value1: String
    let value2: Float
}

class StubCSSValidationConfiguration: CSSValidationConfiguration {

    override var valueGroupingTypeByAttribute: [String: CSSValueGroupingType] {
        var base = super.valueGroupingTypeByAttribute
        base["background"] = .multiple([.color], min: 1)
        base["unit-tester"] = .single([.angle, .length()])
        base["anchored-position"] = .multiple([.length()], min: 2, max: 2)
        return base
    }

    override func parseFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }

        switch functionName {
        case "color":
            return try Self.parseColorFunction(functionToken: functionToken, attributes: attributes)
        default:
            return try super.parseFunction(functionToken: functionToken, attributes: attributes)
        }
    }

    override func parseKeyword(attributeToken: CSSToken, potentialKeyword: CSSToken) throws -> CSSValue {
        guard potentialKeyword.type == .string else { throw CSSParserErrors.invalidToken(potentialKeyword) }

        let stringTokenValue = potentialKeyword.value as! String

        if stringTokenValue == "invertedwhite", let black = CSSColorKeywords.getValue(for: "black") {
            return black
        }

        if stringTokenValue == "sans-serif" {
            return .string("SF Pro")
        }

        if stringTokenValue == "stretch" {
            return .keyword("stretch")
        }

        return try super.parseKeyword(attributeToken: attributeToken, potentialKeyword: potentialKeyword)
    }

    private static func parseColorFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        if attributes.count < 1 {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken: functionToken, values: attributes)
        }
        else if attributes.count > 1 {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken: functionToken, values: attributes)
        }

        guard case let .string(colorName) = attributes[0], let color = CSSColorKeywords.colors[colorName] else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attributes[0])
        }

        return color
    }

}
