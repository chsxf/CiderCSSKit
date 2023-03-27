import Foundation

public enum CSSTokenizerErrors : Error {
    case invalidCharacter
    case missingValidCharacter
}

final class CSSTokenizer {
    
    private let buffer: String
    private let lastPosition: String.Index
    
    private var currentPosition: String.Index
    
    private init(buffer: String) {
        self.buffer = buffer
        currentPosition = buffer.startIndex
        lastPosition = buffer.endIndex
    }
    
    static func tokenize(buffer: String) throws -> [CSSToken] {
        var tokens = [CSSToken]()
        
        let tokenizer = CSSTokenizer(buffer: buffer.trimmingCharacters(in: .whitespacesAndNewlines))
        while !tokenizer.hasReachedEndOfBuffer() {
            var hasWhitespaceBefore = false
            let token = try tokenizer.getNextToken(hasWhitespaceBefore: &hasWhitespaceBefore)
            if hasWhitespaceBefore {
                tokens.append(CSSToken(type: .whitespace))
            }
            tokens.append(token)
        }
        
        return tokens;
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
            return CSSToken(type: .openingBrace)
        case "}":
            return CSSToken(type: .closingBrace)
        case "(":
            return CSSToken(type: .openingParenthesis)
        case ")":
            return CSSToken(type: .closingParenthesis)
        case ":":
            return CSSToken(type: .colon)
        case ";":
            return CSSToken(type: .semiColon)
        case ",":
            return CSSToken(type: .comma)
        case "#":
            return CSSToken(type: .sharp)
        case ".":
            return CSSToken(type: .dot)
        default:
            return try getGeneralToken(firstCharacter: firstCharacter)
        }
    }
    
    private func getGeneralToken(firstCharacter: Character) throws -> CSSToken {
        var token = String(firstCharacter)
        
        var invalidCharacters = CharacterSet()
        invalidCharacters.insert(charactersIn: ":,;.{()")
        invalidCharacters = invalidCharacters.union(.whitespacesAndNewlines)
        
        var validCharacters = CharacterSet(charactersIn: "-_")
        validCharacters = validCharacters.union(.lowercaseLetters).union(.capitalizedLetters).union(.decimalDigits)
        
        while !hasReachedEndOfBuffer() {
            let character = buffer[currentPosition]
            if character.isContainedIn(characterSet: invalidCharacters) {
                break
            }
            if !character.isContainedIn(characterSet: validCharacters) {
                throw CSSTokenizerErrors.invalidCharacter
            }
            moveToNextCharacter()
            token.append(character)
        }
        
        return CSSToken(type: .string, value: token)
    }
    
    private func nextCharacter() -> Character {
        let character = buffer[currentPosition]
        moveToNextCharacter()
        return character
    }
    
    private func moveToNextCharacter() {
        currentPosition = buffer.index(currentPosition, offsetBy: 1)
    }
    
}
