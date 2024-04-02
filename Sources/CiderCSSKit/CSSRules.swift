public final class CSSRules {

    private(set) var rules = [CSSRule]()
    private(set) var attributes = [String]()
    private(set) var rulesByAttribute = [String: [CSSRule]]()

    public var count: Int { rules.count }

    public weak var chainedLowerPriorityRules: CSSRules?

    func addRule(_ rule: CSSRule) {
        rules.append(rule)

        rule.attributes.forEach { (attributeName: String, _) in
            if !attributes.contains(attributeName) {
                attributes.append(attributeName)
            }

            if var rulesForAttribute = self.rulesByAttribute[attributeName] {
                let score = rule.clause.score
                if let insertIndex = rulesForAttribute.firstIndex(where: { $0.clause.score <= score }) {
                    rulesForAttribute.insert(rule, at: insertIndex)
                }
                else {
                    rulesForAttribute.append(rule)
                }
                self.rulesByAttribute[attributeName] = rulesForAttribute
            }
            else {
                self.rulesByAttribute[attributeName] = [rule]
            }
        }
    }

    func addRules(_ rules: [CSSRule]) {
        rules.forEach { self.addRule($0) }
    }

    public func getValue(with attribute: String, for consumer: CSSConsumer) -> [CSSValue]? {
        if let rulesForAttribute = rulesByAttribute[attribute], let rule = rulesForAttribute.first(where: { consumer.isMatching(rule: $0) }) {
            return rule.attributes[attribute]
        }

        return chainedLowerPriorityRules?.getValue(with: attribute, for: consumer)
    }

    public func getAllValues(for consumer: CSSConsumer) -> [String: [CSSValue]] {
        var values: [String: [CSSValue]] = chainedLowerPriorityRules?.getAllValues(for: consumer) ?? [:]
        for attribute in attributes {
            if let value = getValue(with: attribute, for: consumer) {
                values[attribute] = value
            }
        }
        return values
    }

}
