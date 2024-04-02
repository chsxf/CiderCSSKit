public enum CSSTokenType {

    case closingBrace
    case closingParenthesis
    case colon
    case comma
    case dot
    case forwardSlash
    case number
    case openingBrace
    case openingParenthesis
    case percent
    case semiColon
    case sharp
    case star
    case string
    case whitespace

}

public struct CSSToken: Equatable {

    let line: Int
    public let type: CSSTokenType
    public let value: Any?
    public let literalString: Bool

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
