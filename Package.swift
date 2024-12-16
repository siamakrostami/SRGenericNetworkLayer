// swift-tools-version: 6.0
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
                "Data"
            ],
            swiftSettings: [
                .define("SPM_SWIFT_6", .when(platforms: nil, configuration: nil)),
                .define("SPM_SWIFT_5", .when(platforms: nil, configuration: nil)),
                // Specific Swift 5.x version flags for finer control
                .define("SPM_SWIFT_5_9", .when(platforms: nil, configuration: nil)),
                .define("SPM_SWIFT_5_8", .when(platforms: nil, configuration: nil)),
                .define("SPM_SWIFT_5_7", .when(platforms: nil, configuration: nil))
            ]
        ),
        .testTarget(
            name: "SRNetworkManagerTests",
            dependencies: ["SRNetworkManager"],
            path: "Tests/SRNetworkManagerTests"
        ),
    ]
)

// Swift version compatibility check
#if swift(>=6.0)
package.swiftLanguageVersions = [.v6, .v5]
#else
package.swiftLanguageVersions = [.v5]
#endif
