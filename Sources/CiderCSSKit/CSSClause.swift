enum CSSClauseMember: Equatable {

    case universalSelector
    case identifier(String)
    case classIdentifier(String)
    case typeIdentifier(String)
    case pseudoClassIdentifier(String)
    case combinedIdentifier([CSSClauseMember])

}

extension CSSClauseMember {

    var score: Int {
        switch self {
        case .universalSelector:
            return 0
        case .identifier:
            return 10000
        case .typeIdentifier:
            return 10
        case .classIdentifier:
            return 100
        case .pseudoClassIdentifier:
            return 1000
        case .combinedIdentifier(let members):
            return members.reduce(into: 0) { $0 += $1.score }
        }
    }

}

struct CSSClause {

    let members: [CSSClauseMember]

    var lastMember: CSSClauseMember { members.last! }

    var score: Int { members.reduce(into: 0) { $0 += $1.score } }

    init(clauseTokens: [CSSToken]) throws {
        var parsedMembers = [CSSClauseMember]()

        var typeFound = false
        var identifierFound = false
        var universalFound = false

        var tempMembers = [CSSClauseMember]()
        var tokenIndex = 0
        while tokenIndex < clauseTokens.count {
            let token = clauseTokens[tokenIndex]
            switch token.type {
            case .string:
                guard !typeFound, let tokenAsString = token.value as? String else {
                    throw CSSParserErrors.invalidToken(token)
                }
                tempMembers.append(.typeIdentifier(tokenAsString))
                typeFound = true
            case .star:
                if universalFound {
                    throw CSSParserErrors.invalidToken(token)
                }
                tempMembers.append(.universalSelector)
                universalFound = true
            case .sharp:
                if identifierFound {
                    throw CSSParserErrors.invalidToken(token)
                }
                let nextToken = try Self.getTokenAsString(clauseTokens: clauseTokens, at: tokenIndex + 1)
                tempMembers.append(.identifier(nextToken))
                tokenIndex += 1
            case .colon:
                let nextToken = try Self.getTokenAsString(clauseTokens: clauseTokens, at: tokenIndex + 1)
                tempMembers.append(.pseudoClassIdentifier(nextToken))
                tokenIndex += 1
            case .dot:
                let nextToken = try Self.getTokenAsString(clauseTokens: clauseTokens, at: tokenIndex + 1)
                tempMembers.append(.classIdentifier(nextToken))
                tokenIndex += 1
            case .whitespace:
                if tempMembers.count == 1 {
                    parsedMembers.append(tempMembers[0])
                }
                else {
                    parsedMembers.append(.combinedIdentifier(tempMembers))
                }
                typeFound = false
                identifierFound = false
                tempMembers.removeAll()
            default:
                throw CSSParserErrors.invalidToken(token)
            }

            tokenIndex += 1
        }

        if !tempMembers.isEmpty {
            if tempMembers.count == 1 {
                parsedMembers.append(tempMembers[0])
            }
            else {
                parsedMembers.append(.combinedIdentifier(tempMembers))
            }
        }

        members = parsedMembers
    }

    private static func getTokenAsString(clauseTokens: [CSSToken], at index: Int) throws -> String {
        if index >= clauseTokens.count {
            throw CSSParserErrors.unexpectedEnd
        }

        let token = clauseTokens[index]
        guard token.type == .string, let tokenAsString = token.value as? String else {
            throw CSSParserErrors.invalidToken(token)
        }

        return tokenAsString
    }

}
