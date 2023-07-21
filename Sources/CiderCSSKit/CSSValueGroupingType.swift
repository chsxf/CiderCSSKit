public enum CSSValueGroupingType {
    
    case single([CSSValueType])
    case multiple([CSSValueType], min: Int? = nil, max: Int? = nil)
    case sequence([CSSValueType])
    case shorthand([CSSValueShorthandGroupDescriptor], customExpansionMethod: CSSShorthandAttributeExpansion? = nil)
    
    func matches(values: [CSSValue], for attributeToken: CSSToken, validationConfiguration: CSSValidationConfiguration) -> Bool {
        switch self {
        case let .single(types):
            guard values.count == 1 else {
                return false
            }
            return Self.matches(single: values[0], types, attributeToken, validationConfiguration)
            
        case let .multiple(types, min, max):
            var ignoredMatchingCount = 0
            return Self.matches(multiple: values, types, min, max, attributeToken, validationConfiguration, matchingCount: &ignoredMatchingCount, loose: false)
            
        case let .sequence(types):
            return Self.matches(sequence: values, types, attributeToken, validationConfiguration)
            
        case let .shorthand(groups, _):
            return Self.matches(shorthand: values, groups, attributeToken, validationConfiguration)
        }
    }
    
    static func matches(single value: CSSValue, _ types: [CSSValueType], _ attributeToken: CSSToken, _ validationConfiguration: CSSValidationConfiguration) -> Bool {
        for type in types {
            if type.matches(value: value, for: attributeToken, validationConfiguration: validationConfiguration) {
                return true
            }
        }
        return false
    }
    
    static func matches(multiple values: [CSSValue], _ types: [CSSValueType], _ min: Int?, _ max: Int?, _ attributeToken: CSSToken, _ validationConfiguration: CSSValidationConfiguration, matchingCount: inout Int, loose: Bool) -> Bool {
        if let min {
            guard values.count >= min else {
                return false
            }
        }
        
        if let max {
            guard values.count <= max else {
                return false
            }
        }
        
        matchingCount = 0
        for value in values {
            var hasTypeMatch = false
            for type in types {
                if type.matches(value: value, for: attributeToken, validationConfiguration: validationConfiguration) {
                    hasTypeMatch = true
                    break
                }
            }
            if hasTypeMatch {
                matchingCount += 1
            }
            else if loose {
                return (min != nil && matchingCount >= min!) || (min == nil && matchingCount > 0)
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    static func matches(sequence values: [CSSValue], _ types: [CSSValueType], _ attributeToken: CSSToken, _ validationConfiguration: CSSValidationConfiguration) -> Bool {
        guard values.count == types.count else {
            return false
        }
    
        for i in 0..<values.count {
            let type = types[i]
            guard type.matches(value: values[i], for: attributeToken, validationConfiguration: validationConfiguration) else {
                return false
            }
        }
        
        return true
    }
    
    static func matches(shorthand values: [CSSValue], _ groups: [CSSValueShorthandGroupDescriptor], _ attributeToken: CSSToken, _ validationConfiguration: CSSValidationConfiguration) -> Bool {
        var lastValidatedGroupIndex: Int = 0
        var lastValidatedValueIndex: Int = 0
        
        while lastValidatedGroupIndex < groups.count {
            let group = groups[lastValidatedGroupIndex]
            var from = lastValidatedValueIndex
            if group.matches(values: values, from: &from, attributeToken, validationConfiguration) || group.optional {
                lastValidatedGroupIndex += 1
                lastValidatedValueIndex = from
            }
            else if !group.optional {
                return false
            }
        }
        
        return true
    }
    
    static func expand(shorthand values: [CSSValue], _ groups: [CSSValueShorthandGroupDescriptor], _ attributeToken: CSSToken, _ validationConfiguration: CSSValidationConfiguration) -> [String: [CSSValue]]? {
        var lastValidatedGroupIndex: Int = 0
        var lastValidatedValueIndex: Int = 0
        
        var subAttributeValues = [String: [CSSValue]]()
        
        while lastValidatedGroupIndex < groups.count {
            let group = groups[lastValidatedGroupIndex]
            var currentValueIndex = lastValidatedValueIndex
            if group.matches(values: values, from: &currentValueIndex, attributeToken, validationConfiguration) || group.optional {
                lastValidatedGroupIndex += 1
                
                if let subAttributeName = group.subAttributeName {
                    let start = group.afterSeparator ? lastValidatedValueIndex + 1 : lastValidatedValueIndex
                    let subValues = [CSSValue](values[start..<currentValueIndex])
                    subAttributeValues[subAttributeName] = subValues
                }
                
                lastValidatedValueIndex = currentValueIndex
            }
            else if !group.optional {
                return nil
            }
        }
        
        return subAttributeValues
    }
    
}
