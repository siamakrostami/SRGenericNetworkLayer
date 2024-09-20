// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SRGenericNetworkLayer",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v7)  // You can adjust the minimum version as needed
    ],
    products: [
        .library(
            name: "SRGenericNetworkLayer",
            targets: ["SRGenericNetworkLayer"]
        ),
    ],
    targets: [
        .target(
            name: "SRGenericNetworkLayer",
            path: "Sources",
            sources: [
                "SRGenericNetworkLayer",
                "HeaderHandler",
                "Encoding",
                "CustomError",
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
            name: "SRGenericNetworkLayerTests",
            dependencies: ["SRGenericNetworkLayer"],
            path: "Tests/SRGenericNetworkLayerTests"
        ),
    ],
    swiftLanguageModes: [.v5,.v6]
)
