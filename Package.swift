// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "lOrangerie",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "lOrangerie", targets: ["lOrangerie"])
    ],
    targets: [
        .executableTarget(
            name: "lOrangerie",
            path: "Sources/lOrangerie"
        )
    ]
)
