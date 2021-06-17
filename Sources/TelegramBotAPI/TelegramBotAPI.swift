//
//  TelegramAPI.swift
//  TelegramAPI
//
//  Created by Tbxark on 2021/06/17.
//  Copyright © 2018 Tbxark. All rights reserved.
//

import Foundation

public struct TelegramAPI {

    /// Use this method to receive incoming updates using long polling ([wiki](https://en.wikipedia.org/wiki/Push_technology#Long_polling)). An Array of Update objects is returned.
    ///
    /// - parameter offset:  Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. All previous updates will forgotten.
    /// - parameter limit:  Limits the number of updates to be retrieved. Values between 1-100 are accepted. Defaults to 100.
    /// - parameter timeout:  Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.
    /// - parameter allowedUpdates:  A JSON-serialized list of the update types you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all update types except chat_member (default). If not specified, the previous setting will be used.Please note that this parameter doesn’t affect updates created before the call to the getUpdates, so unwanted updates may be received for a short period of time.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getUpdates(offset: Int? = nil, limit: Int? = nil, timeout: Int? = nil, allowedUpdates: [String]? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["offset"] = offset
        parameters["limit"] = limit
        parameters["timeout"] = timeout
        parameters["allowed_updates"] = allowedUpdates
        return Request(method: "getUpdates", body: parameters)
    }

    /// If you’d like to make sure that the Webhook request comes from Telegram, we recommend using a secret path in the URL, e.g. https://www.example.com/&lt;token&gt;. Since nobody else knows your bot’s token, you can be pretty sure it’s us.
    ///
    /// - parameter url:  HTTPS url to send updates to. Use an empty string to remove webhook integration
    /// - parameter certificate:  Upload your public key certificate so that the root certificate in use can be checked. See our self-signed guide for details.
    /// - parameter ipAddress:  The fixed IP address which will be used to send webhook requests instead of the IP address resolved through DNS
    /// - parameter maxConnections:  Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery, 1-100. Defaults to 40. Use lower values to limit the load on your bot’s server, and higher values to increase your bot’s throughput.
    /// - parameter allowedUpdates:  A JSON-serialized list of the update types you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all update types except chat_member (default). If not specified, the previous setting will be used.Please note that this parameter doesn’t affect updates created before the call to the setWebhook, so unwanted updates may be received for a short period of time.
    /// - parameter dropPendingUpdates:  Pass True to drop all pending updates
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setWebhook(url: String, certificate: InputFile? = nil, ipAddress: String? = nil, maxConnections: Int? = nil, allowedUpdates: [String]? = nil, dropPendingUpdates: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["url"] = url
        parameters["certificate"] = certificate
        parameters["ip_address"] = ipAddress
        parameters["max_connections"] = maxConnections
        parameters["allowed_updates"] = allowedUpdates
        parameters["drop_pending_updates"] = dropPendingUpdates
        return Request(method: "setWebhook", body: parameters)
    }

    /// Use this method to remove webhook integration if you decide to switch back to getUpdates. Returns True on success.
    ///
    /// - parameter dropPendingUpdates:  Pass True to drop all pending updates
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func deleteWebhook(dropPendingUpdates: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["drop_pending_updates"] = dropPendingUpdates
        return Request(method: "deleteWebhook", body: parameters)
    }

    /// Use this method to get current webhook status. Requires no parameters. On success, returns a WebhookInfo object. If the bot is using getUpdates, will return an object with the url field empty.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getWebhookInfo() -> Request {
        return Request(method: "getWebhookInfo", body: [:])
    }

    /// A simple method for testing your bot’s auth token. Requires no parameters. Returns basic information about the bot in form of a User object.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getMe() -> Request {
        return Request(method: "getMe", body: [:])
    }

    /// Use this method to log out from the cloud Bot API server before launching the bot locally. You must log out the bot before running it locally, otherwise there is no guarantee that the bot will receive updates. After a successful call, you can immediately log in on a local server, but will not be able to log in back to the cloud Bot API server for 10 minutes. Returns True on success. Requires no parameters.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func logOut() -> Request {
        return Request(method: "logOut", body: [:])
    }

    /// Use this method to close the bot instance before moving it from one local server to another. You need to delete the webhook before calling this method to ensure that the bot isn’t launched again after server restart. The method will return error 429 in the first 10 minutes after the bot is launched. Returns True on success. Requires no parameters.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func close() -> Request {
        return Request(method: "close", body: [:])
    }

    /// Use this method to send text messages. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter text:  Text of the message to be sent, 1-4096 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the message text. See formatting options for more details.
    /// - parameter entities:  List of special entities that appear in message text, which can be specified instead of parse_mode
    /// - parameter disableWebPagePreview:  Disables link previews for links in this message
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendMessage(chatId: ChatId, text: String, parseMode: String? = nil, entities: [MessageEntity]? = nil, disableWebPagePreview: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["text"] = text
        parameters["parse_mode"] = parseMode
        parameters["entities"] = entities
        parameters["disable_web_page_preview"] = disableWebPagePreview
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendMessage", body: parameters)
    }

    /// Use this method to forward messages of any kind. Service messages can’t be forwarded. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter fromChatId:  Unique identifier for the chat where the original message was sent (or channel username in the format @channelusername)
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter messageId:  Message identifier in the chat specified in from_chat_id
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func forwardMessage(chatId: ChatId, fromChatId: ChatId, disableNotification: Bool? = nil, messageId: Int) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["from_chat_id"] = fromChatId
        parameters["disable_notification"] = disableNotification
        parameters["message_id"] = messageId
        return Request(method: "forwardMessage", body: parameters)
    }

    /// Use this method to copy messages of any kind. Service messages and invoice messages can’t be copied. The method is analogous to the method forwardMessage, but the copied message doesn’t have a link to the original message. Returns the MessageId of the sent message on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter fromChatId:  Unique identifier for the chat where the original message was sent (or channel username in the format @channelusername)
    /// - parameter messageId:  Message identifier in the chat specified in from_chat_id
    /// - parameter caption:  New caption for media, 0-1024 characters after entities parsing. If not specified, the original caption is kept
    /// - parameter parseMode:  Mode for parsing entities in the new caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the new caption, which can be specified instead of parse_mode
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func copyMessage(chatId: ChatId, fromChatId: ChatId, messageId: Int, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["from_chat_id"] = fromChatId
        parameters["message_id"] = messageId
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "copyMessage", body: parameters)
    }

    /// Use this method to send photos. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter photo:  Photo to send. Pass a file_id as String to send a photo that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a photo from the Internet, or upload a new photo using multipart/form-data. The photo must be at most 10 MB in size. The photo’s width and height must not exceed 10000 in total. Width and height ratio must be at most 20. More info on Sending Files »
    /// - parameter caption:  Photo caption (may also be used when resending photos by file_id), 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the photo caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendPhoto(chatId: ChatId, photo: FileOrPath, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["photo"] = photo
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendPhoto", body: parameters)
    }

    /// For sending voice messages, use the sendVoice method instead.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter audio:  Audio file to send. Pass a file_id as String to send an audio file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an audio file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
    /// - parameter caption:  Audio caption, 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the audio caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter duration:  Duration of the audio in seconds
    /// - parameter performer:  Performer
    /// - parameter title:  Track name
    /// - parameter thumb:  Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendAudio(chatId: ChatId, audio: FileOrPath, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, duration: Int? = nil, performer: String? = nil, title: String? = nil, thumb: FileOrPath? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["audio"] = audio
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["duration"] = duration
        parameters["performer"] = performer
        parameters["title"] = title
        parameters["thumb"] = thumb
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendAudio", body: parameters)
    }

    /// Use this method to send general files. On success, the sent Message is returned. Bots can currently send files of any type of up to 50 MB in size, this limit may be changed in the future.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter document:  File to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
    /// - parameter thumb:  Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
    /// - parameter caption:  Document caption (may also be used when resending documents by file_id), 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the document caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter disableContentTypeDetection:  Disables automatic server-side content type detection for files uploaded using multipart/form-data
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendDocument(chatId: ChatId, document: FileOrPath, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, disableContentTypeDetection: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["document"] = document
        parameters["thumb"] = thumb
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["disable_content_type_detection"] = disableContentTypeDetection
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
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
    /// - parameter thumb:  Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
    /// - parameter caption:  Video caption (may also be used when resending videos by file_id), 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the video caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter supportsStreaming:  Pass True, if the uploaded video is suitable for streaming
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendVideo(chatId: ChatId, video: FileOrPath, duration: Int? = nil, width: Int? = nil, height: Int? = nil, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, supportsStreaming: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["video"] = video
        parameters["duration"] = duration
        parameters["width"] = width
        parameters["height"] = height
        parameters["thumb"] = thumb
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["supports_streaming"] = supportsStreaming
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
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
    /// - parameter thumb:  Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
    /// - parameter caption:  Animation caption (may also be used when resending animation by file_id), 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the animation caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendAnimation(chatId: ChatId, animation: FileOrPath, duration: Int? = nil, width: Int? = nil, height: Int? = nil, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["animation"] = animation
        parameters["duration"] = duration
        parameters["width"] = width
        parameters["height"] = height
        parameters["thumb"] = thumb
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendAnimation", body: parameters)
    }

    /// Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message. For this to work, your audio must be in an .OGG file encoded with OPUS (other formats may be sent as Audio or Document). On success, the sent Message is returned. Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter voice:  Audio file to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
    /// - parameter caption:  Voice message caption, 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the voice message caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter duration:  Duration of the voice message in seconds
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendVoice(chatId: ChatId, voice: FileOrPath, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, duration: Int? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["voice"] = voice
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["duration"] = duration
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendVoice", body: parameters)
    }

    /// As of [v.4.0](https://telegram.org/blog/video-messages-and-telescope), Telegram clients support rounded square mp4 videos of up to 1 minute long. Use this method to send video messages. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter videoNote:  Video note to send. Pass a file_id as String to send a video note that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. More info on Sending Files ». Sending video notes by a URL is currently unsupported
    /// - parameter duration:  Duration of sent video in seconds
    /// - parameter length:  Video width and height, i.e. diameter of the video message
    /// - parameter thumb:  Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendVideoNote(chatId: ChatId, videoNote: FileOrPath, duration: Int? = nil, length: Int? = nil, thumb: FileOrPath? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["video_note"] = videoNote
        parameters["duration"] = duration
        parameters["length"] = length
        parameters["thumb"] = thumb
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendVideoNote", body: parameters)
    }

    /// Use this method to send a group of photos, videos, documents or audios as an album. Documents and audio files can be only grouped in an album with messages of the same type. On success, an array of Messages that were sent is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter media:  A JSON-serialized array describing messages to be sent, must include 2-10 items
    /// - parameter disableNotification:  Sends messages [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the messages are a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendMediaGroup(chatId: ChatId, media: [Either<InputMediaAudio, InputMediaDocument, InputMediaPhoto, InputMediaVideo>], disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["media"] = media
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        return Request(method: "sendMediaGroup", body: parameters)
    }

    /// Use this method to send point on the map. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter latitude:  Latitude of the location
    /// - parameter longitude:  Longitude of the location
    /// - parameter horizontalAccuracy:  The radius of uncertainty for the location, measured in meters; 0-1500
    /// - parameter livePeriod:  Period in seconds for which the location will be updated (see [Live Locations](https://telegram.org/blog/live-locations), should be between 60 and 86400.
    /// - parameter heading:  For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
    /// - parameter proximityAlertRadius:  For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendLocation(chatId: ChatId, latitude: Float, longitude: Float, horizontalAccuracy: Float? = nil, livePeriod: Int? = nil, heading: Int? = nil, proximityAlertRadius: Int? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        parameters["horizontal_accuracy"] = horizontalAccuracy
        parameters["live_period"] = livePeriod
        parameters["heading"] = heading
        parameters["proximity_alert_radius"] = proximityAlertRadius
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendLocation", body: parameters)
    }

    /// Use this method to edit live location messages. A location can be edited until its live_period expires or editing is explicitly disabled by a call to stopMessageLiveLocation. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
    ///
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the message to edit
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    /// - parameter latitude:  Latitude of new location
    /// - parameter longitude:  Longitude of new location
    /// - parameter horizontalAccuracy:  The radius of uncertainty for the location, measured in meters; 0-1500
    /// - parameter heading:  Direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
    /// - parameter proximityAlertRadius:  Maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
    /// - parameter replyMarkup:  A JSON-serialized object for a new [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func editMessageLiveLocation(chatId: ChatId? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, latitude: Float, longitude: Float, horizontalAccuracy: Float? = nil, heading: Int? = nil, proximityAlertRadius: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["inline_message_id"] = inlineMessageId
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        parameters["horizontal_accuracy"] = horizontalAccuracy
        parameters["heading"] = heading
        parameters["proximity_alert_radius"] = proximityAlertRadius
        parameters["reply_markup"] = replyMarkup
        return Request(method: "editMessageLiveLocation", body: parameters)
    }

    /// Use this method to stop updating a live location message before live_period expires. On success, if the message was sent by the bot, the sent Message is returned, otherwise True is returned.
    ///
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the message with live location to stop
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    /// - parameter replyMarkup:  A JSON-serialized object for a new [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func stopMessageLiveLocation(chatId: ChatId? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
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
    /// - parameter googlePlaceId:  Google Places identifier of the venue
    /// - parameter googlePlaceType:  Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendVenue(chatId: ChatId, latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, googlePlaceId: String? = nil, googlePlaceType: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        parameters["title"] = title
        parameters["address"] = address
        parameters["foursquare_id"] = foursquareId
        parameters["foursquare_type"] = foursquareType
        parameters["google_place_id"] = googlePlaceId
        parameters["google_place_type"] = googlePlaceType
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendVenue", body: parameters)
    }

    /// Use this method to send phone contacts. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter phoneNumber:  Contact’s phone number
    /// - parameter firstName:  Contact’s first name
    /// - parameter lastName:  Contact’s last name
    /// - parameter vcard:  Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendContact(chatId: ChatId, phoneNumber: String, firstName: String, lastName: String? = nil, vcard: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["phone_number"] = phoneNumber
        parameters["first_name"] = firstName
        parameters["last_name"] = lastName
        parameters["vcard"] = vcard
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendContact", body: parameters)
    }

    /// Use this method to send a native poll. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter question:  Poll question, 1-300 characters
    /// - parameter options:  A JSON-serialized list of answer options, 2-10 strings 1-100 characters each
    /// - parameter isAnonymous:  True, if the poll needs to be anonymous, defaults to True
    /// - parameter type:  Poll type, “quiz” or “regular”, defaults to “regular”
    /// - parameter allowsMultipleAnswers:  True, if the poll allows multiple answers, ignored for polls in quiz mode, defaults to False
    /// - parameter correctOptionId:  0-based identifier of the correct answer option, required for polls in quiz mode
    /// - parameter explanation:  Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters with at most 2 line feeds after entities parsing
    /// - parameter explanationParseMode:  Mode for parsing entities in the explanation. See formatting options for more details.
    /// - parameter explanationEntities:  List of special entities that appear in the poll explanation, which can be specified instead of parse_mode
    /// - parameter openPeriod:  Amount of time in seconds the poll will be active after creation, 5-600. Can’t be used together with close_date.
    /// - parameter closeDate:  Point in time (Unix timestamp) when the poll will be automatically closed. Must be at least 5 and no more than 600 seconds in the future. Can’t be used together with open_period.
    /// - parameter isClosed:  Pass True, if the poll needs to be immediately closed. This can be useful for poll preview.
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendPoll(chatId: ChatId, question: String, options: [String], isAnonymous: Bool? = nil, type: String? = nil, allowsMultipleAnswers: Bool? = nil, correctOptionId: Int? = nil, explanation: String? = nil, explanationParseMode: String? = nil, explanationEntities: [MessageEntity]? = nil, openPeriod: Int? = nil, closeDate: Int? = nil, isClosed: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["question"] = question
        parameters["options"] = options
        parameters["is_anonymous"] = isAnonymous
        parameters["type"] = type
        parameters["allows_multiple_answers"] = allowsMultipleAnswers
        parameters["correct_option_id"] = correctOptionId
        parameters["explanation"] = explanation
        parameters["explanation_parse_mode"] = explanationParseMode
        parameters["explanation_entities"] = explanationEntities
        parameters["open_period"] = openPeriod
        parameters["close_date"] = closeDate
        parameters["is_closed"] = isClosed
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendPoll", body: parameters)
    }

    /// Use this method to send an animated emoji that will display a random value. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter emoji:  Emoji on which the dice throw animation is based. Currently, must be one of “”, “”, “”, “”, “”, or “”. Dice can have values 1-6 for “”, “” and “”, values 1-5 for “” and “”, and values 1-64 for “”. Defaults to “”
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendDice(chatId: ChatId, emoji: String? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["emoji"] = emoji
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendDice", body: parameters)
    }

    /// We only recommend using this method when a response from the bot will take a noticeable amount of time to arrive.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter action:  Type of action to broadcast. Choose one, depending on what the user is about to receive: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_voice or upload_voice for voice notes, upload_document for general files, find_location for location data, record_video_note or upload_video_note for video notes.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendChatAction(chatId: ChatId, action: String) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["action"] = action
        return Request(method: "sendChatAction", body: parameters)
    }

    /// Use this method to get a list of profile pictures for a user. Returns a UserProfilePhotos object.
    ///
    /// - parameter userId:  Unique identifier of the target user
    /// - parameter offset:  Sequential number of the first photo to be returned. By default, all photos are returned.
    /// - parameter limit:  Limits the number of photos to be retrieved. Values between 1-100 are accepted. Defaults to 100.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getUserProfilePhotos(userId: Int, offset: Int? = nil, limit: Int? = nil) -> Request {
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
    static public func getFile(fileId: String) -> Request {
        var parameters = [String: Any]()
        parameters["file_id"] = fileId
        return Request(method: "getFile", body: parameters)
    }

    /// Use this method to kick a user from a group, a supergroup or a channel. In the case of supergroups and channels, the user will not be able to return to the chat on their own using invite links, etc., unless unbanned first. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target group or username of the target supergroup or channel (in the format @channelusername)
    /// - parameter userId:  Unique identifier of the target user
    /// - parameter untilDate:  Date when the user will be unbanned, unix time. If user is banned for more than 366 days or less than 30 seconds from the current time they are considered to be banned forever. Applied for supergroups and channels only.
    /// - parameter revokeMessages:  Pass True to delete all messages from the chat for the user that is being removed. If False, the user will be able to see messages in the group that were sent before the user was removed. Always True for supergroups and channels.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func kickChatMember(chatId: ChatId, userId: Int, untilDate: Int? = nil, revokeMessages: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["user_id"] = userId
        parameters["until_date"] = untilDate
        parameters["revoke_messages"] = revokeMessages
        return Request(method: "kickChatMember", body: parameters)
    }

    /// Use this method to unban a previously kicked user in a supergroup or channel. The user will not return to the group or channel automatically, but will be able to join via link, etc. The bot must be an administrator for this to work. By default, this method guarantees that after the call the user is not a member of the chat, but will be able to join it. So if the user is a member of the chat they will also be removed from the chat. If you don’t want this, use the parameter only_if_banned. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target group or username of the target supergroup or channel (in the format @username)
    /// - parameter userId:  Unique identifier of the target user
    /// - parameter onlyIfBanned:  Do nothing if the user is not banned
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func unbanChatMember(chatId: ChatId, userId: Int, onlyIfBanned: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["user_id"] = userId
        parameters["only_if_banned"] = onlyIfBanned
        return Request(method: "unbanChatMember", body: parameters)
    }

    /// Use this method to restrict a user in a supergroup. The bot must be an administrator in the supergroup for this to work and must have the appropriate admin rights. Pass True for all permissions to lift restrictions from a user. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
    /// - parameter userId:  Unique identifier of the target user
    /// - parameter permissions:  A JSON-serialized object for new user permissions
    /// - parameter untilDate:  Date when restrictions will be lifted for the user, unix time. If user is restricted for more than 366 days or less than 30 seconds from the current time, they are considered to be restricted forever
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func restrictChatMember(chatId: ChatId, userId: Int, permissions: ChatPermissions, untilDate: Int? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["user_id"] = userId
        parameters["permissions"] = permissions
        parameters["until_date"] = untilDate
        return Request(method: "restrictChatMember", body: parameters)
    }

    /// Use this method to promote or demote a user in a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Pass False for all boolean parameters to demote a user. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter userId:  Unique identifier of the target user
    /// - parameter isAnonymous:  Pass True, if the administrator’s presence in the chat is hidden
    /// - parameter canManageChat:  Pass True, if the administrator can access the chat event log, chat statistics, message statistics in channels, see channel members, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
    /// - parameter canPostMessages:  Pass True, if the administrator can create channel posts, channels only
    /// - parameter canEditMessages:  Pass True, if the administrator can edit messages of other users and can pin messages, channels only
    /// - parameter canDeleteMessages:  Pass True, if the administrator can delete messages of other users
    /// - parameter canManageVoiceChats:  Pass True, if the administrator can manage voice chats
    /// - parameter canRestrictMembers:  Pass True, if the administrator can restrict, ban or unban chat members
    /// - parameter canPromoteMembers:  Pass True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by him)
    /// - parameter canChangeInfo:  Pass True, if the administrator can change chat title, photo and other settings
    /// - parameter canInviteUsers:  Pass True, if the administrator can invite new users to the chat
    /// - parameter canPinMessages:  Pass True, if the administrator can pin messages, supergroups only
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func promoteChatMember(chatId: ChatId, userId: Int, isAnonymous: Bool? = nil, canManageChat: Bool? = nil, canPostMessages: Bool? = nil, canEditMessages: Bool? = nil, canDeleteMessages: Bool? = nil, canManageVoiceChats: Bool? = nil, canRestrictMembers: Bool? = nil, canPromoteMembers: Bool? = nil, canChangeInfo: Bool? = nil, canInviteUsers: Bool? = nil, canPinMessages: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["user_id"] = userId
        parameters["is_anonymous"] = isAnonymous
        parameters["can_manage_chat"] = canManageChat
        parameters["can_post_messages"] = canPostMessages
        parameters["can_edit_messages"] = canEditMessages
        parameters["can_delete_messages"] = canDeleteMessages
        parameters["can_manage_voice_chats"] = canManageVoiceChats
        parameters["can_restrict_members"] = canRestrictMembers
        parameters["can_promote_members"] = canPromoteMembers
        parameters["can_change_info"] = canChangeInfo
        parameters["can_invite_users"] = canInviteUsers
        parameters["can_pin_messages"] = canPinMessages
        return Request(method: "promoteChatMember", body: parameters)
    }

    /// Use this method to set a custom title for an administrator in a supergroup promoted by the bot. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
    /// - parameter userId:  Unique identifier of the target user
    /// - parameter customTitle:  New custom title for the administrator; 0-16 characters, emoji are not allowed
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setChatAdministratorCustomTitle(chatId: ChatId, userId: Int, customTitle: String) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["user_id"] = userId
        parameters["custom_title"] = customTitle
        return Request(method: "setChatAdministratorCustomTitle", body: parameters)
    }

    /// Use this method to set default chat permissions for all members. The bot must be an administrator in the group or a supergroup for this to work and must have the can_restrict_members admin rights. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
    /// - parameter permissions:  New default chat permissions
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setChatPermissions(chatId: ChatId, permissions: ChatPermissions) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["permissions"] = permissions
        return Request(method: "setChatPermissions", body: parameters)
    }

    /// Use this method to generate a new primary invite link for a chat; any previously generated primary link is revoked. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns the new invite link as String on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func exportChatInviteLink(chatId: ChatId) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        return Request(method: "exportChatInviteLink", body: parameters)
    }

    /// Use this method to create an additional invite link for a chat. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. The link can be revoked using the method revokeChatInviteLink. Returns the new invite link as ChatInviteLink object.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter expireDate:  Point in time (Unix timestamp) when the link will expire
    /// - parameter memberLimit:  Maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func createChatInviteLink(chatId: ChatId, expireDate: Int? = nil, memberLimit: Int? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["expire_date"] = expireDate
        parameters["member_limit"] = memberLimit
        return Request(method: "createChatInviteLink", body: parameters)
    }

    /// Use this method to edit a non-primary invite link created by the bot. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns the edited invite link as a ChatInviteLink object.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter inviteLink:  The invite link to edit
    /// - parameter expireDate:  Point in time (Unix timestamp) when the link will expire
    /// - parameter memberLimit:  Maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func editChatInviteLink(chatId: ChatId, inviteLink: String, expireDate: Int? = nil, memberLimit: Int? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["invite_link"] = inviteLink
        parameters["expire_date"] = expireDate
        parameters["member_limit"] = memberLimit
        return Request(method: "editChatInviteLink", body: parameters)
    }

    /// Use this method to revoke an invite link created by the bot. If the primary link is revoked, a new link is automatically generated. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns the revoked invite link as ChatInviteLink object.
    ///
    /// - parameter chatId:  Unique identifier of the target chat or username of the target channel (in the format @channelusername)
    /// - parameter inviteLink:  The invite link to revoke
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func revokeChatInviteLink(chatId: ChatId, inviteLink: String) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["invite_link"] = inviteLink
        return Request(method: "revokeChatInviteLink", body: parameters)
    }

    /// Use this method to set a new profile photo for the chat. Photos can’t be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter photo:  New chat photo, uploaded using multipart/form-data
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setChatPhoto(chatId: ChatId, photo: InputFile) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["photo"] = photo
        return Request(method: "setChatPhoto", body: parameters)
    }

    /// Use this method to delete a chat photo. Photos can’t be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func deleteChatPhoto(chatId: ChatId) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        return Request(method: "deleteChatPhoto", body: parameters)
    }

    /// Use this method to change the title of a chat. Titles can’t be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter title:  New chat title, 1-255 characters
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setChatTitle(chatId: ChatId, title: String) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["title"] = title
        return Request(method: "setChatTitle", body: parameters)
    }

    /// Use this method to change the description of a group, a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate admin rights. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter description:  New chat description, 0-255 characters
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setChatDescription(chatId: ChatId, description: String? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["description"] = description
        return Request(method: "setChatDescription", body: parameters)
    }

    /// Use this method to add a message to the list of pinned messages in a chat. If the chat is not a private chat, the bot must be an administrator in the chat for this to work and must have the ’can_pin_messages’ admin right in a supergroup or ’can_edit_messages’ admin right in a channel. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Identifier of a message to pin
    /// - parameter disableNotification:  Pass True, if it is not necessary to send a notification to all chat members about the new pinned message. Notifications are always disabled in channels and private chats.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func pinChatMessage(chatId: ChatId, messageId: Int, disableNotification: Bool? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["disable_notification"] = disableNotification
        return Request(method: "pinChatMessage", body: parameters)
    }

    /// Use this method to remove a message from the list of pinned messages in a chat. If the chat is not a private chat, the bot must be an administrator in the chat for this to work and must have the ’can_pin_messages’ admin right in a supergroup or ’can_edit_messages’ admin right in a channel. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Identifier of a message to unpin. If not specified, the most recent pinned message (by sending date) will be unpinned.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func unpinChatMessage(chatId: ChatId, messageId: Int? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        return Request(method: "unpinChatMessage", body: parameters)
    }

    /// Use this method to clear the list of pinned messages in a chat. If the chat is not a private chat, the bot must be an administrator in the chat for this to work and must have the ’can_pin_messages’ admin right in a supergroup or ’can_edit_messages’ admin right in a channel. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func unpinAllChatMessages(chatId: ChatId) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        return Request(method: "unpinAllChatMessages", body: parameters)
    }

    /// Use this method for your bot to leave a group, supergroup or channel. Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup or channel (in the format @channelusername)
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func leaveChat(chatId: ChatId) -> Request {
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
    static public func getChat(chatId: ChatId) -> Request {
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
    static public func getChatAdministrators(chatId: ChatId) -> Request {
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
    static public func getChatMembersCount(chatId: ChatId) -> Request {
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
    static public func getChatMember(chatId: ChatId, userId: Int) -> Request {
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
    static public func setChatStickerSet(chatId: ChatId, stickerSetName: String) -> Request {
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
    static public func deleteChatStickerSet(chatId: ChatId) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        return Request(method: "deleteChatStickerSet", body: parameters)
    }

    /// Alternatively, the user can be redirected to the specified Game URL. For this option to work, you must first create a game for your bot via [@Botfather](https://t.me/botfather) and accept the terms. Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
    ///
    /// - parameter callbackQueryId:  Unique identifier for the query to be answered
    /// - parameter text:  Text of the notification. If not specified, nothing will be shown to the user, 0-200 characters
    /// - parameter showAlert:  If true, an alert will be shown by the client instead of a notification at the top of the chat screen. Defaults to false.
    /// - parameter url:  URL that will be opened by the user’s client. If you have created a Game and accepted the conditions via [@Botfather](https://t.me/botfather), specify the URL that opens your game — note that this will only work if the query comes from a callback_game button.Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
    /// - parameter cacheTime:  The maximum amount of time in seconds that the result of the callback query may be cached client-side. Telegram apps will support caching starting in version 3.14. Defaults to 0.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func answerCallbackQuery(callbackQueryId: String, text: String? = nil, showAlert: Bool? = nil, url: String? = nil, cacheTime: Int? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["callback_query_id"] = callbackQueryId
        parameters["text"] = text
        parameters["show_alert"] = showAlert
        parameters["url"] = url
        parameters["cache_time"] = cacheTime
        return Request(method: "answerCallbackQuery", body: parameters)
    }

    /// Use this method to change the list of the bot’s commands. Returns True on success.
    ///
    /// - parameter commands:  A JSON-serialized list of bot commands to be set as the list of the bot’s commands. At most 100 commands can be specified.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setMyCommands(commands: [BotCommand]) -> Request {
        var parameters = [String: Any]()
        parameters["commands"] = commands
        return Request(method: "setMyCommands", body: parameters)
    }

    /// Use this method to get the current list of the bot’s commands. Requires no parameters. Returns Array of BotCommand on success.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getMyCommands() -> Request {
        return Request(method: "getMyCommands", body: [:])
    }

    /// Use this method to edit text and game messages. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
    ///
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the message to edit
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    /// - parameter text:  New text of the message, 1-4096 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the message text. See formatting options for more details.
    /// - parameter entities:  List of special entities that appear in message text, which can be specified instead of parse_mode
    /// - parameter disableWebPagePreview:  Disables link previews for links in this message
    /// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func editMessageText(chatId: ChatId? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, text: String, parseMode: String? = nil, entities: [MessageEntity]? = nil, disableWebPagePreview: Bool? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["inline_message_id"] = inlineMessageId
        parameters["text"] = text
        parameters["parse_mode"] = parseMode
        parameters["entities"] = entities
        parameters["disable_web_page_preview"] = disableWebPagePreview
        parameters["reply_markup"] = replyMarkup
        return Request(method: "editMessageText", body: parameters)
    }

    /// Use this method to edit captions of messages. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
    ///
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the message to edit
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    /// - parameter caption:  New caption of the message, 0-1024 characters after entities parsing
    /// - parameter parseMode:  Mode for parsing entities in the message caption. See formatting options for more details.
    /// - parameter captionEntities:  List of special entities that appear in the caption, which can be specified instead of parse_mode
    /// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func editMessageCaption(chatId: ChatId? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["inline_message_id"] = inlineMessageId
        parameters["caption"] = caption
        parameters["parse_mode"] = parseMode
        parameters["caption_entities"] = captionEntities
        parameters["reply_markup"] = replyMarkup
        return Request(method: "editMessageCaption", body: parameters)
    }

    /// Use this method to edit animation, audio, document, photo, or video messages. If a message is part of a message album, then it can be edited only to an audio for audio albums, only to a document for document albums and to a photo or a video otherwise. When an inline message is edited, a new file can’t be uploaded. Use a previously uploaded file via its file_id or specify a URL. On success, if the edited message was sent by the bot, the edited Message is returned, otherwise True is returned.
    ///
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the message to edit
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    /// - parameter media:  A JSON-serialized object for a new media content of the message
    /// - parameter replyMarkup:  A JSON-serialized object for a new [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func editMessageMedia(chatId: ChatId? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, media: InputMedia, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["inline_message_id"] = inlineMessageId
        parameters["media"] = media
        parameters["reply_markup"] = replyMarkup
        return Request(method: "editMessageMedia", body: parameters)
    }

    /// Use this method to edit only the reply markup of messages. On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
    ///
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the message to edit
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    /// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func editMessageReplyMarkup(chatId: ChatId? = nil, messageId: Int? = nil, inlineMessageId: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["inline_message_id"] = inlineMessageId
        parameters["reply_markup"] = replyMarkup
        return Request(method: "editMessageReplyMarkup", body: parameters)
    }

    /// Use this method to stop a poll which was sent by the bot. On success, the stopped Poll with the final results is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Identifier of the original message with the poll
    /// - parameter replyMarkup:  A JSON-serialized object for a new message [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating).
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func stopPoll(chatId: ChatId, messageId: Int, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["reply_markup"] = replyMarkup
        return Request(method: "stopPoll", body: parameters)
    }

    /// Use this method to delete a message, including service messages, with the following limitations:- A message can only be deleted if it was sent less than 48 hours ago.- A dice message in a private chat can only be deleted if it was sent more than 24 hours ago.- Bots can delete outgoing messages in private chats, groups, and supergroups.- Bots can delete incoming messages in private chats.- Bots granted can_post_messages permissions can delete outgoing messages in channels.- If the bot is an administrator of a group, it can delete any message there.- If the bot has can_delete_messages permission in a supergroup or a channel, it can delete any message there.Returns True on success.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter messageId:  Identifier of the message to delete
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func deleteMessage(chatId: ChatId, messageId: Int) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        return Request(method: "deleteMessage", body: parameters)
    }

    /// Use this method to send static .WEBP or [animated](https://telegram.org/blog/animated-stickers) .TGS stickers. On success, the sent Message is returned.
    ///
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter sticker:  Sticker to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a .WEBP file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  Additional interface options. A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating), [custom reply keyboard](https://core.telegram.org/bots#keyboards), instructions to remove reply keyboard or to force a reply from the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendSticker(chatId: ChatId, sticker: FileOrPath, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: ReplyMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["sticker"] = sticker
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendSticker", body: parameters)
    }

    /// Use this method to get a sticker set. On success, a StickerSet object is returned.
    ///
    /// - parameter name:  Name of the sticker set
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getStickerSet(name: String) -> Request {
        var parameters = [String: Any]()
        parameters["name"] = name
        return Request(method: "getStickerSet", body: parameters)
    }

    /// Use this method to upload a .PNG file with a sticker for later use in createNewStickerSet and addStickerToSet methods (can be used multiple times). Returns the uploaded File on success.
    ///
    /// - parameter userId:  User identifier of sticker file owner
    /// - parameter pngSticker:  PNG image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. More info on Sending Files »
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func uploadStickerFile(userId: Int, pngSticker: InputFile) -> Request {
        var parameters = [String: Any]()
        parameters["user_id"] = userId
        parameters["png_sticker"] = pngSticker
        return Request(method: "uploadStickerFile", body: parameters)
    }

    /// Use this method to create a new sticker set owned by a user. The bot will be able to edit the sticker set thus created. You must use exactly one of the fields png_sticker or tgs_sticker. Returns True on success.
    ///
    /// - parameter userId:  User identifier of created sticker set owner
    /// - parameter name:  Short name of sticker set, to be used in t.me/addstickers/ URLs (e.g., animals). Can contain only english letters, digits and underscores. Must begin with a letter, can’t contain consecutive underscores and must end in “_by_&lt;bot username&gt;”. &lt;bot_username&gt; is case insensitive. 1-64 characters.
    /// - parameter title:  Sticker set title, 1-64 characters
    /// - parameter pngSticker:  PNG image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
    /// - parameter tgsSticker:  TGS animation with the sticker, uploaded using multipart/form-data. See [[https://core.telegram.org/animated_stickers#technical-requirements](https://core.telegram.org/animated_stickers#technical-requirements)](https://core.telegram.org/animated_stickers#technical-requirements) for technical requirements
    /// - parameter emojis:  One or more emoji corresponding to the sticker
    /// - parameter containsMasks:  Pass True, if a set of mask stickers should be created
    /// - parameter maskPosition:  A JSON-serialized object for position where the mask should be placed on faces
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func createNewStickerSet(userId: Int, name: String, title: String, pngSticker: FileOrPath? = nil, tgsSticker: InputFile? = nil, emojis: String, containsMasks: Bool? = nil, maskPosition: MaskPosition? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["user_id"] = userId
        parameters["name"] = name
        parameters["title"] = title
        parameters["png_sticker"] = pngSticker
        parameters["tgs_sticker"] = tgsSticker
        parameters["emojis"] = emojis
        parameters["contains_masks"] = containsMasks
        parameters["mask_position"] = maskPosition
        return Request(method: "createNewStickerSet", body: parameters)
    }

    /// Use this method to add a new sticker to a set created by the bot. You must use exactly one of the fields png_sticker or tgs_sticker. Animated stickers can be added to animated sticker sets and only to them. Animated sticker sets can have up to 50 stickers. Static sticker sets can have up to 120 stickers. Returns True on success.
    ///
    /// - parameter userId:  User identifier of sticker set owner
    /// - parameter name:  Sticker set name
    /// - parameter pngSticker:  PNG image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
    /// - parameter tgsSticker:  TGS animation with the sticker, uploaded using multipart/form-data. See [[https://core.telegram.org/animated_stickers#technical-requirements](https://core.telegram.org/animated_stickers#technical-requirements)](https://core.telegram.org/animated_stickers#technical-requirements) for technical requirements
    /// - parameter emojis:  One or more emoji corresponding to the sticker
    /// - parameter maskPosition:  A JSON-serialized object for position where the mask should be placed on faces
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func addStickerToSet(userId: Int, name: String, pngSticker: FileOrPath? = nil, tgsSticker: InputFile? = nil, emojis: String, maskPosition: MaskPosition? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["user_id"] = userId
        parameters["name"] = name
        parameters["png_sticker"] = pngSticker
        parameters["tgs_sticker"] = tgsSticker
        parameters["emojis"] = emojis
        parameters["mask_position"] = maskPosition
        return Request(method: "addStickerToSet", body: parameters)
    }

    /// Use this method to move a sticker in a set created by the bot to a specific position. Returns True on success.
    ///
    /// - parameter sticker:  File identifier of the sticker
    /// - parameter position:  New sticker position in the set, zero-based
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setStickerPositionInSet(sticker: String, position: Int) -> Request {
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
    static public func deleteStickerFromSet(sticker: String) -> Request {
        var parameters = [String: Any]()
        parameters["sticker"] = sticker
        return Request(method: "deleteStickerFromSet", body: parameters)
    }

    /// Use this method to set the thumbnail of a sticker set. Animated thumbnails can be set for animated sticker sets only. Returns True on success.
    ///
    /// - parameter name:  Sticker set name
    /// - parameter userId:  User identifier of the sticker set owner
    /// - parameter thumb:  A PNG image with the thumbnail, must be up to 128 kilobytes in size and have width and height exactly 100px, or a TGS animation with the thumbnail up to 32 kilobytes in size; see [[https://core.telegram.org/animated_stickers#technical-requirements](https://core.telegram.org/animated_stickers#technical-requirements)](https://core.telegram.org/animated_stickers#technical-requirements) for animated sticker technical requirements. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files ». Animated sticker set thumbnail can’t be uploaded via HTTP URL.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setStickerSetThumb(name: String, userId: Int, thumb: FileOrPath? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["name"] = name
        parameters["user_id"] = userId
        parameters["thumb"] = thumb
        return Request(method: "setStickerSetThumb", body: parameters)
    }

    /// Use this method to send answers to an inline query. On success, True is returned.No more than 50 results per query are allowed.
    ///
    /// - parameter inlineQueryId:  Unique identifier for the answered query
    /// - parameter results:  A JSON-serialized array of results for the inline query
    /// - parameter cacheTime:  The maximum amount of time in seconds that the result of the inline query may be cached on the server. Defaults to 300.
    /// - parameter isPersonal:  Pass True, if results may be cached on the server side only for the user that sent the query. By default, results may be returned to any user who sends the same query
    /// - parameter nextOffset:  Pass the offset that a client should send in the next query with the same text to receive more results. Pass an empty string if there are no more results or if you don’t support pagination. Offset length can’t exceed 64 bytes.
    /// - parameter switchPmText:  If passed, clients will display a button with specified text that switches the user to a private chat with the bot and sends the bot a start message with the parameter switch_pm_parameter
    /// - parameter switchPmParameter:  Deep-linking parameter for the /start message sent to the bot when user presses the switch button. 1-64 characters, only A-Z, a-z, 0-9, _ and - are allowed.Example: An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a ’Connect your YouTube account’ button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an oauth link. Once done, the bot can offer a switch_inline button so that the user can easily return to the chat where they wanted to use the bot’s inline capabilities.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func answerInlineQuery(inlineQueryId: String, results: [InlineQueryResult], cacheTime: Int? = nil, isPersonal: Bool? = nil, nextOffset: String? = nil, switchPmText: String? = nil, switchPmParameter: String? = nil) -> Request {
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
    /// - parameter chatId:  Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    /// - parameter title:  Product name, 1-32 characters
    /// - parameter description:  Product description, 1-255 characters
    /// - parameter payload:  Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use for your internal processes.
    /// - parameter providerToken:  Payments provider token, obtained via [Botfather](https://t.me/botfather)
    /// - parameter currency:  Three-letter ISO 4217 currency code, see more on currencies
    /// - parameter prices:  Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
    /// - parameter maxTipAmount:  The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0
    /// - parameter suggestedTipAmounts:  A JSON-serialized array of suggested amounts of tips in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
    /// - parameter startParameter:  Unique deep-linking parameter. If left empty, forwarded copies of the sent message will have a Pay button, allowing multiple users to pay directly from the forwarded message, using the same invoice. If non-empty, forwarded copies of the sent message will have a URL button with a deep link to the bot (instead of a Pay button), with the value used as the start parameter
    /// - parameter providerData:  A JSON-serialized data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.
    /// - parameter photoUrl:  URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.
    /// - parameter photoSize:  Photo size
    /// - parameter photoWidth:  Photo width
    /// - parameter photoHeight:  Photo height
    /// - parameter needName:  Pass True, if you require the user’s full name to complete the order
    /// - parameter needPhoneNumber:  Pass True, if you require the user’s phone number to complete the order
    /// - parameter needEmail:  Pass True, if you require the user’s email address to complete the order
    /// - parameter needShippingAddress:  Pass True, if you require the user’s shipping address to complete the order
    /// - parameter sendPhoneNumberToProvider:  Pass True, if user’s phone number should be sent to provider
    /// - parameter sendEmailToProvider:  Pass True, if user’s email address should be sent to provider
    /// - parameter isFlexible:  Pass True, if the final price depends on the shipping method
    /// - parameter disableNotification:  Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.
    /// - parameter replyToMessageId:  If the message is a reply, ID of the original message
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating). If empty, one ’Pay total price’ button will be shown. If not empty, the first button must be a Pay button.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendInvoice(chatId: ChatId, title: String, description: String, payload: String, providerToken: String, currency: String, prices: [LabeledPrice], maxTipAmount: Int? = nil, suggestedTipAmounts: [Int]? = nil, startParameter: String? = nil, providerData: String? = nil, photoUrl: String? = nil, photoSize: Int? = nil, photoWidth: Int? = nil, photoHeight: Int? = nil, needName: Bool? = nil, needPhoneNumber: Bool? = nil, needEmail: Bool? = nil, needShippingAddress: Bool? = nil, sendPhoneNumberToProvider: Bool? = nil, sendEmailToProvider: Bool? = nil, isFlexible: Bool? = nil, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["title"] = title
        parameters["description"] = description
        parameters["payload"] = payload
        parameters["provider_token"] = providerToken
        parameters["currency"] = currency
        parameters["prices"] = prices
        parameters["max_tip_amount"] = maxTipAmount
        parameters["suggested_tip_amounts"] = suggestedTipAmounts
        parameters["start_parameter"] = startParameter
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
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendInvoice", body: parameters)
    }

    /// If you sent an invoice requesting a shipping address and the parameter is_flexible was specified, the Bot API will send an Update with a shipping_query field to the bot. Use this method to reply to shipping queries. On success, True is returned.
    ///
    /// - parameter shippingQueryId:  Unique identifier for the query to be answered
    /// - parameter ok:  Specify True if delivery to the specified address is possible and False if there are any problems (for example, if delivery to the specified address is not possible)
    /// - parameter shippingOptions:  Required if ok is True. A JSON-serialized array of available shipping options.
    /// - parameter errorMessage:  Required if ok is False. Error message in human readable form that explains why it is impossible to complete the order (e.g. &quot;Sorry, delivery to your desired address is unavailable’). Telegram will display this message to the user.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func answerShippingQuery(shippingQueryId: String, ok: Bool, shippingOptions: [ShippingOption]? = nil, errorMessage: String? = nil) -> Request {
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
    static public func answerPreCheckoutQuery(preCheckoutQueryId: String, ok: Bool, errorMessage: String? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["pre_checkout_query_id"] = preCheckoutQueryId
        parameters["ok"] = ok
        parameters["error_message"] = errorMessage
        return Request(method: "answerPreCheckoutQuery", body: parameters)
    }

    /// Use this if the data submitted by the user doesn’t satisfy the standards your service requires for any reason. For example, if a birthday date seems invalid, a submitted document is blurry, a scan shows evidence of tampering, etc. Supply some details in the error message to make sure the user knows how to correct the issues.
    ///
    /// - parameter userId:  User identifier
    /// - parameter errors:  A JSON-serialized array describing the errors
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func setPassportDataErrors(userId: Int, errors: [PassportElementError]) -> Request {
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
    /// - parameter allowSendingWithoutReply:  Pass True, if the message should be sent even if the specified replied-to message is not found
    /// - parameter replyMarkup:  A JSON-serialized object for an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating). If empty, one ’Play game_title’ button will be shown. If not empty, the first button must launch the game.
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func sendGame(chatId: Int, gameShortName: String, disableNotification: Bool? = nil, replyToMessageId: Int? = nil, allowSendingWithoutReply: Bool? = nil, replyMarkup: InlineKeyboardMarkup? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["chat_id"] = chatId
        parameters["game_short_name"] = gameShortName
        parameters["disable_notification"] = disableNotification
        parameters["reply_to_message_id"] = replyToMessageId
        parameters["allow_sending_without_reply"] = allowSendingWithoutReply
        parameters["reply_markup"] = replyMarkup
        return Request(method: "sendGame", body: parameters)
    }

    /// Use this method to set the score of the specified user in a game. On success, if the message was sent by the bot, returns the edited Message, otherwise returns True. Returns an error, if the new score is not greater than the user’s current score in the chat and force is False.
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
    static public func setGameScore(userId: Int, score: Int, force: Bool? = nil, disableEditMessage: Bool? = nil, chatId: Int? = nil, messageId: Int? = nil, inlineMessageId: String? = nil) -> Request {
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

    /// This method will currently return scores for the target user, plus two of their closest neighbors on each side. Will also return the top three users if the user and his neighbors are not among them. Please note that this behavior is subject to change.
    ///
    /// - parameter userId:  Target user id
    /// - parameter chatId:  Required if inline_message_id is not specified. Unique identifier for the target chat
    /// - parameter messageId:  Required if inline_message_id is not specified. Identifier of the sent message
    /// - parameter inlineMessageId:  Required if chat_id and message_id are not specified. Identifier of the inline message
    ///
    /// - returns: The new `TelegramAPI.Request` instance.
    ///
    static public func getGameHighScores(userId: Int, chatId: Int? = nil, messageId: Int? = nil, inlineMessageId: String? = nil) -> Request {
        var parameters = [String: Any]()
        parameters["user_id"] = userId
        parameters["chat_id"] = chatId
        parameters["message_id"] = messageId
        parameters["inline_message_id"] = inlineMessageId
        return Request(method: "getGameHighScores", body: parameters)
    }

}
