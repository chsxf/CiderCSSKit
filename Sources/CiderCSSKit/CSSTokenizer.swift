enum CSSTokenizerErrors : Error {
    case invalidCharacter
}

final class CSSTokenizer {
    
    private let buffer: String
    private var currentPosition: Int
    private let lastPosition: Int
    
    private init(buffer: String) {
        self.buffer = buffer
        currentPosition = 0
        lastPosition = self.buffer.count
    }
    
    static func tokenize(buffer: String) throws -> [CSSToken] {
        var tokens = [CSSToken]()
        
        let tokenizer = CSSTokenizer(buffer: buffer.trimmingCharacters(in: .whitespacesAndNewlines))
        while !tokenizer.hasReachedEndOfBuffer() {
            
        }
        
        return tokens;
    }
    
    private func hasReachedEndOfBuffer() -> Bool {
        return currentPosition >= lastPosition
    }
    
    
    
}
