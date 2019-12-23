// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mini",
    //    platforms: [
//        .iOS(.v11),
//        .macOS(.v10_13),
//        .tvOS(.v11)
//    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Mini",
            targets: ["Mini"]
        ),
        .library(
            name: "Mini/Log",
            targets: ["Mini", "LoggingService"]
        ),
        .library(
            name: "Mini/Test",
            targets: ["Mini", "TestMiddleware"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.7.1")),
        // Development
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")), // dev
        .package(url: "https://github.com/minuscorp/ModuleInterface", from: "0.0.1"), // dev
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.35.8"), // dev
        .package(url: "https://github.com/jpsim/SourceKitten", from: "0.26.0"), // dev
        .package(url: "https://github.com/shibapm/Rocket", from: "0.4.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.35.0"), // dev
        .package(url: "https://github.com/eneko/SourceDocs", from: "0.6.1"), // dev
        .package(url: "https://github.com/shibapm/PackageConfig.git", from: "0.12.2"), // dev
        .package(url: "https://github.com/shibapm/Komondor.git", from: "1.0.0"), // dev
        .package(url: "https://github.com/Carthage/Commandant.git", .exact("0.17.0")), // dev
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Mini",
            dependencies: ["RxSwift", "NIOConcurrencyHelpers", "NIO"]
        ),
        .target(
            name: "LoggingService",
            dependencies: ["Mini"]
        ),
        .target(
            name: "TestMiddleware",
            dependencies: ["Mini"]
        ),
        .testTarget(name: "MiniSwiftTests", dependencies: ["Mini", "TestMiddleware", "NIOConcurrencyHelpers", "RxSwift", "Nimble", "RxTest", "RxBlocking"]), // dev
    ],
    swiftLanguageVersions: [.version("4"), .version("4.2"), .version("5")]
)

#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfiguration([
        "rocket": [
            "before": [
                "brew bundle",
                "bundle install",
                "bundle exec fastlane run version_bump_podspec version_number:`echo $VERSION | cut -d \"v\" -f 2`",
                "rake docs",
            ],
            "after": [
                "pod lib lint --allow-warnings",
                "pod trunk push --allow-warnings",
            ],
        ],
        "komondor": [
            "pre-push": "swift test",
            "pre-commit": [
                "swift test",
                "swift run swiftlint autocorrect --path Sources/",
                "swift run swiftlint autocorrect --path Tests/",
                "swift test --generate-linuxmain",
                "swift run swiftformat .",
                "git add .",
            ],
        ],
    ]).write()
#endif
