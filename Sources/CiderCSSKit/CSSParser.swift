import Foundation

public enum CSSParserErrors : Error {
    
    case invalidToken(CSSToken)
    case malformedToken(CSSToken)
    case invalidKeyword(CSSToken)
    case invalidAttribute(CSSToken)
    case invalidAttributeValue(CSSToken, CSSValue)
    case unknownFunction(CSSToken)
    case invalidFunctionAttribute(CSSToken, CSSValue)
    case tooFewFunctionAttributes(CSSToken, [CSSValue])
    case tooManyFunctionAttributes(CSSToken, [CSSValue])
    case unexpectedEnd
    
}

enum AttributeContext {
    
    case plain
    case hexadecimalColor
    case function
    
}

public final class CSSParser {
    
    private let rules = CSSRules()
    private let tokensToParse: [CSSToken]
    private let validationConfiguration: CSSValidationConfiguration?
    
    private var eligibleTokenTypes = [CSSTokenType]()
    private var stringTokenValidRE: NSRegularExpression? = nil
    private var currentTokenIndex: Int = 0
    
    private init(tokens: [CSSToken], validationConfiguration: CSSValidationConfiguration?) {
        tokensToParse = tokens
        self.validationConfiguration = validationConfiguration
    }
    
    public static func parse(contentsOf: URL, validationConfiguration: CSSValidationConfiguration? = nil) throws -> CSSRules {
        let buffer = try String(contentsOf: contentsOf)
        return try Self.parse(buffer: buffer, validationConfiguration: validationConfiguration)
    }
    
    public static func parse(buffer: String, validationConfiguration: CSSValidationConfiguration? = nil) throws -> CSSRules {
        let tokens = try CSSTokenizer.tokenize(buffer: buffer)
        let parser = CSSParser(tokens: tokens, validationConfiguration: validationConfiguration)
        try parser.parse()
        return parser.rules
    }
    
    public static func parse(ruleBlock: String, validationConfiguration: CSSValidationConfiguration? = nil) throws -> [String:[CSSValue]] {
        var tokens = try CSSTokenizer.tokenize(buffer: ruleBlock)
        guard let lastToken = tokens.last else {
            throw CSSParserErrors.unexpectedEnd
        }
        if lastToken.type != .closingBrace {
            tokens.append(CSSToken(line: lastToken.line, type: .closingBrace))
        }
        let parser = CSSParser(tokens: tokens, validationConfiguration: validationConfiguration)
        return try parser.parseRuleBlock()
    }
    
    public static func parse(attributeValue: String, validationConfiguration: CSSValidationConfiguration? = nil) throws -> [CSSValue] {
        var tokens = try CSSTokenizer.tokenize(buffer: attributeValue)
        guard let lastToken = tokens.last else {
            throw CSSParserErrors.unexpectedEnd
        }
        if lastToken.type != .semiColon {
            tokens.append(CSSToken(line: lastToken.line, type: .semiColon))
        }
        
        let parser = CSSParser(tokens: tokens, validationConfiguration: validationConfiguration)
        return try parser.parseAttributeValue(level: 0)
    }
    
    private func parse() throws {
        while !hasReachedEndOfTokens() {
            rules.addRules(try parseNextRules())
        }
    }
    
    private func parseNextRules() throws -> [CSSRule] {
        var ruleTokens = [[CSSToken]]()
        var currentRuleTokens = [CSSToken]()

        eligibleTokenTypes = [.sharp, .dot, .string]
        stringTokenValidRE = try NSRegularExpression(pattern: "^[a-z][0-9a-z_-]*$", options: .caseInsensitive)
        
        var foundOpeningBrace = false
        
        repeat {
            let token = try getNextToken()
            
            switch token.type {
            case .sharp, .dot:
                currentRuleTokens.append(token)
                eligibleTokenTypes = [.string]
            case .string:
                currentRuleTokens.append(token)
                eligibleTokenTypes = [.sharp, .dot, .comma, .string, .openingBrace, .whitespace]
            case .comma:
                ruleTokens.append(currentRuleTokens)
                currentRuleTokens.removeAll()
                eligibleTokenTypes = [.sharp, .dot, .string]
            case .openingBrace:
                ruleTokens.append(currentRuleTokens)
                foundOpeningBrace = true
            case .whitespace:
                currentRuleTokens.append(token)
                eligibleTokenTypes.removeAll(where: { $0 == .whitespace })
            default:
                break
            }
        }
        while !foundOpeningBrace && !hasReachedEndOfTokens()
        
        let attributes = try parseRuleBlock()
        
        var newRules = [CSSRule]()
        for tokens in ruleTokens {
            let clause = try CSSClause(clauseTokens: tokens)
            newRules.append(CSSRule(clause: clause, attributes: attributes))
        }
        return newRules
    }
    
    private func parseRuleBlock() throws -> [String:[CSSValue]] {
        var foundClosingBrace = false
        
        var attributes = [String:[CSSValue]]()
        var currentAttributeNameToken: CSSToken? = nil
        var currentAttributeName = ""
        
        eligibleTokenTypes = [.closingBrace, .string]
        stringTokenValidRE = try NSRegularExpression(pattern: "^[a-z][a-z-]*$", options: .caseInsensitive)
        
        repeat {
            let token = try getNextToken()
            
            switch token.type {
            case .closingBrace:
                foundClosingBrace = true
            case .string:
                currentAttributeName = token.value as! String
                currentAttributeNameToken = token
                eligibleTokenTypes = [.colon]
            case .colon:
                let attributeValues = try parseAttributeValue(level: 0)
                if try validationConfiguration?.validateAttributeValues(attributeToken: currentAttributeNameToken!, values: attributeValues) ?? true {
                    attributes[currentAttributeName] = attributeValues
                }
                eligibleTokenTypes = [.closingBrace, .string]
                stringTokenValidRE = try NSRegularExpression(pattern: "^[a-z][a-z-]*$", options: .caseInsensitive)
            default:
                break
            }
        }
        while !foundClosingBrace
        
        return attributes;
    }
    
    private func parseAttributeValue(level: Int) throws -> [CSSValue] {
        var values = [CSSValue]()
        
        eligibleTokenTypes = [.string, .sharp, .number]
        stringTokenValidRE = try NSRegularExpression(pattern: "^[a-z][0-9a-z]*$", options: .caseInsensitive)
        
        var currentStringToken: CSSToken? = nil
        var inHexadecimalColor = false
        
        var foundEnd = false
        
        var numberPart: Float? = nil
        
        repeat {
            let token = try getNextToken()
            
            switch token.type {
            case .string:
                eligibleTokenTypes = [.comma, .semiColon]
                
                if inHexadecimalColor {
                    values.append(try parseHexadecimalColor(token: token, hexadecimalString: token.value as! String))
                    inHexadecimalColor = false
                }
                else if let unitNumberPart = numberPart {
                    values.append(.number(unitNumberPart, CSSValueUnit(rawValue: token.value as! String)!))
                    numberPart = nil
                }
                else {
                    currentStringToken = token
                    eligibleTokenTypes.append(.openingParenthesis)
                }
                
                if level == 0 {
                    eligibleTokenTypes.append(.whitespace)
                }
                else {
                    eligibleTokenTypes.append(.closingParenthesis)
                }
            case .number:
                numberPart = token.value as? Float
                eligibleTokenTypes = [.string, .comma]
                if level == 0 {
                    eligibleTokenTypes.append(.whitespace)
                }
                else {
                    eligibleTokenTypes.append(.closingParenthesis)
                }
            case .sharp:
                eligibleTokenTypes = [.string]
                stringTokenValidRE = try NSRegularExpression(pattern: "^[0-9a-f]{6}$", options: .caseInsensitive)
                inHexadecimalColor = true
            case .openingParenthesis:
                let functionAttributes = try parseAttributeValue(level: level + 1)
                let parsedFunctionValue = try CSSValue.parseFunction(functionToken: currentStringToken!, attributes: functionAttributes, validationConfiguration: validationConfiguration)
                values.append(parsedFunctionValue)
                currentStringToken = nil
                eligibleTokenTypes = [.closingParenthesis, .semiColon, .whitespace, .comma]
            case .comma, .whitespace:
                if !inHexadecimalColor && currentStringToken != nil {
                    values.append(try CSSValue.parseStringToken(currentStringToken!, validationConfiguration: validationConfiguration))
                    currentStringToken = nil
                }
                else if let unitNumberPart = numberPart {
                    values.append(.number(unitNumberPart, .none))
                    numberPart = nil
                }

                eligibleTokenTypes = [.string, .sharp, .number]
                stringTokenValidRE = try NSRegularExpression(pattern: "^[a-z][0-9a-z]*$", options: .caseInsensitive)
            case .closingParenthesis, .semiColon:
                if !inHexadecimalColor && currentStringToken != nil {
                    values.append(try CSSValue.parseStringToken(currentStringToken!, validationConfiguration: validationConfiguration))
                    currentStringToken = nil
                }
                else if let unitNumberPart = numberPart {
                    values.append(.number(unitNumberPart, .none))
                    numberPart = nil
                }
                
                foundEnd = true
            default:
                break
            }
        }
        while !foundEnd
        
        return values
    }
    
    private func parseHexadecimalColor(token: CSSToken, hexadecimalString: String) throws -> CSSValue {
        let startIndex = hexadecimalString.startIndex
        
        let redRange = startIndex..<hexadecimalString.index(startIndex, offsetBy: 2)
        let greenRange = hexadecimalString.index(startIndex, offsetBy: 2)..<hexadecimalString.index(startIndex, offsetBy: 4)
        let blueRange = hexadecimalString.index(startIndex, offsetBy: 4)..<hexadecimalString.endIndex

        guard
            let red = UInt8(hexadecimalString[redRange], radix: 16),
            let green = UInt8(hexadecimalString[greenRange], radix: 16),
            let blue = UInt8(hexadecimalString[blueRange], radix: 16)
        else {
            throw CSSParserErrors.malformedToken(token)
        }
        
        return .color(Float(red) / 255.0, Float(green) / 255.0, Float(blue) / 255.0, 1.0)
    }
    
    private func getNextToken() throws -> CSSToken {
        if hasReachedEndOfTokens() {
            throw CSSParserErrors.unexpectedEnd
        }

        let token = tokensToParse[currentTokenIndex]
        currentTokenIndex += 1

        if !eligibleTokenTypes.contains(token.type) {
            throw CSSParserErrors.invalidToken(token)
        }
        
        if token.type == .string, !token.literalString, let value = token.value as? String, let stringTokenValidRE {
            if stringTokenValidRE.numberOfMatches(in: value, range: value.fullNSRange()) != 1 {
                throw CSSParserErrors.malformedToken(token)
            }
        }
        
        return token
    }
    
    private func hasReachedEndOfTokens() -> Bool {
        return currentTokenIndex >= tokensToParse.count
    }
    
}
