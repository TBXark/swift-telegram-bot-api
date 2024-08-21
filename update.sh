/bin/rm ./Cache/TelegramBotAPI.html
wget -O ./Cache/TelegramBotAPI.html https://core.telegram.org/bots/api
swift ./Sources/Generate/main.swift -f ./Sources/TelegramBotAPI -h ./Cache/TelegramBotAPI.html
swift build
swiftlint --fix
if [ $? -eq 0 ]; then
	git add .
	git commit -a -m "Update API $(date -u +%Y.%m.%d)"
	git push origin master
else
    echo "failed"
fi
