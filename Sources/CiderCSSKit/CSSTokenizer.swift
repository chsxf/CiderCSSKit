import Foundation

enum CSSTokenizerErrors : Error {
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
            if let token = try tokenizer.getNextToken() {
                tokens.append(token)
            }
        }
        
        return tokens;
    }
    
    private func hasReachedEndOfBuffer() -> Bool {
        return currentPosition >= lastPosition
    }
    
    private func getNextToken() throws -> CSSToken? {
        var firstCharacter: Character

        repeat {
            firstCharacter = nextCharacter()
        }
        while firstCharacter.isWhitespaceOrNewline

        switch firstCharacter {
        case "{":
            return .openingBrace
        case "}":
            return .closingBrace
        case "(":
            return .openingParenthesis
        case ")":
            return .closingParenthesis
        case ":":
            return .colon
        case ";":
            return .semiColon
        case ",":
            return .comma
        case "#":
            return .sharp
        case ".":
            return .dot
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
        
        return .stringToken(token)
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
