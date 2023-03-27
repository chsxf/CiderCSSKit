enum CSSTokenType {
    
    case openingBrace
    case closingBrace
    case openingParenthesis
    case closingParenthesis
    case semiColon
    case colon
    case comma
    case sharp
    case dot
    case string
    case number
    case whitespace
    
}

public struct CSSToken: Equatable {
    
    let line: Int
    let type: CSSTokenType
    let value: Any?
    let literalString: Bool
    
    init(line: Int, type: CSSTokenType, value: Any? = nil, literalString: Bool = false) {
        self.line = line
        self.type = type
        self.value = value
        self.literalString = type == .string && literalString
    }
    
    public static func == (lhs: CSSToken, rhs: CSSToken) -> Bool {
        guard lhs.type == rhs.type, lhs.line == rhs.line else { return false }
        
        switch lhs.type {
        case .number:
            guard let lhsN = lhs.value as? Float, let rhsN = rhs.value as? Float else { return false }
            return lhsN == rhsN
            
        case .string:
            guard let lhsS = lhs.value as? String, let rhsS = rhs.value as? String else { return false }
            return lhsS == rhsS && lhs.literalString == rhs.literalString
            
        default:
            return true
        }
    }
        
}
