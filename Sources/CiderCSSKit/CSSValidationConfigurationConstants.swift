final class CSSValidationConfigurationConstants {

    static let valueGroupingTypeByAttribute: [String: CSSValueGroupingType] = [
        CSSAttributes.backgroundColor: .single([.color]),
        CSSAttributes.borderImage: .shorthand([
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageSource),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageSlice, optional: true, defaultValue: .percentage(100)),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageWidth, optional: true, afterSeparator: true, defaultValue: .number(1)),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageOutset, optional: true, afterSeparator: true, defaultValue: .number(0)),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.borderImageRepeat, optional: true, defaultValue: .keyword("stretch"))
        ]),
        CSSAttributes.borderImageOutset: .multiple([.number, .length()], min: 1, max: 4, customExpansionMethod: CSSAttributeExpanders.fourValuesExpander(attributeToken:values:)),
        CSSAttributes.borderImageRepeat: .multiple([.keyword("stretch")], min: 1, max: 2, customExpansionMethod: CSSAttributeExpanders.twoValuesExpander(attributeToken:values:)),
        CSSAttributes.borderImageSlice: .multiple([.number, .percentage, .keyword("fill")], min: 1, max: 4, customExpansionMethod: CSSAttributeExpanders.fourValuesExpander(attributeToken:values:)),
        CSSAttributes.borderImageSource: .single([.url]),
        CSSAttributes.borderImageWidth: .multiple([.number, .length(), .percentage, .keyword("auto")], min: 1, max: 4, customExpansionMethod: CSSAttributeExpanders.fourValuesExpander(attributeToken:values:)),
        CSSAttributes.color: .single([.color]),
        CSSAttributes.font: .shorthand([
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontStyle, optional: true, defaultValue: .keyword("normal")),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontVariant, optional: true, defaultValue: .keyword("normal")),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontWeight, optional: true, defaultValue: .number(400)),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontStretch, optional: true, defaultValue: .percentage(100)),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontSize),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.lineHeight, optional: true, afterSeparator: true, defaultValue: .number(1.2)),
            CSSValueShorthandGroupDescriptor(subAttributeName: CSSAttributes.fontFamily)
        ]),
        CSSAttributes.fontFamily: .multiple([
            .string,
            .keyword("sans-serif"),
            .keyword("serif"),
            .keyword("monospace"),
            .keyword("cursive"),
            .keyword("fantasy"),
            .keyword("system-ui"),
            .keyword("math"),
            .keyword("emoji"),
            .keyword("fangsong")
        ], min: 1),
        CSSAttributes.fontSize: .single([.length(), .percentage]),
        CSSAttributes.fontStretch: .single([
            .percentage,
            .keyword("ultra-condensed", associatedValue: .percentage(50)),
            .keyword("extra-condensed", associatedValue: .percentage(62.5)),
            .keyword("condensed", associatedValue: .percentage(75)),
            .keyword("semi-condensed", associatedValue: .percentage(87.5)),
            .keyword("normal", associatedValue: .percentage(100)),
            .keyword("semi-expanded", associatedValue: .percentage(112.5)),
            .keyword("expanded", associatedValue: .percentage(125)),
            .keyword("extra-expanded", associatedValue: .percentage(150)),
            .keyword("ultra-expanded", associatedValue: .percentage(200))
        ]),
        CSSAttributes.fontStyle: .single([.keyword("normal"), .keyword("italic")]),
        CSSAttributes.fontVariant: .single([.keyword("normal"), .keyword("small-caps")]),
        CSSAttributes.fontWeight: .single([.number, .keyword("normal", associatedValue: .number(400)), .keyword("bold", associatedValue: .number(700))]),
        CSSAttributes.lineHeight: .single([.length(), .number, .percentage, .keyword("normal", associatedValue: .number(1.2))]),
        CSSAttributes.padding: .multiple([.number, .length()], min: 1, max: 4, customExpansionMethod: CSSAttributeExpanders.expandPadding(attributeToken:values:)),
        CSSAttributes.paddingBottom: .single([.number, .length()]),
        CSSAttributes.paddingLeft: .single([.number, .length()]),
        CSSAttributes.paddingRight: .single([.number, .length()]),
        CSSAttributes.paddingTop: .single([.number, .length()]),
        CSSAttributes.textAlign: .single([.keyword("start"), .keyword("end"), .keyword("left"), .keyword("right"), .keyword("center"), .keyword("justify"), .keyword("match-parent")]),
        CSSAttributes.transformOrigin: .multiple([
            .percentage,
            .length(),
            .keyword("bottom", associatedValue: .percentage(0)),
            .keyword("center", associatedValue: .percentage(50)),
            .keyword("left", associatedValue: .percentage(0)),
            .keyword("right", associatedValue: .percentage(100)),
            .keyword("top", associatedValue: .percentage(100))
        ], min: 1, max: 3, customExpansionMethod: CSSAttributeExpanders.expandTransformOrigin(attributeToken:values:)),
        CSSAttributes.verticalAlign: .single([.keyword("baseline"), .keyword("sub"), .keyword("super"), .keyword("text-top"), .keyword("text-bottom"), .keyword("middle"), .length(), .percentage]),
        CSSAttributes.visibility: .single([.keyword("visible"), .keyword("hidden"), .keyword("collapse")]),
        CSSAttributes.zIndex: .single([.keyword("auto"), .number])
    ]

}
