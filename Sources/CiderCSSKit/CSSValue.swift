import Foundation

public enum CSSValue: Equatable {
    
    case angle(Float, CSSAngleUnit)
    case color(Float, Float, Float, Float)
    case keyword(String)
    case length(Float, CSSLengthUnit)
    case number(Float)
    case percentage(Float)
    case separator
    case string(String)
    case url(URL)
    
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
    
    static func parseStringToken(_ token: CSSToken, attributeToken: CSSToken, validationConfiguration: CSSValidationConfiguration) throws -> CSSValue {
        guard token.type == .string else { throw CSSParserErrors.invalidToken(token) }
        
        if !token.literalString {
            return try validationConfiguration.parseKeyword(attributeToken: attributeToken, potentialKeyword: token)
        }
        
        return .string(token.value as! String)
    }
    
}
