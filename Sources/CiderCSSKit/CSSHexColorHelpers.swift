final class CSSHexColorHelpers {

    class func parseHexadecimalColor(token: CSSToken, hexadecimalString: String) throws -> CSSValue {
        switch hexadecimalString.count {
        case 3:
            return try parseHexadecimalColor(token: token, hexadecimalString: hexadecimalString, digitsPerComponent: 1, hasAlpha: false)
        case 4:
            return try parseHexadecimalColor(token: token, hexadecimalString: hexadecimalString, digitsPerComponent: 1, hasAlpha: true)
        case 6:
            return try parseHexadecimalColor(token: token, hexadecimalString: hexadecimalString, digitsPerComponent: 2, hasAlpha: false)
        case 8:
            return try parseHexadecimalColor(token: token, hexadecimalString: hexadecimalString, digitsPerComponent: 2, hasAlpha: true)
        default:
            throw CSSParserErrors.malformedToken(token)
        }
    }

    class private func parseHexadecimalColor(token: CSSToken, hexadecimalString: String, digitsPerComponent: Int, hasAlpha: Bool) throws -> CSSValue {
        let startIndex = hexadecimalString.startIndex

        let greenStartIndex = hexadecimalString.index(startIndex, offsetBy: 1 * digitsPerComponent)
        let blueStartIndex = hexadecimalString.index(startIndex, offsetBy: 2 * digitsPerComponent)
        let alphaStartIndex = hexadecimalString.index(startIndex, offsetBy: 3 * digitsPerComponent)

        let redRange = startIndex..<greenStartIndex
        let greenRange = greenStartIndex..<blueStartIndex
        let blueRange = blueStartIndex..<alphaStartIndex

        var redString = hexadecimalString[redRange]
        var greenString = hexadecimalString[greenRange]
        var blueString = hexadecimalString[blueRange]

        var alphaString = digitsPerComponent == 1 ? "f" : "ff"
        if hasAlpha {
            let alphaRange = alphaStartIndex..<hexadecimalString.endIndex
            alphaString = String(hexadecimalString[alphaRange])
        }

        if digitsPerComponent == 1 {
            redString += redString
            greenString += greenString
            blueString += blueString
            alphaString += alphaString
        }

        guard
            let red = UInt8(redString, radix: 16),
            let green = UInt8(greenString, radix: 16),
            let blue = UInt8(blueString, radix: 16),
            let alpha = UInt8(alphaString, radix: 16)
        else {
            throw CSSParserErrors.malformedToken(token)
        }

        return .color(CSSColorSpace.sRGB,
            [
                (Float(red) / 255.0).rounded(toPlaces: 4),
                (Float(green) / 255.0).rounded(toPlaces: 4),
                (Float(blue) / 255.0).rounded(toPlaces: 4),
                (Float(alpha) / 255.0).rounded(toPlaces: 4)
            ]
        )
    }

}
