# ❓ About This Project

CiderCSSKit is lightweight CSS parser written as a pure Swift package.
It was primarily designed to work with [CiderKit](https://github.com/chsxf/CiderKit), but the goal is to make it as agnostic as possible.

## Conventions

This project uses [gitmoji](https://gitmoji.dev) for its commit messages.

# 🪄 Features

CiderCSSKit is still a work-in-progress. So many CSS features are not currenlty supported.

Here's the list of existing and missing features:

- syntax validation is implemented, but you can create any property with any value you like, without control (`background-image: 10px` for example)
- provides easy access to style properties, in bulk or individually
- named colors are already implemented, but any other keyword will be interpreted as a string
- complex CSS combinators (`>`, `+`, and `~`) are not implemented
- no support for pseudo-classes and pseudo-elements (like `:hover`, `:first-child`, or `::first-line` for example)
- no support for attribute selectors (like `a[target]` or `a[target="_blank"]`)
- built-in functions are limited to `rgb` and `rgba`
- short hexadecimal colors (`#fff` for example) are not supported (colors must use six hexadecimal digits)

## Planned improvements

Even if the ultimate goal is to support all syntax features, there is a long road ahead. Below is a list of short-term planned improvements:

- [X] ~~Implement ways to extend the capaibilities of the parser, with a specific model for custom validation and functions~~
- [ ] Provides basic validation configurations for most common attributes, functions and keywords

# 📦 Installation with Swift Package Manager

CiderCSSKit is available through [Swift Package Manager](https://github.com/apple/swift-package-manager).

## As a Package Dependency

To install it, simply add the dependency to your Package.Swift file:

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
