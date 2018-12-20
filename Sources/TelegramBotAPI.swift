import Foundation

public struct TelegramAPI {

    public struct Request {
        public let method: String
        public let body: [String: Any]
    }


	/// Use this method to receive incoming updates using long polling ([wiki](http://en.wikipedia.org/wiki/Push_technology#Long_polling)). An Array of Update objects is returned.
	///
	/// - parameter offset:  Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. All previous updates will forgotten.
	/// - parameter limit:  Limits the number of updates to be retrieved. Values between 1—100 are accepted. Defaults to 100.
	/// - parameter timeout:  Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.
	/// - parameter allowedUpdates:  List the types of updates you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all updates regardless of type (default). If not specified, the previous setting will be used.Please note that this parameter doesn&#39;t affect updates created before the call to the getUpdates, so unwanted updates may be received for a short period of time.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getUpdates(offset: Int? = nil, limit: Int? = nil, timeout: Int? = nil, allowedUpdates: [String]? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["offset"] = offset
		parameters["limit"] = limit
		parameters["timeout"] = timeout
		parameters["allowed_updates"] = allowedUpdates
		return Request(method: "getUpdates", body: parameters)
	}


	/// If you&#39;d like to make sure that the Webhook request comes from Telegram, we recommend using a secret path in the URL, e.g. https://www.example.com/&lt;token&gt;. Since nobody else knows your bot‘s token, you can be pretty sure it’s us.
	///
	/// - parameter url:  HTTPS url to send updates to. Use an empty string to remove webhook integration
	/// - parameter certificate:  Upload your public key certificate so that the root certificate in use can be checked. See our self-signed guide for details.
	/// - parameter maxConnections:  Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery, 1-100. Defaults to 40. Use lower values to limit the load on your bot‘s server, and higher values to increase your bot’s throughput.
	/// - parameter allowedUpdates:  List the types of updates you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all updates regardless of type (default). If not specified, the previous setting will be used.Please note that this parameter doesn&#39;t affect updates created before the call to the setWebhook, so unwanted updates may be received for a short period of time.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setWebhook(url: String, certificate: InputFile? = nil, maxConnections: Int? = nil, allowedUpdates: [String]? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["url"] = url
		parameters["certificate"] = certificate
		parameters["max_connections"] = maxConnections
		parameters["allowed_updates"] = allowedUpdates
		return Request(method: "setWebhook", body: parameters)
	}


	/// Use this method to remove webhook integration if you decide to switch back to getUpdates. Returns True on success. Requires no parameters.
	///
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func deleteWebhook() -> Request {
		
		return Request(method: "deleteWebhook", body: [:])
	}


	/// Use this method to get current webhook status. Requires no parameters. On success, returns a WebhookInfo object. If the bot is using getUpdates, will return an object with the url field empty.
	///
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getWebhookInfo() -> Request {
		
		return Request(method: "getWebhookInfo", body: [:])
	}


	/// A simple method for testing your bot&#39;s auth token. Requires no parameters. Returns basic information about the bot in form of a User object.
	///
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getMe() -> Request {
		
		return Request(method: "getMe", body: [:])
	}


	/// Use this method to send text messages. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter text:  Text of the message to be sent
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot&#39;s message.
	/// - parameter disableWebPagePreview:  Disables link previews for links in this message
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendMessage(chatId: Either<Int, String>, text: String, parseMode: String? = nil, disableWebPagePreview: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["text"] = text
		parameters["parse_mode"] = parseMode
		parameters["disable_web_page_preview"] = disableWebPagePreview
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendMessage", body: parameters)
	}


	/// Use this method to forward messages of any kind. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter fromChatId:  Unique identifier for the chat where the original message was sent (or channel username in the format @channelusername)
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter messageId:  Message identifier in the chat specified in from_chat_id
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func forwardMessage(chatId: Either<Int, String>, fromChatId: Either<Int, String>, disableNotification: Bool? = nil, messageId: Int) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["from_chat_id"] = fromChatId
		parameters["disable_notification"] = disableNotification
		parameters["message_id"] = messageId
		return Request(method: "forwardMessage", body: parameters)
	}


	/// Use this method to send photos. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter photo:  Photo to send. Pass a file_id as String to send a photo that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a photo from the Internet, or upload a new photo using multipart/form-data. More info on Sending Files »
	/// - parameter caption:  Photo caption (may also be used when resending photos by file_id), 0-1024 characters
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendPhoto(chatId: Either<Int, String>, photo: Either<InputFile, String>, caption: String? = nil, parseMode: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["photo"] = photo
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendPhoto", body: parameters)
	}


	/// For sending voice messages, use the sendVoice method instead.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter audio:  Audio file to send. Pass a file_id as String to send an audio file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an audio file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
	/// - parameter caption:  Audio caption, 0-1024 characters
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter duration:  Duration of the audio in seconds
	/// - parameter performer:  Performer
	/// - parameter title:  Track name
	/// - parameter thumb:  Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendAudio(chatId: Either<Int, String>, audio: Either<InputFile, String>, caption: String? = nil, parseMode: String? = nil, duration: Int? = nil, performer: String? = nil, title: String? = nil, thumb: Either<InputFile, String>? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["audio"] = audio
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["duration"] = duration
		parameters["performer"] = performer
		parameters["title"] = title
		parameters["thumb"] = thumb
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendAudio", body: parameters)
	}


	/// Use this method to send general files. On success, the sent Message is returned. Bots can currently send files of any type of up to 50 MB in size, this limit may be changed in the future.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter document:  File to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
	/// - parameter thumb:  Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	/// - parameter caption:  Document caption (may also be used when resending documents by file_id), 0-1024 characters
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendDocument(chatId: Either<Int, String>, document: Either<InputFile, String>, thumb: Either<InputFile, String>? = nil, caption: String? = nil, parseMode: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["document"] = document
		parameters["thumb"] = thumb
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendDocument", body: parameters)
	}


	/// Use this method to send video files, Telegram clients support mp4 videos (other formats may be sent as Document). On success, the sent Message is returned. Bots can currently send video files of up to 50 MB in size, this limit may be changed in the future.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter video:  Video to send. Pass a file_id as String to send a video that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a video from the Internet, or upload a new video using multipart/form-data. More info on Sending Files »
	/// - parameter duration:  Duration of sent video in seconds
	/// - parameter width:  Video width
	/// - parameter height:  Video height
	/// - parameter thumb:  Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	/// - parameter caption:  Video caption (may also be used when resending videos by file_id), 0-1024 characters
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter supportsStreaming:  Pass True, if the uploaded video is suitable for streaming
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendVideo(chatId: Either<Int, String>, video: Either<InputFile, String>, duration: Int? = nil, width: Int? = nil, height: Int? = nil, thumb: Either<InputFile, String>? = nil, caption: String? = nil, parseMode: String? = nil, supportsStreaming: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["video"] = video
		parameters["duration"] = duration
		parameters["width"] = width
		parameters["height"] = height
		parameters["thumb"] = thumb
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["supports_streaming"] = supportsStreaming
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendVideo", body: parameters)
	}


	/// Use this method to send animation files (GIF or H.264/MPEG-4 AVC video without sound). On success, the sent Message is returned. Bots can currently send animation files of up to 50 MB in size, this limit may be changed in the future.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter animation:  Animation to send. Pass a file_id as String to send an animation that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an animation from the Internet, or upload a new animation using multipart/form-data. More info on Sending Files »
	/// - parameter duration:  Duration of sent animation in seconds
	/// - parameter width:  Animation width
	/// - parameter height:  Animation height
	/// - parameter thumb:  Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	/// - parameter caption:  Animation caption (may also be used when resending animation by file_id), 0-1024 characters
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendAnimation(chatId: Either<Int, String>, animation: Either<InputFile, String>, duration: Int? = nil, width: Int? = nil, height: Int? = nil, thumb: Either<InputFile, String>? = nil, caption: String? = nil, parseMode: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["animation"] = animation
		parameters["duration"] = duration
		parameters["width"] = width
		parameters["height"] = height
		parameters["thumb"] = thumb
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendAnimation", body: parameters)
	}


	/// Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message. For this to work, your audio must be in an .ogg file encoded with OPUS (other formats may be sent as Audio or Document). On success, the sent Message is returned. Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter voice:  Audio file to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
	/// - parameter caption:  Voice message caption, 0-1024 characters
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter duration:  Duration of the voice message in seconds
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendVoice(chatId: Either<Int, String>, voice: Either<InputFile, String>, caption: String? = nil, parseMode: String? = nil, duration: Int? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["voice"] = voice
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["duration"] = duration
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendVoice", body: parameters)
	}


	/// As of [v.4.0](https://telegram.org/blog/video-messages-and-telescope), Telegram clients support rounded square mp4 videos of up to 1 minute long. Use this method to send video messages. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter videoNote:  Video note to send. Pass a file_id as String to send a video note that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. More info on Sending Files ». Sending video notes by a URL is currently unsupported
	/// - parameter duration:  Duration of sent video in seconds
	/// - parameter length:  Video width and height, i.e. diameter of the video message
	/// - parameter thumb:  Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendVideoNote(chatId: Either<Int, String>, videoNote: Either<InputFile, String>, duration: Int? = nil, length: Int? = nil, thumb: Either<InputFile, String>? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["video_note"] = videoNote
		parameters["duration"] = duration
		parameters["length"] = length
		parameters["thumb"] = thumb
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendVideoNote", body: parameters)
	}


	/// Use this method to send a group of photos or videos as an album. On success, an array of the sent Messages is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter media:  A JSON-serialized array describing photos and videos to be sent, must include 2–10 items
	/// - parameter disableNotification:  Sends the messages [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the messages are a reply, ID of the original message
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendMediaGroup(chatId: Either<Int, String>, media: [Either<InputMediaPhoto, InputMediaVideo>], disableNotification: Bool? = nil, replyToMessageId: Int? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["media"] = media
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		return Request(method: "sendMediaGroup", body: parameters)
	}


	/// Use this method to send point on the map. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter latitude:  Latitude of the location
	/// - parameter longitude:  Longitude of the location
	/// - parameter livePeriod:  Period in seconds for which the location will be updated (see [Live Locations](https://telegram.org/blog/live-locations), should be between 60 and 86400.
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendLocation(chatId: Either<Int, String>, latitude: Float, longitude: Float, livePeriod: Int? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["latitude"] = latitude
		parameters["longitude"] = longitude
		parameters["live_period"] = livePeriod
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendLocation", body: parameters)
	}


	/// Use this method to edit live location messages sent by the bot or via the bot (for inline bots). A location can be edited until its live_period expires or editing is explicitly disabled by a call to stopMessageLiveLocation. On success, if the edited message was sent by the bot, the edited Message is returned, otherwise True is returned.
	///
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	/// - parameter latitude:  Latitude of new location
	/// - parameter longitude:  Longitude of new location
	/// - parameter replyMarkup:  A JSON-serialized object for a new [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func editMessageLiveLocation(chatId: Either<Int, String>? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, latitude: Float, longitude: Float, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		parameters["latitude"] = latitude
		parameters["longitude"] = longitude
		parameters["reply_markup"] = replyMarkup
		return Request(method: "editMessageLiveLocation", body: parameters)
	}


	/// Use this method to stop updating a live location message sent by the bot or via the bot (for inline bots) before live_period expires. On success, if the message was sent by the bot, the sent Message is returned, otherwise True is returned.
	///
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	/// - parameter replyMarkup:  A JSON-serialized object for a new [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func stopMessageLiveLocation(chatId: Either<Int, String>? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "stopMessageLiveLocation", body: parameters)
	}


	/// Use this method to send information about a venue. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter latitude:  Latitude of the venue
	/// - parameter longitude:  Longitude of the venue
	/// - parameter title:  Name of the venue
	/// - parameter address:  Address of the venue
	/// - parameter foursquareId:  Foursquare identifier of the venue
	/// - parameter foursquareType:  Foursquare type of the venue, if known. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendVenue(chatId: Either<Int, String>, latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["latitude"] = latitude
		parameters["longitude"] = longitude
		parameters["title"] = title
		parameters["address"] = address
		parameters["foursquare_id"] = foursquareId
		parameters["foursquare_type"] = foursquareType
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendVenue", body: parameters)
	}


	/// Use this method to send phone contacts. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter phoneNumber:  Contact&#39;s phone number
	/// - parameter firstName:  Contact&#39;s first name
	/// - parameter lastName:  Contact&#39;s last name
	/// - parameter vcard:  Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendContact(chatId: Either<Int, String>, phoneNumber: String, firstName: String, lastName: String? = nil, vcard: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["phone_number"] = phoneNumber
		parameters["first_name"] = firstName
		parameters["last_name"] = lastName
		parameters["vcard"] = vcard
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendContact", body: parameters)
	}


	/// We only recommend using this method when a response from the bot will take a noticeable amount of time to arrive.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter action:  Type of action to broadcast. Choose one, depending on what the user is about to receive: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for location data, record_video_note or upload_video_note for video notes.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendChatAction(chatId: Either<Int, String>, action: String) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["action"] = action
		return Request(method: "sendChatAction", body: parameters)
	}


	/// Use this method to get a list of profile pictures for a user. Returns a UserProfilePhotos object.
	///
	/// - parameter userId:  Unique identifier of the target user
	/// - parameter offset:  Sequential number of the first photo to be returned. By default, all photos are returned.
	/// - parameter limit:  Limits the number of photos to be retrieved. Values between 1—100 are accepted. Defaults to 100.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getUserProfilePhotos(userId: Int, offset: Int? = nil, limit: Int? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["offset"] = offset
		parameters["limit"] = limit
		return Request(method: "getUserProfilePhotos", body: parameters)
	}


	/// Use this method to get basic info about a file and prepare it for downloading. For the moment, bots can download files of up to 20MB in size. On success, a File object is returned. The file can then be downloaded via the link https://api.telegram.org/file/bot&lt;token&gt;/&lt;file_path&gt;, where &lt;file_path&gt; is taken from the response. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile again.
	///
	/// - parameter fileId:  File identifier to get info about
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getFile(fileId: String) -> Request {
		var parameters = [String: Any]()
		parameters["file_id"] = fileId
		return Request(method: "getFile", body: parameters)
	}


	/// Note: In regular groups (non-supergroups), this method will only work if the ‘All Members Are Admins’ setting is off in the target group. Otherwise members may only be removed by the group&#39;s creator or by the member that added them.
	///
	/// - parameter chatId:  Unique identifier for the target group or username of the target supergroup or channel (in the format @channelusername)
	/// - parameter userId:  Unique identifier of the target user
	/// - parameter untilDate:  Date when the user will be unbanned, unix time. If user is banned for more than 366 days or less than 30 seconds from the current time they are considered to be banned forever
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func kickChatMember(chatId: Either<Int, String>, userId: Int, untilDate: Int? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["user_id"] = userId
		parameters["until_date"] = untilDate
		return Request(method: "kickChatMember", body: parameters)
	}


	/// Use this method to unban a previously kicked user in a supergroup or channel. The user will not return to the group or channel automatically, but will be able to join via link, etc. The bot must be an administrator for this to work. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target group or username of the target supergroup or channel (in the format @username)
	/// - parameter userId:  Unique identifier of the target user
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func unbanChatMember(chatId: Either<Int, String>, userId: Int) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["user_id"] = userId
		return Request(method: "unbanChatMember", body: parameters)
	}


	/// Use this method to restrict a user in a supergroup. The bot must be an administrator in the supergroup for this to work and must have the appropriate admin rights. Pass True for all boolean parameters to lift restrictions from a user. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
	/// - parameter userId:  Unique identifier of the target user
	/// - parameter untilDate:  Date when restrictions will be lifted for the user, unix time. If user is restricted for more than 366 days or less than 30 seconds from the current time, they are considered to be restricted forever
	/// - parameter canSendMessages:  Pass True, if the user can send text messages, contacts, locations and venues
	/// - parameter canSendMediaMessages:  Pass True, if the user can send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
	/// - parameter canSendOtherMessages:  Pass True, if the user can send animations, games, stickers and use inline bots, implies can_send_media_messages
	/// - parameter canAddWebPagePreviews:  Pass True, if the user may add web page previews to their messages, implies can_send_media_messages
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func restrictChatMember(chatId: Either<Int, String>, userId: Int, untilDate: Int? = nil, canSendMessages: Bool? = nil, canSendMediaMessages: Bool? = nil, canSendOtherMessages: Bool? = nil, canAddWebPagePreviews: Bool? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["user_id"] = userId
		parameters["until_date"] = untilDate
		parameters["can_send_messages"] = canSendMessages
		parameters["can_send_media_messages"] = canSendMediaMessages
		parameters["can_send_other_messages"] = canSendOtherMessages
		parameters["can_add_web_page_previews"] = canAddWebPagePreviews
		return Request(method: "restrictChatMember", body: parameters)
	}


	/// Use this method to promote or demote a user in a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Pass False for all boolean parameters to demote a user. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter userId:  Unique identifier of the target user
	/// - parameter canChangeInfo:  Pass True, if the administrator can change chat title, photo and other settings
	/// - parameter canPostMessages:  Pass True, if the administrator can create channel posts, channels only
	/// - parameter canEditMessages:  Pass True, if the administrator can edit messages of other users and can pin messages, channels only
	/// - parameter canDeleteMessages:  Pass True, if the administrator can delete messages of other users
	/// - parameter canInviteUsers:  Pass True, if the administrator can invite new users to the chat
	/// - parameter canRestrictMembers:  Pass True, if the administrator can restrict, ban or unban chat members
	/// - parameter canPinMessages:  Pass True, if the administrator can pin messages, supergroups only
	/// - parameter canPromoteMembers:  Pass True, if the administrator can add new administrators with a subset of his own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by him)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func promoteChatMember(chatId: Either<Int, String>, userId: Int, canChangeInfo: Bool? = nil, canPostMessages: Bool? = nil, canEditMessages: Bool? = nil, canDeleteMessages: Bool? = nil, canInviteUsers: Bool? = nil, canRestrictMembers: Bool? = nil, canPinMessages: Bool? = nil, canPromoteMembers: Bool? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["user_id"] = userId
		parameters["can_change_info"] = canChangeInfo
		parameters["can_post_messages"] = canPostMessages
		parameters["can_edit_messages"] = canEditMessages
		parameters["can_delete_messages"] = canDeleteMessages
		parameters["can_invite_users"] = canInviteUsers
		parameters["can_restrict_members"] = canRestrictMembers
		parameters["can_pin_messages"] = canPinMessages
		parameters["can_promote_members"] = canPromoteMembers
		return Request(method: "promoteChatMember", body: parameters)
	}


	/// Use this method to generate a new invite link for a chat; any previously generated link is revoked. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns the new invite link as String on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func exportChatInviteLink(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "exportChatInviteLink", body: parameters)
	}


	/// Note: In regular groups (non-supergroups), this method will only work if the ‘All Members Are Admins’ setting is off in the target group.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter photo:  New chat photo, uploaded using multipart/form-data
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setChatPhoto(chatId: Either<Int, String>, photo: InputFile) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["photo"] = photo
		return Request(method: "setChatPhoto", body: parameters)
	}


	/// Note: In regular groups (non-supergroups), this method will only work if the ‘All Members Are Admins’ setting is off in the target group.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func deleteChatPhoto(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "deleteChatPhoto", body: parameters)
	}


	/// Note: In regular groups (non-supergroups), this method will only work if the ‘All Members Are Admins’ setting is off in the target group.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter title:  New chat title, 1-255 characters
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setChatTitle(chatId: Either<Int, String>, title: String) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["title"] = title
		return Request(method: "setChatTitle", body: parameters)
	}


	/// Use this method to change the description of a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns True on success. 
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter description:  New chat description, 0-255 characters
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setChatDescription(chatId: Either<Int, String>, description: String? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["description"] = description
		return Request(method: "setChatDescription", body: parameters)
	}


	/// Use this method to pin a message in a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the ‘can_pin_messages’ admin right in the supergroup or ‘can_edit_messages’ admin right in the channel. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Identifier of a message to pin
	/// - parameter disableNotification:  Pass True, if it is not necessary to send a notification to all chat members about the new pinned message. Notifications are always disabled in channels.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func pinChatMessage(chatId: Either<Int, String>, messageId: Int, disableNotification: Bool? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["disable_notification"] = disableNotification
		return Request(method: "pinChatMessage", body: parameters)
	}


	/// Use this method to unpin a message in a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the ‘can_pin_messages’ admin right in the supergroup or ‘can_edit_messages’ admin right in the channel. Returns True on success. 
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func unpinChatMessage(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "unpinChatMessage", body: parameters)
	}


	/// Use this method for your bot to leave a group, supergroup or channel. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup or channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func leaveChat(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "leaveChat", body: parameters)
	}


	/// Use this method to get up to date information about the chat (current name of the user for one-on-one conversations, current username of a user, group or channel, etc.). Returns a Chat object on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup or channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getChat(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "getChat", body: parameters)
	}


	/// Use this method to get a list of administrators in a chat. On success, returns an Array of ChatMember objects that contains information about all chat administrators except other bots. If the chat is a group or a supergroup and no administrators were appointed, only the creator will be returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup or channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getChatAdministrators(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "getChatAdministrators", body: parameters)
	}


	/// Use this method to get the number of members in a chat. Returns Int on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup or channel (in the format @channelusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getChatMembersCount(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "getChatMembersCount", body: parameters)
	}


	/// Use this method to get information about a member of a chat. Returns a ChatMember object on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup or channel (in the format @channelusername)
	/// - parameter userId:  Unique identifier of the target user
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getChatMember(chatId: Either<Int, String>, userId: Int) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["user_id"] = userId
		return Request(method: "getChatMember", body: parameters)
	}


	/// Use this method to set a new group sticker set for a supergroup. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Use the field can_set_sticker_set optionally returned in getChat requests to check if the bot can use this method. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
	/// - parameter stickerSetName:  Name of the sticker set to be set as the group sticker set
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setChatStickerSet(chatId: Either<Int, String>, stickerSetName: String) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["sticker_set_name"] = stickerSetName
		return Request(method: "setChatStickerSet", body: parameters)
	}


	/// Use this method to delete a group sticker set from a supergroup. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Use the field can_set_sticker_set optionally returned in getChat requests to check if the bot can use this method. Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func deleteChatStickerSet(chatId: Either<Int, String>) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		return Request(method: "deleteChatStickerSet", body: parameters)
	}


	/// Alternatively, the user can be redirected to the specified Game URL. For this option to work, you must first create a game for your bot via [@Botfather](https://t.me/botfather) and accept the terms. Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
	///
	/// - parameter callbackQueryId:  Unique identifier for the query to be answered
	/// - parameter text:  Text of the notification. If not specified, nothing will be shown to the user, 0-200 characters
	/// - parameter showAlert:  If true, an alert will be shown by the client instead of a notification at the top of the chat screen. Defaults to false.
	/// - parameter url:  URL that will be opened by the user&#39;s client. If you have created a Game and accepted the conditions via [@Botfather](https://t.me/botfather), specify the URL that opens your game – note that this will only work if the query comes from a callback_game button.Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
	/// - parameter cacheTime:  The maximum amount of time in seconds that the result of the callback query may be cached client-side. Telegram apps will support caching starting in version 3.14. Defaults to 0.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func answerCallbackQuery(callbackQueryId: String, text: String? = nil, showAlert: Bool? = nil, url: String? = nil, cacheTime: Int? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["callback_query_id"] = callbackQueryId
		parameters["text"] = text
		parameters["show_alert"] = showAlert
		parameters["url"] = url
		parameters["cache_time"] = cacheTime
		return Request(method: "answerCallbackQuery", body: parameters)
	}


	/// Use this method to edit text and game messages sent by the bot or via the bot (for inline bots). On success, if edited message is sent by the bot, the edited Message is returned, otherwise True is returned.
	///
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	/// - parameter text:  New text of the message
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot&#39;s message.
	/// - parameter disableWebPagePreview:  Disables link previews for links in this message
	/// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func editMessageText(chatId: Either<Int, String>? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, text: String, parseMode: String? = nil, disableWebPagePreview: Bool? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		parameters["text"] = text
		parameters["parse_mode"] = parseMode
		parameters["disable_web_page_preview"] = disableWebPagePreview
		parameters["reply_markup"] = replyMarkup
		return Request(method: "editMessageText", body: parameters)
	}


	/// Use this method to edit captions of messages sent by the bot or via the bot (for inline bots). On success, if edited message is sent by the bot, the edited Message is returned, otherwise True is returned.
	///
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	/// - parameter caption:  New caption of the message
	/// - parameter parseMode:  Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	/// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func editMessageCaption(chatId: Either<Int, String>? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		parameters["caption"] = caption
		parameters["parse_mode"] = parseMode
		parameters["reply_markup"] = replyMarkup
		return Request(method: "editMessageCaption", body: parameters)
	}


	/// Use this method to edit audio, document, photo, or video messages. If a message is a part of a message album, then it can be edited only to a photo or a video. Otherwise, message type can be changed arbitrarily. When inline message is edited, new file can&#39;t be uploaded. Use previously uploaded file via its file_id or specify a URL. On success, if the edited message was sent by the bot, the edited Message is returned, otherwise True is returned.
	///
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	/// - parameter media:  A JSON-serialized object for a new media content of the message
	/// - parameter replyMarkup:  A JSON-serialized object for a new [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func editMessageMedia(chatId: Either<Int, String>? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, media: InputMedia, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		parameters["media"] = media
		parameters["reply_markup"] = replyMarkup
		return Request(method: "editMessageMedia", body: parameters)
	}


	/// Use this method to edit only the reply markup of messages sent by the bot or via the bot (for inline bots).  On success, if edited message is sent by the bot, the edited Message is returned, otherwise True is returned.
	///
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	/// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func editMessageReplyMarkup(chatId: Either<Int, String>? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "editMessageReplyMarkup", body: parameters)
	}


	/// Use this method to delete a message, including service messages, with the following limitations:- A message can only be deleted if it was sent less than 48 hours ago.- Bots can delete outgoing messages in private chats, groups, and supergroups.- Bots granted can_post_messages permissions can delete outgoing messages in channels.- If the bot is an administrator of a group, it can delete any message there.- If the bot has can_delete_messages permission in a supergroup or a channel, it can delete any message there.Returns True on success.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter messageId:  Identifier of the message to delete
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func deleteMessage(chatId: Either<Int, String>, messageId: Int) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		return Request(method: "deleteMessage", body: parameters)
	}


	/// Use this method to send .webp stickers. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
	/// - parameter sticker:  Sticker to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a .webp file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendSticker(chatId: Either<Int, String>, sticker: Either<InputFile, String>, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["sticker"] = sticker
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendSticker", body: parameters)
	}


	/// Use this method to get a sticker set. On success, a StickerSet object is returned.
	///
	/// - parameter name:  Name of the sticker set
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getStickerSet(name: String) -> Request {
		var parameters = [String: Any]()
		parameters["name"] = name
		return Request(method: "getStickerSet", body: parameters)
	}


	/// Use this method to upload a .png file with a sticker for later use in createNewStickerSet and addStickerToSet methods (can be used multiple times). Returns the uploaded File on success.
	///
	/// - parameter userId:  User identifier of sticker file owner
	/// - parameter pngSticker:  Png image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. More info on Sending Files »
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func uploadStickerFile(userId: Int, pngSticker: InputFile) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["png_sticker"] = pngSticker
		return Request(method: "uploadStickerFile", body: parameters)
	}


	/// Use this method to create new sticker set owned by a user. The bot will be able to edit the created sticker set. Returns True on success.
	///
	/// - parameter userId:  User identifier of created sticker set owner
	/// - parameter name:  Short name of sticker set, to be used in t.me/addstickers/ URLs (e.g., animals). Can contain only english letters, digits and underscores. Must begin with a letter, can&#39;t contain consecutive underscores and must end in “_by_&lt;bot username&gt;”. &lt;bot_username&gt; is case insensitive. 1-64 characters.
	/// - parameter title:  Sticker set title, 1-64 characters
	/// - parameter pngSticker:  Png image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
	/// - parameter emojis:  One or more emoji corresponding to the sticker
	/// - parameter containsMasks:  Pass True, if a set of mask stickers should be created
	/// - parameter maskPosition:  A JSON-serialized object for position where the mask should be placed on faces
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func createNewStickerSet(userId: Int, name: String, title: String, pngSticker: Either<InputFile, String>, emojis: String, containsMasks: Bool? = nil, maskPosition: MaskPosition? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["name"] = name
		parameters["title"] = title
		parameters["png_sticker"] = pngSticker
		parameters["emojis"] = emojis
		parameters["contains_masks"] = containsMasks
		parameters["mask_position"] = maskPosition
		return Request(method: "createNewStickerSet", body: parameters)
	}


	/// Use this method to add a new sticker to a set created by the bot. Returns True on success.
	///
	/// - parameter userId:  User identifier of sticker set owner
	/// - parameter name:  Sticker set name
	/// - parameter pngSticker:  Png image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
	/// - parameter emojis:  One or more emoji corresponding to the sticker
	/// - parameter maskPosition:  A JSON-serialized object for position where the mask should be placed on faces
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func addStickerToSet(userId: Int, name: String, pngSticker: Either<InputFile, String>, emojis: String, maskPosition: MaskPosition? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["name"] = name
		parameters["png_sticker"] = pngSticker
		parameters["emojis"] = emojis
		parameters["mask_position"] = maskPosition
		return Request(method: "addStickerToSet", body: parameters)
	}


	/// Use this method to move a sticker in a set created by the bot to a specific position . Returns True on success.
	///
	/// - parameter sticker:  File identifier of the sticker
	/// - parameter position:  New sticker position in the set, zero-based
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setStickerPositionInSet(sticker: String, position: Int) -> Request {
		var parameters = [String: Any]()
		parameters["sticker"] = sticker
		parameters["position"] = position
		return Request(method: "setStickerPositionInSet", body: parameters)
	}


	/// Use this method to delete a sticker from a set created by the bot. Returns True on success.
	///
	/// - parameter sticker:  File identifier of the sticker
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func deleteStickerFromSet(sticker: String) -> Request {
		var parameters = [String: Any]()
		parameters["sticker"] = sticker
		return Request(method: "deleteStickerFromSet", body: parameters)
	}


	/// Use this method to send answers to an inline query. On success, True is returned.No more than 50 results per query are allowed.
	///
	/// - parameter inlineQueryId:  Unique identifier for the answered query
	/// - parameter results:  A JSON-serialized array of results for the inline query
	/// - parameter cacheTime:  The maximum amount of time in seconds that the result of the inline query may be cached on the server. Defaults to 300.
	/// - parameter isPersonal:  Pass True, if results may be cached on the server side only for the user that sent the query. By default, results may be returned to any user who sends the same query
	/// - parameter nextOffset:  Pass the offset that a client should send in the next query with the same text to receive more results. Pass an empty string if there are no more results or if you don‘t support pagination. Offset length can’t exceed 64 bytes.
	/// - parameter switchPmText:  If passed, clients will display a button with specified text that switches the user to a private chat with the bot and sends the bot a start message with the parameter switch_pm_parameter
	/// - parameter switchPmParameter:  Deep-linking parameter for the /start message sent to the bot when user presses the switch button. 1-64 characters, only A-Z, a-z, 0-9, _ and - are allowed.Example: An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a ‘Connect your YouTube account’ button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an oauth link. Once done, the bot can offer a switch_inline button so that the user can easily return to the chat where they wanted to use the bot&#39;s inline capabilities.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func answerInlineQuery(inlineQueryId: String, results: [InlineQueryResult], cacheTime: Int? = nil, isPersonal: Bool? = nil, nextOffset: String? = nil, switchPmText: String? = nil, switchPmParameter: String? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["inline_query_id"] = inlineQueryId
		parameters["results"] = results
		parameters["cache_time"] = cacheTime
		parameters["is_personal"] = isPersonal
		parameters["next_offset"] = nextOffset
		parameters["switch_pm_text"] = switchPmText
		parameters["switch_pm_parameter"] = switchPmParameter
		return Request(method: "answerInlineQuery", body: parameters)
	}


	/// Use this method to send invoices. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target private chat
	/// - parameter title:  Product name, 1-32 characters
	/// - parameter description:  Product description, 1-255 characters
	/// - parameter payload:  Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use for your internal processes.
	/// - parameter providerToken:  Payments provider token, obtained via [Botfather](https://t.me/botfather)
	/// - parameter startParameter:  Unique deep-linking parameter that can be used to generate this invoice when used as a start parameter
	/// - parameter currency:  Three-letter ISO 4217 currency code, see more on currencies
	/// - parameter prices:  Price breakdown, a list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
	/// - parameter providerData:  JSON-encoded data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.
	/// - parameter photoUrl:  URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.
	/// - parameter photoSize:  Photo size
	/// - parameter photoWidth:  Photo width
	/// - parameter photoHeight:  Photo height
	/// - parameter needName:  Pass True, if you require the user&#39;s full name to complete the order
	/// - parameter needPhoneNumber:  Pass True, if you require the user&#39;s phone number to complete the order
	/// - parameter needEmail:  Pass True, if you require the user&#39;s email address to complete the order
	/// - parameter needShippingAddress:  Pass True, if you require the user&#39;s shipping address to complete the order
	/// - parameter sendPhoneNumberToProvider:  Pass True, if user&#39;s phone number should be sent to provider
	/// - parameter sendEmailToProvider:  Pass True, if user&#39;s email address should be sent to provider
	/// - parameter isFlexible:  Pass True, if the final price depends on the shipping method
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating). If empty, one &#39;Pay total price&#39; button will be shown. If not empty, the first button must be a Pay button.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendInvoice(chatId: Int, title: String, description: String, payload: String, providerToken: String, startParameter: String, currency: String, prices: [LabeledPrice], providerData: String? = nil, photoUrl: String? = nil, photoSize: Int? = nil, photoWidth: Int? = nil, photoHeight: Int? = nil, needName: Bool? = nil, needPhoneNumber: Bool? = nil, needEmail: Bool? = nil, needShippingAddress: Bool? = nil, sendPhoneNumberToProvider: Bool? = nil, sendEmailToProvider: Bool? = nil, isFlexible: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["title"] = title
		parameters["description"] = description
		parameters["payload"] = payload
		parameters["provider_token"] = providerToken
		parameters["start_parameter"] = startParameter
		parameters["currency"] = currency
		parameters["prices"] = prices
		parameters["provider_data"] = providerData
		parameters["photo_url"] = photoUrl
		parameters["photo_size"] = photoSize
		parameters["photo_width"] = photoWidth
		parameters["photo_height"] = photoHeight
		parameters["need_name"] = needName
		parameters["need_phone_number"] = needPhoneNumber
		parameters["need_email"] = needEmail
		parameters["need_shipping_address"] = needShippingAddress
		parameters["send_phone_number_to_provider"] = sendPhoneNumberToProvider
		parameters["send_email_to_provider"] = sendEmailToProvider
		parameters["is_flexible"] = isFlexible
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendInvoice", body: parameters)
	}


	/// If you sent an invoice requesting a shipping address and the parameter is_flexible was specified, the Bot API will send an Update with a shipping_query field to the bot. Use this method to reply to shipping queries. On success, True is returned.
	///
	/// - parameter shippingQueryId:  Unique identifier for the query to be answered
	/// - parameter ok:  Specify True if delivery to the specified address is possible and False if there are any problems (for example, if delivery to the specified address is not possible)
	/// - parameter shippingOptions:  Required if ok is True. A JSON-serialized array of available shipping options.
	/// - parameter errorMessage:  Required if ok is False. Error message in human readable form that explains why it is impossible to complete the order (e.g. &quot;Sorry, delivery to your desired address is unavailable&#39;). Telegram will display this message to the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func answerShippingQuery(shippingQueryId: String, ok: Bool, shippingOptions: [ShippingOption]? = nil, errorMessage: String? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["shipping_query_id"] = shippingQueryId
		parameters["ok"] = ok
		parameters["shipping_options"] = shippingOptions
		parameters["error_message"] = errorMessage
		return Request(method: "answerShippingQuery", body: parameters)
	}


	/// Once the user has confirmed their payment and shipping details, the Bot API sends the final confirmation in the form of an Update with the field pre_checkout_query. Use this method to respond to such pre-checkout queries. On success, True is returned. Note: The Bot API must receive an answer within 10 seconds after the pre-checkout query was sent.
	///
	/// - parameter preCheckoutQueryId:  Unique identifier for the query to be answered
	/// - parameter ok:  Specify True if everything is alright (goods are available, etc.) and the bot is ready to proceed with the order. Use False if there are any problems.
	/// - parameter errorMessage:  Required if ok is False. Error message in human readable form that explains the reason for failure to proceed with the checkout (e.g. &quot;Sorry, somebody just bought the last of our amazing black T-shirts while you were busy filling out your payment details. Please choose a different color or garment!&quot;). Telegram will display this message to the user.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func answerPreCheckoutQuery(preCheckoutQueryId: String, ok: Bool, errorMessage: String? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["pre_checkout_query_id"] = preCheckoutQueryId
		parameters["ok"] = ok
		parameters["error_message"] = errorMessage
		return Request(method: "answerPreCheckoutQuery", body: parameters)
	}


	/// Use this if the data submitted by the user doesn&#39;t satisfy the standards your service requires for any reason. For example, if a birthday date seems invalid, a submitted document is blurry, a scan shows evidence of tampering, etc. Supply some details in the error message to make sure the user knows how to correct the issues.
	///
	/// - parameter userId:  User identifier
	/// - parameter errors:  A JSON-serialized array describing the errors
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setPassportDataErrors(userId: Int, errors: [PassportElementError]) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["errors"] = errors
		return Request(method: "setPassportDataErrors", body: parameters)
	}


	/// Use this method to send a game. On success, the sent Message is returned.
	///
	/// - parameter chatId:  Unique identifier for the target chat
	/// - parameter gameShortName:  Short name of the game, serves as the unique identifier for the game. Set up your games via [Botfather](https://t.me/botfather).
	/// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
	/// - parameter replyToMessageId:  If the message is a reply, ID of the original message
	/// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating). If empty, one ‘Play game_title’ button will be shown. If not empty, the first button must launch the game.
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func sendGame(chatId: Int, gameShortName: String, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["chat_id"] = chatId
		parameters["game_short_name"] = gameShortName
		parameters["disable_notification"] = disableNotification
		parameters["reply_to_message_id"] = replyToMessageId
		parameters["reply_markup"] = replyMarkup
		return Request(method: "sendGame", body: parameters)
	}


	/// Use this method to set the score of the specified user in a game. On success, if the message was sent by the bot, returns the edited Message, otherwise returns True. Returns an error, if the new score is not greater than the user&#39;s current score in the chat and force is False.
	///
	/// - parameter userId:  User identifier
	/// - parameter score:  New score, must be non-negative
	/// - parameter force:  Pass True, if the high score is allowed to decrease. This can be useful when fixing mistakes or banning cheaters
	/// - parameter disableEditMessage:  Pass True, if the game message should not be automatically edited to include the current scoreboard
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func setGameScore(userId: Int, score: Int, force: Bool? = nil, disableEditMessage: Bool? = nil, chatId: Int? = nil, messageId: Int? = nil, inlineMessageId: String? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["score"] = score
		parameters["force"] = force
		parameters["disable_edit_message"] = disableEditMessage
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		return Request(method: "setGameScore", body: parameters)
	}


	/// This method will currently return scores for the target user, plus two of his closest neighbors on each side. Will also return the top three users if the user and his neighbors are not among them. Please note that this behavior is subject to change.
	///
	/// - parameter userId:  Target user id
	/// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat
	/// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
	/// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
	///
	/// - returns: The new `TelegramAPI.Request` instance.
	///
	func getGameHighScores(userId: Int, chatId: Int? = nil, messageId: Int? = nil, inlineMessageId: String? = nil) -> Request {
		var parameters = [String: Any]()
		parameters["user_id"] = userId
		parameters["chat_id"] = chatId
		parameters["message_id"] = messageId
		parameters["inline_message_id"] = inlineMessageId
		return Request(method: "getGameHighScores", body: parameters)
	}

}