import CiderCSSKit

class StubInvalidCSSValidationConfiguration: CSSValidationConfiguration {
    
    override var valuesTypesByAttribute: [String : [CSSValueType]] { [
        "background": [.string],
        "background-color": [.color],
        "color": [.color],
        "name": [.string],
        "text-color": [.color]
    ] }
    
}

