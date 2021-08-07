// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ProjectDependencies",
    products: [
        .executable(name: "ProjectDependencies", targets: ["ProjectDependencies"])
    ],
    dependencies: [
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "ProjectDependencies",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj")
            ]
        ),
    ]
)
