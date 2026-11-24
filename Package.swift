// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NazarDangle",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "NazarDangle", targets: ["NazarDangle"])
    ],
    targets: [
        .executableTarget(
            name: "NazarDangle",
            path: "Sources/NazarDangle",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
