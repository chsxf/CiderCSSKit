import CiderCSSKit

struct StubCSSConsumer: CSSConsumer {
    
    var type: String
    var identifier: String?
    var classes: [String]?
    var ancestor: CSSConsumer?
    
}
