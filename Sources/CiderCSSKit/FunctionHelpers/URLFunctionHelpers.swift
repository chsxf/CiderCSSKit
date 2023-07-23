import Foundation

final class URLFunctionHelpers {
    
    static func parseURL(_ functionToken: CSSToken, _ attributes: [CSSValue]) throws -> CSSValue {
        try CSSFunctionHelpers.validatesArgumentCount(numberOfArguments: 1, functionToken, attributes)
        guard case let .string(urlString) = attributes[0], let url = URL(string: urlString) else {
            throw CSSParserErrors.invalidFunctionAttribute(functionToken: functionToken, value: attributes[0])
        }
        return .url(url)
    }
    
}
