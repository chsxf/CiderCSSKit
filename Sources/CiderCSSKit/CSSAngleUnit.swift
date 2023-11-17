/// Units used for angle values
public enum CSSAngleUnit: String, CaseIterable {
    
    /// Represents an angle in degrees. One full circle is `360deg`. Examples: `0deg`, `90deg`, `14.23deg`.
    case deg
    /// Represents an angle in radians. One full circle is 2π radians which approximates to `6.2832rad`. `1rad` is 180/π degrees. Examples: `0rad`, `1.0708rad`, `6.2832rad`.
    case rad
    /// Represents an angle in gradians. One full circle is `400grad`. Examples: `0grad`, `100grad`, `38.8grad`.
    case grad
    /// Represents an angle in a number of turns. One full circle is `1turn`. Examples: `0turn`, `0.25turn`, `1.2turn`.
    case turn
    
    /// Converts an angle value to another unit
    ///
    /// Angle values are always specified with a unit in CSS. This method helps converting one unit to another with an optional amount.
    ///
    /// ```
    /// let tenDegreesInRadians = CSSAngleUnit.deg.convert(amount: 10, to: .rad)
    /// print(tenDegreesInRadians) // Prints 0.174532925199433
    /// ```
    ///
    /// - Parameters:
    ///     - amount: how many of the current unit to use for the conversion. Defaults to `1`
    ///     - destinationUnit: Unit to which the conversion must be done
    /// - Returns: The amount of the current unit converted to the destination unit as a `Float`
    public func convert(amount: Float = 1, to destinationUnit: CSSAngleUnit) -> Float {
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
