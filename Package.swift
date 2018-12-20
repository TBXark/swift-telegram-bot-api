// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TelegramBotAPI",
    products: [
        .library(name: "TelegramBotAPI", targets: ["TelegramBotAPI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TelegramBotAPI", 
            path: "Sources/",
            exclude: []
        )
    ],
    swiftLanguageVersions: [4]
)