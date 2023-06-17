@testable import CiderCSSKit

struct StubCustomValueHolder: Equatable {
    let value1: String
    let value2: Float
}

class StubCSSValidationConfiguration: CSSValidationConfiguration {
    
    override var valueTypesByAttribute: [String : [CSSValueType]] { [
        "background": [.color],
        "background-color": [.color],
        "color": [.color],
        "name": [.string, .custom("CustomValueHolder")],
        "text-color": [.color]
    ] }
    
    override func parseFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }
        
        switch functionName {
        case "color":
            return try Self.parseColorFunction(functionToken: functionToken, attributes: attributes)
        case "custommethod":
            return try Self.parseCustomMethodFunction(functionToken: functionToken, attributes: attributes)
        default:
            throw CSSParserErrors.unknownFunction(functionToken)
        }
    }
    
    override func parseKeyword(stringToken: CSSToken) throws -> CSSValue {
        guard stringToken.type == .string else { throw CSSParserErrors.invalidToken(stringToken) }
        
        let stringTokenValue = stringToken.value as! String
        
        if stringTokenValue == "invertedwhite", let black = CSSValueKeywords.getValue(for: "black") {
            return black
        }
        
        throw CSSParserErrors.invalidKeyword(stringToken)
    }
    
    override func validateCustomAttributeValue(attributeToken: CSSToken, value: CSSValue, customTypeName: String) -> Bool {
        if case let .custom(equatable) = value, customTypeName == "CustomValueHolder", equatable is StubCustomValueHolder {
            return true
        }
        return false
    }
    
    private static func parseColorFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        if attributes.count < 1 {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken, attributes)
        }
        else if attributes.count > 1 {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken, attributes)
        }

        guard case let .string(colorName) = attributes[0], let color = CSSValueKeywords.colors[colorName] else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken, attributes[0])
        }

        return color
    }
    
    private static func parseCustomMethodFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        if attributes.count < 2 {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken, attributes)
        }
        else if attributes.count > 2 {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken, attributes)
        }

        guard case let .string(value1) = attributes[0] else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken, attributes[0])
        }
        
        guard case let .number(value2, _) = attributes[1] else {
            throw CSSParserErrors.invalidAttributeValue(functionToken, attributes[1])
        }

        return .custom(StubCustomValueHolder(value1: value1, value2: value2))
    }
    
}
