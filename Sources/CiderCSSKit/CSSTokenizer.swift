import Foundation

enum CSSTokenizerErrors : Error {
    
    case unexpectedEndOfBuffer
    
}

final class CSSTokenizer {
    
    private let buffer: String
    private let lastPosition: String.Index
    
    private var currentPosition: String.Index
    private var currentLine: Int
    
    private init(buffer: String) {
        self.buffer = buffer
        currentPosition = buffer.startIndex
        currentLine = 0
        lastPosition = buffer.endIndex
    }
    
    static func tokenize(buffer: String) throws -> [CSSToken] {
        var tokens = [CSSToken]()
        
        let tokenizer = CSSTokenizer(buffer: buffer.trimmingCharacters(in: .whitespacesAndNewlines))
        while !tokenizer.hasReachedEndOfBuffer() {
            var hasWhitespaceBefore = false
            let token = try tokenizer.getNextToken(hasWhitespaceBefore: &hasWhitespaceBefore)
            if hasWhitespaceBefore {
                tokens.append(CSSToken(line: tokenizer.currentLine, type: .whitespace))
            }
            tokens.append(token)
        }
        
        return filterWhitespaceTokens(tokens);
    }
    
    private func hasReachedEndOfBuffer() -> Bool {
        return currentPosition >= lastPosition
    }
    
    private func getNextToken(hasWhitespaceBefore: inout Bool) throws -> CSSToken {
        var firstCharacter: Character

        var countWhitespaces = -1
        repeat {
            firstCharacter = nextCharacter()
            countWhitespaces += 1
        }
        while firstCharacter.isWhitespaceOrNewline

        hasWhitespaceBefore = countWhitespaces >= 1
                
        switch firstCharacter {
        case "{":
            return CSSToken(line: currentLine, type: .openingBrace)
        case "}":
            return CSSToken(line: currentLine, type: .closingBrace)
        case "(":
            return CSSToken(line: currentLine, type: .openingParenthesis)
        case ")":
            return CSSToken(line: currentLine, type: .closingParenthesis)
        case ":":
            return CSSToken(line: currentLine, type: .colon)
        case ";":
            return CSSToken(line: currentLine, type: .semiColon)
        case ",":
            return CSSToken(line: currentLine, type: .comma)
        case "#":
            return CSSToken(line: currentLine, type: .sharp)
        case ".":
            return CSSToken(line: currentLine, type: .dot)
        case "*":
            return CSSToken(line: currentLine, type: .star)
        case "\"":
            return try getLiteralString()
        default:
            return try getGeneralToken(firstCharacter: firstCharacter)
        }
    }
    
    private func getLiteralString() throws -> CSSToken {
        var str = ""
        
        var closed = false
        var previousCharacterWasSkipper = false
        
        while !hasReachedEndOfBuffer() {
            var character = buffer[currentPosition]
            if character == "\n" {
                currentLine += 1
            }
            
            var appendCharacter = true
            if character == "\\" {
                previousCharacterWasSkipper = true
                appendCharacter = false
            }
            else if previousCharacterWasSkipper {
                previousCharacterWasSkipper = false
                switch character {
                case "\"", "\\":
                    break
                case "n":
                    character = "\n"
                case "r":
                    character = "\r"
                case "t":
                    character = "\t"
                default:
                    str.append("\\")
                }
            }
            else if character == "\"" {
                closed = true
                moveToNextCharacter()
                break
            }
            
            moveToNextCharacter()
            if appendCharacter {
                str.append(character)
            }
        }
        
        if !closed {
            throw CSSTokenizerErrors.unexpectedEndOfBuffer
        }
        
        return CSSToken(line: currentLine, type: .string, value: str, literalString: true)
    }
    
    private func getGeneralToken(firstCharacter: Character) throws -> CSSToken {
        var tokenStr = String(firstCharacter)
        let firstCharacterIsHyphen = firstCharacter == "-"
        
        let numberRE = try NSRegularExpression(pattern: "^-?(0|[1-9][0-9]*)(\\.[0-9]+)?$")
        var isNumber = tokenStr == "-" || (tokenStr.first!.isNumber && tokenStr.first!.isASCII)
        
        while !hasReachedEndOfBuffer() {
            let character = buffer[currentPosition]
            if character == "\n" {
                currentLine += 1
            }
            
            var validCharacters: CharacterSet
            if isNumber {
                if tokenStr == "-0" || tokenStr == "0" {
                    validCharacters = CharacterSet(charactersIn: ".")
                }
                else {
                    validCharacters = CharacterSet(charactersIn: "0123456789")
                    if tokenStr.count > (firstCharacterIsHyphen ? 1 : 0) {
                        validCharacters.insert(".")
                    }
                }
            }
            else {
                validCharacters = CharacterSet(charactersIn: "-").union(.lowercaseLetters).union(.uppercaseLetters).union(.decimalDigits)
            }
            
            if !character.isContainedIn(characterSet: validCharacters) {
                break
            }
            
            tokenStr.append(character)
            isNumber = numberRE.firstMatch(in: tokenStr, range: tokenStr.fullNSRange()) != nil
            
            moveToNextCharacter()
        }
        
        if isNumber {
            return CSSToken(line: currentLine, type: .number, value: Float(tokenStr)!)
        }
        else {
            return CSSToken(line: currentLine, type: .string, value: tokenStr)
        }
    }
    
    private func nextCharacter() -> Character {
        let character = buffer[currentPosition]
        if character == "\n" {
            currentLine += 1
        }
        moveToNextCharacter()
        return character
    }
    
    private func moveToNextCharacter() {
        currentPosition = buffer.index(currentPosition, offsetBy: 1)
    }
    
    private static func filterWhitespaceTokens(_ unfilteredTokens: [CSSToken]) -> [CSSToken] {
        var filteredTokens = [CSSToken]()
        
        let discardableWhitespaceFollowers: [CSSTokenType] = [.openingBrace, .closingBrace, .comma, .closingParenthesis, .colon, .semiColon]
        let discardableWhitespacePredecessors: [CSSTokenType] = [.openingBrace, .closingBrace, .comma, .openingParenthesis, .closingParenthesis, .colon, .semiColon]
        
        for i in 0..<unfilteredTokens.count {
            let token = unfilteredTokens[i]
            
            var appendToken = true
            if token.type == .whitespace {
                let followerDiscards = i < unfilteredTokens.count - 1 && discardableWhitespaceFollowers.contains(unfilteredTokens[i + 1].type)
                let predecessorDiscards = i > 0 && discardableWhitespacePredecessors.contains(unfilteredTokens[i - 1].type)
                if followerDiscards || predecessorDiscards {
                    appendToken = false
                }
            }
            
            if appendToken {
                filteredTokens.append(token)
            }
        }
        return filteredTokens
    }
    
}
