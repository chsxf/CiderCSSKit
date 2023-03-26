enum CSSValueUnit {
    case px
    case pt
}

enum CSSValue {
    case string(String)
    case unit(Float, CSSValueUnit)
}
