// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FORME",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FORME",
            targets: ["FORME"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "FORME",
            dependencies: [
                "Alamofire",
                "SnapKit",
                "Kingfisher",
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "FORME/FORME",
            resources: []
        ),
        .testTarget(
            name: "FORMETests",
            dependencies: ["FORME"]),
    ]
)