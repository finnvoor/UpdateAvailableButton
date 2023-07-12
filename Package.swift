// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "UpdateAvailableButton",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "UpdateAvailableButton",
            targets: ["UpdateAvailableButton"]
        ),
    ],
    dependencies: [.package(url: "https://github.com/Finnvoor/iTunesSearchAPI.git", branch: "main")],
    targets: [
        .target(
            name: "UpdateAvailableButton",
            dependencies: [.product(name: "iTunesSearchAPI", package: "iTunesSearchAPI")]
        )
    ]
)
