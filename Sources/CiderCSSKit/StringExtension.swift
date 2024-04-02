import Foundation

extension String {

    func fullNSRange() -> NSRange {
        NSRange(location: 0, length: self.count)
    }

}
