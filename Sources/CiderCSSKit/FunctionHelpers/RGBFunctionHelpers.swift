final class RGBFunctionHelpers {
    
    static func parseRGBFunction(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        let components = try CSSFunctionHelpers.parseFloatComponents(numberOfComponents: 3, functionToken, attributes, min: 0, max: 255)
        let roundedComponents = components.map { ($0 / 255.0).rounded(toPlaces: 4) }
        return .color(roundedComponents[0], roundedComponents[1], roundedComponents[2], 1)
    }
    
    static func parseRGBAFunction(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        let rgbComponents = try CSSFunctionHelpers.parseFloatComponents(numberOfComponents: 4, functionToken, attributes, min: 0, max: 255)
        let roundedRGBComponents = rgbComponents.map { ($0 / 255.0).rounded(toPlaces: 4) }
        let alphaComponent = try CSSFunctionHelpers.parseFloatComponents(numberOfComponents: 1, functionToken, attributes, from: 3)
        return .color(roundedRGBComponents[0], roundedRGBComponents[1], roundedRGBComponents[2], alphaComponent[0].rounded(toPlaces: 4))
    }
    
}
