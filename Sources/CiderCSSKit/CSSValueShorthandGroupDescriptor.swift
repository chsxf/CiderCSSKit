public struct CSSValueShorthandGroupDescriptor {
    
    public let subAttributeName: String?
    public let groupingType: CSSValueGroupingType
    public let optional: Bool
    public let afterSeparator: Bool
    
    public init(subAttributeName: String? = nil, groupingType: CSSValueGroupingType, optional: Bool = false, afterSeparator: Bool = false) {
        self.subAttributeName = subAttributeName
        self.groupingType = groupingType
        self.optional = optional
        self.afterSeparator = afterSeparator
    }
    
    func matches(values: [CSSValue], from index: inout Int, _ attributeToken: CSSToken, _ validationConfiguration: CSSValidationConfiguration) -> Bool {
        if afterSeparator {
            if values[index] != .separator {
                return false
            }
            index += 1
        }
        
        switch groupingType {
        case let .single(types):
            if CSSValueGroupingType.matches(single: values[index], types, attributeToken, validationConfiguration) {
                index += 1
                return true
            }
            
        case let .multiple(types, minValueCount, maxValueCount):
            var testValues: [CSSValue]
            if let maxValueCount {
                let valueCount = min(maxValueCount, values.count - index)
                testValues = [CSSValue](values[index..<index + valueCount])
            }
            else {
                testValues = [CSSValue](values[index..<values.count])
            }
            var matchingCount: Int = 0
            if CSSValueGroupingType.matches(multiple: testValues, types, minValueCount, maxValueCount, attributeToken, validationConfiguration, matchingCount: &matchingCount, loose: true) {
                index += matchingCount
                return true
            }
            
        case let .sequence(types):
            let valueCount = min(types.count, values.count - index)
            let testValues = [CSSValue](values[index..<index + valueCount])
            if CSSValueGroupingType.matches(sequence: testValues, types, attributeToken, validationConfiguration) {
                index += types.count
                return true
            }
            
        default:
            break
        }
        
        return false
    }
    
}
