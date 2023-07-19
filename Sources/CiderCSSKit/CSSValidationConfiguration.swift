public enum CSSValueType {
    
    case string
    case number
    case color
    case custom(String)
    
}

public typealias CSSShorthandAttributeExpansion = (CSSToken, [CSSValue]) throws -> [String:[CSSValue]]

open class CSSValidationConfiguration {
    
    public init() { }
    
    open var valueTypesByAttribute: [String:[CSSValueType]] { [:] }
    open var shorthandAttributes: [String: CSSShorthandAttributeExpansion] { [:] }
    
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
        
        guard let expansionMethod = shorthandAttributes[attributeName] else { return nil }
        return try expansionMethod(token, values)
    }
    
    func validateAttributeValues(attributeToken: CSSToken, values: [CSSValue]) throws -> Bool {
        guard
            attributeToken.type == .string,
            let attributeName = attributeToken.value as? String
        else {
            throw CSSParserErrors.invalidToken(attributeToken)
        }
        
        guard
            let allowedValueTypes = valueTypesByAttribute[attributeName],
            !allowedValueTypes.isEmpty
        else {
            throw CSSParserErrors.invalidAttribute(attributeToken)
        }
        
        for value in values {
            var matches = false
            for allowedValueType in allowedValueTypes {
                switch allowedValueType {
                case .string:
                    if case .string = value {
                        matches = true
                    }
                    break
                case .number:
                    if case .number = value {
                        matches = true
                    }
                    break
                case .color:
                    if case .color = value {
                        matches = true
                    }
                    break
                case let .custom(typeName):
                    matches = validateCustomAttributeValue(attributeToken: attributeToken, value: value, customTypeName: typeName)
                    break
                }
                
                if matches {
                    break
                }
            }
            
            if !matches {
                throw CSSParserErrors.invalidAttributeValue(attributonToken: attributeToken, value: value)
            }
        }
        
        return true
    }
    
    open func validateCustomAttributeValue(attributeToken: CSSToken, value: CSSValue, customTypeName: String) -> Bool {
        return false
    }
    
}
