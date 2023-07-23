public final class CSSAttributeExpanders {
    
    public class func fourValuesExpander(attributeName: String, values: [CSSValue]) -> [String: [CSSValue]] {
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
        
        return [ attributeName: expandedValues ]
    }
    
    class func expandPadding(attributeName: String, values: [CSSValue]) -> [String:[CSSValue]] {
        var result = fourValuesExpander(attributeName: CSSAttributes.padding, values: values)
        
        let expanded = result[CSSAttributes.padding]!
        result[CSSAttributes.paddingBottom] = [ expanded[2] ]
        result[CSSAttributes.paddingLeft] = [ expanded[3] ]
        result[CSSAttributes.paddingRight] = [ expanded[1] ]
        result[CSSAttributes.paddingTop] = [ expanded[0] ]
        
        return result
    }
    
}
