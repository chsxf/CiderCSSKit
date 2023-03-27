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
    case stringToken

}

struct CSSToken : Equatable {
    
    let type: CSSTokenType
    let value: String?
    
    init(type: CSSTokenType, value: String? = nil) {
        self.type = type
        self.value = value
    }
    
}
