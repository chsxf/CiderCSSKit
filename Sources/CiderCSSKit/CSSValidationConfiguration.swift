public typealias CSSAttributeExpansion = (CSSToken, [CSSValue]) throws -> [String:[CSSValue]]

open class CSSValidationConfiguration {
    
    static let `default` = CSSValidationConfiguration()
    
    public init() { }
    
    open var valueGroupingTypeByAttribute: [String:CSSValueGroupingType] { CSSValidationConfigurationConstants.valueGroupingTypeByAttribute }
    
    open func parseFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        guard let functionName = functionToken.value as? String else { throw CSSParserErrors.invalidToken(functionToken) }
        
        switch functionName {
        case "rgb":
            return try RGBFunctionHelpers.parseRGBFunction(functionToken, attributes)
        case "rgba":
            return try RGBFunctionHelpers.parseRGBAFunction(functionToken, attributes)
        case "url":
            return try URLFunctionHelpers.parseURL(functionToken, attributes)
        default:
            throw CSSParserErrors.unknownFunction(functionToken)
        }
    }
    
    open func parseKeyword(attributeToken: CSSToken, potentialKeyword: CSSToken) throws -> CSSValue {
        guard
            attributeToken.type == .string,
            let attributeName = attributeToken.value as? String,
            let attributeGroupingType = valueGroupingTypeByAttribute[attributeName]
        else {
            throw CSSParserErrors.invalidToken(attributeToken)
        }
        
        guard potentialKeyword.type == .string, let keyword = potentialKeyword.value as? String else {
            throw CSSParserErrors.invalidToken(potentialKeyword)
        }
        
        if attributeGroupingType.accepts(valueType: .color, validationConfiguration: self), let builtinColorValue = CSSColorKeywords.getValue(for: keyword) {
            return builtinColorValue
        }
        
        if attributeGroupingType.accepts(valueType: .keyword(keyword), exactMatch: true, validationConfiguration: self) {
            return .keyword(keyword)
        }
        
        throw CSSParserErrors.invalidKeyword(attributeToken: attributeToken, potentialKeyword: potentialKeyword)
    }
    
    func expandAttribute(_ token: CSSToken, values: [CSSValue]) throws -> [String:[CSSValue]] {
        guard let attributeName = token.value as? String else {
            throw CSSParserErrors.invalidToken(token)
        }
        
        if case let .shorthand(groups, customExpansionMethod) = valueGroupingTypeByAttribute[attributeName] {
            if let customExpansionMethod {
                return try customExpansionMethod(token, values)
            }
            
            return try CSSValueGroupingType.expand(shorthand: values, groups, attributeToken: token, validationConfiguration: self)
        }
        
        if case let .multiple(_, _, _, customExpansionMethod) = valueGroupingTypeByAttribute[attributeName] {
            if let customExpansionMethod {
                return try customExpansionMethod(token, values)
            }
        }

        return [ attributeName: values ]
    }
    
    func validateAttributeValues(attributeToken: CSSToken, values: [CSSValue]) throws -> Bool {
        guard
            attributeToken.type == .string,
            let attributeName = attributeToken.value as? String
        else {
            throw CSSParserErrors.invalidToken(attributeToken)
        }
        
        guard let allowedValueGroupingType = valueGroupingTypeByAttribute[attributeName] else {
            throw CSSParserErrors.invalidAttribute(attributeToken)
        }
        
        if !values.isEmpty && allowedValueGroupingType.matches(values: values, validationConfiguration: self) {
            return true
        }
        
        throw CSSParserErrors.invalidAttributeValues(attributeToken: attributeToken, values: values)
    }
    
    func replaceKeywordsWithAssociatedValues(_ attributeName: String, _ values: [CSSValue]) -> [CSSValue] {
        var newValues = [CSSValue]()
        for value in values {
            if case let .keyword(keyword) = value, let groupingType = valueGroupingTypeByAttribute[attributeName] {
                var associatedValue: CSSValue = value
                switch groupingType {
                case .single(let types), .multiple(let types, _, _, _), .sequence(let types):
                    for type in types {
                        if case let .keyword(typeKeyword, typeAssociatedValue) = type, typeKeyword == keyword, typeAssociatedValue != nil {
                            associatedValue = typeAssociatedValue!
                        }
                    }
                    break
                default:
                    break
                }
                newValues.append(associatedValue)
            }
            else {
                newValues.append(value)
            }
        }
        return newValues
    }
    
}
