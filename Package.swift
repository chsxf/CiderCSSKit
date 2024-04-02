// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CiderCSSKit",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CiderCSSKit",
            targets: ["CiderCSSKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.5.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CiderCSSKit",
            dependencies: [],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .testTarget(
            name: "CiderCSSKitTests",
            dependencies: ["CiderCSSKit"],
            resources: [
                .copy("TokenizerTests.ckcss"),
                .copy("ParserTests.ckcss"),
                .copy("ParserTestsWithComments.ckcss"),
                .copy("ParserTestsWithInvalidComment.ckcss"),
                .copy("ParserCustomTests.ckcss"),
                .copy("ParserInvalidCustomTests.ckcss"),
                .copy("ParserRuleBlockTests.ckcss")
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
    ]
)
