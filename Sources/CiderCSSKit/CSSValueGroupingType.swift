public enum CSSValueGroupingType {

    case single([CSSValueType])
    case multiple([CSSValueType], min: Int? = nil, max: Int? = nil, customExpansionMethod: CSSAttributeExpansion? = nil)
    case sequence([CSSValueType])
    case shorthand([CSSValueShorthandGroupDescriptor], customExpansionMethod: CSSAttributeExpansion? = nil)

    func accepts(valueType: CSSValueType, exactMatch: Bool = false, validationConfiguration: CSSValidationConfiguration) -> Bool {
        switch self {
        case .single(let types), .multiple(let types, _, _, _), .sequence(let types):
            return types.contains(where: { $0.isEqual(to: valueType, fully: exactMatch) })

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
            return Self.matches(multiple: values, types, min, max, loose: false) != nil

        case let .sequence(types):
            return Self.matches(sequence: values, types)

        case let .shorthand(groups, _):
            return Self.matches(shorthand: values, groups, validationConfiguration)
        }
    }

    static func matches(single value: CSSValue, _ types: [CSSValueType]) -> Bool {
        types.contains(where: { $0.matches(value: value) })
    }

    static func matches(multiple values: [CSSValue], _ types: [CSSValueType], _ min: Int?, _ max: Int?, loose: Bool) -> Int? {
        if let min {
            guard values.count >= min else { return nil }
        }

        if let max {
            guard values.count <= max else { return nil }
        }

        var matchingCount: Int = 0
        for value in values {
            let hasTypeMatch = types.contains(where: { $0.matches(value: value) })
            if hasTypeMatch {
                matchingCount += 1
            }
            else if loose {
                if (min != nil && matchingCount >= min!) || (min == nil && matchingCount > 0) {
                    return matchingCount
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }

        return matchingCount
    }

    static func matches(sequence values: [CSSValue], _ types: [CSSValueType]) -> Bool {
        guard values.count == types.count else {
            return false
        }

        for index in 0..<values.count {
            let type = types[index]
            guard type.matches(value: values[index]) else {
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

            if from >= values.count && group.optional {
                lastValidatedGroupIndex += 1
                continue
            }

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

    static func expand(shorthand values: [CSSValue], _ groups: [CSSValueShorthandGroupDescriptor], attributeToken: CSSToken, validationConfiguration: CSSValidationConfiguration) throws -> [String: [CSSValue]] {
        var lastValidatedGroupIndex: Int = 0
        var lastValidatedValueIndex: Int = 0

        let mainAttributeName = attributeToken.value as! String
        var mainAttributeValues = [CSSValue]()
        var expandedValues: [String: [CSSValue]] = [:]

        while lastValidatedGroupIndex < groups.count {
            let group = groups[lastValidatedGroupIndex]
            var currentValueIndex = lastValidatedValueIndex

            if currentValueIndex >= values.count && group.optional {
                lastValidatedGroupIndex += 1
                continue
            }

            if group.matches(values: values, from: &currentValueIndex, validationConfiguration) {
                lastValidatedGroupIndex += 1

                let start = group.afterSeparator ? lastValidatedValueIndex + 1 : lastValidatedValueIndex
                var subValues = [CSSValue](values[start..<currentValueIndex])
                subValues = validationConfiguration.replaceKeywordsWithAssociatedValues(group.subAttributeName, subValues)

                if case let .multiple(_, _, _, groupCustomExpansionMethod) = validationConfiguration.valueGroupingTypeByAttribute[group.subAttributeName], groupCustomExpansionMethod != nil {
                    let subAttributeToken = CSSToken(line: attributeToken.line, type: .string, value: group.subAttributeName)
                    let expandedSubAttribute = try groupCustomExpansionMethod!(subAttributeToken, subValues)
                    for entry in expandedSubAttribute {
                        expandedValues[entry.key] = entry.value
                    }
                }
                else {
                    expandedValues[group.subAttributeName] = subValues
                }

                if group.afterSeparator {
                    mainAttributeValues.append(.separator)
                }
                mainAttributeValues.append(contentsOf: subValues)

                lastValidatedValueIndex = currentValueIndex
            }
            else if group.optional {
                lastValidatedGroupIndex += 1

                let subValues = [ group.defaultValue! ]

                if case let .multiple(_, _, _, groupCustomExpansionMethod) = validationConfiguration.valueGroupingTypeByAttribute[group.subAttributeName], groupCustomExpansionMethod != nil {
                    let subAttributeToken = CSSToken(line: attributeToken.line, type: .string, value: group.subAttributeName)
                    let expandedSubAttribute = try groupCustomExpansionMethod!(subAttributeToken, subValues)
                    for entry in expandedSubAttribute {
                        expandedValues[entry.key] = entry.value
                    }
                }
                else {
                    expandedValues[group.subAttributeName] = subValues
                }
            }
            else if !group.optional {
                throw CSSParserErrors.invalidAttributeValues(attributeToken: attributeToken, values: values)
            }
        }

        expandedValues[mainAttributeName] = mainAttributeValues

        return expandedValues
    }

}
