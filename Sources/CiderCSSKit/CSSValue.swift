public enum CSSValueUnit: String {
    case none = ""
    case px = "px"
    case pt = "pt"
}

public enum CSSValue: Equatable {
    
    case string(String)
    case unit(Float, CSSValueUnit)
    case color(Float, Float, Float, Float)
    
    static func parseStringToken(_ token: CSSToken) throws -> CSSValue {
        guard token.type == .string else { throw CSSParserErrors.invalidToken(token) }
        
        let stringTokenValue = token.value as! String
        
        guard
            !token.literalString,
            let keywordValue = CSSValueKeywords.keywords[stringTokenValue.lowercased()]
        else {
            return .string(stringTokenValue)
        }
        
        return keywordValue
    }
    
    static func parseFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }
        
        switch functionName {
        case "rgb":
            return try Self.parseRGBFunction(functionToken: functionToken, attributes: attributes)
        case "rgba":
            return try Self.parseRGBAFunction(functionToken: functionToken, attributes: attributes)
        default:
            throw CSSParserErrors.unknownedFunction(functionToken)
        }
    }
    
    private static func parseFloatComponents(numberOfComponents: Int, functionToken: CSSToken, attributes: [CSSValue]) throws -> [Float] {
        if attributes.count < numberOfComponents {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken, attributes)
        }
        else if attributes.count > numberOfComponents {
            throw CSSParserErrors.tooManyFunctionAttributs(functionToken, attributes)
        }
        
        var components = [Float]()
        
        for i in 0..<numberOfComponents {
            let attr = attributes[i]
            if case let .unit(value, unit) = attr {
                if value < 0 || value > 1 || unit != .none {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken, attr)
                }
                else {
                    components.append(value)
                }
            }
            else {
                throw CSSParserErrors.invalidFunctionAttribute(functionToken, attr)
            }
        }
        
        return components
    }
    
    private static func parseRGBFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        let components = try parseFloatComponents(numberOfComponents: 3, functionToken: functionToken, attributes: attributes)
        return .color(components[0], components[1], components[2], 1)
    }
    
    private static func parseRGBAFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        let components = try parseFloatComponents(numberOfComponents: 4, functionToken: functionToken, attributes: attributes)
        return .color(components[0], components[1], components[2], components[3])
    }
    
}
