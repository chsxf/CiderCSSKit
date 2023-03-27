public protocol CSSConsumer {
    
    var type: String { get }
    var identifier: String? { get }
    var classes: [String]? { get }
    var parent: CSSConsumer? { get }
    
}

extension CSSConsumer {
    
    func isMatching(rule: CSSRule) -> Bool {
        guard self.isMatching(clause: rule.clause.lastMember) else { return false }
        
        var previousAncestor: CSSConsumer = self
        for i in 1..<rule.clause.members.count {
            let memberIndex = rule.clause.members.count - 1 - i
            guard let ancestor = previousAncestor.firstAncestorMatching(clause: rule.clause.members[memberIndex]) else { return false }
            previousAncestor = ancestor
        }
        
        return true
    }
    
    func isMatching(clause: CSSClauseMember) -> Bool {
        switch (clause) {
        case .typeIdentifier(let type):
            return self.type == type
        case .identifier(let identifier):
            return self.identifier == identifier
        case .classIdentifier(let className):
            return self.classes?.contains(className) ?? false
        case .combinedIdentifier(let members):
            for member in members {
                if !self.isMatching(clause: member) {
                    return false
                }
            }
            return true
        }
    }
    
    func firstAncestorMatching(clause: CSSClauseMember) -> CSSConsumer? {
        var consumer = self.parent
        while consumer != nil {
            if consumer!.isMatching(clause: clause) {
                return consumer
            }
            consumer = consumer!.parent
        }
        return nil
    }
    
}
