// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UnscrollCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "UnscrollCore", targets: ["UnscrollCore"])],
    targets: [
        .target(name: "UnscrollCore"),
        .testTarget(name: "UnscrollCoreTests", dependencies: ["UnscrollCore"]),
    ]
)
