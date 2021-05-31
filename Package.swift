// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Either",
    products: [
        .executable(name: "Generate", targets: ["Generate"]),
        .library(name: "TelegramBotAPI", targets: ["TelegramBotAPI"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Generate", dependencies: []),
        .target(name: "TelegramBotAPI", dependencies: [])
    ]
)
