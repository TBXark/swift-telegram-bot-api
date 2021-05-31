/bin/rm TelegramBotAPI.html
wget -O TelegramBotAPI.html https://core.telegram.org/bots/api
swift run Generate -f ./Sources/TelegramBotAPI
swiftlint --fix
if [ $? -eq 0 ]; then
	git add .
	git commit -a -m "Update API $(date -u +%Y.%m.%d)"
	git push origin master
else
    echo "failed"
fi
