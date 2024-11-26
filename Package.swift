// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TelegramBotAPI",
    products: [
        .library(name: "TelegramBotAPI", targets: ["TelegramBotAPI"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "TelegramBotAPI", dependencies: [])
    ]
)
