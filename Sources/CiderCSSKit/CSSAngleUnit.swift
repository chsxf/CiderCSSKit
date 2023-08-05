public enum CSSAngleUnit: String, CaseIterable {
    
    case deg
    case rad
    case grad
    case turn
    
    func convert(amount: Float = 1, to destinationUnit: CSSAngleUnit) -> Float {
        let selfInDegrees = self.toDegreesRatio()
        let destinationFromDegrees = 1.0 / destinationUnit.toDegreesRatio()
        return selfInDegrees * destinationFromDegrees * amount
    }
    
    private func toDegreesRatio() -> Float {
        switch self {
        case .deg:
            return 1
        case .rad:
            return 180.0 / Float.pi
        case .grad:
            return 360.0 / 400.0
        case .turn:
            return 360
        }
    }
    
}
