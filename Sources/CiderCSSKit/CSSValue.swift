import Foundation

public enum CSSValue: Equatable {
    
    case angle(Float, CSSAngleUnit)
    case color(Float, Float, Float, Float)
    case custom(any Equatable)
    case keyword(String)
    case length(Float, CSSLengthUnit)
    case number(Float)
    case percentage(Float)
    case separator
    case string(String)
    case url(URL)
    
    public var isNumeric: Bool {
        switch self {
        case .angle, .length, .number, .percentage:
            return true
        default:
            return false
        }
    }
    
    public static func == (lhs: CSSValue, rhs: CSSValue) -> Bool {
        switch lhs {
        case let angle(leftValue, leftUnit):
            if case let .angle(rightValue, rightUnit) = rhs {
                return leftValue == rightValue && leftUnit == rightUnit
            }
            
        case let .color(leftR, leftG, leftB, leftA):
            if case let .color(rightR, rightG, rightB, rightA) = rhs {
                return leftR == rightR && leftG == rightG && leftB == rightB && leftA == rightA
            }
            
        case let .custom(leftEquatable):
            if case let .custom(rightEquatable) = rhs {
                return leftEquatable.isEqual(rightEquatable)
            }

        case let .keyword(leftKeyword):
            if case let .keyword(rightKeyword) = rhs {
                return leftKeyword == rightKeyword
            }
            
        case let length(leftValue, leftUnit):
            if case let .length(rightValue, rightUnit) = rhs {
                return leftValue == rightValue && leftUnit == rightUnit
            }
            
        case let .number(leftNumber):
            if case let .number(rightNumber) = rhs {
                return leftNumber == rightNumber
            }

        case let .percentage(leftPercent):
            if case let .percentage(rightPercent) = rhs {
                return leftPercent == rightPercent
            }
            
        case .separator:
            if case .separator = rhs {
                return true
            }
            
        case let .string(leftString):
            if case let .string(rightString) = rhs {
                return leftString == rightString
            }
            
        case let .url(leftURL):
            if case let .url(rightURL) = rhs {
                return leftURL == rightURL
            }
        }
        
        return false
    }
    
    static func parseStringToken(_ token: CSSToken, attributeToken: CSSToken, validationConfiguration: CSSValidationConfiguration?) throws -> CSSValue {
        guard token.type == .string else { throw CSSParserErrors.invalidToken(token) }
        
        let stringTokenValue = token.value as! String
        
        if !token.literalString {
            if let builtinColorValue = CSSColorKeywords.getValue(for: stringTokenValue.lowercased()) {
                return builtinColorValue
            }
            
            if let validationConfiguration {
                return try validationConfiguration.parseKeyword(attributeToken: attributeToken, potentialKeyword: token)
            }
            
            throw CSSParserErrors.invalidKeyword(attributeToken: attributeToken, potentialKeyword: token)
        }
        
        return .string(stringTokenValue)
    }
    
    static func parseFunction(functionToken: CSSToken, attributes: [CSSValue], validationConfiguration: CSSValidationConfiguration?) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }
        
        switch functionName {
        case "rgb":
            return try Self.parseRGBFunction(functionToken, attributes)
        case "rgba":
            return try Self.parseRGBAFunction(functionToken, attributes)
        case "url":
            return try Self.parseURL(functionToken, attributes)
        default:
            break
        }
        
        if let validationConfiguration {
            return try validationConfiguration.parseFunction(functionToken: functionToken, attributes: attributes)
        }
        
        throw CSSParserErrors.unknownFunction(functionToken)
    }
    
    private static func validatesArgumentCount(numberOfArguments: Int, _ functionToken: CSSToken, _ attributes: [CSSValue]) throws {
        if attributes.count < numberOfArguments {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken: functionToken, values: attributes)
        }
        else if attributes.count > numberOfArguments {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken: functionToken, values: attributes)
        }
    }
    
    private static func parseFloatComponents(numberOfComponents: Int, _ functionToken: CSSToken, _ attributes: [CSSValue], from baseIndex: Int = 0, min: Float? = nil, max: Float? = nil) throws -> [Float] {
        try validatesArgumentCount(numberOfArguments: numberOfComponents + baseIndex, functionToken, attributes)
        
        var components = [Float]()
        
        for i in 0..<numberOfComponents {
            let attr = attributes[baseIndex + i]
            if case let .number(value) = attr {
                if let min, value < min {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attr)
                }
                if let max, value > max {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attr)
                }
                components.append(value)
            }
            else {
                throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attr)
            }
        }
        
        return components
    }
    
    private static func parseRGBFunction(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        let components = try parseFloatComponents(numberOfComponents: 3, functionToken, attributes, min: 0, max: 255)
        let roundedComponents = components.map { ($0 / 255.0).rounded(toPlaces: 4) }
        return .color(roundedComponents[0], roundedComponents[1], roundedComponents[2], 1)
    }
    
    private static func parseRGBAFunction(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        let rgbComponents = try parseFloatComponents(numberOfComponents: 4, functionToken, attributes, min: 0, max: 255)
        let roundedRGBComponents = rgbComponents.map { ($0 / 255.0).rounded(toPlaces: 4) }
        let alphaComponent = try parseFloatComponents(numberOfComponents: 1, functionToken, attributes, from: 3)
        return .color(roundedRGBComponents[0], roundedRGBComponents[1], roundedRGBComponents[2], alphaComponent[0].rounded(toPlaces: 4))
    }
    
    private static func parseURL(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        try validatesArgumentCount(numberOfArguments: 1, functionToken, attributes)
        guard case let .string(urlString) = attributes[0], let url = URL(string: urlString) else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attributes[0])
        }
        return .url(url)
    }
    
}
