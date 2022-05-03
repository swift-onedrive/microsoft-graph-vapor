// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "microsoft-graph-vapor",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MicrosoftGraph",
            targets: ["MicrosoftGraph"]),
        .library(name: "MicrosoftOneDrive",
                 targets: ["MicrosoftOneDrive"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-onedrive/microsoft-graph-kit", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MicrosoftGraph",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MicrosoftGraphOneDrive", package: "microsoft-graph-kit")
            ]
        ),
        .target(name: "MicrosoftOneDrive",
                dependencies: [
                    .product(name: "Vapor", package: "vapor"),
                    .product(name: "MicrosoftGraphOneDrive", package: "microsoft-graph-kit"),
                    .target(name: "MicrosoftGraph")
                ],
                exclude: ["README.md"]
        ),
        .testTarget(
            name: "microsoft-graph-vaporTests",
            dependencies: ["MicrosoftOneDrive"]),
    ]
)
