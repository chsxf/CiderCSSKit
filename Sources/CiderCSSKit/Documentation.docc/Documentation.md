# ``CiderCSSKit``

A fast and lightweight CSS parser, written as a pure Swift package

## Overview

CiderCSSKit is a lightweight CSS parser written as a pure Swift package.

It was primarily designed to work with [CiderKit](https://github.com/chsxf/CiderKit), but the goal is to make it as agnostic as possible.

## Installation with Swift Package Manager

CiderCSSKit is available through [Swift Package Manager](https://github.com/apple/swift-package-manager).

### As a Package Dependency

To install it, simply add the dependency to your Package.Swift file:

```swift
dependencies: [
    .package(url: "https://github.com/chsxf/CiderCSSKit.git", requirement: .branch("main")),
],
targets: [
    .target(name: "YourTarget", dependencies: ["CiderCSSKit"]),
]
```

### As a Project Dependency in Xcode

- In Xcode, select **File > Add Packages...** and enter `https://github.com/chsxf/CiderCSSKit.git` in the search field (top-right).
- Then select **Branch** as the **Dependency Rule** with `main` in the associated text field.
- Then select the project of your choice in the **Add to Project** list.
- Finally, click the **Add Package** button.

### License

Unless stated otherwise, all source code and assets are distributed under the [MIT License](https://github.com/chsxf/CiderCSSKit/blob/main/LICENSE).

## Topics

### Essentials

- ``CSSParser``
- ``CSSRules``
- ``CSSConsumer``
- ``CSSAttributes``

### Values

- ``CSSValue``
- ``CSSAngleUnit``
- ``CSSLengthUnit``
- ``CSSColorKeywords``

### Error Management

- ``CSSParserErrors``

### Extending and Validating

- ``CSSValidationConfiguration``
- ``CSSValueType``
- ``CSSValueGroupingType``
- ``CSSValueShorthandGroupDescriptor``
- ``CSSAttributeExpansion``
- ``CSSAttributeExpanders``
- ``CSSFunctionHelpers``

### Tokens

- ``CSSToken``
- ``CSSTokenType``
