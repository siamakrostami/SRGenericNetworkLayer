// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SRGenericNetworkLayer",
    platforms: [
        .iOS(.v13),  // Specify your minimum deployment target
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
    ]
)
