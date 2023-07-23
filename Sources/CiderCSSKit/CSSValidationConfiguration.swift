public typealias CSSAttributeExpansion = (CSSToken, [CSSValue]) throws -> [String:[CSSValue]]

open class CSSValidationConfiguration {
    
    public static let `default` = CSSValidationConfiguration()
    
    public init() { }
    
    open var valueGroupingTypeByAttribute: [String:CSSValueGroupingType] { [
        CSSAttributes.backgroundColor: .single([.color]),
        CSSAttributes.borderImage: .shorthand([
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageSource),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageSlice),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageWidth, optional: true, afterSeparator: true),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageOutset, optional: true, afterSeparator: true),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageRepeat)
        ]),
        CSSAttributes.borderImageOutset: .multiple([.number, .length()], min: 1, max: 4),
        CSSAttributes.borderImageRepeat: .multiple([.keyword("stretch")], min: 1, max: 2),
        CSSAttributes.borderImageSlice: .multiple([.number, .percentage, .keyword("fill")], min: 1, max: 4),
        CSSAttributes.borderImageSource: .single([.url]),
        CSSAttributes.borderImageWidth: .multiple([.number, .length(), .percentage, .keyword("auto")], min: 1, max: 4),
        CSSAttributes.color: .single([.color]),
        CSSAttributes.font: .shorthand([
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontSize),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.lineHeight, optional: true, afterSeparator: true),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontFamily)
        ]),
        CSSAttributes.fontFamily: .multiple([.string], min: 1),
        CSSAttributes.fontSize: .single([.length()]),
        CSSAttributes.lineHeight: .single([.length()]),
        CSSAttributes.padding: .multiple([.number, .length()], min: 1, max: 4, customExpansionMethod: CSSAttributeExpanders.expandPadding(attributeToken:values:)),
        CSSAttributes.paddingBottom: .single([.number, .length()]),
        CSSAttributes.paddingLeft: .single([.number, .length()]),
        CSSAttributes.paddingRight: .single([.number, .length()]),
        CSSAttributes.paddingTop: .single([.number, .length()]),
        CSSAttributes.textColor: .single([.color]),
        CSSAttributes.transformOrigin: .multiple([.percentage, .length(), .keyword("bottom"), .keyword("center"), .keyword("left"), .keyword("right"), .keyword("top")], min: 1, max: 3, customExpansionMethod: CSSAttributeExpanders.expandTransformOrigin(attributeToken:values:))
    ] }
    
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
    
}
