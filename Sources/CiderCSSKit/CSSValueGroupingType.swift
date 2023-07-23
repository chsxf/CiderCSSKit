public enum CSSValueGroupingType {
    
    case single([CSSValueType])
    case multiple([CSSValueType], min: Int? = nil, max: Int? = nil, customExpansionMethod: CSSShorthandAttributeExpansion? = nil)
    case sequence([CSSValueType])
    case shorthand([CSSValueShorthandGroupDescriptor], customExpansionMethod: CSSShorthandAttributeExpansion? = nil)
    
    func accepts(valueType: CSSValueType, exactMatch: Bool = false, validationConfiguration: CSSValidationConfiguration) -> Bool {
        switch self {
        case .single(let types), .multiple(let types, _, _, _), .sequence(let types):
            for type in types {
                if type.isEqual(to: valueType, fully: exactMatch) {
                    return true
                }
            }
        case .shorthand(let groups, _):
            for group in groups {
                guard let groupingType = validationConfiguration.valueGroupingTypeByAttribute[group.subAttributeName] else {
                    return false
                }
                
                if groupingType.accepts(valueType: valueType, exactMatch: exactMatch, validationConfiguration: validationConfiguration) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func matches(values: [CSSValue], validationConfiguration: CSSValidationConfiguration) -> Bool {
        switch self {
        case let .single(types):
            guard values.count == 1 else {
                return false
            }
            return Self.matches(single: values[0], types)
            
        case let .multiple(types, min, max, _):
            var ignoredMatchingCount = 0
            return Self.matches(multiple: values, types, min, max, matchingCount: &ignoredMatchingCount, loose: false)
            
        case let .sequence(types):
            return Self.matches(sequence: values, types)
            
        case let .shorthand(groups, _):
            return Self.matches(shorthand: values, groups, validationConfiguration)
        }
    }
    
    static func matches(single value: CSSValue, _ types: [CSSValueType]) -> Bool {
        for type in types {
            if type.matches(value: value) {
                return true
            }
        }
        return false
    }
    
    static func matches(multiple values: [CSSValue], _ types: [CSSValueType], _ min: Int?, _ max: Int?, matchingCount: inout Int, loose: Bool) -> Bool {
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
                if type.matches(value: value) {
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
    
    static func matches(sequence values: [CSSValue], _ types: [CSSValueType]) -> Bool {
        guard values.count == types.count else {
            return false
        }
    
        for i in 0..<values.count {
            let type = types[i]
            guard type.matches(value: values[i]) else {
                return false
            }
        }
        
        return true
    }
    
    static func matches(shorthand values: [CSSValue], _ groups: [CSSValueShorthandGroupDescriptor], _ validationConfiguration: CSSValidationConfiguration) -> Bool {
        var lastValidatedGroupIndex: Int = 0
        var lastValidatedValueIndex: Int = 0
        
        while lastValidatedGroupIndex < groups.count {
            let group = groups[lastValidatedGroupIndex]
            var from = lastValidatedValueIndex
            if group.matches(values: values, from: &from, validationConfiguration) || group.optional {
                lastValidatedGroupIndex += 1
                lastValidatedValueIndex = from
            }
            else if !group.optional {
                return false
            }
        }
        
        return true
    }
    
    static func expand(shorthand values: [CSSValue], _ groups: [CSSValueShorthandGroupDescriptor], attributeToken: CSSToken, validationConfiguration: CSSValidationConfiguration) -> [String: [CSSValue]]? {
        var lastValidatedGroupIndex: Int = 0
        var lastValidatedValueIndex: Int = 0
        
        let attributeName = attributeToken.value as! String
        var expandedValues:[String: [CSSValue]] = [
            attributeName: values
        ]
        
        while lastValidatedGroupIndex < groups.count {
            let group = groups[lastValidatedGroupIndex]
            var currentValueIndex = lastValidatedValueIndex
            if group.matches(values: values, from: &currentValueIndex, validationConfiguration) || group.optional {
                lastValidatedGroupIndex += 1
                
                let start = group.afterSeparator ? lastValidatedValueIndex + 1 : lastValidatedValueIndex
                let subValues = [CSSValue](values[start..<currentValueIndex])
                expandedValues[group.subAttributeName] = subValues
                
                lastValidatedValueIndex = currentValueIndex
            }
            else if !group.optional {
                return nil
            }
        }
        
        return expandedValues
    }
    
}
