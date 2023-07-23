public final class CSSFunctionHelpers {
    
    public static func validatesArgumentCount(numberOfArguments: Int, _ functionToken: CSSToken, _ attributes: [CSSValue]) throws {
        if attributes.count < numberOfArguments {
            throw CSSParserErrors.tooFewFunctionAttributes(functionToken: functionToken, values: attributes)
        }
        else if attributes.count > numberOfArguments {
            throw CSSParserErrors.tooManyFunctionAttributes(functionToken: functionToken, values: attributes)
        }
    }
    
    public static func parseFloatComponents(numberOfComponents: Int, _ functionToken: CSSToken, _ attributes: [CSSValue], from baseIndex: Int = 0, min: Float? = nil, max: Float? = nil) throws -> [Float] {
        try validatesArgumentCount(numberOfArguments: numberOfComponents + baseIndex, functionToken, attributes)
        
        var components = [Float]()
        
        for i in 0..<numberOfComponents {
            let attr = attributes[baseIndex + i]
            if case let .number(value) = attr {
                if let min, value < min {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attr)
                }
                if let max, value > max {
                    throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attr)
                }
                components.append(value)
            }
            else {
                throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attr)
            }
        }
        
        return components
    }
    
}
