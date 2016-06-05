import PackageDescription

let package = Package(
    name: "Swiftpy",
    targets: [
        Target(
            name: "Swiftpy"),
        Target(
            name: "SwiftpyDemo",
            dependencies: [.Target(name: "Swiftpy")])
    ],
    dependencies: []
)

