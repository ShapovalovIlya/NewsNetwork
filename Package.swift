// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NewsNetwork",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "NewsNetwork", targets: [
            "Repository",
            "Models"
        ]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NetworkManager", targets: ["NetworkManager"]),
        .library(name: "PersistenceManager", targets: ["PersistenceManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/ShapovalovIlya/SwiftFP.git", branch: "main")
    ],
    targets: [
        .target(name: "Models"),
        .target(
            name: "PersistenceManager",
            dependencies: [
                .product(name: "SwiftFP", package: "SwiftFP"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(name: "NetworkManager", dependencies: [
            .product(name: "SwiftFP", package: "SwiftFP"),
            "Models"
        ]),
        .target(name: "Repository", dependencies: [
            .product(name: "SwiftFP", package: "SwiftFP"),
            "Models",
            "NetworkManager",
            "PersistenceManager"
        ]),
        .testTarget(name: "NewsNetworkTests", dependencies: [
            "Repository"
        ])
    ]
)
