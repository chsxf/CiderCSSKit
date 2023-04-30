public enum CSSValueUnit: String {
    case none = ""
    case px = "px"
    case pt = "pt"
}

public enum CSSSpriteScalingMethod: String {
    case sliced
    case fill
}

public enum CSSValue: Equatable {
    
    case string(String)
    case unit(Float, CSSValueUnit)
    case color(Float, Float, Float, Float)
    case sprite(String, CSSSpriteScalingMethod, Float, Float, Float, Float)
    
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
        case "sprite":
            return try Self.parseSpriteFunction(functionToken: functionToken, attributes: attributes)
        default:
            throw CSSParserErrors.unknownedFunction(functionToken)
        }
    }
    
    private static func parseFloatComponents(numberOfComponents: Int, functionToken: CSSToken, attributes: [CSSValue], from baseIndex: Int = 0) throws -> [Float] {
        if attributes.count < numberOfComponents + baseIndex {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken, attributes)
        }
        else if attributes.count > numberOfComponents + baseIndex {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken, attributes)
        }
        
        var components = [Float]()
        
        for i in 0..<numberOfComponents {
            let attr = attributes[baseIndex + i]
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
    
    private static func parseSpriteFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        if attributes.count < 2 {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken, attributes)
        }
        
        guard case let .string(spriteName) = attributes[0] else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken, attributes[0])
        }
        
        guard
            case let .string(scalingMethodString) = attributes[1],
            let scalingMethod = CSSSpriteScalingMethod(rawValue: scalingMethodString)
        else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken, attributes[1])
        }
        
        switch scalingMethod {
        case .fill:
            return .sprite(spriteName, scalingMethod, 0, 0, 0, 0)
            
        case .sliced:
            let components = try parseFloatComponents(numberOfComponents: 4, functionToken: functionToken, attributes: attributes, from: 2)
            return .sprite(spriteName, scalingMethod, components[0], components[1], components[2], components[3])
        }
    }
    
}
