import CiderCSSKit

class StubInvalidCSSValidationConfiguration: CSSValidationConfiguration {
    
    override var valueGroupingTypeByAttribute: [String : CSSValueGroupingType] { [
        "background": .multiple([.string]),
        "background-color": .single([.color]),
        "color": .single([.color]),
        "name": .single([.string]),
        "text-color": .single([.color])
    ] }
    
}
