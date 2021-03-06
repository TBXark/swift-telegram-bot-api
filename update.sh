/bin/rm TelegramBotAPI.html
wget -O TelegramBotAPI.html https://core.telegram.org/bots/api
swift run Generate -f ./Sources/TelegramBotAPI
if [ $? -eq 0 ]; then
	git add .
	git commit -a -m "Update $(date -u +%Y.%m.%d)"
else
    echo "failed"
fi
