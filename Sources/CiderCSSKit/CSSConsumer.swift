public protocol CSSConsumer {

    var type: String { get }
    var identifier: String? { get }
    var classes: [String]? { get }
    var pseudoClasses: [String]? { get }
    var ancestor: CSSConsumer? { get }

}

extension CSSConsumer {

    public var pseudoClasses: [String]? { nil }

    func isMatching(rule: CSSRule) -> Bool {
        guard self.isMatching(clause: rule.clause.lastMember) else { return false }

        var previousAncestor: CSSConsumer = self
        for index in 1..<rule.clause.members.count {
            let memberIndex = rule.clause.members.count - 1 - index
            guard let ancestor = previousAncestor.firstAncestorMatching(clause: rule.clause.members[memberIndex]) else { return false }
            previousAncestor = ancestor
        }

        return true
    }

    func isMatching(clause: CSSClauseMember) -> Bool {
        switch clause {
        case .universalSelector:
            return true
        case .typeIdentifier(let type):
            return self.type == type
        case .identifier(let identifier):
            return self.identifier == identifier
        case .classIdentifier(let className):
            return self.classes?.contains(className) ?? false
        case .pseudoClassIdentifier(let pseudoClassName):
            return self.pseudoClasses?.contains(pseudoClassName) ?? false
        case .combinedIdentifier(let members):
            return members.allSatisfy { self.isMatching(clause: $0) }
        }
    }

    func firstAncestorMatching(clause: CSSClauseMember) -> CSSConsumer? {
        var consumer = self.ancestor
        while consumer != nil {
            if consumer!.isMatching(clause: clause) {
                return consumer
            }
            consumer = consumer!.ancestor
        }
        return nil
    }

}
