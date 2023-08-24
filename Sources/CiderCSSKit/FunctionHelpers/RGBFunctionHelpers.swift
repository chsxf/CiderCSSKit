final class RGBFunctionHelpers {
    
    static func parseRGBFunction(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        let components = try CSSFunctionHelpers.parseFloatComponents(numberOfComponents: 3, functionToken, attributes, min: 0, max: 255)
        var roundedComponents: [Float] = components.map { ($0 / 255.0).rounded(toPlaces: 4) }
        roundedComponents.append(1)
        return .color(CSSColorSpace.sRGB, roundedComponents)
    }
    
    static func parseRGBAFunction(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        let rgbComponents = try CSSFunctionHelpers.parseFloatComponents(numberOfComponents: 4, functionToken, attributes, min: 0, max: 255)
        var roundedComponents: [Float] = rgbComponents.map { ($0 / 255.0).rounded(toPlaces: 4) }
        let alphaComponent = try CSSFunctionHelpers.parseFloatComponents(numberOfComponents: 1, functionToken, attributes, from: 3, min: 0, max: 1)
        roundedComponents[3] = alphaComponent[0].rounded(toPlaces: 4)
        return .color(CSSColorSpace.sRGB, roundedComponents)
    }
    
}
