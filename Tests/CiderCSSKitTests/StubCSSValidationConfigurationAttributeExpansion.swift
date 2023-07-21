import CiderCSSKit

final class StubCSSValidationConfigurationAttributeExpansion {
    
    private static let padding = "padding"
    private static let paddingTop = "padding-top"
    private static let paddingRight = "padding-right"
    private static let paddingBottom = "padding-bottom"
    private static let paddingLeft = "padding-left"
    
    private static let font = "font"
    private static let fontSize = "font-size"
    private static let fontFamily = "font-family"
    private static let lineHeight = "line-height"

    public class func expandPadding(attributeName: String, values: [CSSValue]) -> [String:[CSSValue]] {
        return CSSBuiltinAttributeExpanders.fourValuesExpander(shorthandAttributeName: padding, expandedAttributeNames: [paddingTop, paddingRight, paddingBottom, paddingLeft], values: values)
    }
    
    public static func expandFont(attributeName: String, values: [CSSValue]) -> [String:[CSSValue]] {
        return [:]
    }
    
}
