public final class CSSAttributeExpanders {
    
    public class func fourValuesExpander(attributeToken: CSSToken, values: [CSSValue]) throws -> [String: [CSSValue]] {
        var expandedValues = [CSSValue](values)
        
        if expandedValues.count == 1 {
            expandedValues.append(expandedValues[0])
        }
        if expandedValues.count == 2 {
            expandedValues.append(expandedValues[0])
        }
        if (expandedValues.count == 3) {
            expandedValues.append(expandedValues[1])
        }
        
        let attributeName = attributeToken.value as! String
        return [ attributeName: expandedValues ]
    }
    
    class func expandPadding(attributeToken: CSSToken, values: [CSSValue]) throws -> [String:[CSSValue]] {
        var result = try fourValuesExpander(attributeToken: attributeToken, values: values)
        
        let expanded = result[CSSAttributes.padding]!
        result[CSSAttributes.paddingBottom] = [ expanded[2] ]
        result[CSSAttributes.paddingLeft] = [ expanded[3] ]
        result[CSSAttributes.paddingRight] = [ expanded[1] ]
        result[CSSAttributes.paddingTop] = [ expanded[0] ]
        
        return result
    }
    
    class func expandTransformOrigin(attributeToken: CSSToken, values: [CSSValue]) throws -> [String: [CSSValue]] {
        var expanded: [CSSValue]
        
        switch values.count {
        case 1:
            guard CSSValueGroupingType.matches(single: values[0], [.length(), .percentage, .keyword("bottom"), .keyword("center"), .keyword("left"), .keyword("right"), .keyword("top")]) else {
                throw CSSParserErrors.invalidAttributeValue(attributeToken: attributeToken, value: values[0])
            }
            expanded = [ values[0], .percentage(50), .length(0, .px)]
        case 2, 3:
            guard CSSValueGroupingType.matches(single: values[0], [.length(), .percentage, .keyword("center"), .keyword("left"), .keyword("right")]) else {
                throw CSSParserErrors.invalidAttributeValue(attributeToken: attributeToken, value: values[0])
            }
            guard CSSValueGroupingType.matches(single: values[1], [.length(), .percentage, .keyword("bottom"), .keyword("center"), .keyword("top")]) else {
                throw CSSParserErrors.invalidAttributeValue(attributeToken: attributeToken, value: values[1])
            }
            expanded = [ values[0], values[1], .length(0, .px)]
            if values.count == 3 {
                guard CSSValueGroupingType.matches(single: values[2], [.length()]) else {
                    throw CSSParserErrors.invalidAttributeValue(attributeToken: attributeToken, value: values[2])
                }
                expanded[2] = values[2]
            }
        default:
            throw CSSParserErrors.invalidAttributeValues(attributeToken: attributeToken, values: values)
        }
        
        return [ CSSAttributes.transformOrigin: expanded ]
    }
    
}
