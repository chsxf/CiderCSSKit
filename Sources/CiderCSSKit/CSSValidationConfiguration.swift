public typealias CSSShorthandAttributeExpansion = (String, [CSSValue]) -> [String:[CSSValue]]

open class CSSValidationConfiguration {
    
    public init() { }
    
    open var valueGroupingTypeByAttribute: [String:CSSValueGroupingType] { [:] }
    
    open func parseFunction(functionToken: CSSToken, attributes: [CSSValue]) throws -> CSSValue {
        throw CSSParserErrors.unknownFunction(functionToken)
    }
    
    open func parseKeyword(attributeToken: CSSToken, potentialKeyword: CSSToken) throws -> CSSValue {
        throw CSSParserErrors.invalidKeyword(attributeToken: attributeToken, potentialKeyword: potentialKeyword)
    }
    
    func expandShorthandAttribute(_ token: CSSToken, values: [CSSValue]) throws -> [String:[CSSValue]]? {
        guard let attributeName = token.value as? String else {
            throw CSSParserErrors.invalidToken(token)
        }
        
        guard case let .shorthand(groups, customExpansionMethod) = valueGroupingTypeByAttribute[attributeName] else { return nil }
        
        if let customExpansionMethod {
            return customExpansionMethod(attributeName, values)
        }
        
        return CSSValueGroupingType.expand(shorthand: values, groups, token, self)
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
        
        if !values.isEmpty && allowedValueGroupingType.matches(values: values, for: attributeToken, validationConfiguration: self) {
            return true
        }
        
        throw CSSParserErrors.invalidAttributeValues(attributeToken: attributeToken, values: values)
    }
    
    open func validateCustomAttributeValue(attributeToken: CSSToken, value: CSSValue, customTypeName: String) -> Bool {
        return false
    }
    
}
