public enum CSSValueUnit: String, CaseIterable {
    case none = ""
    case ch
    case cm
    case dvh
    case dvw
    case em
    case ex
    case `in`
    case lh
    case lvh
    case lvw
    case mm
    case pc
    case pt
    case px
    case Q
    case rem
    case rlh
    case svh
    case svw
    case vb
    case vh
    case vi
    case vmax
    case vmin
    case vw
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
        
        throw CSSParserErrors.unknownFunction(functionToken)
    }
    
    public static func parseFloatComponents(numberOfComponents: Int, functionToken: CSSToken, attributes: [CSSValue], from baseIndex: Int = 0, min: Float? = nil, max: Float? = nil, specificUnit: CSSValueUnit? = nil) throws -> [Float] {
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
                if let min, value < min {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken, attr)
                }
                if let max, value > max {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken, attr)
                }
                if let specificUnit, unit != specificUnit {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken, attr)
                }
                components.append(value)
            }
            else {
                throw CSSParserErrors.invalidFunctionAttribute(functionToken, attr)
            }
        }
        
        return components
    }
    
    private static func parseRGBFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        let components = try parseFloatComponents(numberOfComponents: 3, functionToken: functionToken, attributes: attributes, min: 0, max: 255, specificUnit: CSSValueUnit.none)
        let roundedComponents = components.map { ($0 / 255.0).rounded(toPlaces: 4) }
        return .color(roundedComponents[0], roundedComponents[1], roundedComponents[2], 1)
    }
    
    private static func parseRGBAFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        let rgbComponents = try parseFloatComponents(numberOfComponents: 4, functionToken: functionToken, attributes: attributes, min: 0, max: 255, specificUnit: CSSValueUnit.none)
        let roundedRGBComponents = rgbComponents.map { ($0 / 255.0).rounded(toPlaces: 4) }
        let alphaComponent = try parseFloatComponents(numberOfComponents: 1, functionToken: functionToken, attributes: attributes, from: 3)
        return .color(roundedRGBComponents[0], roundedRGBComponents[1], roundedRGBComponents[2], alphaComponent[0].rounded(toPlaces: 4))
    }
    
}
