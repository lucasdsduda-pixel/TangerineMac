// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TangerineMac",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TangerineMac", targets: ["TangerineMac"])
    ],
    targets: [
        .executableTarget(
            name: "TangerineMac",
            path: "Sources/TangerineMac"
        )
    ]
)
