public enum CSSValueType {
    
    case angle
    case color
    case custom(String)
    case keyword(String? = nil)
    case length(CSSLengthUnit? = nil)
    case number
    case percentage
    case string
    case url
    
}
