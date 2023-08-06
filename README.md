# ❓ About This Project

CiderCSSKit is lightweight CSS parser written as a pure Swift package.
It was primarily designed to work with [CiderKit](https://github.com/chsxf/CiderKit), but the goal is to make it as agnostic as possible.

![](https://github.com/chsxf/CiderCSSKit/actions/workflows/swift.yml/badge.svg)
[![](https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg)](https://gitmoji.dev/)
![](https://analytics.chsxf.dev/GitHubStats.badge/CiderCSSKit/README.md)

# 🪄 Features

CiderCSSKit is still a work-in-progress. So many CSS features are not currenlty supported.

Here's the list of existing and missing features:

- provides easy access to style properties, in bulk or individually
- named colors are already implemented
- built-in functions are limited to `rgb` and `rgba`
- complex CSS combinators (`>`, `+`, and `~`) are not implemented
- no support pseudo-elements (like `::first-line` for example)
- no support for parametric pseudo-classes (like `:nth-child()` for example)
- no support for attribute selectors (like `a[target]` or `a[target="_blank"]`)

## Supported Attributes

The list of supported attributes is fairly limited for now but will expand over time.

- `background-color`
- `border-image` and its sub-attributes
    - `border-image-outset`
    - `border-image-repeat`
    - `border-image-slice`
    - `border-image-source`
    - `border-image-width`
- `color`
- `font` and its sub-attributes
    - `font-family`
    - `font-size`
    - `font-stretch`
    - `font-style`
    - `font-variant`
    - `font-weight`
    - `line-height`
- `padding` and its sub-attributes
    - `padding-bottom`
    - `padding-left`
    - `padding-right`
    - `padding-top`
- `text-align`
- `transform-origin`

## Planned improvements

Even if the ultimate goal is to support all syntax features, there is a long road ahead. Below is a list of short-term planned improvements:

- [ ] Add support for `hsl()` color function ([#12](https://github.com/chsxf/CiderCSSKit/issues/12))
- [ ] Add support for the adjacent sibling combinator (`+`) ([#6](https://github.com/chsxf/CiderCSSKit/issues/6))
- [ ] Add support for the child combinator (`>`) ([#7](https://github.com/chsxf/CiderCSSKit/issues/7))
- [ ] Add support for the general sibling combinator (`~`) ([#8](https://github.com/chsxf/CiderCSSKit/issues/8))
- [ ] Provides basic validation configurations for most common attributes, functions and keywords

[Previously Closed Issues](https://github.com/chsxf/CiderCSSKit/issues?q=is%3Aissue+is%3Aclosed)

# 🚀 Getting Started

The full documentation of the package is available [here](https://chsxf.github.io/CiderCSSKit/documentation/cidercsskit).

# 📦 Installation with Swift Package Manager

CiderCSSKit is available through [Swift Package Manager](https://github.com/apple/swift-package-manager).

## As a Package Dependency

To install it, simply add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/chsxf/CiderCSSKit.git", requirement: .branch("main")),
],
targets: [
    .target(name: "YourTarget", dependencies: ["CiderCSSKit"]),
]
```

## As a Project Dependency in Xcode

- In Xcode, select **File > Add Packages...** and enter `https://github.com/chsxf/CiderCSSKit.git` in the search field (top-right). 
- Then select **Branch** as the **Dependency Rule** with `main` in the associated text field.
- Then select the project of your choice in the **Add to Project** list.
- Finally, click the **Add Package** button.

# ⚖️ License

Unless stated otherwise, all source code and assets are distributed under the [MIT License](LICENSE).
