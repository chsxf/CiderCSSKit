@testable import CiderCSSKit

struct StubCustomValueHolder: Equatable {
    let value1: String
    let value2: Float
}

class StubCSSValidationConfiguration: CSSValidationConfiguration {
    
    override var valueGroupingTypeByAttribute: [String : CSSValueGroupingType] {
        var base = super.valueGroupingTypeByAttribute
        base["background"] = .multiple([.color], min: 1)
        base["unit-tester"] = .single([.angle, .length()])
        return base
    }
    
    override func parseFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }
        
        switch functionName {
        case "color":
            return try Self.parseColorFunction(functionToken: functionToken, attributes: attributes)
        case "custommethod":
            return try Self.parseCustomMethodFunction(functionToken: functionToken, attributes: attributes)
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
    
    override func validateCustomAttributeValue(attributeToken: CSSToken, value: CSSValue, customTypeName: String) -> Bool {
        if case let .custom(equatable) = value, customTypeName == "CustomValueHolder", equatable is StubCustomValueHolder {
            return true
        }
        return false
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
    
    private static func parseCustomMethodFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        if attributes.count < 2 {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken: functionToken, values: attributes)
        }
        else if attributes.count > 2 {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken: functionToken, values: attributes)
        }

        guard case let .string(value1) = attributes[0] else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attributes[0])
        }
        
        guard case let .number(value2) = attributes[1] else {
            throw CSSParserErrors.invalidAttributeValue(attributeToken: functionToken, value: attributes[1])
        }

        return .custom(StubCustomValueHolder(value1: value1, value2: value2))
    }
    
}
