// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClockHandKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ClockHandKit",
            targets: ["ClockHandKit"]
        ),
    ],
    targets: [
        .target(
            name: "ClockHandKit"
        ),
    ]
)
