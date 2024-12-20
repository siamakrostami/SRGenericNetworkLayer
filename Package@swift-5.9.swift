// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SRNetworkManager",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v7)
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
                "Data",
                "DownloadManager"
            ],
            swiftSettings: [
                .define("SPM_SWIFT_5"),
                .define("SWIFT_PACKAGE")
            ]
        ),
        .testTarget(
            name: "SRNetworkManagerTests",
            dependencies: ["SRNetworkManager"],
            path: "Tests/SRNetworkManagerTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
