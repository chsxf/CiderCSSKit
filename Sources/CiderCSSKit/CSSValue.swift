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
    case number(Float, CSSValueUnit)
    case color(Float, Float, Float, Float)
    case custom(any Equatable)
    
    public static func == (lhs: CSSValue, rhs: CSSValue) -> Bool {
        switch lhs {
        case let .string(leftString):
            if case let .string(rightString) = rhs {
                return leftString == rightString
            }
            return false
            
        case let .number(leftNumber, leftUnit):
            if case let .number(rightNumber, rightUnit) = rhs {
                return leftNumber == rightNumber && leftUnit == rightUnit
            }
            return false
            
        case let .color(leftR, leftG, leftB, leftA):
            if case let .color(rightR, rightG, rightB, rightA) = rhs {
                return leftR == rightR && leftG == rightG && leftB == rightB && leftA == rightA
            }
            return false
            
        case let .custom(leftEquatable):
            if case let .custom(rightEquatable) = rhs {
                return leftEquatable.isEqual(rightEquatable)
            }
            return false
        }
    }
    
    static func parseStringToken(_ token: CSSToken, validationConfiguration: CSSValidationConfiguration?) throws -> CSSValue {
        guard token.type == .string else { throw CSSParserErrors.invalidToken(token) }
        
        let stringTokenValue = token.value as! String
        
        if !token.literalString {
            if let builtinKeywordValue = CSSValueKeywords.getValue(for: stringTokenValue.lowercased()) {
                return builtinKeywordValue
            }
            
            if let validationConfiguration {
                return try validationConfiguration.parseKeyword(stringToken: token)
            }
            
            throw CSSParserErrors.invalidKeyword(token)
        }
        
        return .string(stringTokenValue)
    }
    
    static func parseFunction(functionToken: CSSToken, attributes: [CSSValue], validationConfiguration: CSSValidationConfiguration?) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }
        
        switch functionName {
        case "rgb":
            return try Self.parseRGBFunction(functionToken: functionToken, attributes: attributes)
        case "rgba":
            return try Self.parseRGBAFunction(functionToken: functionToken, attributes: attributes)
        default:
            break
        }
        
        if let validationConfiguration {
            return try validationConfiguration.parseFunction(functionToken: functionToken, attributes: attributes)
        }
        
        throw CSSParserErrors.unknownedFunction(functionToken)
    }
    
    public static func parseFloatComponents(numberOfComponents: Int, functionToken: CSSToken, attributes: [CSSValue], from baseIndex: Int = 0) throws -> [Float] {
        if attributes.count < numberOfComponents + baseIndex {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken, attributes)
        }
        else if attributes.count > numberOfComponents + baseIndex {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken, attributes)
        }
        
        var components = [Float]()
        
        for i in 0..<numberOfComponents {
            let attr = attributes[baseIndex + i]
            if case let .number(value, unit) = attr {
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
