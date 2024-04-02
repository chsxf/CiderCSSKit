import Foundation

extension Character {

    var isWhitespaceOrNewline: Bool { self.isWhitespace || self.isNewline }

    func isContainedIn(characterSet: CharacterSet) -> Bool {
        self.unicodeScalars.contains(where: { characterSet.contains($0) })
    }

}
