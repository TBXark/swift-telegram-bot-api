.PHONY: init
init:
	go install github.com/TBXark/telegram-bot-api-types@latest

.PHONY: gen
gen:
	mkdir ./Sources/TelegramBotAPI/swift > /dev/null 2>&1 || true
	telegram-bot-api-types -lang=swift -dist=./Sources/TelegramBotAPI
	mv ./Sources/TelegramBotAPI/swift/index.swift ./Sources/TelegramBotAPI/API.swift

.PHONY: test
test:
	swift build