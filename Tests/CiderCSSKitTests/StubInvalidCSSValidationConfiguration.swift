import CiderCSSKit

class StubInvalidCSSValidationConfiguration: CSSValidationConfiguration {
    
    override var valueGroupingTypeByAttribute: [String : CSSValueGroupingType] {
        var base = super.valueGroupingTypeByAttribute
        base["background"] = .multiple([.string])
        base["name"] = .single([.string])
        return base
    }
    
}
