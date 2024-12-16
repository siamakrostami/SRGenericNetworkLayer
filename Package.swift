// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SRNetworkManager",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v7)  // You can adjust the minimum version as needed
    ],
    products: [
        .library(
            name: "SRNetworkManager",
            targets: ["SRNetworkManager"]
        ),
    ],
    targets: [
        .target(
            name: "SRNetworkManager",
            path: "Sources",
            sources: [
                "SRNetworkManager",
                "HeaderHandler",
                "Encoding",
                "Log",
                "Mime",
                "Error",
                "Client",
                "UploadProgress",
                "Router",
                "Data"
            ]
        ),
        .testTarget(
            name: "SRNetworkManagerTests",
            dependencies: ["SRNetworkManager"],
            path: "Tests/SRNetworkManagerTests"
        ),
    ],
    swiftLanguageModes: [.v5,.v6]
)
