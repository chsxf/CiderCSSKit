public final class CSSParser {
    
    public static func parse(buffer: String) throws -> CSSRules {
        let tokens = try CSSTokenizer.tokenize(buffer: buffer)
        return CSSRules()
    }
    
}
