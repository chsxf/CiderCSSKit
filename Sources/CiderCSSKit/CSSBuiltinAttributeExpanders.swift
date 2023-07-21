public final class CSSBuiltinAttributeExpanders {
    
    public class func fourValuesExpander(shorthandAttributeName: String, expandedAttributeNames: [String], values: [CSSValue]) -> [String:[CSSValue]] {
        var expandedValues = [CSSValue]()
        for i in 0..<4 {
            if values.count < i + 1 {
                break
            }
            expandedValues.append(values[i])
        }

        if expandedValues.count == 1 {
            expandedValues.append(expandedValues[0])
        }
        if expandedValues.count == 2 {
            expandedValues.append(expandedValues[0])
        }
        if (expandedValues.count == 3) {
            expandedValues.append(expandedValues[1])
        }
        
        var result = [ shorthandAttributeName: expandedValues ]
        for i in 0..<4 {
            result[expandedAttributeNames[i]] = [expandedValues[i]]
        }
        return result
     }
    
}
