import CiderCSSKit

final class StubCSSValidationConfigurationAttributeExpansion {
    
    private static let padding = "padding"
    private static let paddingTop = "padding-top"
    private static let paddingRight = "padding-right"
    private static let paddingBottom = "padding-bottom"
    private static let paddingLeft = "padding-left"

    public class func expandPadding(attributeToken token: CSSToken, values: [CSSValue]) throws -> [String:[CSSValue]] {
        if values.count < 1 {
            throw CSSParserErrors.tooFewShorthandAttributeValues(token, values)
        }
        if values.count > 4 {
            throw CSSParserErrors.tooManyShorthandAttributeValues(token, values)
        }
        
        for value in values {
            guard case .number = value else {
                throw CSSParserErrors.invalidShorthandAttributeValue(token, value)
            }
        }

        switch values.count {
        case 2:
            return [
                padding: [ values[0], values[1], values[0], values[1] ],
                paddingTop: [ values[0] ],
                paddingRight: [ values[1] ],
                paddingBottom: [ values[0] ],
                paddingLeft: [ values[1] ]
            ]
        case 3:
            return [
                padding: [ values[0], values[1], values[2], values[1] ],
                paddingTop: [ values[0] ],
                paddingRight: [ values[1] ],
                paddingBottom: [ values[2] ],
                paddingLeft: [ values[1] ]
            ]
        case 4:
            return [
                padding: [ values[0], values[1], values[2], values[3] ],
                paddingTop: [ values[0] ],
                paddingRight: [ values[1] ],
                paddingBottom: [ values[2] ],
                paddingLeft: [ values[3] ]
            ]
        default:
            return [
                padding: [ values[0], values[0], values[0], values[0] ],
                paddingTop: [ values[0] ],
                paddingRight: [ values[0] ],
                paddingBottom: [ values[0] ],
                paddingLeft: [ values[0] ]
            ]
        }
    }
    
}
