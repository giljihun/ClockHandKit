// swift-tools-version: 6.2
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
