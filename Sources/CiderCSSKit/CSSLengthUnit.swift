public enum CSSLengthUnit: String, CaseIterable {
    case ch
    case cm
    case dvh
    case dvw
    case em
    case ex
    case `in`
    case lh
    case lvh
    case lvw
    case mm
    case pc
    case pt
    case px
    case Q
    case rem
    case rlh
    case svh
    case svw
    case vb
    case vh
    case vi
    case vmax
    case vmin
    case vw
    
    func convert(amount: Float = 1, to destinationUnit: CSSLengthUnit) -> Float {
        let selfInCentimeters = self.toCentimetersRatio()
        let destinationFromCentimeters = 1.0 / destinationUnit.toCentimetersRatio()
        return selfInCentimeters * destinationFromCentimeters * amount
    }
    
    private static let inchesToCentimers: Float = 2.54
    
    private func toCentimetersRatio() -> Float {
        switch self {
        case .cm:
            return 1
        case .mm:
            return 0.1
        case .Q:
            return 0.025
        case .in:
            return Self.inchesToCentimers
        case .pc:
            return Self.inchesToCentimers / 6
        case .pt:
            return Self.inchesToCentimers / 72
        case .px:
            return Self.inchesToCentimers / 96
        default:
            return 0
        }
    }
    
}
