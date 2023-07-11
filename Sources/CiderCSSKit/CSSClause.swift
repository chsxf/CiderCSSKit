enum CSSClauseMember {
    
    case identifier(String)
    case classIdentifier(String)
    case typeIdentifier(String)
    case pseudoClassIdentifier(String)
    case combinedIdentifier([CSSClauseMember])
    
}

extension CSSClauseMember {
    
    var score: Int {
        switch (self) {
        case .identifier(_):
            return 100
        case .typeIdentifier(_):
            return 10000
        case .classIdentifier(_):
            return 1
        case .pseudoClassIdentifier(_):
            return 10
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
        
        var tempMembers = [CSSClauseMember]()
        var i = 0
        while i < clauseTokens.count {
            let token = clauseTokens[i]
            switch token.type {
            case .string:
                if typeFound {
                    throw CSSParserErrors.invalidToken(token)
                }
                tempMembers.append(.typeIdentifier(token.value as! String))
                typeFound = true
                break
            case .sharp:
                if identifierFound {
                    throw CSSParserErrors.invalidToken(token)
                }
                let nextToken = clauseTokens[i + 1]
                tempMembers.append(.identifier(nextToken.value as! String))
                i += 1
                break
            case .colon:
                let nextToken = clauseTokens[i + 1]
                tempMembers.append(.pseudoClassIdentifier(nextToken.value as! String))
                i += 1
                break
            case .dot:
                let nextToken = clauseTokens[i + 1]
                tempMembers.append(.classIdentifier(nextToken.value as! String))
                i += 1
                break
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
                break
            default:
                throw CSSParserErrors.invalidToken(token)
            }
            
            i += 1
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
    
}
