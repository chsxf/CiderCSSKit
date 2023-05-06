import Foundation

extension Character {
    
    var isWhitespaceOrNewline: Bool { self.isWhitespace || self.isNewline }
    
    func isContainedIn(characterSet: CharacterSet) -> Bool {
        for scalar in self.unicodeScalars {
            if characterSet.contains(scalar) {
                return true
            }
        }
        return false
    }
    
}
