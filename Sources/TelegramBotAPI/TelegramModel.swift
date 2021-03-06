//
//  TelegramModel.swift
//  TelegramAPI
//
//  Created by Tbxark on 2021/06/17.
//  Copyright © 2018 Tbxark. All rights reserved.
//

import Foundation

extension TelegramAPI {

    /// Telegram Request wrapper
    /// Authorizing your bot
    ///
    /// Each bot is given a unique authentication token when it is created. The token looks something like 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11, but we'll use simply <token> in this document instead. You can learn about obtaining tokens and generating new ones in this document.
    ///
    /// Making requests
    ///
    /// All queries to the Telegram Bot API must be served over HTTPS and need to be presented in this form: https://api.telegram.org/bot<token>/METHOD_NAME. Like this for example:
    ///
    /// https://api.telegram.org/bot123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11/getMe
    /// We support GET and POST HTTP methods. We support four ways of passing parameters in Bot API requests:
    ///
    /// URL query string
    /// application/x-www-form-urlencoded
    /// application/json (except for uploading files)
    /// multipart/form-data (use to upload files)
    /// The response contains a JSON object, which always has a Boolean field 'ok' and may have an optional String field 'description' with a human-readable description of the result. If 'ok' equals true, the request was successful and the result of the query can be found in the 'result' field. In case of an unsuccessful request, 'ok' equals false and the error is explained in the 'description'. An Integer 'error_code' field is also returned, but its contents are subject to change in the future. Some errors may also have an optional field 'parameters' of the type ResponseParameters, which can help to automatically handle the error.
    ///
    /// All methods in the Bot API are case-insensitive.
    /// All queries must be made using UTF-8.
    /// Making requests when getting updates
    /// If you're using webhooks, you can perform a request to the Bot API while sending an answer to the webhook. Use either application/json or application/x-www-form-urlencoded or multipart/form-data response content type for passing parameters. Specify the method to be invoked in the method parameter of the request. It's not possible to know that such a request was successful or get its result.
    ///
    /// Please see our FAQ for examples.
    public struct Request {
        public let method: String
        public let body: [String: Any]

        public func jsonRequest(token: String) throws -> URLRequest {
            let urlRaw = "https://api.telegram.org/bot\(token)/\(method)"
            guard let url = URL(string: urlRaw) else {
                throw NSError.init(domain: "com.tbxark.TelegramBotAPI",
                                   code: -1,
                                   userInfo: [NSLocalizedFailureReasonErrorKey: "URL(\(urlRaw) is illegal"])
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            req.httpBody = try AnyEncodable.encode(body)
            return req
        }

    }

    /// AnyEncodable
    public struct AnyEncodable: Encodable {
        private let encodable: Encodable

        public init(_ encodable: Encodable) {
            self.encodable = encodable
        }

        public func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }

        public static func encode(_ dict: [String: Any]) throws -> Data {
            var map = [String: AnyEncodable]()
            for (k, v) in dict {
                if let e = v as? Encodable {
                    map[k] = AnyEncodable(e)
                }
            }
            let data = try JSONEncoder().encode(map)
            return data
        }
    }

    /// May contain two different types
    public enum Either<A: Codable, B: Codable>: Codable {
        case left(A)
        case right(B)

        public var value: Any {
            switch self {
            case .left(let a):
                return a
            case .right(let b):
                return b
            }
        }

        public var left: A? {
            switch self {
            case .left(let a):
                return a
            case .right:
                return nil
            }
        }

        public var right: B? {
            switch self {
            case .left:
                return nil
            case .right(let b):
                return b
            }
        }

        public init(_ a: A) {
            self = .left(a)
        }

        public init(_ b: B) {
            self = .right(b)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let a = try? container.decode(A.self) {
                self = .left(a)
            } else {
                let b = try container.decode(B.self)
                self = .right(b)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .left(let a):
                    try container.encode(a)
                case .right(let b):
                    try container.encode(b)
            }
        }
    }

    /// ReplyMarkup: InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply
    public enum ReplyMarkup: Codable {

        case inlineKeyboardMarkup(InlineKeyboardMarkup)
        case replyKeyboardMarkup(ReplyKeyboardMarkup)
        case replyKeyboardRemove(ReplyKeyboardRemove)
        case forceReply(ForceReply)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let inlineKeyboardMarkup = try? container.decode(InlineKeyboardMarkup.self) {
                self = .inlineKeyboardMarkup(inlineKeyboardMarkup)
            } else if let replyKeyboardMarkup = try? container.decode(ReplyKeyboardMarkup.self) {
                self = .replyKeyboardMarkup(replyKeyboardMarkup)
            } else if let replyKeyboardRemove = try? container.decode(ReplyKeyboardRemove.self) {
                self = .replyKeyboardRemove(replyKeyboardRemove)
            } else if let forceReply = try? container.decode(ForceReply.self) {
                self = .forceReply(forceReply)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "ReplyMarkup"])
            }
        }

        public init(_ inlineKeyboardMarkup: InlineKeyboardMarkup) {
            self = .inlineKeyboardMarkup(inlineKeyboardMarkup)
        }

        public init(_ replyKeyboardMarkup: ReplyKeyboardMarkup) {
            self = .replyKeyboardMarkup(replyKeyboardMarkup)
        }

        public init(_ replyKeyboardRemove: ReplyKeyboardRemove) {
            self = .replyKeyboardRemove(replyKeyboardRemove)
        }

        public init(_ forceReply: ForceReply) {
            self = .forceReply(forceReply)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .inlineKeyboardMarkup(let inlineKeyboardMarkup):
                try container.encode(inlineKeyboardMarkup)
            case .replyKeyboardMarkup(let replyKeyboardMarkup):
                try container.encode(replyKeyboardMarkup)
            case .replyKeyboardRemove(let replyKeyboardRemove):
                try container.encode(replyKeyboardRemove)
            case .forceReply(let forceReply):
                try container.encode(forceReply)
            }
        }
    }

    /// ChatId: Int or String
    public enum ChatId: Codable {

        case int(Int)
        case string(String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let int = try? container.decode(Int.self) {
                self = .int(int)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "ChatId"])
            }
        }

        public init(_ int: Int) {
            self = .int(int)
        }

        public init(_ string: String) {
            self = .string(string)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let int):
                try container.encode(int)
            case .string(let string):
                try container.encode(string)
            }
        }
    }

    /// FileOrPath: InputFile or String
    public enum FileOrPath: Codable {

        case inputFile(InputFile)
        case string(String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let inputFile = try? container.decode(InputFile.self) {
                self = .inputFile(inputFile)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "FileOrPath"])
            }
        }

        public init(_ inputFile: InputFile) {
            self = .inputFile(inputFile)
        }

        public init(_ string: String) {
            self = .string(string)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .inputFile(let inputFile):
                try container.encode(inputFile)
            case .string(let string):
                try container.encode(string)
            }
        }
    }

    /// This object represents an incoming update.At most one of the optional parameters can be present in any given update.
    public class Update: Codable {

        /// The update’s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
        public var updateId: Int

        /// Optional. New incoming message of any kind — text, photo, sticker, etc.
        public var message: Message?

        /// Optional. New version of a message that is known to the bot and was edited
        public var editedMessage: Message?

        /// Optional. New incoming channel post of any kind — text, photo, sticker, etc.
        public var channelPost: Message?

        /// Optional. New version of a channel post that is known to the bot and was edited
        public var editedChannelPost: Message?

        /// Optional. New incoming inline query
        public var inlineQuery: InlineQuery?

        /// Optional. The result of an inline query that was chosen by a user and sent to their chat partner. Please see our documentation on the feedback collecting for details on how to enable these updates for your bot.
        public var chosenInlineResult: ChosenInlineResult?

        /// Optional. New incoming callback query
        public var callbackQuery: CallbackQuery?

        /// Optional. New incoming shipping query. Only for invoices with flexible price
        public var shippingQuery: ShippingQuery?

        /// Optional. New incoming pre-checkout query. Contains full information about checkout
        public var preCheckoutQuery: PreCheckoutQuery?

        /// Optional. New poll state. Bots receive only updates about stopped polls and polls, which are sent by the bot
        public var poll: Poll?

        /// Optional. A user changed their answer in a non-anonymous poll. Bots receive new votes only in polls that were sent by the bot itself.
        public var pollAnswer: PollAnswer?

        /// Optional. The bot’s chat member status was updated in a chat. For private chats, this update is received only when the bot is blocked or unblocked by the user.
        public var myChatMember: ChatMemberUpdated?

        /// Optional. A chat member’s status was updated in a chat. The bot must be an administrator in the chat and must explicitly specify “chat_member” in the list of allowed_updates to receive these updates.
        public var chatMember: ChatMemberUpdated?

        /// Update initialization
        ///
        /// - parameter updateId:  The update’s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
        /// - parameter message:  Optional. New incoming message of any kind — text, photo, sticker, etc.
        /// - parameter editedMessage:  Optional. New version of a message that is known to the bot and was edited
        /// - parameter channelPost:  Optional. New incoming channel post of any kind — text, photo, sticker, etc.
        /// - parameter editedChannelPost:  Optional. New version of a channel post that is known to the bot and was edited
        /// - parameter inlineQuery:  Optional. New incoming inline query
        /// - parameter chosenInlineResult:  Optional. The result of an inline query that was chosen by a user and sent to their chat partner. Please see our documentation on the feedback collecting for details on how to enable these updates for your bot.
        /// - parameter callbackQuery:  Optional. New incoming callback query
        /// - parameter shippingQuery:  Optional. New incoming shipping query. Only for invoices with flexible price
        /// - parameter preCheckoutQuery:  Optional. New incoming pre-checkout query. Contains full information about checkout
        /// - parameter poll:  Optional. New poll state. Bots receive only updates about stopped polls and polls, which are sent by the bot
        /// - parameter pollAnswer:  Optional. A user changed their answer in a non-anonymous poll. Bots receive new votes only in polls that were sent by the bot itself.
        /// - parameter myChatMember:  Optional. The bot’s chat member status was updated in a chat. For private chats, this update is received only when the bot is blocked or unblocked by the user.
        /// - parameter chatMember:  Optional. A chat member’s status was updated in a chat. The bot must be an administrator in the chat and must explicitly specify “chat_member” in the list of allowed_updates to receive these updates.
        ///
        /// - returns: The new `Update` instance.
        ///
        public init(updateId: Int, message: Message? = nil, editedMessage: Message? = nil, channelPost: Message? = nil, editedChannelPost: Message? = nil, inlineQuery: InlineQuery? = nil, chosenInlineResult: ChosenInlineResult? = nil, callbackQuery: CallbackQuery? = nil, shippingQuery: ShippingQuery? = nil, preCheckoutQuery: PreCheckoutQuery? = nil, poll: Poll? = nil, pollAnswer: PollAnswer? = nil, myChatMember: ChatMemberUpdated? = nil, chatMember: ChatMemberUpdated? = nil) {
            self.updateId = updateId
            self.message = message
            self.editedMessage = editedMessage
            self.channelPost = channelPost
            self.editedChannelPost = editedChannelPost
            self.inlineQuery = inlineQuery
            self.chosenInlineResult = chosenInlineResult
            self.callbackQuery = callbackQuery
            self.shippingQuery = shippingQuery
            self.preCheckoutQuery = preCheckoutQuery
            self.poll = poll
            self.pollAnswer = pollAnswer
            self.myChatMember = myChatMember
            self.chatMember = chatMember
        }

        private enum CodingKeys: String, CodingKey {
            case updateId = "update_id"
            case message = "message"
            case editedMessage = "edited_message"
            case channelPost = "channel_post"
            case editedChannelPost = "edited_channel_post"
            case inlineQuery = "inline_query"
            case chosenInlineResult = "chosen_inline_result"
            case callbackQuery = "callback_query"
            case shippingQuery = "shipping_query"
            case preCheckoutQuery = "pre_checkout_query"
            case poll = "poll"
            case pollAnswer = "poll_answer"
            case myChatMember = "my_chat_member"
            case chatMember = "chat_member"
        }

    }

    /// Contains information about the current status of a webhook.
    public class WebhookInfo: Codable {

        /// Webhook URL, may be empty if webhook is not set up
        public var url: String

        /// True, if a custom certificate was provided for webhook certificate checks
        public var hasCustomCertificate: Bool

        /// Number of updates awaiting delivery
        public var pendingUpdateCount: Int

        /// Optional. Currently used webhook IP address
        public var ipAddress: String?

        /// Optional. Unix time for the most recent error that happened when trying to deliver an update via webhook
        public var lastErrorDate: Int?

        /// Optional. Error message in human-readable format for the most recent error that happened when trying to deliver an update via webhook
        public var lastErrorMessage: String?

        /// Optional. Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
        public var maxConnections: Int?

        /// Optional. A list of update types the bot is subscribed to. Defaults to all update types except chat_member
        public var allowedUpdates: [String]?

        /// WebhookInfo initialization
        ///
        /// - parameter url:  Webhook URL, may be empty if webhook is not set up
        /// - parameter hasCustomCertificate:  True, if a custom certificate was provided for webhook certificate checks
        /// - parameter pendingUpdateCount:  Number of updates awaiting delivery
        /// - parameter ipAddress:  Optional. Currently used webhook IP address
        /// - parameter lastErrorDate:  Optional. Unix time for the most recent error that happened when trying to deliver an update via webhook
        /// - parameter lastErrorMessage:  Optional. Error message in human-readable format for the most recent error that happened when trying to deliver an update via webhook
        /// - parameter maxConnections:  Optional. Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
        /// - parameter allowedUpdates:  Optional. A list of update types the bot is subscribed to. Defaults to all update types except chat_member
        ///
        /// - returns: The new `WebhookInfo` instance.
        ///
        public init(url: String, hasCustomCertificate: Bool, pendingUpdateCount: Int, ipAddress: String? = nil, lastErrorDate: Int? = nil, lastErrorMessage: String? = nil, maxConnections: Int? = nil, allowedUpdates: [String]? = nil) {
            self.url = url
            self.hasCustomCertificate = hasCustomCertificate
            self.pendingUpdateCount = pendingUpdateCount
            self.ipAddress = ipAddress
            self.lastErrorDate = lastErrorDate
            self.lastErrorMessage = lastErrorMessage
            self.maxConnections = maxConnections
            self.allowedUpdates = allowedUpdates
        }

        private enum CodingKeys: String, CodingKey {
            case url = "url"
            case hasCustomCertificate = "has_custom_certificate"
            case pendingUpdateCount = "pending_update_count"
            case ipAddress = "ip_address"
            case lastErrorDate = "last_error_date"
            case lastErrorMessage = "last_error_message"
            case maxConnections = "max_connections"
            case allowedUpdates = "allowed_updates"
        }

    }

    /// This object represents a Telegram user or bot.
    public class User: Codable {

        /// Unique identifier for this user or bot. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
        public var id: Int

        /// True, if this user is a bot
        public var isBot: Bool

        /// User’s or bot’s first name
        public var firstName: String

        /// Optional. User’s or bot’s last name
        public var lastName: String?

        /// Optional. User’s or bot’s username
        public var username: String?

        /// Optional. [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) of the user’s language
        public var languageCode: String?

        /// Optional. True, if the bot can be invited to groups. Returned only in getMe.
        public var canJoinGroups: Bool?

        /// Optional. True, if [privacy mode](https://core.telegram.org/bots#privacy-mode) is disabled for the bot. Returned only in getMe.
        public var canReadAllGroupMessages: Bool?

        /// Optional. True, if the bot supports inline queries. Returned only in getMe.
        public var supportsInlineQueries: Bool?

        /// User initialization
        ///
        /// - parameter id:  Unique identifier for this user or bot. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter isBot:  True, if this user is a bot
        /// - parameter firstName:  User’s or bot’s first name
        /// - parameter lastName:  Optional. User’s or bot’s last name
        /// - parameter username:  Optional. User’s or bot’s username
        /// - parameter languageCode:  Optional. [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) of the user’s language
        /// - parameter canJoinGroups:  Optional. True, if the bot can be invited to groups. Returned only in getMe.
        /// - parameter canReadAllGroupMessages:  Optional. True, if [privacy mode](https://core.telegram.org/bots#privacy-mode) is disabled for the bot. Returned only in getMe.
        /// - parameter supportsInlineQueries:  Optional. True, if the bot supports inline queries. Returned only in getMe.
        ///
        /// - returns: The new `User` instance.
        ///
        public init(id: Int, isBot: Bool, firstName: String, lastName: String? = nil, username: String? = nil, languageCode: String? = nil, canJoinGroups: Bool? = nil, canReadAllGroupMessages: Bool? = nil, supportsInlineQueries: Bool? = nil) {
            self.id = id
            self.isBot = isBot
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.languageCode = languageCode
            self.canJoinGroups = canJoinGroups
            self.canReadAllGroupMessages = canReadAllGroupMessages
            self.supportsInlineQueries = supportsInlineQueries
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case isBot = "is_bot"
            case firstName = "first_name"
            case lastName = "last_name"
            case username = "username"
            case languageCode = "language_code"
            case canJoinGroups = "can_join_groups"
            case canReadAllGroupMessages = "can_read_all_group_messages"
            case supportsInlineQueries = "supports_inline_queries"
        }

    }

    /// This object represents a chat.
    public class Chat: Codable {

        /// Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        public var id: Int

        /// Type of chat, can be either “private”, “group”, “supergroup” or “channel”
        public var type: String

        /// Optional. Title, for supergroups, channels and group chats
        public var title: String?

        /// Optional. Username, for private chats, supergroups and channels if available
        public var username: String?

        /// Optional. First name of the other party in a private chat
        public var firstName: String?

        /// Optional. Last name of the other party in a private chat
        public var lastName: String?

        /// Optional. Chat photo. Returned only in getChat.
        public var photo: ChatPhoto?

        /// Optional. Bio of the other party in a private chat. Returned only in getChat.
        public var bio: String?

        /// Optional. Description, for groups, supergroups and channel chats. Returned only in getChat.
        public var description: String?

        /// Optional. Primary invite link, for groups, supergroups and channel chats. Returned only in getChat.
        public var inviteLink: String?

        /// Optional. The most recent pinned message (by sending date). Returned only in getChat.
        public var pinnedMessage: Message?

        /// Optional. Default chat member permissions, for groups and supergroups. Returned only in getChat.
        public var permissions: ChatPermissions?

        /// Optional. For supergroups, the minimum allowed delay between consecutive messages sent by each unpriviledged user. Returned only in getChat.
        public var slowModeDelay: Int?

        /// Optional. The time after which all messages sent to the chat will be automatically deleted; in seconds. Returned only in getChat.
        public var messageAutoDeleteTime: Int?

        /// Optional. For supergroups, name of group sticker set. Returned only in getChat.
        public var stickerSetName: String?

        /// Optional. True, if the bot can change the group sticker set. Returned only in getChat.
        public var canSetStickerSet: Bool?

        /// Optional. Unique identifier for the linked chat, i.e. the discussion group identifier for a channel and vice versa; for supergroups and channel chats. This identifier may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier. Returned only in getChat.
        public var linkedChatId: Int?

        /// Optional. For supergroups, the location to which the supergroup is connected. Returned only in getChat.
        public var location: ChatLocation?

        /// Chat initialization
        ///
        /// - parameter id:  Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter type:  Type of chat, can be either “private”, “group”, “supergroup” or “channel”
        /// - parameter title:  Optional. Title, for supergroups, channels and group chats
        /// - parameter username:  Optional. Username, for private chats, supergroups and channels if available
        /// - parameter firstName:  Optional. First name of the other party in a private chat
        /// - parameter lastName:  Optional. Last name of the other party in a private chat
        /// - parameter photo:  Optional. Chat photo. Returned only in getChat.
        /// - parameter bio:  Optional. Bio of the other party in a private chat. Returned only in getChat.
        /// - parameter description:  Optional. Description, for groups, supergroups and channel chats. Returned only in getChat.
        /// - parameter inviteLink:  Optional. Primary invite link, for groups, supergroups and channel chats. Returned only in getChat.
        /// - parameter pinnedMessage:  Optional. The most recent pinned message (by sending date). Returned only in getChat.
        /// - parameter permissions:  Optional. Default chat member permissions, for groups and supergroups. Returned only in getChat.
        /// - parameter slowModeDelay:  Optional. For supergroups, the minimum allowed delay between consecutive messages sent by each unpriviledged user. Returned only in getChat.
        /// - parameter messageAutoDeleteTime:  Optional. The time after which all messages sent to the chat will be automatically deleted; in seconds. Returned only in getChat.
        /// - parameter stickerSetName:  Optional. For supergroups, name of group sticker set. Returned only in getChat.
        /// - parameter canSetStickerSet:  Optional. True, if the bot can change the group sticker set. Returned only in getChat.
        /// - parameter linkedChatId:  Optional. Unique identifier for the linked chat, i.e. the discussion group identifier for a channel and vice versa; for supergroups and channel chats. This identifier may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier. Returned only in getChat.
        /// - parameter location:  Optional. For supergroups, the location to which the supergroup is connected. Returned only in getChat.
        ///
        /// - returns: The new `Chat` instance.
        ///
        public init(id: Int, type: String, title: String? = nil, username: String? = nil, firstName: String? = nil, lastName: String? = nil, photo: ChatPhoto? = nil, bio: String? = nil, description: String? = nil, inviteLink: String? = nil, pinnedMessage: Message? = nil, permissions: ChatPermissions? = nil, slowModeDelay: Int? = nil, messageAutoDeleteTime: Int? = nil, stickerSetName: String? = nil, canSetStickerSet: Bool? = nil, linkedChatId: Int? = nil, location: ChatLocation? = nil) {
            self.id = id
            self.type = type
            self.title = title
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
            self.photo = photo
            self.bio = bio
            self.description = description
            self.inviteLink = inviteLink
            self.pinnedMessage = pinnedMessage
            self.permissions = permissions
            self.slowModeDelay = slowModeDelay
            self.messageAutoDeleteTime = messageAutoDeleteTime
            self.stickerSetName = stickerSetName
            self.canSetStickerSet = canSetStickerSet
            self.linkedChatId = linkedChatId
            self.location = location
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case type = "type"
            case title = "title"
            case username = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case photo = "photo"
            case bio = "bio"
            case description = "description"
            case inviteLink = "invite_link"
            case pinnedMessage = "pinned_message"
            case permissions = "permissions"
            case slowModeDelay = "slow_mode_delay"
            case messageAutoDeleteTime = "message_auto_delete_time"
            case stickerSetName = "sticker_set_name"
            case canSetStickerSet = "can_set_sticker_set"
            case linkedChatId = "linked_chat_id"
            case location = "location"
        }

    }

    /// This object represents a message.
    public class Message: Codable {

        /// Unique message identifier inside this chat
        public var messageId: Int

        /// Optional. Sender, empty for messages sent to channels
        public var from: User?

        /// Optional. Sender of the message, sent on behalf of a chat. The channel itself for channel messages. The supergroup itself for messages from anonymous group administrators. The linked channel for messages automatically forwarded to the discussion group
        public var senderChat: Chat?

        /// Date the message was sent in Unix time
        public var date: Int

        /// Conversation the message belongs to
        public var chat: Chat

        /// Optional. For forwarded messages, sender of the original message
        public var forwardFrom: User?

        /// Optional. For messages forwarded from channels or from anonymous administrators, information about the original sender chat
        public var forwardFromChat: Chat?

        /// Optional. For messages forwarded from channels, identifier of the original message in the channel
        public var forwardFromMessageId: Int?

        /// Optional. For messages forwarded from channels, signature of the post author if present
        public var forwardSignature: String?

        /// Optional. Sender’s name for messages forwarded from users who disallow adding a link to their account in forwarded messages
        public var forwardSenderName: String?

        /// Optional. For forwarded messages, date the original message was sent in Unix time
        public var forwardDate: Int?

        /// Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
        public var replyToMessage: Message?

        /// Optional. Bot through which the message was sent
        public var viaBot: User?

        /// Optional. Date the message was last edited in Unix time
        public var editDate: Int?

        /// Optional. The unique identifier of a media message group this message belongs to
        public var mediaGroupId: String?

        /// Optional. Signature of the post author for messages in channels, or the custom title of an anonymous group administrator
        public var authorSignature: String?

        /// Optional. For text messages, the actual UTF-8 text of the message, 0-4096 characters
        public var text: String?

        /// Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
        public var entities: [MessageEntity]?

        /// Optional. Message is an animation, information about the animation. For backward compatibility, when this field is set, the document field will also be set
        public var animation: Animation?

        /// Optional. Message is an audio file, information about the file
        public var audio: Audio?

        /// Optional. Message is a general file, information about the file
        public var document: Document?

        /// Optional. Message is a photo, available sizes of the photo
        public var photo: [PhotoSize]?

        /// Optional. Message is a sticker, information about the sticker
        public var sticker: Sticker?

        /// Optional. Message is a video, information about the video
        public var video: Video?

        /// Optional. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message
        public var videoNote: VideoNote?

        /// Optional. Message is a voice message, information about the file
        public var voice: Voice?

        /// Optional. Caption for the animation, audio, document, photo, video or voice, 0-1024 characters
        public var caption: String?

        /// Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
        public var captionEntities: [MessageEntity]?

        /// Optional. Message is a shared contact, information about the contact
        public var contact: Contact?

        /// Optional. Message is a dice with random value
        public var dice: Dice?

        /// Optional. Message is a game, information about the game. More about games »
        public var game: Game?

        /// Optional. Message is a native poll, information about the poll
        public var poll: Poll?

        /// Optional. Message is a venue, information about the venue. For backward compatibility, when this field is set, the location field will also be set
        public var venue: Venue?

        /// Optional. Message is a shared location, information about the location
        public var location: Location?

        /// Optional. New members that were added to the group or supergroup and information about them (the bot itself may be one of these members)
        public var newChatMembers: [User]?

        /// Optional. A member was removed from the group, information about them (this member may be the bot itself)
        public var leftChatMember: User?

        /// Optional. A chat title was changed to this value
        public var newChatTitle: String?

        /// Optional. A chat photo was change to this value
        public var newChatPhoto: [PhotoSize]?

        /// Optional. Service message: the chat photo was deleted
        public var deleteChatPhoto: Bool?

        /// Optional. Service message: the group has been created
        public var groupChatCreated: Bool?

        /// Optional. Service message: the supergroup has been created. This field can’t be received in a message coming through updates, because bot can’t be a member of a supergroup when it is created. It can only be found in reply_to_message if someone replies to a very first message in a directly created supergroup.
        public var supergroupChatCreated: Bool?

        /// Optional. Service message: the channel has been created. This field can’t be received in a message coming through updates, because bot can’t be a member of a channel when it is created. It can only be found in reply_to_message if someone replies to a very first message in a channel.
        public var channelChatCreated: Bool?

        /// Optional. Service message: auto-delete timer settings changed in the chat
        public var messageAutoDeleteTimerChanged: MessageAutoDeleteTimerChanged?

        /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        public var migrateToChatId: Int?

        /// Optional. The supergroup has been migrated from a group with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        public var migrateFromChatId: Int?

        /// Optional. Specified message was pinned. Note that the Message object in this field will not contain further reply_to_message fields even if it is itself a reply.
        public var pinnedMessage: Message?

        /// Optional. Message is an invoice for a payment, information about the invoice. More about payments »
        public var invoice: Invoice?

        /// Optional. Message is a service message about a successful payment, information about the payment. More about payments »
        public var successfulPayment: SuccessfulPayment?

        /// Optional. The domain name of the website on which the user has logged in. More about Telegram Login »
        public var connectedWebsite: String?

        /// Optional. Telegram Passport data
        public var passportData: PassportData?

        /// Optional. Service message. A user in the chat triggered another user’s proximity alert while sharing Live Location.
        public var proximityAlertTriggered: ProximityAlertTriggered?

        /// Optional. Service message: voice chat scheduled
        public var voiceChatScheduled: VoiceChatScheduled?

        /// Optional. Service message: voice chat started
        public var voiceChatStarted: VoiceChatStarted?

        /// Optional. Service message: voice chat ended
        public var voiceChatEnded: VoiceChatEnded?

        /// Optional. Service message: new participants invited to a voice chat
        public var voiceChatParticipantsInvited: VoiceChatParticipantsInvited?

        /// Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
        public var replyMarkup: InlineKeyboardMarkup?

        /// Message initialization
        ///
        /// - parameter messageId:  Unique message identifier inside this chat
        /// - parameter from:  Optional. Sender, empty for messages sent to channels
        /// - parameter senderChat:  Optional. Sender of the message, sent on behalf of a chat. The channel itself for channel messages. The supergroup itself for messages from anonymous group administrators. The linked channel for messages automatically forwarded to the discussion group
        /// - parameter date:  Date the message was sent in Unix time
        /// - parameter chat:  Conversation the message belongs to
        /// - parameter forwardFrom:  Optional. For forwarded messages, sender of the original message
        /// - parameter forwardFromChat:  Optional. For messages forwarded from channels or from anonymous administrators, information about the original sender chat
        /// - parameter forwardFromMessageId:  Optional. For messages forwarded from channels, identifier of the original message in the channel
        /// - parameter forwardSignature:  Optional. For messages forwarded from channels, signature of the post author if present
        /// - parameter forwardSenderName:  Optional. Sender’s name for messages forwarded from users who disallow adding a link to their account in forwarded messages
        /// - parameter forwardDate:  Optional. For forwarded messages, date the original message was sent in Unix time
        /// - parameter replyToMessage:  Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
        /// - parameter viaBot:  Optional. Bot through which the message was sent
        /// - parameter editDate:  Optional. Date the message was last edited in Unix time
        /// - parameter mediaGroupId:  Optional. The unique identifier of a media message group this message belongs to
        /// - parameter authorSignature:  Optional. Signature of the post author for messages in channels, or the custom title of an anonymous group administrator
        /// - parameter text:  Optional. For text messages, the actual UTF-8 text of the message, 0-4096 characters
        /// - parameter entities:  Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
        /// - parameter animation:  Optional. Message is an animation, information about the animation. For backward compatibility, when this field is set, the document field will also be set
        /// - parameter audio:  Optional. Message is an audio file, information about the file
        /// - parameter document:  Optional. Message is a general file, information about the file
        /// - parameter photo:  Optional. Message is a photo, available sizes of the photo
        /// - parameter sticker:  Optional. Message is a sticker, information about the sticker
        /// - parameter video:  Optional. Message is a video, information about the video
        /// - parameter videoNote:  Optional. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message
        /// - parameter voice:  Optional. Message is a voice message, information about the file
        /// - parameter caption:  Optional. Caption for the animation, audio, document, photo, video or voice, 0-1024 characters
        /// - parameter captionEntities:  Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
        /// - parameter contact:  Optional. Message is a shared contact, information about the contact
        /// - parameter dice:  Optional. Message is a dice with random value
        /// - parameter game:  Optional. Message is a game, information about the game. More about games »
        /// - parameter poll:  Optional. Message is a native poll, information about the poll
        /// - parameter venue:  Optional. Message is a venue, information about the venue. For backward compatibility, when this field is set, the location field will also be set
        /// - parameter location:  Optional. Message is a shared location, information about the location
        /// - parameter newChatMembers:  Optional. New members that were added to the group or supergroup and information about them (the bot itself may be one of these members)
        /// - parameter leftChatMember:  Optional. A member was removed from the group, information about them (this member may be the bot itself)
        /// - parameter newChatTitle:  Optional. A chat title was changed to this value
        /// - parameter newChatPhoto:  Optional. A chat photo was change to this value
        /// - parameter deleteChatPhoto:  Optional. Service message: the chat photo was deleted
        /// - parameter groupChatCreated:  Optional. Service message: the group has been created
        /// - parameter supergroupChatCreated:  Optional. Service message: the supergroup has been created. This field can’t be received in a message coming through updates, because bot can’t be a member of a supergroup when it is created. It can only be found in reply_to_message if someone replies to a very first message in a directly created supergroup.
        /// - parameter channelChatCreated:  Optional. Service message: the channel has been created. This field can’t be received in a message coming through updates, because bot can’t be a member of a channel when it is created. It can only be found in reply_to_message if someone replies to a very first message in a channel.
        /// - parameter messageAutoDeleteTimerChanged:  Optional. Service message: auto-delete timer settings changed in the chat
        /// - parameter migrateToChatId:  Optional. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter migrateFromChatId:  Optional. The supergroup has been migrated from a group with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter pinnedMessage:  Optional. Specified message was pinned. Note that the Message object in this field will not contain further reply_to_message fields even if it is itself a reply.
        /// - parameter invoice:  Optional. Message is an invoice for a payment, information about the invoice. More about payments »
        /// - parameter successfulPayment:  Optional. Message is a service message about a successful payment, information about the payment. More about payments »
        /// - parameter connectedWebsite:  Optional. The domain name of the website on which the user has logged in. More about Telegram Login »
        /// - parameter passportData:  Optional. Telegram Passport data
        /// - parameter proximityAlertTriggered:  Optional. Service message. A user in the chat triggered another user’s proximity alert while sharing Live Location.
        /// - parameter voiceChatScheduled:  Optional. Service message: voice chat scheduled
        /// - parameter voiceChatStarted:  Optional. Service message: voice chat started
        /// - parameter voiceChatEnded:  Optional. Service message: voice chat ended
        /// - parameter voiceChatParticipantsInvited:  Optional. Service message: new participants invited to a voice chat
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
        ///
        /// - returns: The new `Message` instance.
        ///
        public init(messageId: Int, from: User? = nil, senderChat: Chat? = nil, date: Int, chat: Chat, forwardFrom: User? = nil, forwardFromChat: Chat? = nil, forwardFromMessageId: Int? = nil, forwardSignature: String? = nil, forwardSenderName: String? = nil, forwardDate: Int? = nil, replyToMessage: Message? = nil, viaBot: User? = nil, editDate: Int? = nil, mediaGroupId: String? = nil, authorSignature: String? = nil, text: String? = nil, entities: [MessageEntity]? = nil, animation: Animation? = nil, audio: Audio? = nil, document: Document? = nil, photo: [PhotoSize]? = nil, sticker: Sticker? = nil, video: Video? = nil, videoNote: VideoNote? = nil, voice: Voice? = nil, caption: String? = nil, captionEntities: [MessageEntity]? = nil, contact: Contact? = nil, dice: Dice? = nil, game: Game? = nil, poll: Poll? = nil, venue: Venue? = nil, location: Location? = nil, newChatMembers: [User]? = nil, leftChatMember: User? = nil, newChatTitle: String? = nil, newChatPhoto: [PhotoSize]? = nil, deleteChatPhoto: Bool? = nil, groupChatCreated: Bool? = nil, supergroupChatCreated: Bool? = nil, channelChatCreated: Bool? = nil, messageAutoDeleteTimerChanged: MessageAutoDeleteTimerChanged? = nil, migrateToChatId: Int? = nil, migrateFromChatId: Int? = nil, pinnedMessage: Message? = nil, invoice: Invoice? = nil, successfulPayment: SuccessfulPayment? = nil, connectedWebsite: String? = nil, passportData: PassportData? = nil, proximityAlertTriggered: ProximityAlertTriggered? = nil, voiceChatScheduled: VoiceChatScheduled? = nil, voiceChatStarted: VoiceChatStarted? = nil, voiceChatEnded: VoiceChatEnded? = nil, voiceChatParticipantsInvited: VoiceChatParticipantsInvited? = nil, replyMarkup: InlineKeyboardMarkup? = nil) {
            self.messageId = messageId
            self.from = from
            self.senderChat = senderChat
            self.date = date
            self.chat = chat
            self.forwardFrom = forwardFrom
            self.forwardFromChat = forwardFromChat
            self.forwardFromMessageId = forwardFromMessageId
            self.forwardSignature = forwardSignature
            self.forwardSenderName = forwardSenderName
            self.forwardDate = forwardDate
            self.replyToMessage = replyToMessage
            self.viaBot = viaBot
            self.editDate = editDate
            self.mediaGroupId = mediaGroupId
            self.authorSignature = authorSignature
            self.text = text
            self.entities = entities
            self.animation = animation
            self.audio = audio
            self.document = document
            self.photo = photo
            self.sticker = sticker
            self.video = video
            self.videoNote = videoNote
            self.voice = voice
            self.caption = caption
            self.captionEntities = captionEntities
            self.contact = contact
            self.dice = dice
            self.game = game
            self.poll = poll
            self.venue = venue
            self.location = location
            self.newChatMembers = newChatMembers
            self.leftChatMember = leftChatMember
            self.newChatTitle = newChatTitle
            self.newChatPhoto = newChatPhoto
            self.deleteChatPhoto = deleteChatPhoto
            self.groupChatCreated = groupChatCreated
            self.supergroupChatCreated = supergroupChatCreated
            self.channelChatCreated = channelChatCreated
            self.messageAutoDeleteTimerChanged = messageAutoDeleteTimerChanged
            self.migrateToChatId = migrateToChatId
            self.migrateFromChatId = migrateFromChatId
            self.pinnedMessage = pinnedMessage
            self.invoice = invoice
            self.successfulPayment = successfulPayment
            self.connectedWebsite = connectedWebsite
            self.passportData = passportData
            self.proximityAlertTriggered = proximityAlertTriggered
            self.voiceChatScheduled = voiceChatScheduled
            self.voiceChatStarted = voiceChatStarted
            self.voiceChatEnded = voiceChatEnded
            self.voiceChatParticipantsInvited = voiceChatParticipantsInvited
            self.replyMarkup = replyMarkup
        }

        private enum CodingKeys: String, CodingKey {
            case messageId = "message_id"
            case from = "from"
            case senderChat = "sender_chat"
            case date = "date"
            case chat = "chat"
            case forwardFrom = "forward_from"
            case forwardFromChat = "forward_from_chat"
            case forwardFromMessageId = "forward_from_message_id"
            case forwardSignature = "forward_signature"
            case forwardSenderName = "forward_sender_name"
            case forwardDate = "forward_date"
            case replyToMessage = "reply_to_message"
            case viaBot = "via_bot"
            case editDate = "edit_date"
            case mediaGroupId = "media_group_id"
            case authorSignature = "author_signature"
            case text = "text"
            case entities = "entities"
            case animation = "animation"
            case audio = "audio"
            case document = "document"
            case photo = "photo"
            case sticker = "sticker"
            case video = "video"
            case videoNote = "video_note"
            case voice = "voice"
            case caption = "caption"
            case captionEntities = "caption_entities"
            case contact = "contact"
            case dice = "dice"
            case game = "game"
            case poll = "poll"
            case venue = "venue"
            case location = "location"
            case newChatMembers = "new_chat_members"
            case leftChatMember = "left_chat_member"
            case newChatTitle = "new_chat_title"
            case newChatPhoto = "new_chat_photo"
            case deleteChatPhoto = "delete_chat_photo"
            case groupChatCreated = "group_chat_created"
            case supergroupChatCreated = "supergroup_chat_created"
            case channelChatCreated = "channel_chat_created"
            case messageAutoDeleteTimerChanged = "message_auto_delete_timer_changed"
            case migrateToChatId = "migrate_to_chat_id"
            case migrateFromChatId = "migrate_from_chat_id"
            case pinnedMessage = "pinned_message"
            case invoice = "invoice"
            case successfulPayment = "successful_payment"
            case connectedWebsite = "connected_website"
            case passportData = "passport_data"
            case proximityAlertTriggered = "proximity_alert_triggered"
            case voiceChatScheduled = "voice_chat_scheduled"
            case voiceChatStarted = "voice_chat_started"
            case voiceChatEnded = "voice_chat_ended"
            case voiceChatParticipantsInvited = "voice_chat_participants_invited"
            case replyMarkup = "reply_markup"
        }

    }

    /// This object represents a unique message identifier.
    public class MessageId: Codable {

        /// Unique message identifier
        public var messageId: Int

        /// MessageId initialization
        ///
        /// - parameter messageId:  Unique message identifier
        ///
        /// - returns: The new `MessageId` instance.
        ///
        public init(messageId: Int) {
            self.messageId = messageId
        }

        private enum CodingKeys: String, CodingKey {
            case messageId = "message_id"
        }

    }

    /// This object represents one special entity in a text message. For example, hashtags, usernames, URLs, etc.
    public class MessageEntity: Codable {

        /// Type of the entity. Can be “mention” (@username), “hashtag” (#hashtag), “cashtag” ($USD), “bot_command” (/start@jobs_bot), “url” (https://telegram.org), “email” (do-not-reply@telegram.org), “phone_number” (+1-212-555-0123), “bold” (bold text), “italic” (italic text), “underline” (underlined text), “strikethrough” (strikethrough text), “code” (monowidth string), “pre” (monowidth block), “text_link” (for clickable text URLs), “text_mention” (for users [without usernames](https://telegram.org/blog/edit#new-mentions))
        public var type: String

        /// Offset in UTF-16 code units to the start of the entity
        public var offset: Int

        /// Length of the entity in UTF-16 code units
        public var length: Int

        /// Optional. For “text_link” only, url that will be opened after user taps on the text
        public var url: String?

        /// Optional. For “text_mention” only, the mentioned user
        public var user: User?

        /// Optional. For “pre” only, the programming language of the entity text
        public var language: String?

        /// MessageEntity initialization
        ///
        /// - parameter type:  Type of the entity. Can be “mention” (@username), “hashtag” (#hashtag), “cashtag” ($USD), “bot_command” (/start@jobs_bot), “url” (https://telegram.org), “email” (do-not-reply@telegram.org), “phone_number” (+1-212-555-0123), “bold” (bold text), “italic” (italic text), “underline” (underlined text), “strikethrough” (strikethrough text), “code” (monowidth string), “pre” (monowidth block), “text_link” (for clickable text URLs), “text_mention” (for users [without usernames](https://telegram.org/blog/edit#new-mentions))
        /// - parameter offset:  Offset in UTF-16 code units to the start of the entity
        /// - parameter length:  Length of the entity in UTF-16 code units
        /// - parameter url:  Optional. For “text_link” only, url that will be opened after user taps on the text
        /// - parameter user:  Optional. For “text_mention” only, the mentioned user
        /// - parameter language:  Optional. For “pre” only, the programming language of the entity text
        ///
        /// - returns: The new `MessageEntity` instance.
        ///
        public init(type: String, offset: Int, length: Int, url: String? = nil, user: User? = nil, language: String? = nil) {
            self.type = type
            self.offset = offset
            self.length = length
            self.url = url
            self.user = user
            self.language = language
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case offset = "offset"
            case length = "length"
            case url = "url"
            case user = "user"
            case language = "language"
        }

    }

    /// This object represents one size of a photo or a file / sticker thumbnail.
    public class PhotoSize: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Photo width
        public var width: Int

        /// Photo height
        public var height: Int

        /// Optional. File size
        public var fileSize: Int?

        /// PhotoSize initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Photo width
        /// - parameter height:  Photo height
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `PhotoSize` instance.
        ///
        public init(fileId: String, fileUniqueId: String, width: Int, height: Int, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.width = width
            self.height = height
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case width = "width"
            case height = "height"
            case fileSize = "file_size"
        }

    }

    /// This object represents an animation file (GIF or H.264/MPEG-4 AVC video without sound).
    public class Animation: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Video width as defined by sender
        public var width: Int

        /// Video height as defined by sender
        public var height: Int

        /// Duration of the video in seconds as defined by sender
        public var duration: Int

        /// Optional. Animation thumbnail as defined by sender
        public var thumb: PhotoSize?

        /// Optional. Original animation filename as defined by sender
        public var fileName: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Animation initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Video width as defined by sender
        /// - parameter height:  Video height as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumb:  Optional. Animation thumbnail as defined by sender
        /// - parameter fileName:  Optional. Original animation filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Animation` instance.
        ///
        public init(fileId: String, fileUniqueId: String, width: Int, height: Int, duration: Int, thumb: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.width = width
            self.height = height
            self.duration = duration
            self.thumb = thumb
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case width = "width"
            case height = "height"
            case duration = "duration"
            case thumb = "thumb"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents an audio file to be treated as music by the Telegram clients.
    public class Audio: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Duration of the audio in seconds as defined by sender
        public var duration: Int

        /// Optional. Performer of the audio as defined by sender or by audio tags
        public var performer: String?

        /// Optional. Title of the audio as defined by sender or by audio tags
        public var title: String?

        /// Optional. Original filename as defined by sender
        public var fileName: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Optional. Thumbnail of the album cover to which the music file belongs
        public var thumb: PhotoSize?

        /// Audio initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter duration:  Duration of the audio in seconds as defined by sender
        /// - parameter performer:  Optional. Performer of the audio as defined by sender or by audio tags
        /// - parameter title:  Optional. Title of the audio as defined by sender or by audio tags
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        /// - parameter thumb:  Optional. Thumbnail of the album cover to which the music file belongs
        ///
        /// - returns: The new `Audio` instance.
        ///
        public init(fileId: String, fileUniqueId: String, duration: Int, performer: String? = nil, title: String? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil, thumb: PhotoSize? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.duration = duration
            self.performer = performer
            self.title = title
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
            self.thumb = thumb
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case duration = "duration"
            case performer = "performer"
            case title = "title"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
            case thumb = "thumb"
        }

    }

    /// This object represents a general file (as opposed to photos, voice messages and audio files).
    public class Document: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Optional. Document thumbnail as defined by sender
        public var thumb: PhotoSize?

        /// Optional. Original filename as defined by sender
        public var fileName: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Document initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter thumb:  Optional. Document thumbnail as defined by sender
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Document` instance.
        ///
        public init(fileId: String, fileUniqueId: String, thumb: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.thumb = thumb
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case thumb = "thumb"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a video file.
    public class Video: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Video width as defined by sender
        public var width: Int

        /// Video height as defined by sender
        public var height: Int

        /// Duration of the video in seconds as defined by sender
        public var duration: Int

        /// Optional. Video thumbnail
        public var thumb: PhotoSize?

        /// Optional. Original filename as defined by sender
        public var fileName: String?

        /// Optional. Mime type of a file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Video initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Video width as defined by sender
        /// - parameter height:  Video height as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumb:  Optional. Video thumbnail
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. Mime type of a file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Video` instance.
        ///
        public init(fileId: String, fileUniqueId: String, width: Int, height: Int, duration: Int, thumb: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.width = width
            self.height = height
            self.duration = duration
            self.thumb = thumb
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case width = "width"
            case height = "height"
            case duration = "duration"
            case thumb = "thumb"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a [video message](https://telegram.org/blog/video-messages-and-telescope) (available in Telegram apps as of [v.4.0](https://telegram.org/blog/video-messages-and-telescope)).
    public class VideoNote: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Video width and height (diameter of the video message) as defined by sender
        public var length: Int

        /// Duration of the video in seconds as defined by sender
        public var duration: Int

        /// Optional. Video thumbnail
        public var thumb: PhotoSize?

        /// Optional. File size
        public var fileSize: Int?

        /// VideoNote initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter length:  Video width and height (diameter of the video message) as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumb:  Optional. Video thumbnail
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `VideoNote` instance.
        ///
        public init(fileId: String, fileUniqueId: String, length: Int, duration: Int, thumb: PhotoSize? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.length = length
            self.duration = duration
            self.thumb = thumb
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case length = "length"
            case duration = "duration"
            case thumb = "thumb"
            case fileSize = "file_size"
        }

    }

    /// This object represents a voice note.
    public class Voice: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Duration of the audio in seconds as defined by sender
        public var duration: Int

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Voice initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter duration:  Duration of the audio in seconds as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Voice` instance.
        ///
        public init(fileId: String, fileUniqueId: String, duration: Int, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.duration = duration
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case duration = "duration"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a phone contact.
    public class Contact: Codable {

        /// Contact’s phone number
        public var phoneNumber: String

        /// Contact’s first name
        public var firstName: String

        /// Optional. Contact’s last name
        public var lastName: String?

        /// Optional. Contact’s user identifier in Telegram. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
        public var userId: Int?

        /// Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard)
        public var vcard: String?

        /// Contact initialization
        ///
        /// - parameter phoneNumber:  Contact’s phone number
        /// - parameter firstName:  Contact’s first name
        /// - parameter lastName:  Optional. Contact’s last name
        /// - parameter userId:  Optional. Contact’s user identifier in Telegram. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter vcard:  Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard)
        ///
        /// - returns: The new `Contact` instance.
        ///
        public init(phoneNumber: String, firstName: String, lastName: String? = nil, userId: Int? = nil, vcard: String? = nil) {
            self.phoneNumber = phoneNumber
            self.firstName = firstName
            self.lastName = lastName
            self.userId = userId
            self.vcard = vcard
        }

        private enum CodingKeys: String, CodingKey {
            case phoneNumber = "phone_number"
            case firstName = "first_name"
            case lastName = "last_name"
            case userId = "user_id"
            case vcard = "vcard"
        }

    }

    /// This object represents an animated emoji that displays a random value.
    public class Dice: Codable {

        /// Emoji on which the dice throw animation is based
        public var emoji: String

        /// Value of the dice, 1-6 for “”, “” and “” base emoji, 1-5 for “” and “” base emoji, 1-64 for “” base emoji
        public var value: Int

        /// Dice initialization
        ///
        /// - parameter emoji:  Emoji on which the dice throw animation is based
        /// - parameter value:  Value of the dice, 1-6 for “”, “” and “” base emoji, 1-5 for “” and “” base emoji, 1-64 for “” base emoji
        ///
        /// - returns: The new `Dice` instance.
        ///
        public init(emoji: String, value: Int) {
            self.emoji = emoji
            self.value = value
        }

        private enum CodingKeys: String, CodingKey {
            case emoji = "emoji"
            case value = "value"
        }

    }

    /// This object contains information about one answer option in a poll.
    public class PollOption: Codable {

        /// Option text, 1-100 characters
        public var text: String

        /// Number of users that voted for this option
        public var voterCount: Int

        /// PollOption initialization
        ///
        /// - parameter text:  Option text, 1-100 characters
        /// - parameter voterCount:  Number of users that voted for this option
        ///
        /// - returns: The new `PollOption` instance.
        ///
        public init(text: String, voterCount: Int) {
            self.text = text
            self.voterCount = voterCount
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case voterCount = "voter_count"
        }

    }

    /// This object represents an answer of a user in a non-anonymous poll.
    public class PollAnswer: Codable {

        /// Unique poll identifier
        public var pollId: String

        /// The user, who changed the answer to the poll
        public var user: User

        /// 0-based identifiers of answer options, chosen by the user. May be empty if the user retracted their vote.
        public var optionIds: [Int]

        /// PollAnswer initialization
        ///
        /// - parameter pollId:  Unique poll identifier
        /// - parameter user:  The user, who changed the answer to the poll
        /// - parameter optionIds:  0-based identifiers of answer options, chosen by the user. May be empty if the user retracted their vote.
        ///
        /// - returns: The new `PollAnswer` instance.
        ///
        public init(pollId: String, user: User, optionIds: [Int]) {
            self.pollId = pollId
            self.user = user
            self.optionIds = optionIds
        }

        private enum CodingKeys: String, CodingKey {
            case pollId = "poll_id"
            case user = "user"
            case optionIds = "option_ids"
        }

    }

    /// This object contains information about a poll.
    public class Poll: Codable {

        /// Unique poll identifier
        public var id: String

        /// Poll question, 1-300 characters
        public var question: String

        /// List of poll options
        public var options: [PollOption]

        /// Total number of users that voted in the poll
        public var totalVoterCount: Int

        /// True, if the poll is closed
        public var isClosed: Bool

        /// True, if the poll is anonymous
        public var isAnonymous: Bool

        /// Poll type, currently can be “regular” or “quiz”
        public var type: String

        /// True, if the poll allows multiple answers
        public var allowsMultipleAnswers: Bool

        /// Optional. 0-based identifier of the correct answer option. Available only for polls in the quiz mode, which are closed, or was sent (not forwarded) by the bot or to the private chat with the bot.
        public var correctOptionId: Int?

        /// Optional. Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters
        public var explanation: String?

        /// Optional. Special entities like usernames, URLs, bot commands, etc. that appear in the explanation
        public var explanationEntities: [MessageEntity]?

        /// Optional. Amount of time in seconds the poll will be active after creation
        public var openPeriod: Int?

        /// Optional. Point in time (Unix timestamp) when the poll will be automatically closed
        public var closeDate: Int?

        /// Poll initialization
        ///
        /// - parameter id:  Unique poll identifier
        /// - parameter question:  Poll question, 1-300 characters
        /// - parameter options:  List of poll options
        /// - parameter totalVoterCount:  Total number of users that voted in the poll
        /// - parameter isClosed:  True, if the poll is closed
        /// - parameter isAnonymous:  True, if the poll is anonymous
        /// - parameter type:  Poll type, currently can be “regular” or “quiz”
        /// - parameter allowsMultipleAnswers:  True, if the poll allows multiple answers
        /// - parameter correctOptionId:  Optional. 0-based identifier of the correct answer option. Available only for polls in the quiz mode, which are closed, or was sent (not forwarded) by the bot or to the private chat with the bot.
        /// - parameter explanation:  Optional. Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters
        /// - parameter explanationEntities:  Optional. Special entities like usernames, URLs, bot commands, etc. that appear in the explanation
        /// - parameter openPeriod:  Optional. Amount of time in seconds the poll will be active after creation
        /// - parameter closeDate:  Optional. Point in time (Unix timestamp) when the poll will be automatically closed
        ///
        /// - returns: The new `Poll` instance.
        ///
        public init(id: String, question: String, options: [PollOption], totalVoterCount: Int, isClosed: Bool, isAnonymous: Bool, type: String, allowsMultipleAnswers: Bool, correctOptionId: Int? = nil, explanation: String? = nil, explanationEntities: [MessageEntity]? = nil, openPeriod: Int? = nil, closeDate: Int? = nil) {
            self.id = id
            self.question = question
            self.options = options
            self.totalVoterCount = totalVoterCount
            self.isClosed = isClosed
            self.isAnonymous = isAnonymous
            self.type = type
            self.allowsMultipleAnswers = allowsMultipleAnswers
            self.correctOptionId = correctOptionId
            self.explanation = explanation
            self.explanationEntities = explanationEntities
            self.openPeriod = openPeriod
            self.closeDate = closeDate
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case question = "question"
            case options = "options"
            case totalVoterCount = "total_voter_count"
            case isClosed = "is_closed"
            case isAnonymous = "is_anonymous"
            case type = "type"
            case allowsMultipleAnswers = "allows_multiple_answers"
            case correctOptionId = "correct_option_id"
            case explanation = "explanation"
            case explanationEntities = "explanation_entities"
            case openPeriod = "open_period"
            case closeDate = "close_date"
        }

    }

    /// This object represents a point on the map.
    public class Location: Codable {

        /// Longitude as defined by sender
        public var longitude: Float

        /// Latitude as defined by sender
        public var latitude: Float

        /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        public var horizontalAccuracy: Float?

        /// Optional. Time relative to the message sending date, during which the location can be updated, in seconds. For active live locations only.
        public var livePeriod: Int?

        /// Optional. The direction in which user is moving, in degrees; 1-360. For active live locations only.
        public var heading: Int?

        /// Optional. Maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.
        public var proximityAlertRadius: Int?

        /// Location initialization
        ///
        /// - parameter longitude:  Longitude as defined by sender
        /// - parameter latitude:  Latitude as defined by sender
        /// - parameter horizontalAccuracy:  Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        /// - parameter livePeriod:  Optional. Time relative to the message sending date, during which the location can be updated, in seconds. For active live locations only.
        /// - parameter heading:  Optional. The direction in which user is moving, in degrees; 1-360. For active live locations only.
        /// - parameter proximityAlertRadius:  Optional. Maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.
        ///
        /// - returns: The new `Location` instance.
        ///
        public init(longitude: Float, latitude: Float, horizontalAccuracy: Float? = nil, livePeriod: Int? = nil, heading: Int? = nil, proximityAlertRadius: Int? = nil) {
            self.longitude = longitude
            self.latitude = latitude
            self.horizontalAccuracy = horizontalAccuracy
            self.livePeriod = livePeriod
            self.heading = heading
            self.proximityAlertRadius = proximityAlertRadius
        }

        private enum CodingKeys: String, CodingKey {
            case longitude = "longitude"
            case latitude = "latitude"
            case horizontalAccuracy = "horizontal_accuracy"
            case livePeriod = "live_period"
            case heading = "heading"
            case proximityAlertRadius = "proximity_alert_radius"
        }

    }

    /// This object represents a venue.
    public class Venue: Codable {

        /// Venue location. Can’t be a live location
        public var location: Location

        /// Name of the venue
        public var title: String

        /// Address of the venue
        public var address: String

        /// Optional. Foursquare identifier of the venue
        public var foursquareId: String?

        /// Optional. Foursquare type of the venue. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        public var foursquareType: String?

        /// Optional. Google Places identifier of the venue
        public var googlePlaceId: String?

        /// Optional. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
        public var googlePlaceType: String?

        /// Venue initialization
        ///
        /// - parameter location:  Venue location. Can’t be a live location
        /// - parameter title:  Name of the venue
        /// - parameter address:  Address of the venue
        /// - parameter foursquareId:  Optional. Foursquare identifier of the venue
        /// - parameter foursquareType:  Optional. Foursquare type of the venue. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        /// - parameter googlePlaceId:  Optional. Google Places identifier of the venue
        /// - parameter googlePlaceType:  Optional. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
        ///
        /// - returns: The new `Venue` instance.
        ///
        public init(location: Location, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, googlePlaceId: String? = nil, googlePlaceType: String? = nil) {
            self.location = location
            self.title = title
            self.address = address
            self.foursquareId = foursquareId
            self.foursquareType = foursquareType
            self.googlePlaceId = googlePlaceId
            self.googlePlaceType = googlePlaceType
        }

        private enum CodingKeys: String, CodingKey {
            case location = "location"
            case title = "title"
            case address = "address"
            case foursquareId = "foursquare_id"
            case foursquareType = "foursquare_type"
            case googlePlaceId = "google_place_id"
            case googlePlaceType = "google_place_type"
        }

    }

    /// This object represents the content of a service message, sent whenever a user in the chat triggers a proximity alert set by another user.
    public class ProximityAlertTriggered: Codable {

        /// User that triggered the alert
        public var traveler: User

        /// User that set the alert
        public var watcher: User

        /// The distance between the users
        public var distance: Int

        /// ProximityAlertTriggered initialization
        ///
        /// - parameter traveler:  User that triggered the alert
        /// - parameter watcher:  User that set the alert
        /// - parameter distance:  The distance between the users
        ///
        /// - returns: The new `ProximityAlertTriggered` instance.
        ///
        public init(traveler: User, watcher: User, distance: Int) {
            self.traveler = traveler
            self.watcher = watcher
            self.distance = distance
        }

        private enum CodingKeys: String, CodingKey {
            case traveler = "traveler"
            case watcher = "watcher"
            case distance = "distance"
        }

    }

    /// This object represents a service message about a change in auto-delete timer settings.
    public class MessageAutoDeleteTimerChanged: Codable {

        /// New auto-delete time for messages in the chat
        public var messageAutoDeleteTime: Int

        /// MessageAutoDeleteTimerChanged initialization
        ///
        /// - parameter messageAutoDeleteTime:  New auto-delete time for messages in the chat
        ///
        /// - returns: The new `MessageAutoDeleteTimerChanged` instance.
        ///
        public init(messageAutoDeleteTime: Int) {
            self.messageAutoDeleteTime = messageAutoDeleteTime
        }

        private enum CodingKeys: String, CodingKey {
            case messageAutoDeleteTime = "message_auto_delete_time"
        }

    }

    /// This object represents a service message about a voice chat scheduled in the chat.
    public class VoiceChatScheduled: Codable {

        /// Point in time (Unix timestamp) when the voice chat is supposed to be started by a chat administrator
        public var startDate: Int

        /// VoiceChatScheduled initialization
        ///
        /// - parameter startDate:  Point in time (Unix timestamp) when the voice chat is supposed to be started by a chat administrator
        ///
        /// - returns: The new `VoiceChatScheduled` instance.
        ///
        public init(startDate: Int) {
            self.startDate = startDate
        }

        private enum CodingKeys: String, CodingKey {
            case startDate = "start_date"
        }

    }

    /// This object represents a service message about a voice chat started in the chat. Currently holds no information.
    public struct VoiceChatStarted: Codable {

    }

    /// This object represents a service message about a voice chat ended in the chat.
    public class VoiceChatEnded: Codable {

        /// Voice chat duration; in seconds
        public var duration: Int

        /// VoiceChatEnded initialization
        ///
        /// - parameter duration:  Voice chat duration; in seconds
        ///
        /// - returns: The new `VoiceChatEnded` instance.
        ///
        public init(duration: Int) {
            self.duration = duration
        }

        private enum CodingKeys: String, CodingKey {
            case duration = "duration"
        }

    }

    /// This object represents a service message about new members invited to a voice chat.
    public class VoiceChatParticipantsInvited: Codable {

        /// Optional. New members that were invited to the voice chat
        public var users: [User]?

        /// VoiceChatParticipantsInvited initialization
        ///
        /// - parameter users:  Optional. New members that were invited to the voice chat
        ///
        /// - returns: The new `VoiceChatParticipantsInvited` instance.
        ///
        public init(users: [User]? = nil) {
            self.users = users
        }

        private enum CodingKeys: String, CodingKey {
            case users = "users"
        }

    }

    /// This object represent a user’s profile pictures.
    public class UserProfilePhotos: Codable {

        /// Total number of profile pictures the target user has
        public var totalCount: Int

        /// Requested profile pictures (in up to 4 sizes each)
        public var photos: [PhotoSize]

        /// UserProfilePhotos initialization
        ///
        /// - parameter totalCount:  Total number of profile pictures the target user has
        /// - parameter photos:  Requested profile pictures (in up to 4 sizes each)
        ///
        /// - returns: The new `UserProfilePhotos` instance.
        ///
        public init(totalCount: Int, photos: [PhotoSize]) {
            self.totalCount = totalCount
            self.photos = photos
        }

        private enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case photos = "photos"
        }

    }

    /// Maximum file size to download is 20 MB
    public class File: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Optional. File size, if known
        public var fileSize: Int?

        /// Optional. File path. Use https://api.telegram.org/file/bot&lt;token&gt;/&lt;file_path&gt; to get the file.
        public var filePath: String?

        /// File initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter fileSize:  Optional. File size, if known
        /// - parameter filePath:  Optional. File path. Use https://api.telegram.org/file/bot&lt;token&gt;/&lt;file_path&gt; to get the file.
        ///
        /// - returns: The new `File` instance.
        ///
        public init(fileId: String, fileUniqueId: String, fileSize: Int? = nil, filePath: String? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.fileSize = fileSize
            self.filePath = filePath
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case fileSize = "file_size"
            case filePath = "file_path"
        }

    }

    /// This object represents a [custom keyboard](https://core.telegram.org/bots#keyboards) with reply options (see [Introduction to bots](https://core.telegram.org/bots#keyboards) for details and examples).
    public class ReplyKeyboardMarkup: Codable {

        /// Array of button rows, each represented by an Array of KeyboardButton objects
        public var keyboard: [KeyboardButton]

        /// Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app’s standard keyboard.
        public var resizeKeyboard: Bool?

        /// Optional. Requests clients to hide the keyboard as soon as it’s been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat – the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
        public var oneTimeKeyboard: Bool?

        /// Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.Example: A user requests to change the bot’s language, bot replies to the request with a keyboard to select the new language. Other users in the group don’t see the keyboard.
        public var selective: Bool?

        /// ReplyKeyboardMarkup initialization
        ///
        /// - parameter keyboard:  Array of button rows, each represented by an Array of KeyboardButton objects
        /// - parameter resizeKeyboard:  Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app’s standard keyboard.
        /// - parameter oneTimeKeyboard:  Optional. Requests clients to hide the keyboard as soon as it’s been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat – the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
        /// - parameter selective:  Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.Example: A user requests to change the bot’s language, bot replies to the request with a keyboard to select the new language. Other users in the group don’t see the keyboard.
        ///
        /// - returns: The new `ReplyKeyboardMarkup` instance.
        ///
        public init(keyboard: [KeyboardButton], resizeKeyboard: Bool? = nil, oneTimeKeyboard: Bool? = nil, selective: Bool? = nil) {
            self.keyboard = keyboard
            self.resizeKeyboard = resizeKeyboard
            self.oneTimeKeyboard = oneTimeKeyboard
            self.selective = selective
        }

        private enum CodingKeys: String, CodingKey {
            case keyboard = "keyboard"
            case resizeKeyboard = "resize_keyboard"
            case oneTimeKeyboard = "one_time_keyboard"
            case selective = "selective"
        }

    }

    /// This object represents one button of the reply keyboard. For simple text buttons String can be used instead of this object to specify text of the button. Optional fields request_contact, request_location, and request_poll are mutually exclusive.
    public class KeyboardButton: Codable {

        /// Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed
        public var text: String

        /// Optional. If True, the user’s phone number will be sent as a contact when the button is pressed. Available in private chats only
        public var requestContact: Bool?

        /// Optional. If True, the user’s current location will be sent when the button is pressed. Available in private chats only
        public var requestLocation: Bool?

        /// Optional. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed. Available in private chats only
        public var requestPoll: KeyboardButtonPollType?

        /// KeyboardButton initialization
        ///
        /// - parameter text:  Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed
        /// - parameter requestContact:  Optional. If True, the user’s phone number will be sent as a contact when the button is pressed. Available in private chats only
        /// - parameter requestLocation:  Optional. If True, the user’s current location will be sent when the button is pressed. Available in private chats only
        /// - parameter requestPoll:  Optional. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed. Available in private chats only
        ///
        /// - returns: The new `KeyboardButton` instance.
        ///
        public init(text: String, requestContact: Bool? = nil, requestLocation: Bool? = nil, requestPoll: KeyboardButtonPollType? = nil) {
            self.text = text
            self.requestContact = requestContact
            self.requestLocation = requestLocation
            self.requestPoll = requestPoll
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case requestContact = "request_contact"
            case requestLocation = "request_location"
            case requestPoll = "request_poll"
        }

    }

    /// This object represents type of a poll, which is allowed to be created and sent when the corresponding button is pressed.
    public class KeyboardButtonPollType: Codable {

        /// Optional. If quiz is passed, the user will be allowed to create only polls in the quiz mode. If regular is passed, only regular polls will be allowed. Otherwise, the user will be allowed to create a poll of any type.
        public var type: String?

        /// KeyboardButtonPollType initialization
        ///
        /// - parameter type:  Optional. If quiz is passed, the user will be allowed to create only polls in the quiz mode. If regular is passed, only regular polls will be allowed. Otherwise, the user will be allowed to create a poll of any type.
        ///
        /// - returns: The new `KeyboardButtonPollType` instance.
        ///
        public init(type: String? = nil) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard. By default, custom keyboards are displayed until a new keyboard is sent by a bot. An exception is made for one-time keyboards that are hidden immediately after the user presses a button (see ReplyKeyboardMarkup).
    public class ReplyKeyboardRemove: Codable {

        /// Requests clients to remove the custom keyboard (user will not be able to summon this keyboard; if you want to hide the keyboard from sight but keep it accessible, use one_time_keyboard in ReplyKeyboardMarkup)
        public var removeKeyboard: Bool

        /// Optional. Use this parameter if you want to remove the keyboard for specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.Example: A user votes in a poll, bot returns confirmation message in reply to the vote and removes the keyboard for that user, while still showing the keyboard with poll options to users who haven’t voted yet.
        public var selective: Bool?

        /// ReplyKeyboardRemove initialization
        ///
        /// - parameter removeKeyboard:  Requests clients to remove the custom keyboard (user will not be able to summon this keyboard; if you want to hide the keyboard from sight but keep it accessible, use one_time_keyboard in ReplyKeyboardMarkup)
        /// - parameter selective:  Optional. Use this parameter if you want to remove the keyboard for specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.Example: A user votes in a poll, bot returns confirmation message in reply to the vote and removes the keyboard for that user, while still showing the keyboard with poll options to users who haven’t voted yet.
        ///
        /// - returns: The new `ReplyKeyboardRemove` instance.
        ///
        public init(removeKeyboard: Bool, selective: Bool? = nil) {
            self.removeKeyboard = removeKeyboard
            self.selective = selective
        }

        private enum CodingKeys: String, CodingKey {
            case removeKeyboard = "remove_keyboard"
            case selective = "selective"
        }

    }

    /// This object represents an [inline keyboard](https://core.telegram.org/bots#inline-keyboards-and-on-the-fly-updating) that appears right next to the message it belongs to.
    public class InlineKeyboardMarkup: Codable {

        /// Array of button rows, each represented by an Array of InlineKeyboardButton objects
        public var inlineKeyboard: [InlineKeyboardButton]

        /// InlineKeyboardMarkup initialization
        ///
        /// - parameter inlineKeyboard:  Array of button rows, each represented by an Array of InlineKeyboardButton objects
        ///
        /// - returns: The new `InlineKeyboardMarkup` instance.
        ///
        public init(inlineKeyboard: [InlineKeyboardButton]) {
            self.inlineKeyboard = inlineKeyboard
        }

        private enum CodingKeys: String, CodingKey {
            case inlineKeyboard = "inline_keyboard"
        }

    }

    /// This object represents one button of an inline keyboard. You must use exactly one of the optional fields.
    public class InlineKeyboardButton: Codable {

        /// Label text on the button
        public var text: String

        /// Optional. HTTP or tg:// url to be opened when button is pressed
        public var url: String?

        /// Optional. An HTTP URL used to automatically authorize the user. Can be used as a replacement for the [Telegram Login Widget](https://core.telegram.org/widgets/login).
        public var loginUrl: LoginUrl?

        /// Optional. Data to be sent in a callback query to the bot when button is pressed, 1-64 bytes
        public var callbackData: String?

        /// Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot’s username and the specified inline query in the input field. Can be empty, in which case just the bot’s username will be inserted.Note: This offers an easy way for users to start using your bot in inline mode when they are currently in a private chat with it. Especially useful when combined with switch_pm… actions – in this case the user will be automatically returned to the chat they switched from, skipping the chat selection screen.
        public var switchInlineQuery: String?

        /// Optional. If set, pressing the button will insert the bot’s username and the specified inline query in the current chat’s input field. Can be empty, in which case only the bot’s username will be inserted.This offers a quick way for the user to open your bot in inline mode in the same chat – good for selecting something from multiple options.
        public var switchInlineQueryCurrentChat: String?

        /// Optional. Description of the game that will be launched when the user presses the button.NOTE: This type of button must always be the first button in the first row.
        public var callbackGame: CallbackGame?

        /// Optional. Specify True, to send a Pay button.NOTE: This type of button must always be the first button in the first row.
        public var pay: Bool?

        /// InlineKeyboardButton initialization
        ///
        /// - parameter text:  Label text on the button
        /// - parameter url:  Optional. HTTP or tg:// url to be opened when button is pressed
        /// - parameter loginUrl:  Optional. An HTTP URL used to automatically authorize the user. Can be used as a replacement for the [Telegram Login Widget](https://core.telegram.org/widgets/login).
        /// - parameter callbackData:  Optional. Data to be sent in a callback query to the bot when button is pressed, 1-64 bytes
        /// - parameter switchInlineQuery:  Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot’s username and the specified inline query in the input field. Can be empty, in which case just the bot’s username will be inserted.Note: This offers an easy way for users to start using your bot in inline mode when they are currently in a private chat with it. Especially useful when combined with switch_pm… actions – in this case the user will be automatically returned to the chat they switched from, skipping the chat selection screen.
        /// - parameter switchInlineQueryCurrentChat:  Optional. If set, pressing the button will insert the bot’s username and the specified inline query in the current chat’s input field. Can be empty, in which case only the bot’s username will be inserted.This offers a quick way for the user to open your bot in inline mode in the same chat – good for selecting something from multiple options.
        /// - parameter callbackGame:  Optional. Description of the game that will be launched when the user presses the button.NOTE: This type of button must always be the first button in the first row.
        /// - parameter pay:  Optional. Specify True, to send a Pay button.NOTE: This type of button must always be the first button in the first row.
        ///
        /// - returns: The new `InlineKeyboardButton` instance.
        ///
        public init(text: String, url: String? = nil, loginUrl: LoginUrl? = nil, callbackData: String? = nil, switchInlineQuery: String? = nil, switchInlineQueryCurrentChat: String? = nil, callbackGame: CallbackGame? = nil, pay: Bool? = nil) {
            self.text = text
            self.url = url
            self.loginUrl = loginUrl
            self.callbackData = callbackData
            self.switchInlineQuery = switchInlineQuery
            self.switchInlineQueryCurrentChat = switchInlineQueryCurrentChat
            self.callbackGame = callbackGame
            self.pay = pay
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case url = "url"
            case loginUrl = "login_url"
            case callbackData = "callback_data"
            case switchInlineQuery = "switch_inline_query"
            case switchInlineQueryCurrentChat = "switch_inline_query_current_chat"
            case callbackGame = "callback_game"
            case pay = "pay"
        }

    }

    /// Sample bot: [@discussbot](https://t.me/discussbot)
    public class LoginUrl: Codable {

        /// An HTTP URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in [Receiving authorization data](https://core.telegram.org/widgets/login#receiving-authorization-data).NOTE: You must always check the hash of the received data to verify the authentication and the integrity of the data as described in [Checking authorization](https://core.telegram.org/widgets/login#checking-authorization).
        public var url: String

        /// Optional. New text of the button in forwarded messages.
        public var forwardText: String?

        /// Optional. Username of a bot, which will be used for user authorization. See [Setting up a bot](https://core.telegram.org/widgets/login#setting-up-a-bot) for more details. If not specified, the current bot’s username will be assumed. The url’s domain must be the same as the domain linked with the bot. See [Linking your domain to the bot](https://core.telegram.org/widgets/login#linking-your-domain-to-the-bot) for more details.
        public var botUsername: String?

        /// Optional. Pass True to request the permission for your bot to send messages to the user.
        public var requestWriteAccess: Bool?

        /// LoginUrl initialization
        ///
        /// - parameter url:  An HTTP URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in [Receiving authorization data](https://core.telegram.org/widgets/login#receiving-authorization-data).NOTE: You must always check the hash of the received data to verify the authentication and the integrity of the data as described in [Checking authorization](https://core.telegram.org/widgets/login#checking-authorization).
        /// - parameter forwardText:  Optional. New text of the button in forwarded messages.
        /// - parameter botUsername:  Optional. Username of a bot, which will be used for user authorization. See [Setting up a bot](https://core.telegram.org/widgets/login#setting-up-a-bot) for more details. If not specified, the current bot’s username will be assumed. The url’s domain must be the same as the domain linked with the bot. See [Linking your domain to the bot](https://core.telegram.org/widgets/login#linking-your-domain-to-the-bot) for more details.
        /// - parameter requestWriteAccess:  Optional. Pass True to request the permission for your bot to send messages to the user.
        ///
        /// - returns: The new `LoginUrl` instance.
        ///
        public init(url: String, forwardText: String? = nil, botUsername: String? = nil, requestWriteAccess: Bool? = nil) {
            self.url = url
            self.forwardText = forwardText
            self.botUsername = botUsername
            self.requestWriteAccess = requestWriteAccess
        }

        private enum CodingKeys: String, CodingKey {
            case url = "url"
            case forwardText = "forward_text"
            case botUsername = "bot_username"
            case requestWriteAccess = "request_write_access"
        }

    }

    /// This object represents an incoming callback query from a callback button in an inline keyboard. If the button that originated the query was attached to a message sent by the bot, the field message will be present. If the button was attached to a message sent via the bot (in inline mode), the field inline_message_id will be present. Exactly one of the fields data or game_short_name will be present.
    public class CallbackQuery: Codable {

        /// Unique identifier for this query
        public var id: String

        /// Sender
        public var from: User

        /// Optional. Message with the callback button that originated the query. Note that message content and message date will not be available if the message is too old
        public var message: Message?

        /// Optional. Identifier of the message sent via the bot in inline mode, that originated the query.
        public var inlineMessageId: String?

        /// Global identifier, uniquely corresponding to the chat to which the message with the callback button was sent. Useful for high scores in games.
        public var chatInstance: String

        /// Optional. Data associated with the callback button. Be aware that a bad client can send arbitrary data in this field.
        public var data: String?

        /// Optional. Short name of a Game to be returned, serves as the unique identifier for the game
        public var gameShortName: String?

        /// CallbackQuery initialization
        ///
        /// - parameter id:  Unique identifier for this query
        /// - parameter from:  Sender
        /// - parameter message:  Optional. Message with the callback button that originated the query. Note that message content and message date will not be available if the message is too old
        /// - parameter inlineMessageId:  Optional. Identifier of the message sent via the bot in inline mode, that originated the query.
        /// - parameter chatInstance:  Global identifier, uniquely corresponding to the chat to which the message with the callback button was sent. Useful for high scores in games.
        /// - parameter data:  Optional. Data associated with the callback button. Be aware that a bad client can send arbitrary data in this field.
        /// - parameter gameShortName:  Optional. Short name of a Game to be returned, serves as the unique identifier for the game
        ///
        /// - returns: The new `CallbackQuery` instance.
        ///
        public init(id: String, from: User, message: Message? = nil, inlineMessageId: String? = nil, chatInstance: String, data: String? = nil, gameShortName: String? = nil) {
            self.id = id
            self.from = from
            self.message = message
            self.inlineMessageId = inlineMessageId
            self.chatInstance = chatInstance
            self.data = data
            self.gameShortName = gameShortName
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case from = "from"
            case message = "message"
            case inlineMessageId = "inline_message_id"
            case chatInstance = "chat_instance"
            case data = "data"
            case gameShortName = "game_short_name"
        }

    }

    /// Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot’s message and tapped ’Reply’). This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice privacy mode.
    public class ForceReply: Codable {

        /// Shows reply interface to the user, as if they manually selected the bot’s message and tapped ’Reply’
        public var forceReply: Bool

        /// Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.
        public var selective: Bool?

        /// ForceReply initialization
        ///
        /// - parameter forceReply:  Shows reply interface to the user, as if they manually selected the bot’s message and tapped ’Reply’
        /// - parameter selective:  Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.
        ///
        /// - returns: The new `ForceReply` instance.
        ///
        public init(forceReply: Bool, selective: Bool? = nil) {
            self.forceReply = forceReply
            self.selective = selective
        }

        private enum CodingKeys: String, CodingKey {
            case forceReply = "force_reply"
            case selective = "selective"
        }

    }

    /// This object represents a chat photo.
    public class ChatPhoto: Codable {

        /// File identifier of small (160x160) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
        public var smallFileId: String

        /// Unique file identifier of small (160x160) chat photo, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var smallFileUniqueId: String

        /// File identifier of big (640x640) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
        public var bigFileId: String

        /// Unique file identifier of big (640x640) chat photo, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var bigFileUniqueId: String

        /// ChatPhoto initialization
        ///
        /// - parameter smallFileId:  File identifier of small (160x160) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
        /// - parameter smallFileUniqueId:  Unique file identifier of small (160x160) chat photo, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter bigFileId:  File identifier of big (640x640) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
        /// - parameter bigFileUniqueId:  Unique file identifier of big (640x640) chat photo, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        ///
        /// - returns: The new `ChatPhoto` instance.
        ///
        public init(smallFileId: String, smallFileUniqueId: String, bigFileId: String, bigFileUniqueId: String) {
            self.smallFileId = smallFileId
            self.smallFileUniqueId = smallFileUniqueId
            self.bigFileId = bigFileId
            self.bigFileUniqueId = bigFileUniqueId
        }

        private enum CodingKeys: String, CodingKey {
            case smallFileId = "small_file_id"
            case smallFileUniqueId = "small_file_unique_id"
            case bigFileId = "big_file_id"
            case bigFileUniqueId = "big_file_unique_id"
        }

    }

    /// Represents an invite link for a chat.
    public class ChatInviteLink: Codable {

        /// The invite link. If the link was created by another chat administrator, then the second part of the link will be replaced with “…”.
        public var inviteLink: String

        /// Creator of the link
        public var creator: User

        /// True, if the link is primary
        public var isPrimary: Bool

        /// True, if the link is revoked
        public var isRevoked: Bool

        /// Optional. Point in time (Unix timestamp) when the link will expire or has been expired
        public var expireDate: Int?

        /// Optional. Maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
        public var memberLimit: Int?

        /// ChatInviteLink initialization
        ///
        /// - parameter inviteLink:  The invite link. If the link was created by another chat administrator, then the second part of the link will be replaced with “…”.
        /// - parameter creator:  Creator of the link
        /// - parameter isPrimary:  True, if the link is primary
        /// - parameter isRevoked:  True, if the link is revoked
        /// - parameter expireDate:  Optional. Point in time (Unix timestamp) when the link will expire or has been expired
        /// - parameter memberLimit:  Optional. Maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
        ///
        /// - returns: The new `ChatInviteLink` instance.
        ///
        public init(inviteLink: String, creator: User, isPrimary: Bool, isRevoked: Bool, expireDate: Int? = nil, memberLimit: Int? = nil) {
            self.inviteLink = inviteLink
            self.creator = creator
            self.isPrimary = isPrimary
            self.isRevoked = isRevoked
            self.expireDate = expireDate
            self.memberLimit = memberLimit
        }

        private enum CodingKeys: String, CodingKey {
            case inviteLink = "invite_link"
            case creator = "creator"
            case isPrimary = "is_primary"
            case isRevoked = "is_revoked"
            case expireDate = "expire_date"
            case memberLimit = "member_limit"
        }

    }

    /// This object contains information about one member of a chat.
    public class ChatMember: Codable {

        /// Information about the user
        public var user: User

        /// The member’s status in the chat. Can be “creator”, “administrator”, “member”, “restricted”, “left” or “kicked”
        public var status: String

        /// Optional. Owner and administrators only. Custom title for this user
        public var customTitle: String?

        /// Optional. Owner and administrators only. True, if the user’s presence in the chat is hidden
        public var isAnonymous: Bool?

        /// Optional. Administrators only. True, if the bot is allowed to edit administrator privileges of that user
        public var canBeEdited: Bool?

        /// Optional. Administrators only. True, if the administrator can access the chat event log, chat statistics, message statistics in channels, see channel members, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
        public var canManageChat: Bool?

        /// Optional. Administrators only. True, if the administrator can post in the channel; channels only
        public var canPostMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can edit messages of other users and can pin messages; channels only
        public var canEditMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can delete messages of other users
        public var canDeleteMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can manage voice chats
        public var canManageVoiceChats: Bool?

        /// Optional. Administrators only. True, if the administrator can restrict, ban or unban chat members
        public var canRestrictMembers: Bool?

        /// Optional. Administrators only. True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        public var canPromoteMembers: Bool?

        /// Optional. Administrators and restricted only. True, if the user is allowed to change the chat title, photo and other settings
        public var canChangeInfo: Bool?

        /// Optional. Administrators and restricted only. True, if the user is allowed to invite new users to the chat
        public var canInviteUsers: Bool?

        /// Optional. Administrators and restricted only. True, if the user is allowed to pin messages; groups and supergroups only
        public var canPinMessages: Bool?

        /// Optional. Restricted only. True, if the user is a member of the chat at the moment of the request
        public var isMember: Bool?

        /// Optional. Restricted only. True, if the user is allowed to send text messages, contacts, locations and venues
        public var canSendMessages: Bool?

        /// Optional. Restricted only. True, if the user is allowed to send audios, documents, photos, videos, video notes and voice notes
        public var canSendMediaMessages: Bool?

        /// Optional. Restricted only. True, if the user is allowed to send polls
        public var canSendPolls: Bool?

        /// Optional. Restricted only. True, if the user is allowed to send animations, games, stickers and use inline bots
        public var canSendOtherMessages: Bool?

        /// Optional. Restricted only. True, if the user is allowed to add web page previews to their messages
        public var canAddWebPagePreviews: Bool?

        /// Optional. Restricted and kicked only. Date when restrictions will be lifted for this user; unix time
        public var untilDate: Int?

        /// ChatMember initialization
        ///
        /// - parameter user:  Information about the user
        /// - parameter status:  The member’s status in the chat. Can be “creator”, “administrator”, “member”, “restricted”, “left” or “kicked”
        /// - parameter customTitle:  Optional. Owner and administrators only. Custom title for this user
        /// - parameter isAnonymous:  Optional. Owner and administrators only. True, if the user’s presence in the chat is hidden
        /// - parameter canBeEdited:  Optional. Administrators only. True, if the bot is allowed to edit administrator privileges of that user
        /// - parameter canManageChat:  Optional. Administrators only. True, if the administrator can access the chat event log, chat statistics, message statistics in channels, see channel members, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
        /// - parameter canPostMessages:  Optional. Administrators only. True, if the administrator can post in the channel; channels only
        /// - parameter canEditMessages:  Optional. Administrators only. True, if the administrator can edit messages of other users and can pin messages; channels only
        /// - parameter canDeleteMessages:  Optional. Administrators only. True, if the administrator can delete messages of other users
        /// - parameter canManageVoiceChats:  Optional. Administrators only. True, if the administrator can manage voice chats
        /// - parameter canRestrictMembers:  Optional. Administrators only. True, if the administrator can restrict, ban or unban chat members
        /// - parameter canPromoteMembers:  Optional. Administrators only. True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        /// - parameter canChangeInfo:  Optional. Administrators and restricted only. True, if the user is allowed to change the chat title, photo and other settings
        /// - parameter canInviteUsers:  Optional. Administrators and restricted only. True, if the user is allowed to invite new users to the chat
        /// - parameter canPinMessages:  Optional. Administrators and restricted only. True, if the user is allowed to pin messages; groups and supergroups only
        /// - parameter isMember:  Optional. Restricted only. True, if the user is a member of the chat at the moment of the request
        /// - parameter canSendMessages:  Optional. Restricted only. True, if the user is allowed to send text messages, contacts, locations and venues
        /// - parameter canSendMediaMessages:  Optional. Restricted only. True, if the user is allowed to send audios, documents, photos, videos, video notes and voice notes
        /// - parameter canSendPolls:  Optional. Restricted only. True, if the user is allowed to send polls
        /// - parameter canSendOtherMessages:  Optional. Restricted only. True, if the user is allowed to send animations, games, stickers and use inline bots
        /// - parameter canAddWebPagePreviews:  Optional. Restricted only. True, if the user is allowed to add web page previews to their messages
        /// - parameter untilDate:  Optional. Restricted and kicked only. Date when restrictions will be lifted for this user; unix time
        ///
        /// - returns: The new `ChatMember` instance.
        ///
        public init(user: User, status: String, customTitle: String? = nil, isAnonymous: Bool? = nil, canBeEdited: Bool? = nil, canManageChat: Bool? = nil, canPostMessages: Bool? = nil, canEditMessages: Bool? = nil, canDeleteMessages: Bool? = nil, canManageVoiceChats: Bool? = nil, canRestrictMembers: Bool? = nil, canPromoteMembers: Bool? = nil, canChangeInfo: Bool? = nil, canInviteUsers: Bool? = nil, canPinMessages: Bool? = nil, isMember: Bool? = nil, canSendMessages: Bool? = nil, canSendMediaMessages: Bool? = nil, canSendPolls: Bool? = nil, canSendOtherMessages: Bool? = nil, canAddWebPagePreviews: Bool? = nil, untilDate: Int? = nil) {
            self.user = user
            self.status = status
            self.customTitle = customTitle
            self.isAnonymous = isAnonymous
            self.canBeEdited = canBeEdited
            self.canManageChat = canManageChat
            self.canPostMessages = canPostMessages
            self.canEditMessages = canEditMessages
            self.canDeleteMessages = canDeleteMessages
            self.canManageVoiceChats = canManageVoiceChats
            self.canRestrictMembers = canRestrictMembers
            self.canPromoteMembers = canPromoteMembers
            self.canChangeInfo = canChangeInfo
            self.canInviteUsers = canInviteUsers
            self.canPinMessages = canPinMessages
            self.isMember = isMember
            self.canSendMessages = canSendMessages
            self.canSendMediaMessages = canSendMediaMessages
            self.canSendPolls = canSendPolls
            self.canSendOtherMessages = canSendOtherMessages
            self.canAddWebPagePreviews = canAddWebPagePreviews
            self.untilDate = untilDate
        }

        private enum CodingKeys: String, CodingKey {
            case user = "user"
            case status = "status"
            case customTitle = "custom_title"
            case isAnonymous = "is_anonymous"
            case canBeEdited = "can_be_edited"
            case canManageChat = "can_manage_chat"
            case canPostMessages = "can_post_messages"
            case canEditMessages = "can_edit_messages"
            case canDeleteMessages = "can_delete_messages"
            case canManageVoiceChats = "can_manage_voice_chats"
            case canRestrictMembers = "can_restrict_members"
            case canPromoteMembers = "can_promote_members"
            case canChangeInfo = "can_change_info"
            case canInviteUsers = "can_invite_users"
            case canPinMessages = "can_pin_messages"
            case isMember = "is_member"
            case canSendMessages = "can_send_messages"
            case canSendMediaMessages = "can_send_media_messages"
            case canSendPolls = "can_send_polls"
            case canSendOtherMessages = "can_send_other_messages"
            case canAddWebPagePreviews = "can_add_web_page_previews"
            case untilDate = "until_date"
        }

    }

    /// This object represents changes in the status of a chat member.
    public class ChatMemberUpdated: Codable {

        /// Chat the user belongs to
        public var chat: Chat

        /// Performer of the action, which resulted in the change
        public var from: User

        /// Date the change was done in Unix time
        public var date: Int

        /// Previous information about the chat member
        public var oldChatMember: ChatMember

        /// New information about the chat member
        public var newChatMember: ChatMember

        /// Optional. Chat invite link, which was used by the user to join the chat; for joining by invite link events only.
        public var inviteLink: ChatInviteLink?

        /// ChatMemberUpdated initialization
        ///
        /// - parameter chat:  Chat the user belongs to
        /// - parameter from:  Performer of the action, which resulted in the change
        /// - parameter date:  Date the change was done in Unix time
        /// - parameter oldChatMember:  Previous information about the chat member
        /// - parameter newChatMember:  New information about the chat member
        /// - parameter inviteLink:  Optional. Chat invite link, which was used by the user to join the chat; for joining by invite link events only.
        ///
        /// - returns: The new `ChatMemberUpdated` instance.
        ///
        public init(chat: Chat, from: User, date: Int, oldChatMember: ChatMember, newChatMember: ChatMember, inviteLink: ChatInviteLink? = nil) {
            self.chat = chat
            self.from = from
            self.date = date
            self.oldChatMember = oldChatMember
            self.newChatMember = newChatMember
            self.inviteLink = inviteLink
        }

        private enum CodingKeys: String, CodingKey {
            case chat = "chat"
            case from = "from"
            case date = "date"
            case oldChatMember = "old_chat_member"
            case newChatMember = "new_chat_member"
            case inviteLink = "invite_link"
        }

    }

    /// Describes actions that a non-administrator user is allowed to take in a chat.
    public class ChatPermissions: Codable {

        /// Optional. True, if the user is allowed to send text messages, contacts, locations and venues
        public var canSendMessages: Bool?

        /// Optional. True, if the user is allowed to send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
        public var canSendMediaMessages: Bool?

        /// Optional. True, if the user is allowed to send polls, implies can_send_messages
        public var canSendPolls: Bool?

        /// Optional. True, if the user is allowed to send animations, games, stickers and use inline bots, implies can_send_media_messages
        public var canSendOtherMessages: Bool?

        /// Optional. True, if the user is allowed to add web page previews to their messages, implies can_send_media_messages
        public var canAddWebPagePreviews: Bool?

        /// Optional. True, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups
        public var canChangeInfo: Bool?

        /// Optional. True, if the user is allowed to invite new users to the chat
        public var canInviteUsers: Bool?

        /// Optional. True, if the user is allowed to pin messages. Ignored in public supergroups
        public var canPinMessages: Bool?

        /// ChatPermissions initialization
        ///
        /// - parameter canSendMessages:  Optional. True, if the user is allowed to send text messages, contacts, locations and venues
        /// - parameter canSendMediaMessages:  Optional. True, if the user is allowed to send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
        /// - parameter canSendPolls:  Optional. True, if the user is allowed to send polls, implies can_send_messages
        /// - parameter canSendOtherMessages:  Optional. True, if the user is allowed to send animations, games, stickers and use inline bots, implies can_send_media_messages
        /// - parameter canAddWebPagePreviews:  Optional. True, if the user is allowed to add web page previews to their messages, implies can_send_media_messages
        /// - parameter canChangeInfo:  Optional. True, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups
        /// - parameter canInviteUsers:  Optional. True, if the user is allowed to invite new users to the chat
        /// - parameter canPinMessages:  Optional. True, if the user is allowed to pin messages. Ignored in public supergroups
        ///
        /// - returns: The new `ChatPermissions` instance.
        ///
        public init(canSendMessages: Bool? = nil, canSendMediaMessages: Bool? = nil, canSendPolls: Bool? = nil, canSendOtherMessages: Bool? = nil, canAddWebPagePreviews: Bool? = nil, canChangeInfo: Bool? = nil, canInviteUsers: Bool? = nil, canPinMessages: Bool? = nil) {
            self.canSendMessages = canSendMessages
            self.canSendMediaMessages = canSendMediaMessages
            self.canSendPolls = canSendPolls
            self.canSendOtherMessages = canSendOtherMessages
            self.canAddWebPagePreviews = canAddWebPagePreviews
            self.canChangeInfo = canChangeInfo
            self.canInviteUsers = canInviteUsers
            self.canPinMessages = canPinMessages
        }

        private enum CodingKeys: String, CodingKey {
            case canSendMessages = "can_send_messages"
            case canSendMediaMessages = "can_send_media_messages"
            case canSendPolls = "can_send_polls"
            case canSendOtherMessages = "can_send_other_messages"
            case canAddWebPagePreviews = "can_add_web_page_previews"
            case canChangeInfo = "can_change_info"
            case canInviteUsers = "can_invite_users"
            case canPinMessages = "can_pin_messages"
        }

    }

    /// Represents a location to which a chat is connected.
    public class ChatLocation: Codable {

        /// The location to which the supergroup is connected. Can’t be a live location.
        public var location: Location

        /// Location address; 1-64 characters, as defined by the chat owner
        public var address: String

        /// ChatLocation initialization
        ///
        /// - parameter location:  The location to which the supergroup is connected. Can’t be a live location.
        /// - parameter address:  Location address; 1-64 characters, as defined by the chat owner
        ///
        /// - returns: The new `ChatLocation` instance.
        ///
        public init(location: Location, address: String) {
            self.location = location
            self.address = address
        }

        private enum CodingKeys: String, CodingKey {
            case location = "location"
            case address = "address"
        }

    }

    /// This object represents a bot command.
    public class BotCommand: Codable {

        /// Text of the command, 1-32 characters. Can contain only lowercase English letters, digits and underscores.
        public var command: String

        /// Description of the command, 3-256 characters.
        public var description: String

        /// BotCommand initialization
        ///
        /// - parameter command:  Text of the command, 1-32 characters. Can contain only lowercase English letters, digits and underscores.
        /// - parameter description:  Description of the command, 3-256 characters.
        ///
        /// - returns: The new `BotCommand` instance.
        ///
        public init(command: String, description: String) {
            self.command = command
            self.description = description
        }

        private enum CodingKeys: String, CodingKey {
            case command = "command"
            case description = "description"
        }

    }

    /// Contains information about why a request was unsuccessful.
    public class ResponseParameters: Codable {

        /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        public var migrateToChatId: Int?

        /// Optional. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated
        public var retryAfter: Int?

        /// ResponseParameters initialization
        ///
        /// - parameter migrateToChatId:  Optional. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter retryAfter:  Optional. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated
        ///
        /// - returns: The new `ResponseParameters` instance.
        ///
        public init(migrateToChatId: Int? = nil, retryAfter: Int? = nil) {
            self.migrateToChatId = migrateToChatId
            self.retryAfter = retryAfter
        }

        private enum CodingKeys: String, CodingKey {
            case migrateToChatId = "migrate_to_chat_id"
            case retryAfter = "retry_after"
        }

    }

    /// This object represents the content of a media message to be sent. It should be one of
    public enum InputMedia: Codable {

        case animation(InputMediaAnimation)
        case document(InputMediaDocument)
        case audio(InputMediaAudio)
        case photo(InputMediaPhoto)
        case video(InputMediaVideo)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let animation = try? container.decode(InputMediaAnimation.self) {
                self = .animation(animation)
            } else if let document = try? container.decode(InputMediaDocument.self) {
                self = .document(document)
            } else if let audio = try? container.decode(InputMediaAudio.self) {
                self = .audio(audio)
            } else if let photo = try? container.decode(InputMediaPhoto.self) {
                self = .photo(photo)
            } else if let video = try? container.decode(InputMediaVideo.self) {
                self = .video(video)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "InputMedia"])
            }
        }

        public init(_ animation: InputMediaAnimation) {
            self = .animation(animation)
        }

        public init(_ document: InputMediaDocument) {
            self = .document(document)
        }

        public init(_ audio: InputMediaAudio) {
            self = .audio(audio)
        }

        public init(_ photo: InputMediaPhoto) {
            self = .photo(photo)
        }

        public init(_ video: InputMediaVideo) {
            self = .video(video)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .animation(let animation):
                try container.encode(animation)
            case .document(let document):
                try container.encode(document)
            case .audio(let audio):
                try container.encode(audio)
            case .photo(let photo):
                try container.encode(photo)
            case .video(let video):
                try container.encode(video)
            }
        }
    }
    /// Represents a photo to be sent.
    public class InputMediaPhoto: Codable {

        /// Type of the result, must be photo
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        public var media: String

        /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// InputMediaPhoto initialization
        ///
        /// - parameter type:  Type of the result, must be photo
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        ///
        /// - returns: The new `InputMediaPhoto` instance.
        ///
        public init(type: String, media: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil) {
            self.type = type
            self.media = media
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
        }

    }

    /// Represents a video to be sent.
    public class InputMediaVideo: Codable {

        /// Type of the result, must be video
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Video width
        public var width: Int?

        /// Optional. Video height
        public var height: Int?

        /// Optional. Video duration
        public var duration: Int?

        /// Optional. Pass True, if the uploaded video is suitable for streaming
        public var supportsStreaming: Bool?

        /// InputMediaVideo initialization
        ///
        /// - parameter type:  Type of the result, must be video
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter width:  Optional. Video width
        /// - parameter height:  Optional. Video height
        /// - parameter duration:  Optional. Video duration
        /// - parameter supportsStreaming:  Optional. Pass True, if the uploaded video is suitable for streaming
        ///
        /// - returns: The new `InputMediaVideo` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil, supportsStreaming: Bool? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.width = width
            self.height = height
            self.duration = duration
            self.supportsStreaming = supportsStreaming
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumb = "thumb"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case width = "width"
            case height = "height"
            case duration = "duration"
            case supportsStreaming = "supports_streaming"
        }

    }

    /// Represents an animation file (GIF or H.264/MPEG-4 AVC video without sound) to be sent.
    public class InputMediaAnimation: Codable {

        /// Type of the result, must be animation
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the animation to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the animation caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Animation width
        public var width: Int?

        /// Optional. Animation height
        public var height: Int?

        /// Optional. Animation duration
        public var duration: Int?

        /// InputMediaAnimation initialization
        ///
        /// - parameter type:  Type of the result, must be animation
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the animation to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the animation caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter width:  Optional. Animation width
        /// - parameter height:  Optional. Animation height
        /// - parameter duration:  Optional. Animation duration
        ///
        /// - returns: The new `InputMediaAnimation` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.width = width
            self.height = height
            self.duration = duration
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumb = "thumb"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case width = "width"
            case height = "height"
            case duration = "duration"
        }

    }

    /// Represents an audio file to be treated as music to be sent.
    public class InputMediaAudio: Codable {

        /// Type of the result, must be audio
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the audio to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Duration of the audio in seconds
        public var duration: Int?

        /// Optional. Performer of the audio
        public var performer: String?

        /// Optional. Title of the audio
        public var title: String?

        /// InputMediaAudio initialization
        ///
        /// - parameter type:  Type of the result, must be audio
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the audio to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter duration:  Optional. Duration of the audio in seconds
        /// - parameter performer:  Optional. Performer of the audio
        /// - parameter title:  Optional. Title of the audio
        ///
        /// - returns: The new `InputMediaAudio` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, duration: Int? = nil, performer: String? = nil, title: String? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.duration = duration
            self.performer = performer
            self.title = title
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumb = "thumb"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case duration = "duration"
            case performer = "performer"
            case title = "title"
        }

    }

    /// Represents a general file to be sent.
    public class InputMediaDocument: Codable {

        /// Type of the result, must be document
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Disables automatic server-side content type detection for files uploaded using multipart/form-data. Always true, if the document is sent as part of an album.
        public var disableContentTypeDetection: Bool?

        /// InputMediaDocument initialization
        ///
        /// - parameter type:  Type of the result, must be document
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter disableContentTypeDetection:  Optional. Disables automatic server-side content type detection for files uploaded using multipart/form-data. Always true, if the document is sent as part of an album.
        ///
        /// - returns: The new `InputMediaDocument` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, disableContentTypeDetection: Bool? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.disableContentTypeDetection = disableContentTypeDetection
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumb = "thumb"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case disableContentTypeDetection = "disable_content_type_detection"
        }

    }

    /// This object represents the contents of a file to be uploaded. Must be posted using multipart/form-data in the usual way that files are uploaded via the browser.
    public struct InputFile: Codable {

    }

    /// This object represents a sticker.
    public class Sticker: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Sticker width
        public var width: Int

        /// Sticker height
        public var height: Int

        /// True, if the sticker is [animated](https://telegram.org/blog/animated-stickers)
        public var isAnimated: Bool

        /// Optional. Sticker thumbnail in the .WEBP or .JPG format
        public var thumb: PhotoSize?

        /// Optional. Emoji associated with the sticker
        public var emoji: String?

        /// Optional. Name of the sticker set to which the sticker belongs
        public var setName: String?

        /// Optional. For mask stickers, the position where the mask should be placed
        public var maskPosition: MaskPosition?

        /// Optional. File size
        public var fileSize: Int?

        /// Sticker initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Sticker width
        /// - parameter height:  Sticker height
        /// - parameter isAnimated:  True, if the sticker is [animated](https://telegram.org/blog/animated-stickers)
        /// - parameter thumb:  Optional. Sticker thumbnail in the .WEBP or .JPG format
        /// - parameter emoji:  Optional. Emoji associated with the sticker
        /// - parameter setName:  Optional. Name of the sticker set to which the sticker belongs
        /// - parameter maskPosition:  Optional. For mask stickers, the position where the mask should be placed
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Sticker` instance.
        ///
        public init(fileId: String, fileUniqueId: String, width: Int, height: Int, isAnimated: Bool, thumb: PhotoSize? = nil, emoji: String? = nil, setName: String? = nil, maskPosition: MaskPosition? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.width = width
            self.height = height
            self.isAnimated = isAnimated
            self.thumb = thumb
            self.emoji = emoji
            self.setName = setName
            self.maskPosition = maskPosition
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case width = "width"
            case height = "height"
            case isAnimated = "is_animated"
            case thumb = "thumb"
            case emoji = "emoji"
            case setName = "set_name"
            case maskPosition = "mask_position"
            case fileSize = "file_size"
        }

    }

    /// This object represents a sticker set.
    public class StickerSet: Codable {

        /// Sticker set name
        public var name: String

        /// Sticker set title
        public var title: String

        /// True, if the sticker set contains [animated stickers](https://telegram.org/blog/animated-stickers)
        public var isAnimated: Bool

        /// True, if the sticker set contains masks
        public var containsMasks: Bool

        /// List of all set stickers
        public var stickers: [Sticker]

        /// Optional. Sticker set thumbnail in the .WEBP or .TGS format
        public var thumb: PhotoSize?

        /// StickerSet initialization
        ///
        /// - parameter name:  Sticker set name
        /// - parameter title:  Sticker set title
        /// - parameter isAnimated:  True, if the sticker set contains [animated stickers](https://telegram.org/blog/animated-stickers)
        /// - parameter containsMasks:  True, if the sticker set contains masks
        /// - parameter stickers:  List of all set stickers
        /// - parameter thumb:  Optional. Sticker set thumbnail in the .WEBP or .TGS format
        ///
        /// - returns: The new `StickerSet` instance.
        ///
        public init(name: String, title: String, isAnimated: Bool, containsMasks: Bool, stickers: [Sticker], thumb: PhotoSize? = nil) {
            self.name = name
            self.title = title
            self.isAnimated = isAnimated
            self.containsMasks = containsMasks
            self.stickers = stickers
            self.thumb = thumb
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case title = "title"
            case isAnimated = "is_animated"
            case containsMasks = "contains_masks"
            case stickers = "stickers"
            case thumb = "thumb"
        }

    }

    /// This object describes the position on faces where a mask should be placed by default.
    public class MaskPosition: Codable {

        /// The part of the face relative to which the mask should be placed. One of “forehead”, “eyes”, “mouth”, or “chin”.
        public var point: String

        /// Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position.
        public var xShift: Float

        /// Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.
        public var yShift: Float

        /// Mask scaling coefficient. For example, 2.0 means double size.
        public var scale: Float

        /// MaskPosition initialization
        ///
        /// - parameter point:  The part of the face relative to which the mask should be placed. One of “forehead”, “eyes”, “mouth”, or “chin”.
        /// - parameter xShift:  Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position.
        /// - parameter yShift:  Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.
        /// - parameter scale:  Mask scaling coefficient. For example, 2.0 means double size.
        ///
        /// - returns: The new `MaskPosition` instance.
        ///
        public init(point: String, xShift: Float, yShift: Float, scale: Float) {
            self.point = point
            self.xShift = xShift
            self.yShift = yShift
            self.scale = scale
        }

        private enum CodingKeys: String, CodingKey {
            case point = "point"
            case xShift = "x_shift"
            case yShift = "y_shift"
            case scale = "scale"
        }

    }

    /// This object represents an incoming inline query. When the user sends an empty query, your bot could return some default or trending results.
    public class InlineQuery: Codable {

        /// Unique identifier for this query
        public var id: String

        /// Sender
        public var from: User

        /// Text of the query (up to 256 characters)
        public var query: String

        /// Offset of the results to be returned, can be controlled by the bot
        public var offset: String

        /// Optional. Type of the chat, from which the inline query was sent. Can be either “sender” for a private chat with the inline query sender, “private”, “group”, “supergroup”, or “channel”. The chat type should be always known for requests sent from official clients and most third-party clients, unless the request was sent from a secret chat
        public var chatType: String?

        /// Optional. Sender location, only for bots that request user location
        public var location: Location?

        /// InlineQuery initialization
        ///
        /// - parameter id:  Unique identifier for this query
        /// - parameter from:  Sender
        /// - parameter query:  Text of the query (up to 256 characters)
        /// - parameter offset:  Offset of the results to be returned, can be controlled by the bot
        /// - parameter chatType:  Optional. Type of the chat, from which the inline query was sent. Can be either “sender” for a private chat with the inline query sender, “private”, “group”, “supergroup”, or “channel”. The chat type should be always known for requests sent from official clients and most third-party clients, unless the request was sent from a secret chat
        /// - parameter location:  Optional. Sender location, only for bots that request user location
        ///
        /// - returns: The new `InlineQuery` instance.
        ///
        public init(id: String, from: User, query: String, offset: String, chatType: String? = nil, location: Location? = nil) {
            self.id = id
            self.from = from
            self.query = query
            self.offset = offset
            self.chatType = chatType
            self.location = location
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case from = "from"
            case query = "query"
            case offset = "offset"
            case chatType = "chat_type"
            case location = "location"
        }

    }

    /// Note: All URLs passed in inline query results will be available to end users and therefore must be assumed to be public.
    public enum InlineQueryResult: Codable {

        case cachedAudio(InlineQueryResultCachedAudio)
        case cachedDocument(InlineQueryResultCachedDocument)
        case cachedGif(InlineQueryResultCachedGif)
        case cachedMpeg4Gif(InlineQueryResultCachedMpeg4Gif)
        case cachedPhoto(InlineQueryResultCachedPhoto)
        case cachedSticker(InlineQueryResultCachedSticker)
        case cachedVideo(InlineQueryResultCachedVideo)
        case cachedVoice(InlineQueryResultCachedVoice)
        case article(InlineQueryResultArticle)
        case audio(InlineQueryResultAudio)
        case contact(InlineQueryResultContact)
        case game(InlineQueryResultGame)
        case document(InlineQueryResultDocument)
        case gif(InlineQueryResultGif)
        case location(InlineQueryResultLocation)
        case mpeg4Gif(InlineQueryResultMpeg4Gif)
        case photo(InlineQueryResultPhoto)
        case venue(InlineQueryResultVenue)
        case video(InlineQueryResultVideo)
        case voice(InlineQueryResultVoice)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let cachedAudio = try? container.decode(InlineQueryResultCachedAudio.self) {
                self = .cachedAudio(cachedAudio)
            } else if let cachedDocument = try? container.decode(InlineQueryResultCachedDocument.self) {
                self = .cachedDocument(cachedDocument)
            } else if let cachedGif = try? container.decode(InlineQueryResultCachedGif.self) {
                self = .cachedGif(cachedGif)
            } else if let cachedMpeg4Gif = try? container.decode(InlineQueryResultCachedMpeg4Gif.self) {
                self = .cachedMpeg4Gif(cachedMpeg4Gif)
            } else if let cachedPhoto = try? container.decode(InlineQueryResultCachedPhoto.self) {
                self = .cachedPhoto(cachedPhoto)
            } else if let cachedSticker = try? container.decode(InlineQueryResultCachedSticker.self) {
                self = .cachedSticker(cachedSticker)
            } else if let cachedVideo = try? container.decode(InlineQueryResultCachedVideo.self) {
                self = .cachedVideo(cachedVideo)
            } else if let cachedVoice = try? container.decode(InlineQueryResultCachedVoice.self) {
                self = .cachedVoice(cachedVoice)
            } else if let article = try? container.decode(InlineQueryResultArticle.self) {
                self = .article(article)
            } else if let audio = try? container.decode(InlineQueryResultAudio.self) {
                self = .audio(audio)
            } else if let contact = try? container.decode(InlineQueryResultContact.self) {
                self = .contact(contact)
            } else if let game = try? container.decode(InlineQueryResultGame.self) {
                self = .game(game)
            } else if let document = try? container.decode(InlineQueryResultDocument.self) {
                self = .document(document)
            } else if let gif = try? container.decode(InlineQueryResultGif.self) {
                self = .gif(gif)
            } else if let location = try? container.decode(InlineQueryResultLocation.self) {
                self = .location(location)
            } else if let mpeg4Gif = try? container.decode(InlineQueryResultMpeg4Gif.self) {
                self = .mpeg4Gif(mpeg4Gif)
            } else if let photo = try? container.decode(InlineQueryResultPhoto.self) {
                self = .photo(photo)
            } else if let venue = try? container.decode(InlineQueryResultVenue.self) {
                self = .venue(venue)
            } else if let video = try? container.decode(InlineQueryResultVideo.self) {
                self = .video(video)
            } else if let voice = try? container.decode(InlineQueryResultVoice.self) {
                self = .voice(voice)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "InlineQueryResult"])
            }
        }

        public init(_ cachedAudio: InlineQueryResultCachedAudio) {
            self = .cachedAudio(cachedAudio)
        }

        public init(_ cachedDocument: InlineQueryResultCachedDocument) {
            self = .cachedDocument(cachedDocument)
        }

        public init(_ cachedGif: InlineQueryResultCachedGif) {
            self = .cachedGif(cachedGif)
        }

        public init(_ cachedMpeg4Gif: InlineQueryResultCachedMpeg4Gif) {
            self = .cachedMpeg4Gif(cachedMpeg4Gif)
        }

        public init(_ cachedPhoto: InlineQueryResultCachedPhoto) {
            self = .cachedPhoto(cachedPhoto)
        }

        public init(_ cachedSticker: InlineQueryResultCachedSticker) {
            self = .cachedSticker(cachedSticker)
        }

        public init(_ cachedVideo: InlineQueryResultCachedVideo) {
            self = .cachedVideo(cachedVideo)
        }

        public init(_ cachedVoice: InlineQueryResultCachedVoice) {
            self = .cachedVoice(cachedVoice)
        }

        public init(_ article: InlineQueryResultArticle) {
            self = .article(article)
        }

        public init(_ audio: InlineQueryResultAudio) {
            self = .audio(audio)
        }

        public init(_ contact: InlineQueryResultContact) {
            self = .contact(contact)
        }

        public init(_ game: InlineQueryResultGame) {
            self = .game(game)
        }

        public init(_ document: InlineQueryResultDocument) {
            self = .document(document)
        }

        public init(_ gif: InlineQueryResultGif) {
            self = .gif(gif)
        }

        public init(_ location: InlineQueryResultLocation) {
            self = .location(location)
        }

        public init(_ mpeg4Gif: InlineQueryResultMpeg4Gif) {
            self = .mpeg4Gif(mpeg4Gif)
        }

        public init(_ photo: InlineQueryResultPhoto) {
            self = .photo(photo)
        }

        public init(_ venue: InlineQueryResultVenue) {
            self = .venue(venue)
        }

        public init(_ video: InlineQueryResultVideo) {
            self = .video(video)
        }

        public init(_ voice: InlineQueryResultVoice) {
            self = .voice(voice)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .cachedAudio(let cachedAudio):
                try container.encode(cachedAudio)
            case .cachedDocument(let cachedDocument):
                try container.encode(cachedDocument)
            case .cachedGif(let cachedGif):
                try container.encode(cachedGif)
            case .cachedMpeg4Gif(let cachedMpeg4Gif):
                try container.encode(cachedMpeg4Gif)
            case .cachedPhoto(let cachedPhoto):
                try container.encode(cachedPhoto)
            case .cachedSticker(let cachedSticker):
                try container.encode(cachedSticker)
            case .cachedVideo(let cachedVideo):
                try container.encode(cachedVideo)
            case .cachedVoice(let cachedVoice):
                try container.encode(cachedVoice)
            case .article(let article):
                try container.encode(article)
            case .audio(let audio):
                try container.encode(audio)
            case .contact(let contact):
                try container.encode(contact)
            case .game(let game):
                try container.encode(game)
            case .document(let document):
                try container.encode(document)
            case .gif(let gif):
                try container.encode(gif)
            case .location(let location):
                try container.encode(location)
            case .mpeg4Gif(let mpeg4Gif):
                try container.encode(mpeg4Gif)
            case .photo(let photo):
                try container.encode(photo)
            case .venue(let venue):
                try container.encode(venue)
            case .video(let video):
                try container.encode(video)
            case .voice(let voice):
                try container.encode(voice)
            }
        }
    }
    /// Represents a link to an article or web page.
    public class InlineQueryResultArticle: Codable {

        /// Type of the result, must be article
        public var type: String

        /// Unique identifier for this result, 1-64 Bytes
        public var id: String

        /// Title of the result
        public var title: String

        /// Content of the message to be sent
        public var inputMessageContent: InputMessageContent

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. URL of the result
        public var url: String?

        /// Optional. Pass True, if you don’t want the URL to be shown in the message
        public var hideUrl: Bool?

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Url of the thumbnail for the result
        public var thumbUrl: String?

        /// Optional. Thumbnail width
        public var thumbWidth: Int?

        /// Optional. Thumbnail height
        public var thumbHeight: Int?

        /// InlineQueryResultArticle initialization
        ///
        /// - parameter type:  Type of the result, must be article
        /// - parameter id:  Unique identifier for this result, 1-64 Bytes
        /// - parameter title:  Title of the result
        /// - parameter inputMessageContent:  Content of the message to be sent
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter url:  Optional. URL of the result
        /// - parameter hideUrl:  Optional. Pass True, if you don’t want the URL to be shown in the message
        /// - parameter description:  Optional. Short description of the result
        /// - parameter thumbUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultArticle` instance.
        ///
        public init(type: String, id: String, title: String, inputMessageContent: InputMessageContent, replyMarkup: InlineKeyboardMarkup? = nil, url: String? = nil, hideUrl: Bool? = nil, description: String? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.title = title
            self.inputMessageContent = inputMessageContent
            self.replyMarkup = replyMarkup
            self.url = url
            self.hideUrl = hideUrl
            self.description = description
            self.thumbUrl = thumbUrl
            self.thumbWidth = thumbWidth
            self.thumbHeight = thumbHeight
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case title = "title"
            case inputMessageContent = "input_message_content"
            case replyMarkup = "reply_markup"
            case url = "url"
            case hideUrl = "hide_url"
            case description = "description"
            case thumbUrl = "thumb_url"
            case thumbWidth = "thumb_width"
            case thumbHeight = "thumb_height"
        }

    }

    /// Represents a link to a photo. By default, this photo will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
    public class InlineQueryResultPhoto: Codable {

        /// Type of the result, must be photo
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL of the photo. Photo must be in jpeg format. Photo size must not exceed 5MB
        public var photoUrl: String

        /// URL of the thumbnail for the photo
        public var thumbUrl: String

        /// Optional. Width of the photo
        public var photoWidth: Int?

        /// Optional. Height of the photo
        public var photoHeight: Int?

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the photo
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultPhoto initialization
        ///
        /// - parameter type:  Type of the result, must be photo
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter photoUrl:  A valid URL of the photo. Photo must be in jpeg format. Photo size must not exceed 5MB
        /// - parameter thumbUrl:  URL of the thumbnail for the photo
        /// - parameter photoWidth:  Optional. Width of the photo
        /// - parameter photoHeight:  Optional. Height of the photo
        /// - parameter title:  Optional. Title for the result
        /// - parameter description:  Optional. Short description of the result
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the photo
        ///
        /// - returns: The new `InlineQueryResultPhoto` instance.
        ///
        public init(type: String, id: String, photoUrl: String, thumbUrl: String, photoWidth: Int? = nil, photoHeight: Int? = nil, title: String? = nil, description: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.photoUrl = photoUrl
            self.thumbUrl = thumbUrl
            self.photoWidth = photoWidth
            self.photoHeight = photoHeight
            self.title = title
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case photoUrl = "photo_url"
            case thumbUrl = "thumb_url"
            case photoWidth = "photo_width"
            case photoHeight = "photo_height"
            case title = "title"
            case description = "description"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to an animated GIF file. By default, this animated GIF file will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
    public class InlineQueryResultGif: Codable {

        /// Type of the result, must be gif
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the GIF file. File size must not exceed 1MB
        public var gifUrl: String

        /// Optional. Width of the GIF
        public var gifWidth: Int?

        /// Optional. Height of the GIF
        public var gifHeight: Int?

        /// Optional. Duration of the GIF
        public var gifDuration: Int?

        /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        public var thumbUrl: String

        /// Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        public var thumbMimeType: String?

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the GIF animation
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultGif initialization
        ///
        /// - parameter type:  Type of the result, must be gif
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter gifUrl:  A valid URL for the GIF file. File size must not exceed 1MB
        /// - parameter gifWidth:  Optional. Width of the GIF
        /// - parameter gifHeight:  Optional. Height of the GIF
        /// - parameter gifDuration:  Optional. Duration of the GIF
        /// - parameter thumbUrl:  URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        /// - parameter thumbMimeType:  Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the GIF animation
        ///
        /// - returns: The new `InlineQueryResultGif` instance.
        ///
        public init(type: String, id: String, gifUrl: String, gifWidth: Int? = nil, gifHeight: Int? = nil, gifDuration: Int? = nil, thumbUrl: String, thumbMimeType: String? = nil, title: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.gifUrl = gifUrl
            self.gifWidth = gifWidth
            self.gifHeight = gifHeight
            self.gifDuration = gifDuration
            self.thumbUrl = thumbUrl
            self.thumbMimeType = thumbMimeType
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case gifUrl = "gif_url"
            case gifWidth = "gif_width"
            case gifHeight = "gif_height"
            case gifDuration = "gif_duration"
            case thumbUrl = "thumb_url"
            case thumbMimeType = "thumb_mime_type"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a video animation (H.264/MPEG-4 AVC video without sound). By default, this animated MPEG-4 file will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
    public class InlineQueryResultMpeg4Gif: Codable {

        /// Type of the result, must be mpeg4_gif
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the MP4 file. File size must not exceed 1MB
        public var mpeg4Url: String

        /// Optional. Video width
        public var mpeg4Width: Int?

        /// Optional. Video height
        public var mpeg4Height: Int?

        /// Optional. Video duration
        public var mpeg4Duration: Int?

        /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        public var thumbUrl: String

        /// Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        public var thumbMimeType: String?

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the video animation
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultMpeg4Gif initialization
        ///
        /// - parameter type:  Type of the result, must be mpeg4_gif
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter mpeg4Url:  A valid URL for the MP4 file. File size must not exceed 1MB
        /// - parameter mpeg4Width:  Optional. Video width
        /// - parameter mpeg4Height:  Optional. Video height
        /// - parameter mpeg4Duration:  Optional. Video duration
        /// - parameter thumbUrl:  URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        /// - parameter thumbMimeType:  Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video animation
        ///
        /// - returns: The new `InlineQueryResultMpeg4Gif` instance.
        ///
        public init(type: String, id: String, mpeg4Url: String, mpeg4Width: Int? = nil, mpeg4Height: Int? = nil, mpeg4Duration: Int? = nil, thumbUrl: String, thumbMimeType: String? = nil, title: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.mpeg4Url = mpeg4Url
            self.mpeg4Width = mpeg4Width
            self.mpeg4Height = mpeg4Height
            self.mpeg4Duration = mpeg4Duration
            self.thumbUrl = thumbUrl
            self.thumbMimeType = thumbMimeType
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case mpeg4Url = "mpeg4_url"
            case mpeg4Width = "mpeg4_width"
            case mpeg4Height = "mpeg4_height"
            case mpeg4Duration = "mpeg4_duration"
            case thumbUrl = "thumb_url"
            case thumbMimeType = "thumb_mime_type"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// If an InlineQueryResultVideo message contains an embedded video (e.g., YouTube), you must replace its content using input_message_content.
    public class InlineQueryResultVideo: Codable {

        /// Type of the result, must be video
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the embedded video player or video file
        public var videoUrl: String

        /// Mime type of the content of video url, “text/html” or “video/mp4”
        public var mimeType: String

        /// URL of the thumbnail (jpeg only) for the video
        public var thumbUrl: String

        /// Title for the result
        public var title: String

        /// Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Video width
        public var videoWidth: Int?

        /// Optional. Video height
        public var videoHeight: Int?

        /// Optional. Video duration in seconds
        public var videoDuration: Int?

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the video. This field is required if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a YouTube video).
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultVideo initialization
        ///
        /// - parameter type:  Type of the result, must be video
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter videoUrl:  A valid URL for the embedded video player or video file
        /// - parameter mimeType:  Mime type of the content of video url, “text/html” or “video/mp4”
        /// - parameter thumbUrl:  URL of the thumbnail (jpeg only) for the video
        /// - parameter title:  Title for the result
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter videoWidth:  Optional. Video width
        /// - parameter videoHeight:  Optional. Video height
        /// - parameter videoDuration:  Optional. Video duration in seconds
        /// - parameter description:  Optional. Short description of the result
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video. This field is required if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a YouTube video).
        ///
        /// - returns: The new `InlineQueryResultVideo` instance.
        ///
        public init(type: String, id: String, videoUrl: String, mimeType: String, thumbUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, videoWidth: Int? = nil, videoHeight: Int? = nil, videoDuration: Int? = nil, description: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.videoUrl = videoUrl
            self.mimeType = mimeType
            self.thumbUrl = thumbUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.videoWidth = videoWidth
            self.videoHeight = videoHeight
            self.videoDuration = videoDuration
            self.description = description
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case videoUrl = "video_url"
            case mimeType = "mime_type"
            case thumbUrl = "thumb_url"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case videoWidth = "video_width"
            case videoHeight = "video_height"
            case videoDuration = "video_duration"
            case description = "description"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to an MP3 audio file. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
    public class InlineQueryResultAudio: Codable {

        /// Type of the result, must be audio
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the audio file
        public var audioUrl: String

        /// Title
        public var title: String

        /// Optional. Caption, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Performer
        public var performer: String?

        /// Optional. Audio duration in seconds
        public var audioDuration: Int?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the audio
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultAudio initialization
        ///
        /// - parameter type:  Type of the result, must be audio
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter audioUrl:  A valid URL for the audio file
        /// - parameter title:  Title
        /// - parameter caption:  Optional. Caption, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter performer:  Optional. Performer
        /// - parameter audioDuration:  Optional. Audio duration in seconds
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the audio
        ///
        /// - returns: The new `InlineQueryResultAudio` instance.
        ///
        public init(type: String, id: String, audioUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, performer: String? = nil, audioDuration: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.audioUrl = audioUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.performer = performer
            self.audioDuration = audioDuration
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case audioUrl = "audio_url"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case performer = "performer"
            case audioDuration = "audio_duration"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a voice recording in an .OGG container encoded with OPUS. By default, this voice recording will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the the voice message.
    public class InlineQueryResultVoice: Codable {

        /// Type of the result, must be voice
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the voice recording
        public var voiceUrl: String

        /// Recording title
        public var title: String

        /// Optional. Caption, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Recording duration in seconds
        public var voiceDuration: Int?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the voice recording
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultVoice initialization
        ///
        /// - parameter type:  Type of the result, must be voice
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter voiceUrl:  A valid URL for the voice recording
        /// - parameter title:  Recording title
        /// - parameter caption:  Optional. Caption, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter voiceDuration:  Optional. Recording duration in seconds
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the voice recording
        ///
        /// - returns: The new `InlineQueryResultVoice` instance.
        ///
        public init(type: String, id: String, voiceUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, voiceDuration: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.voiceUrl = voiceUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.voiceDuration = voiceDuration
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case voiceUrl = "voice_url"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case voiceDuration = "voice_duration"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a file. By default, this file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the file. Currently, only .PDF and .ZIP files can be sent using this method.
    public class InlineQueryResultDocument: Codable {

        /// Type of the result, must be document
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// Title for the result
        public var title: String

        /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// A valid URL for the file
        public var documentUrl: String

        /// Mime type of the content of the file, either “application/pdf” or “application/zip”
        public var mimeType: String

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the file
        public var inputMessageContent: InputMessageContent?

        /// Optional. URL of the thumbnail (jpeg only) for the file
        public var thumbUrl: String?

        /// Optional. Thumbnail width
        public var thumbWidth: Int?

        /// Optional. Thumbnail height
        public var thumbHeight: Int?

        /// InlineQueryResultDocument initialization
        ///
        /// - parameter type:  Type of the result, must be document
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter title:  Title for the result
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter documentUrl:  A valid URL for the file
        /// - parameter mimeType:  Mime type of the content of the file, either “application/pdf” or “application/zip”
        /// - parameter description:  Optional. Short description of the result
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the file
        /// - parameter thumbUrl:  Optional. URL of the thumbnail (jpeg only) for the file
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultDocument` instance.
        ///
        public init(type: String, id: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, documentUrl: String, mimeType: String, description: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.documentUrl = documentUrl
            self.mimeType = mimeType
            self.description = description
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
            self.thumbUrl = thumbUrl
            self.thumbWidth = thumbWidth
            self.thumbHeight = thumbHeight
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case documentUrl = "document_url"
            case mimeType = "mime_type"
            case description = "description"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
            case thumbUrl = "thumb_url"
            case thumbWidth = "thumb_width"
            case thumbHeight = "thumb_height"
        }

    }

    /// Represents a location on a map. By default, the location will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the location.
    public class InlineQueryResultLocation: Codable {

        /// Type of the result, must be location
        public var type: String

        /// Unique identifier for this result, 1-64 Bytes
        public var id: String

        /// Location latitude in degrees
        public var latitude: Float

        /// Location longitude in degrees
        public var longitude: Float

        /// Location title
        public var title: String

        /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        public var horizontalAccuracy: Float?

        /// Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        public var livePeriod: Int?

        /// Optional. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
        public var heading: Int?

        /// Optional. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
        public var proximityAlertRadius: Int?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the location
        public var inputMessageContent: InputMessageContent?

        /// Optional. Url of the thumbnail for the result
        public var thumbUrl: String?

        /// Optional. Thumbnail width
        public var thumbWidth: Int?

        /// Optional. Thumbnail height
        public var thumbHeight: Int?

        /// InlineQueryResultLocation initialization
        ///
        /// - parameter type:  Type of the result, must be location
        /// - parameter id:  Unique identifier for this result, 1-64 Bytes
        /// - parameter latitude:  Location latitude in degrees
        /// - parameter longitude:  Location longitude in degrees
        /// - parameter title:  Location title
        /// - parameter horizontalAccuracy:  Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        /// - parameter livePeriod:  Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        /// - parameter heading:  Optional. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
        /// - parameter proximityAlertRadius:  Optional. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the location
        /// - parameter thumbUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultLocation` instance.
        ///
        public init(type: String, id: String, latitude: Float, longitude: Float, title: String, horizontalAccuracy: Float? = nil, livePeriod: Int? = nil, heading: Int? = nil, proximityAlertRadius: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.horizontalAccuracy = horizontalAccuracy
            self.livePeriod = livePeriod
            self.heading = heading
            self.proximityAlertRadius = proximityAlertRadius
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
            self.thumbUrl = thumbUrl
            self.thumbWidth = thumbWidth
            self.thumbHeight = thumbHeight
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case latitude = "latitude"
            case longitude = "longitude"
            case title = "title"
            case horizontalAccuracy = "horizontal_accuracy"
            case livePeriod = "live_period"
            case heading = "heading"
            case proximityAlertRadius = "proximity_alert_radius"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
            case thumbUrl = "thumb_url"
            case thumbWidth = "thumb_width"
            case thumbHeight = "thumb_height"
        }

    }

    /// Represents a venue. By default, the venue will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the venue.
    public class InlineQueryResultVenue: Codable {

        /// Type of the result, must be venue
        public var type: String

        /// Unique identifier for this result, 1-64 Bytes
        public var id: String

        /// Latitude of the venue location in degrees
        public var latitude: Float

        /// Longitude of the venue location in degrees
        public var longitude: Float

        /// Title of the venue
        public var title: String

        /// Address of the venue
        public var address: String

        /// Optional. Foursquare identifier of the venue if known
        public var foursquareId: String?

        /// Optional. Foursquare type of the venue, if known. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        public var foursquareType: String?

        /// Optional. Google Places identifier of the venue
        public var googlePlaceId: String?

        /// Optional. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
        public var googlePlaceType: String?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the venue
        public var inputMessageContent: InputMessageContent?

        /// Optional. Url of the thumbnail for the result
        public var thumbUrl: String?

        /// Optional. Thumbnail width
        public var thumbWidth: Int?

        /// Optional. Thumbnail height
        public var thumbHeight: Int?

        /// InlineQueryResultVenue initialization
        ///
        /// - parameter type:  Type of the result, must be venue
        /// - parameter id:  Unique identifier for this result, 1-64 Bytes
        /// - parameter latitude:  Latitude of the venue location in degrees
        /// - parameter longitude:  Longitude of the venue location in degrees
        /// - parameter title:  Title of the venue
        /// - parameter address:  Address of the venue
        /// - parameter foursquareId:  Optional. Foursquare identifier of the venue if known
        /// - parameter foursquareType:  Optional. Foursquare type of the venue, if known. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        /// - parameter googlePlaceId:  Optional. Google Places identifier of the venue
        /// - parameter googlePlaceType:  Optional. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the venue
        /// - parameter thumbUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultVenue` instance.
        ///
        public init(type: String, id: String, latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, googlePlaceId: String? = nil, googlePlaceType: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.address = address
            self.foursquareId = foursquareId
            self.foursquareType = foursquareType
            self.googlePlaceId = googlePlaceId
            self.googlePlaceType = googlePlaceType
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
            self.thumbUrl = thumbUrl
            self.thumbWidth = thumbWidth
            self.thumbHeight = thumbHeight
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case latitude = "latitude"
            case longitude = "longitude"
            case title = "title"
            case address = "address"
            case foursquareId = "foursquare_id"
            case foursquareType = "foursquare_type"
            case googlePlaceId = "google_place_id"
            case googlePlaceType = "google_place_type"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
            case thumbUrl = "thumb_url"
            case thumbWidth = "thumb_width"
            case thumbHeight = "thumb_height"
        }

    }

    /// Represents a contact with a phone number. By default, this contact will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the contact.
    public class InlineQueryResultContact: Codable {

        /// Type of the result, must be contact
        public var type: String

        /// Unique identifier for this result, 1-64 Bytes
        public var id: String

        /// Contact’s phone number
        public var phoneNumber: String

        /// Contact’s first name
        public var firstName: String

        /// Optional. Contact’s last name
        public var lastName: String?

        /// Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
        public var vcard: String?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the contact
        public var inputMessageContent: InputMessageContent?

        /// Optional. Url of the thumbnail for the result
        public var thumbUrl: String?

        /// Optional. Thumbnail width
        public var thumbWidth: Int?

        /// Optional. Thumbnail height
        public var thumbHeight: Int?

        /// InlineQueryResultContact initialization
        ///
        /// - parameter type:  Type of the result, must be contact
        /// - parameter id:  Unique identifier for this result, 1-64 Bytes
        /// - parameter phoneNumber:  Contact’s phone number
        /// - parameter firstName:  Contact’s first name
        /// - parameter lastName:  Optional. Contact’s last name
        /// - parameter vcard:  Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the contact
        /// - parameter thumbUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultContact` instance.
        ///
        public init(type: String, id: String, phoneNumber: String, firstName: String, lastName: String? = nil, vcard: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.phoneNumber = phoneNumber
            self.firstName = firstName
            self.lastName = lastName
            self.vcard = vcard
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
            self.thumbUrl = thumbUrl
            self.thumbWidth = thumbWidth
            self.thumbHeight = thumbHeight
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case phoneNumber = "phone_number"
            case firstName = "first_name"
            case lastName = "last_name"
            case vcard = "vcard"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
            case thumbUrl = "thumb_url"
            case thumbWidth = "thumb_width"
            case thumbHeight = "thumb_height"
        }

    }

    /// Represents a Game.
    public class InlineQueryResultGame: Codable {

        /// Type of the result, must be game
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// Short name of the game
        public var gameShortName: String

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// InlineQueryResultGame initialization
        ///
        /// - parameter type:  Type of the result, must be game
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter gameShortName:  Short name of the game
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        ///
        /// - returns: The new `InlineQueryResultGame` instance.
        ///
        public init(type: String, id: String, gameShortName: String, replyMarkup: InlineKeyboardMarkup? = nil) {
            self.type = type
            self.id = id
            self.gameShortName = gameShortName
            self.replyMarkup = replyMarkup
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case gameShortName = "game_short_name"
            case replyMarkup = "reply_markup"
        }

    }

    /// Represents a link to a photo stored on the Telegram servers. By default, this photo will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
    public class InlineQueryResultCachedPhoto: Codable {

        /// Type of the result, must be photo
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier of the photo
        public var photoFileId: String

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the photo
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedPhoto initialization
        ///
        /// - parameter type:  Type of the result, must be photo
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter photoFileId:  A valid file identifier of the photo
        /// - parameter title:  Optional. Title for the result
        /// - parameter description:  Optional. Short description of the result
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the photo
        ///
        /// - returns: The new `InlineQueryResultCachedPhoto` instance.
        ///
        public init(type: String, id: String, photoFileId: String, title: String? = nil, description: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.photoFileId = photoFileId
            self.title = title
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case photoFileId = "photo_file_id"
            case title = "title"
            case description = "description"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to an animated GIF file stored on the Telegram servers. By default, this animated GIF file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with specified content instead of the animation.
    public class InlineQueryResultCachedGif: Codable {

        /// Type of the result, must be gif
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier for the GIF file
        public var gifFileId: String

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the GIF animation
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedGif initialization
        ///
        /// - parameter type:  Type of the result, must be gif
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter gifFileId:  A valid file identifier for the GIF file
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the GIF animation
        ///
        /// - returns: The new `InlineQueryResultCachedGif` instance.
        ///
        public init(type: String, id: String, gifFileId: String, title: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.gifFileId = gifFileId
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case gifFileId = "gif_file_id"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a video animation (H.264/MPEG-4 AVC video without sound) stored on the Telegram servers. By default, this animated MPEG-4 file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the animation.
    public class InlineQueryResultCachedMpeg4Gif: Codable {

        /// Type of the result, must be mpeg4_gif
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier for the MP4 file
        public var mpeg4FileId: String

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the video animation
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedMpeg4Gif initialization
        ///
        /// - parameter type:  Type of the result, must be mpeg4_gif
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter mpeg4FileId:  A valid file identifier for the MP4 file
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video animation
        ///
        /// - returns: The new `InlineQueryResultCachedMpeg4Gif` instance.
        ///
        public init(type: String, id: String, mpeg4FileId: String, title: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.mpeg4FileId = mpeg4FileId
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case mpeg4FileId = "mpeg4_file_id"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a sticker stored on the Telegram servers. By default, this sticker will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the sticker.
    public class InlineQueryResultCachedSticker: Codable {

        /// Type of the result, must be sticker
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier of the sticker
        public var stickerFileId: String

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the sticker
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedSticker initialization
        ///
        /// - parameter type:  Type of the result, must be sticker
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter stickerFileId:  A valid file identifier of the sticker
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the sticker
        ///
        /// - returns: The new `InlineQueryResultCachedSticker` instance.
        ///
        public init(type: String, id: String, stickerFileId: String, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.stickerFileId = stickerFileId
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case stickerFileId = "sticker_file_id"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a file stored on the Telegram servers. By default, this file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the file.
    public class InlineQueryResultCachedDocument: Codable {

        /// Type of the result, must be document
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// Title for the result
        public var title: String

        /// A valid file identifier for the file
        public var documentFileId: String

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the file
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedDocument initialization
        ///
        /// - parameter type:  Type of the result, must be document
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter title:  Title for the result
        /// - parameter documentFileId:  A valid file identifier for the file
        /// - parameter description:  Optional. Short description of the result
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the file
        ///
        /// - returns: The new `InlineQueryResultCachedDocument` instance.
        ///
        public init(type: String, id: String, title: String, documentFileId: String, description: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.title = title
            self.documentFileId = documentFileId
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case title = "title"
            case documentFileId = "document_file_id"
            case description = "description"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a video file stored on the Telegram servers. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the video.
    public class InlineQueryResultCachedVideo: Codable {

        /// Type of the result, must be video
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier for the video file
        public var videoFileId: String

        /// Title for the result
        public var title: String

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the video
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedVideo initialization
        ///
        /// - parameter type:  Type of the result, must be video
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter videoFileId:  A valid file identifier for the video file
        /// - parameter title:  Title for the result
        /// - parameter description:  Optional. Short description of the result
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video
        ///
        /// - returns: The new `InlineQueryResultCachedVideo` instance.
        ///
        public init(type: String, id: String, videoFileId: String, title: String, description: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.videoFileId = videoFileId
            self.title = title
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case videoFileId = "video_file_id"
            case title = "title"
            case description = "description"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a voice message stored on the Telegram servers. By default, this voice message will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the voice message.
    public class InlineQueryResultCachedVoice: Codable {

        /// Type of the result, must be voice
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier for the voice message
        public var voiceFileId: String

        /// Voice message title
        public var title: String

        /// Optional. Caption, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the voice message
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedVoice initialization
        ///
        /// - parameter type:  Type of the result, must be voice
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter voiceFileId:  A valid file identifier for the voice message
        /// - parameter title:  Voice message title
        /// - parameter caption:  Optional. Caption, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the voice message caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the voice message
        ///
        /// - returns: The new `InlineQueryResultCachedVoice` instance.
        ///
        public init(type: String, id: String, voiceFileId: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.voiceFileId = voiceFileId
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case voiceFileId = "voice_file_id"
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to an MP3 audio file stored on the Telegram servers. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
    public class InlineQueryResultCachedAudio: Codable {

        /// Type of the result, must be audio
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier for the audio file
        public var audioFileId: String

        /// Optional. Caption, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the audio
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedAudio initialization
        ///
        /// - parameter type:  Type of the result, must be audio
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter audioFileId:  A valid file identifier for the audio file
        /// - parameter caption:  Optional. Caption, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the audio
        ///
        /// - returns: The new `InlineQueryResultCachedAudio` instance.
        ///
        public init(type: String, id: String, audioFileId: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.audioFileId = audioFileId
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case audioFileId = "audio_file_id"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// This object represents the content of a message to be sent as a result of an inline query. Telegram clients currently support the following 5 types:
    public enum InputMessageContent: Codable {

        case text(InputTextMessageContent)
        case location(InputLocationMessageContent)
        case venue(InputVenueMessageContent)
        case contact(InputContactMessageContent)
        case invoice(InputInvoiceMessageContent)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let text = try? container.decode(InputTextMessageContent.self) {
                self = .text(text)
            } else if let location = try? container.decode(InputLocationMessageContent.self) {
                self = .location(location)
            } else if let venue = try? container.decode(InputVenueMessageContent.self) {
                self = .venue(venue)
            } else if let contact = try? container.decode(InputContactMessageContent.self) {
                self = .contact(contact)
            } else if let invoice = try? container.decode(InputInvoiceMessageContent.self) {
                self = .invoice(invoice)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "InputMessageContent"])
            }
        }

        public init(_ text: InputTextMessageContent) {
            self = .text(text)
        }

        public init(_ location: InputLocationMessageContent) {
            self = .location(location)
        }

        public init(_ venue: InputVenueMessageContent) {
            self = .venue(venue)
        }

        public init(_ contact: InputContactMessageContent) {
            self = .contact(contact)
        }

        public init(_ invoice: InputInvoiceMessageContent) {
            self = .invoice(invoice)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let text):
                try container.encode(text)
            case .location(let location):
                try container.encode(location)
            case .venue(let venue):
                try container.encode(venue)
            case .contact(let contact):
                try container.encode(contact)
            case .invoice(let invoice):
                try container.encode(invoice)
            }
        }
    }
    /// Represents the content of a text message to be sent as the result of an inline query.
    public class InputTextMessageContent: Codable {

        /// Text of the message to be sent, 1-4096 characters
        public var messageText: String

        /// Optional. Mode for parsing entities in the message text. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in message text, which can be specified instead of parse_mode
        public var entities: [MessageEntity]?

        /// Optional. Disables link previews for links in the sent message
        public var disableWebPagePreview: Bool?

        /// InputTextMessageContent initialization
        ///
        /// - parameter messageText:  Text of the message to be sent, 1-4096 characters
        /// - parameter parseMode:  Optional. Mode for parsing entities in the message text. See formatting options for more details.
        /// - parameter entities:  Optional. List of special entities that appear in message text, which can be specified instead of parse_mode
        /// - parameter disableWebPagePreview:  Optional. Disables link previews for links in the sent message
        ///
        /// - returns: The new `InputTextMessageContent` instance.
        ///
        public init(messageText: String, parseMode: String? = nil, entities: [MessageEntity]? = nil, disableWebPagePreview: Bool? = nil) {
            self.messageText = messageText
            self.parseMode = parseMode
            self.entities = entities
            self.disableWebPagePreview = disableWebPagePreview
        }

        private enum CodingKeys: String, CodingKey {
            case messageText = "message_text"
            case parseMode = "parse_mode"
            case entities = "entities"
            case disableWebPagePreview = "disable_web_page_preview"
        }

    }

    /// Represents the content of a location message to be sent as the result of an inline query.
    public class InputLocationMessageContent: Codable {

        /// Latitude of the location in degrees
        public var latitude: Float

        /// Longitude of the location in degrees
        public var longitude: Float

        /// Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        public var horizontalAccuracy: Float?

        /// Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        public var livePeriod: Int?

        /// Optional. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
        public var heading: Int?

        /// Optional. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
        public var proximityAlertRadius: Int?

        /// InputLocationMessageContent initialization
        ///
        /// - parameter latitude:  Latitude of the location in degrees
        /// - parameter longitude:  Longitude of the location in degrees
        /// - parameter horizontalAccuracy:  Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        /// - parameter livePeriod:  Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        /// - parameter heading:  Optional. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
        /// - parameter proximityAlertRadius:  Optional. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
        ///
        /// - returns: The new `InputLocationMessageContent` instance.
        ///
        public init(latitude: Float, longitude: Float, horizontalAccuracy: Float? = nil, livePeriod: Int? = nil, heading: Int? = nil, proximityAlertRadius: Int? = nil) {
            self.latitude = latitude
            self.longitude = longitude
            self.horizontalAccuracy = horizontalAccuracy
            self.livePeriod = livePeriod
            self.heading = heading
            self.proximityAlertRadius = proximityAlertRadius
        }

        private enum CodingKeys: String, CodingKey {
            case latitude = "latitude"
            case longitude = "longitude"
            case horizontalAccuracy = "horizontal_accuracy"
            case livePeriod = "live_period"
            case heading = "heading"
            case proximityAlertRadius = "proximity_alert_radius"
        }

    }

    /// Represents the content of a venue message to be sent as the result of an inline query.
    public class InputVenueMessageContent: Codable {

        /// Latitude of the venue in degrees
        public var latitude: Float

        /// Longitude of the venue in degrees
        public var longitude: Float

        /// Name of the venue
        public var title: String

        /// Address of the venue
        public var address: String

        /// Optional. Foursquare identifier of the venue, if known
        public var foursquareId: String?

        /// Optional. Foursquare type of the venue, if known. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        public var foursquareType: String?

        /// Optional. Google Places identifier of the venue
        public var googlePlaceId: String?

        /// Optional. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
        public var googlePlaceType: String?

        /// InputVenueMessageContent initialization
        ///
        /// - parameter latitude:  Latitude of the venue in degrees
        /// - parameter longitude:  Longitude of the venue in degrees
        /// - parameter title:  Name of the venue
        /// - parameter address:  Address of the venue
        /// - parameter foursquareId:  Optional. Foursquare identifier of the venue, if known
        /// - parameter foursquareType:  Optional. Foursquare type of the venue, if known. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        /// - parameter googlePlaceId:  Optional. Google Places identifier of the venue
        /// - parameter googlePlaceType:  Optional. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)
        ///
        /// - returns: The new `InputVenueMessageContent` instance.
        ///
        public init(latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, googlePlaceId: String? = nil, googlePlaceType: String? = nil) {
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.address = address
            self.foursquareId = foursquareId
            self.foursquareType = foursquareType
            self.googlePlaceId = googlePlaceId
            self.googlePlaceType = googlePlaceType
        }

        private enum CodingKeys: String, CodingKey {
            case latitude = "latitude"
            case longitude = "longitude"
            case title = "title"
            case address = "address"
            case foursquareId = "foursquare_id"
            case foursquareType = "foursquare_type"
            case googlePlaceId = "google_place_id"
            case googlePlaceType = "google_place_type"
        }

    }

    /// Represents the content of a contact message to be sent as the result of an inline query.
    public class InputContactMessageContent: Codable {

        /// Contact’s phone number
        public var phoneNumber: String

        /// Contact’s first name
        public var firstName: String

        /// Optional. Contact’s last name
        public var lastName: String?

        /// Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
        public var vcard: String?

        /// InputContactMessageContent initialization
        ///
        /// - parameter phoneNumber:  Contact’s phone number
        /// - parameter firstName:  Contact’s first name
        /// - parameter lastName:  Optional. Contact’s last name
        /// - parameter vcard:  Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
        ///
        /// - returns: The new `InputContactMessageContent` instance.
        ///
        public init(phoneNumber: String, firstName: String, lastName: String? = nil, vcard: String? = nil) {
            self.phoneNumber = phoneNumber
            self.firstName = firstName
            self.lastName = lastName
            self.vcard = vcard
        }

        private enum CodingKeys: String, CodingKey {
            case phoneNumber = "phone_number"
            case firstName = "first_name"
            case lastName = "last_name"
            case vcard = "vcard"
        }

    }

    /// Represents the content of an invoice message to be sent as the result of an inline query.
    public class InputInvoiceMessageContent: Codable {

        /// Product name, 1-32 characters
        public var title: String

        /// Product description, 1-255 characters
        public var description: String

        /// Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use for your internal processes.
        public var payload: String

        /// Payment provider token, obtained via [Botfather](https://t.me/botfather)
        public var providerToken: String

        /// Three-letter ISO 4217 currency code, see more on currencies
        public var currency: String

        /// Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
        public var prices: [LabeledPrice]

        /// Optional. The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0
        public var maxTipAmount: Int?

        /// Optional. A JSON-serialized array of suggested amounts of tip in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
        public var suggestedTipAmounts: [Int]?

        /// Optional. A JSON-serialized object for data about the invoice, which will be shared with the payment provider. A detailed description of the required fields should be provided by the payment provider.
        public var providerData: String?

        /// Optional. URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.
        public var photoUrl: String?

        /// Optional. Photo size
        public var photoSize: Int?

        /// Optional. Photo width
        public var photoWidth: Int?

        /// Optional. Photo height
        public var photoHeight: Int?

        /// Optional. Pass True, if you require the user’s full name to complete the order
        public var needName: Bool?

        /// Optional. Pass True, if you require the user’s phone number to complete the order
        public var needPhoneNumber: Bool?

        /// Optional. Pass True, if you require the user’s email address to complete the order
        public var needEmail: Bool?

        /// Optional. Pass True, if you require the user’s shipping address to complete the order
        public var needShippingAddress: Bool?

        /// Optional. Pass True, if user’s phone number should be sent to provider
        public var sendPhoneNumberToProvider: Bool?

        /// Optional. Pass True, if user’s email address should be sent to provider
        public var sendEmailToProvider: Bool?

        /// Optional. Pass True, if the final price depends on the shipping method
        public var isFlexible: Bool?

        /// InputInvoiceMessageContent initialization
        ///
        /// - parameter title:  Product name, 1-32 characters
        /// - parameter description:  Product description, 1-255 characters
        /// - parameter payload:  Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use for your internal processes.
        /// - parameter providerToken:  Payment provider token, obtained via [Botfather](https://t.me/botfather)
        /// - parameter currency:  Three-letter ISO 4217 currency code, see more on currencies
        /// - parameter prices:  Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
        /// - parameter maxTipAmount:  Optional. The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0
        /// - parameter suggestedTipAmounts:  Optional. A JSON-serialized array of suggested amounts of tip in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
        /// - parameter providerData:  Optional. A JSON-serialized object for data about the invoice, which will be shared with the payment provider. A detailed description of the required fields should be provided by the payment provider.
        /// - parameter photoUrl:  Optional. URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.
        /// - parameter photoSize:  Optional. Photo size
        /// - parameter photoWidth:  Optional. Photo width
        /// - parameter photoHeight:  Optional. Photo height
        /// - parameter needName:  Optional. Pass True, if you require the user’s full name to complete the order
        /// - parameter needPhoneNumber:  Optional. Pass True, if you require the user’s phone number to complete the order
        /// - parameter needEmail:  Optional. Pass True, if you require the user’s email address to complete the order
        /// - parameter needShippingAddress:  Optional. Pass True, if you require the user’s shipping address to complete the order
        /// - parameter sendPhoneNumberToProvider:  Optional. Pass True, if user’s phone number should be sent to provider
        /// - parameter sendEmailToProvider:  Optional. Pass True, if user’s email address should be sent to provider
        /// - parameter isFlexible:  Optional. Pass True, if the final price depends on the shipping method
        ///
        /// - returns: The new `InputInvoiceMessageContent` instance.
        ///
        public init(title: String, description: String, payload: String, providerToken: String, currency: String, prices: [LabeledPrice], maxTipAmount: Int? = nil, suggestedTipAmounts: [Int]? = nil, providerData: String? = nil, photoUrl: String? = nil, photoSize: Int? = nil, photoWidth: Int? = nil, photoHeight: Int? = nil, needName: Bool? = nil, needPhoneNumber: Bool? = nil, needEmail: Bool? = nil, needShippingAddress: Bool? = nil, sendPhoneNumberToProvider: Bool? = nil, sendEmailToProvider: Bool? = nil, isFlexible: Bool? = nil) {
            self.title = title
            self.description = description
            self.payload = payload
            self.providerToken = providerToken
            self.currency = currency
            self.prices = prices
            self.maxTipAmount = maxTipAmount
            self.suggestedTipAmounts = suggestedTipAmounts
            self.providerData = providerData
            self.photoUrl = photoUrl
            self.photoSize = photoSize
            self.photoWidth = photoWidth
            self.photoHeight = photoHeight
            self.needName = needName
            self.needPhoneNumber = needPhoneNumber
            self.needEmail = needEmail
            self.needShippingAddress = needShippingAddress
            self.sendPhoneNumberToProvider = sendPhoneNumberToProvider
            self.sendEmailToProvider = sendEmailToProvider
            self.isFlexible = isFlexible
        }

        private enum CodingKeys: String, CodingKey {
            case title = "title"
            case description = "description"
            case payload = "payload"
            case providerToken = "provider_token"
            case currency = "currency"
            case prices = "prices"
            case maxTipAmount = "max_tip_amount"
            case suggestedTipAmounts = "suggested_tip_amounts"
            case providerData = "provider_data"
            case photoUrl = "photo_url"
            case photoSize = "photo_size"
            case photoWidth = "photo_width"
            case photoHeight = "photo_height"
            case needName = "need_name"
            case needPhoneNumber = "need_phone_number"
            case needEmail = "need_email"
            case needShippingAddress = "need_shipping_address"
            case sendPhoneNumberToProvider = "send_phone_number_to_provider"
            case sendEmailToProvider = "send_email_to_provider"
            case isFlexible = "is_flexible"
        }

    }

    /// Represents a result of an inline query that was chosen by the user and sent to their chat partner.
    public class ChosenInlineResult: Codable {

        /// The unique identifier for the result that was chosen
        public var resultId: String

        /// The user that chose the result
        public var from: User

        /// Optional. Sender location, only for bots that require user location
        public var location: Location?

        /// Optional. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message. Will be also received in callback queries and can be used to edit the message.
        public var inlineMessageId: String?

        /// The query that was used to obtain the result
        public var query: String

        /// ChosenInlineResult initialization
        ///
        /// - parameter resultId:  The unique identifier for the result that was chosen
        /// - parameter from:  The user that chose the result
        /// - parameter location:  Optional. Sender location, only for bots that require user location
        /// - parameter inlineMessageId:  Optional. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message. Will be also received in callback queries and can be used to edit the message.
        /// - parameter query:  The query that was used to obtain the result
        ///
        /// - returns: The new `ChosenInlineResult` instance.
        ///
        public init(resultId: String, from: User, location: Location? = nil, inlineMessageId: String? = nil, query: String) {
            self.resultId = resultId
            self.from = from
            self.location = location
            self.inlineMessageId = inlineMessageId
            self.query = query
        }

        private enum CodingKeys: String, CodingKey {
            case resultId = "result_id"
            case from = "from"
            case location = "location"
            case inlineMessageId = "inline_message_id"
            case query = "query"
        }

    }

    /// This object represents a portion of the price for goods or services.
    public class LabeledPrice: Codable {

        /// Portion label
        public var label: String

        /// Price of the product in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var amount: Int

        /// LabeledPrice initialization
        ///
        /// - parameter label:  Portion label
        /// - parameter amount:  Price of the product in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        ///
        /// - returns: The new `LabeledPrice` instance.
        ///
        public init(label: String, amount: Int) {
            self.label = label
            self.amount = amount
        }

        private enum CodingKeys: String, CodingKey {
            case label = "label"
            case amount = "amount"
        }

    }

    /// This object contains basic information about an invoice.
    public class Invoice: Codable {

        /// Product name
        public var title: String

        /// Product description
        public var description: String

        /// Unique bot deep-linking parameter that can be used to generate this invoice
        public var startParameter: String

        /// Three-letter ISO 4217 currency code
        public var currency: String

        /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var totalAmount: Int

        /// Invoice initialization
        ///
        /// - parameter title:  Product name
        /// - parameter description:  Product description
        /// - parameter startParameter:  Unique bot deep-linking parameter that can be used to generate this invoice
        /// - parameter currency:  Three-letter ISO 4217 currency code
        /// - parameter totalAmount:  Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        ///
        /// - returns: The new `Invoice` instance.
        ///
        public init(title: String, description: String, startParameter: String, currency: String, totalAmount: Int) {
            self.title = title
            self.description = description
            self.startParameter = startParameter
            self.currency = currency
            self.totalAmount = totalAmount
        }

        private enum CodingKeys: String, CodingKey {
            case title = "title"
            case description = "description"
            case startParameter = "start_parameter"
            case currency = "currency"
            case totalAmount = "total_amount"
        }

    }

    /// This object represents a shipping address.
    public class ShippingAddress: Codable {

        /// ISO 3166-1 alpha-2 country code
        public var countryCode: String

        /// State, if applicable
        public var state: String

        /// City
        public var city: String

        /// First line for the address
        public var streetLine1: String

        /// Second line for the address
        public var streetLine2: String

        /// Address post code
        public var postCode: String

        /// ShippingAddress initialization
        ///
        /// - parameter countryCode:  ISO 3166-1 alpha-2 country code
        /// - parameter state:  State, if applicable
        /// - parameter city:  City
        /// - parameter streetLine1:  First line for the address
        /// - parameter streetLine2:  Second line for the address
        /// - parameter postCode:  Address post code
        ///
        /// - returns: The new `ShippingAddress` instance.
        ///
        public init(countryCode: String, state: String, city: String, streetLine1: String, streetLine2: String, postCode: String) {
            self.countryCode = countryCode
            self.state = state
            self.city = city
            self.streetLine1 = streetLine1
            self.streetLine2 = streetLine2
            self.postCode = postCode
        }

        private enum CodingKeys: String, CodingKey {
            case countryCode = "country_code"
            case state = "state"
            case city = "city"
            case streetLine1 = "street_line1"
            case streetLine2 = "street_line2"
            case postCode = "post_code"
        }

    }

    /// This object represents information about an order.
    public class OrderInfo: Codable {

        /// Optional. User name
        public var name: String?

        /// Optional. User’s phone number
        public var phoneNumber: String?

        /// Optional. User email
        public var email: String?

        /// Optional. User shipping address
        public var shippingAddress: ShippingAddress?

        /// OrderInfo initialization
        ///
        /// - parameter name:  Optional. User name
        /// - parameter phoneNumber:  Optional. User’s phone number
        /// - parameter email:  Optional. User email
        /// - parameter shippingAddress:  Optional. User shipping address
        ///
        /// - returns: The new `OrderInfo` instance.
        ///
        public init(name: String? = nil, phoneNumber: String? = nil, email: String? = nil, shippingAddress: ShippingAddress? = nil) {
            self.name = name
            self.phoneNumber = phoneNumber
            self.email = email
            self.shippingAddress = shippingAddress
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case phoneNumber = "phone_number"
            case email = "email"
            case shippingAddress = "shipping_address"
        }

    }

    /// This object represents one shipping option.
    public class ShippingOption: Codable {

        /// Shipping option identifier
        public var id: String

        /// Option title
        public var title: String

        /// List of price portions
        public var prices: [LabeledPrice]

        /// ShippingOption initialization
        ///
        /// - parameter id:  Shipping option identifier
        /// - parameter title:  Option title
        /// - parameter prices:  List of price portions
        ///
        /// - returns: The new `ShippingOption` instance.
        ///
        public init(id: String, title: String, prices: [LabeledPrice]) {
            self.id = id
            self.title = title
            self.prices = prices
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case title = "title"
            case prices = "prices"
        }

    }

    /// This object contains basic information about a successful payment.
    public class SuccessfulPayment: Codable {

        /// Three-letter ISO 4217 currency code
        public var currency: String

        /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var totalAmount: Int

        /// Bot specified invoice payload
        public var invoicePayload: String

        /// Optional. Identifier of the shipping option chosen by the user
        public var shippingOptionId: String?

        /// Optional. Order info provided by the user
        public var orderInfo: OrderInfo?

        /// Telegram payment identifier
        public var telegramPaymentChargeId: String

        /// Provider payment identifier
        public var providerPaymentChargeId: String

        /// SuccessfulPayment initialization
        ///
        /// - parameter currency:  Three-letter ISO 4217 currency code
        /// - parameter totalAmount:  Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        /// - parameter invoicePayload:  Bot specified invoice payload
        /// - parameter shippingOptionId:  Optional. Identifier of the shipping option chosen by the user
        /// - parameter orderInfo:  Optional. Order info provided by the user
        /// - parameter telegramPaymentChargeId:  Telegram payment identifier
        /// - parameter providerPaymentChargeId:  Provider payment identifier
        ///
        /// - returns: The new `SuccessfulPayment` instance.
        ///
        public init(currency: String, totalAmount: Int, invoicePayload: String, shippingOptionId: String? = nil, orderInfo: OrderInfo? = nil, telegramPaymentChargeId: String, providerPaymentChargeId: String) {
            self.currency = currency
            self.totalAmount = totalAmount
            self.invoicePayload = invoicePayload
            self.shippingOptionId = shippingOptionId
            self.orderInfo = orderInfo
            self.telegramPaymentChargeId = telegramPaymentChargeId
            self.providerPaymentChargeId = providerPaymentChargeId
        }

        private enum CodingKeys: String, CodingKey {
            case currency = "currency"
            case totalAmount = "total_amount"
            case invoicePayload = "invoice_payload"
            case shippingOptionId = "shipping_option_id"
            case orderInfo = "order_info"
            case telegramPaymentChargeId = "telegram_payment_charge_id"
            case providerPaymentChargeId = "provider_payment_charge_id"
        }

    }

    /// This object contains information about an incoming shipping query.
    public class ShippingQuery: Codable {

        /// Unique query identifier
        public var id: String

        /// User who sent the query
        public var from: User

        /// Bot specified invoice payload
        public var invoicePayload: String

        /// User specified shipping address
        public var shippingAddress: ShippingAddress

        /// ShippingQuery initialization
        ///
        /// - parameter id:  Unique query identifier
        /// - parameter from:  User who sent the query
        /// - parameter invoicePayload:  Bot specified invoice payload
        /// - parameter shippingAddress:  User specified shipping address
        ///
        /// - returns: The new `ShippingQuery` instance.
        ///
        public init(id: String, from: User, invoicePayload: String, shippingAddress: ShippingAddress) {
            self.id = id
            self.from = from
            self.invoicePayload = invoicePayload
            self.shippingAddress = shippingAddress
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case from = "from"
            case invoicePayload = "invoice_payload"
            case shippingAddress = "shipping_address"
        }

    }

    /// This object contains information about an incoming pre-checkout query.
    public class PreCheckoutQuery: Codable {

        /// Unique query identifier
        public var id: String

        /// User who sent the query
        public var from: User

        /// Three-letter ISO 4217 currency code
        public var currency: String

        /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var totalAmount: Int

        /// Bot specified invoice payload
        public var invoicePayload: String

        /// Optional. Identifier of the shipping option chosen by the user
        public var shippingOptionId: String?

        /// Optional. Order info provided by the user
        public var orderInfo: OrderInfo?

        /// PreCheckoutQuery initialization
        ///
        /// - parameter id:  Unique query identifier
        /// - parameter from:  User who sent the query
        /// - parameter currency:  Three-letter ISO 4217 currency code
        /// - parameter totalAmount:  Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in [currencies.json](https://core.telegram.org/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        /// - parameter invoicePayload:  Bot specified invoice payload
        /// - parameter shippingOptionId:  Optional. Identifier of the shipping option chosen by the user
        /// - parameter orderInfo:  Optional. Order info provided by the user
        ///
        /// - returns: The new `PreCheckoutQuery` instance.
        ///
        public init(id: String, from: User, currency: String, totalAmount: Int, invoicePayload: String, shippingOptionId: String? = nil, orderInfo: OrderInfo? = nil) {
            self.id = id
            self.from = from
            self.currency = currency
            self.totalAmount = totalAmount
            self.invoicePayload = invoicePayload
            self.shippingOptionId = shippingOptionId
            self.orderInfo = orderInfo
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case from = "from"
            case currency = "currency"
            case totalAmount = "total_amount"
            case invoicePayload = "invoice_payload"
            case shippingOptionId = "shipping_option_id"
            case orderInfo = "order_info"
        }

    }

    /// Contains information about Telegram Passport data shared with the bot by the user.
    public class PassportData: Codable {

        /// Array with information about documents and other Telegram Passport elements that was shared with the bot
        public var data: [EncryptedPassportElement]

        /// Encrypted credentials required to decrypt the data
        public var credentials: EncryptedCredentials

        /// PassportData initialization
        ///
        /// - parameter data:  Array with information about documents and other Telegram Passport elements that was shared with the bot
        /// - parameter credentials:  Encrypted credentials required to decrypt the data
        ///
        /// - returns: The new `PassportData` instance.
        ///
        public init(data: [EncryptedPassportElement], credentials: EncryptedCredentials) {
            self.data = data
            self.credentials = credentials
        }

        private enum CodingKeys: String, CodingKey {
            case data = "data"
            case credentials = "credentials"
        }

    }

    /// This object represents a file uploaded to Telegram Passport. Currently all Telegram Passport files are in JPEG format when decrypted and don’t exceed 10MB.
    public class PassportFile: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// File size
        public var fileSize: Int

        /// Unix time when the file was uploaded
        public var fileDate: Int

        /// PassportFile initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter fileSize:  File size
        /// - parameter fileDate:  Unix time when the file was uploaded
        ///
        /// - returns: The new `PassportFile` instance.
        ///
        public init(fileId: String, fileUniqueId: String, fileSize: Int, fileDate: Int) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.fileSize = fileSize
            self.fileDate = fileDate
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case fileSize = "file_size"
            case fileDate = "file_date"
        }

    }

    /// Contains information about documents or other Telegram Passport elements shared with the bot by the user.
    public class EncryptedPassportElement: Codable {

        /// Element type. One of “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”, “phone_number”, “email”.
        public var type: String

        /// Optional. Base64-encoded encrypted Telegram Passport element data provided by the user, available for “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport” and “address” types. Can be decrypted and verified using the accompanying EncryptedCredentials.
        public var data: String?

        /// Optional. User’s verified phone number, available only for “phone_number” type
        public var phoneNumber: String?

        /// Optional. User’s verified email address, available only for “email” type
        public var email: String?

        /// Optional. Array of encrypted files with documents provided by the user, available for “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration” and “temporary_registration” types. Files can be decrypted and verified using the accompanying EncryptedCredentials.
        public var files: [PassportFile]?

        /// Optional. Encrypted file with the front side of the document, provided by the user. Available for “passport”, “driver_license”, “identity_card” and “internal_passport”. The file can be decrypted and verified using the accompanying EncryptedCredentials.
        public var frontSide: PassportFile?

        /// Optional. Encrypted file with the reverse side of the document, provided by the user. Available for “driver_license” and “identity_card”. The file can be decrypted and verified using the accompanying EncryptedCredentials.
        public var reverseSide: PassportFile?

        /// Optional. Encrypted file with the selfie of the user holding a document, provided by the user; available for “passport”, “driver_license”, “identity_card” and “internal_passport”. The file can be decrypted and verified using the accompanying EncryptedCredentials.
        public var selfie: PassportFile?

        /// Optional. Array of encrypted files with translated versions of documents provided by the user. Available if requested for “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration” and “temporary_registration” types. Files can be decrypted and verified using the accompanying EncryptedCredentials.
        public var translation: [PassportFile]?

        /// Base64-encoded element hash for using in PassportElementErrorUnspecified
        public var hash: String

        /// EncryptedPassportElement initialization
        ///
        /// - parameter type:  Element type. One of “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”, “phone_number”, “email”.
        /// - parameter data:  Optional. Base64-encoded encrypted Telegram Passport element data provided by the user, available for “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport” and “address” types. Can be decrypted and verified using the accompanying EncryptedCredentials.
        /// - parameter phoneNumber:  Optional. User’s verified phone number, available only for “phone_number” type
        /// - parameter email:  Optional. User’s verified email address, available only for “email” type
        /// - parameter files:  Optional. Array of encrypted files with documents provided by the user, available for “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration” and “temporary_registration” types. Files can be decrypted and verified using the accompanying EncryptedCredentials.
        /// - parameter frontSide:  Optional. Encrypted file with the front side of the document, provided by the user. Available for “passport”, “driver_license”, “identity_card” and “internal_passport”. The file can be decrypted and verified using the accompanying EncryptedCredentials.
        /// - parameter reverseSide:  Optional. Encrypted file with the reverse side of the document, provided by the user. Available for “driver_license” and “identity_card”. The file can be decrypted and verified using the accompanying EncryptedCredentials.
        /// - parameter selfie:  Optional. Encrypted file with the selfie of the user holding a document, provided by the user; available for “passport”, “driver_license”, “identity_card” and “internal_passport”. The file can be decrypted and verified using the accompanying EncryptedCredentials.
        /// - parameter translation:  Optional. Array of encrypted files with translated versions of documents provided by the user. Available if requested for “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration” and “temporary_registration” types. Files can be decrypted and verified using the accompanying EncryptedCredentials.
        /// - parameter hash:  Base64-encoded element hash for using in PassportElementErrorUnspecified
        ///
        /// - returns: The new `EncryptedPassportElement` instance.
        ///
        public init(type: String, data: String? = nil, phoneNumber: String? = nil, email: String? = nil, files: [PassportFile]? = nil, frontSide: PassportFile? = nil, reverseSide: PassportFile? = nil, selfie: PassportFile? = nil, translation: [PassportFile]? = nil, hash: String) {
            self.type = type
            self.data = data
            self.phoneNumber = phoneNumber
            self.email = email
            self.files = files
            self.frontSide = frontSide
            self.reverseSide = reverseSide
            self.selfie = selfie
            self.translation = translation
            self.hash = hash
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case data = "data"
            case phoneNumber = "phone_number"
            case email = "email"
            case files = "files"
            case frontSide = "front_side"
            case reverseSide = "reverse_side"
            case selfie = "selfie"
            case translation = "translation"
            case hash = "hash"
        }

    }

    /// Contains data required for decrypting and authenticating EncryptedPassportElement. See the [Telegram Passport Documentation](https://core.telegram.org/passport#receiving-information) for a complete description of the data decryption and authentication processes.
    public class EncryptedCredentials: Codable {

        /// Base64-encoded encrypted JSON-serialized data with unique user’s payload, data hashes and secrets required for EncryptedPassportElement decryption and authentication
        public var data: String

        /// Base64-encoded data hash for data authentication
        public var hash: String

        /// Base64-encoded secret, encrypted with the bot’s public RSA key, required for data decryption
        public var secret: String

        /// EncryptedCredentials initialization
        ///
        /// - parameter data:  Base64-encoded encrypted JSON-serialized data with unique user’s payload, data hashes and secrets required for EncryptedPassportElement decryption and authentication
        /// - parameter hash:  Base64-encoded data hash for data authentication
        /// - parameter secret:  Base64-encoded secret, encrypted with the bot’s public RSA key, required for data decryption
        ///
        /// - returns: The new `EncryptedCredentials` instance.
        ///
        public init(data: String, hash: String, secret: String) {
            self.data = data
            self.hash = hash
            self.secret = secret
        }

        private enum CodingKeys: String, CodingKey {
            case data = "data"
            case hash = "hash"
            case secret = "secret"
        }

    }

    /// This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user. It should be one of:
    public enum PassportElementError: Codable {

        case dataField(PassportElementErrorDataField)
        case frontSide(PassportElementErrorFrontSide)
        case reverseSide(PassportElementErrorReverseSide)
        case selfie(PassportElementErrorSelfie)
        case file(PassportElementErrorFile)
        case files(PassportElementErrorFiles)
        case translationFile(PassportElementErrorTranslationFile)
        case translationFiles(PassportElementErrorTranslationFiles)
        case unspecified(PassportElementErrorUnspecified)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let dataField = try? container.decode(PassportElementErrorDataField.self) {
                self = .dataField(dataField)
            } else if let frontSide = try? container.decode(PassportElementErrorFrontSide.self) {
                self = .frontSide(frontSide)
            } else if let reverseSide = try? container.decode(PassportElementErrorReverseSide.self) {
                self = .reverseSide(reverseSide)
            } else if let selfie = try? container.decode(PassportElementErrorSelfie.self) {
                self = .selfie(selfie)
            } else if let file = try? container.decode(PassportElementErrorFile.self) {
                self = .file(file)
            } else if let files = try? container.decode(PassportElementErrorFiles.self) {
                self = .files(files)
            } else if let translationFile = try? container.decode(PassportElementErrorTranslationFile.self) {
                self = .translationFile(translationFile)
            } else if let translationFiles = try? container.decode(PassportElementErrorTranslationFiles.self) {
                self = .translationFiles(translationFiles)
            } else if let unspecified = try? container.decode(PassportElementErrorUnspecified.self) {
                self = .unspecified(unspecified)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "PassportElementError"])
            }
        }

        public init(_ dataField: PassportElementErrorDataField) {
            self = .dataField(dataField)
        }

        public init(_ frontSide: PassportElementErrorFrontSide) {
            self = .frontSide(frontSide)
        }

        public init(_ reverseSide: PassportElementErrorReverseSide) {
            self = .reverseSide(reverseSide)
        }

        public init(_ selfie: PassportElementErrorSelfie) {
            self = .selfie(selfie)
        }

        public init(_ file: PassportElementErrorFile) {
            self = .file(file)
        }

        public init(_ files: PassportElementErrorFiles) {
            self = .files(files)
        }

        public init(_ translationFile: PassportElementErrorTranslationFile) {
            self = .translationFile(translationFile)
        }

        public init(_ translationFiles: PassportElementErrorTranslationFiles) {
            self = .translationFiles(translationFiles)
        }

        public init(_ unspecified: PassportElementErrorUnspecified) {
            self = .unspecified(unspecified)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .dataField(let dataField):
                try container.encode(dataField)
            case .frontSide(let frontSide):
                try container.encode(frontSide)
            case .reverseSide(let reverseSide):
                try container.encode(reverseSide)
            case .selfie(let selfie):
                try container.encode(selfie)
            case .file(let file):
                try container.encode(file)
            case .files(let files):
                try container.encode(files)
            case .translationFile(let translationFile):
                try container.encode(translationFile)
            case .translationFiles(let translationFiles):
                try container.encode(translationFiles)
            case .unspecified(let unspecified):
                try container.encode(unspecified)
            }
        }
    }
    /// Represents an issue in one of the data fields that was provided by the user. The error is considered resolved when the field’s value changes.
    public class PassportElementErrorDataField: Codable {

        /// Error source, must be data
        public var source: String

        /// The section of the user’s Telegram Passport which has the error, one of “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”
        public var type: String

        /// Name of the data field which has the error
        public var fieldName: String

        /// Base64-encoded data hash
        public var dataHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorDataField initialization
        ///
        /// - parameter source:  Error source, must be data
        /// - parameter type:  The section of the user’s Telegram Passport which has the error, one of “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”
        /// - parameter fieldName:  Name of the data field which has the error
        /// - parameter dataHash:  Base64-encoded data hash
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorDataField` instance.
        ///
        public init(source: String, type: String, fieldName: String, dataHash: String, message: String) {
            self.source = source
            self.type = type
            self.fieldName = fieldName
            self.dataHash = dataHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fieldName = "field_name"
            case dataHash = "data_hash"
            case message = "message"
        }

    }

    /// Represents an issue with the front side of a document. The error is considered resolved when the file with the front side of the document changes.
    public class PassportElementErrorFrontSide: Codable {

        /// Error source, must be front_side
        public var source: String

        /// The section of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
        public var type: String

        /// Base64-encoded hash of the file with the front side of the document
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorFrontSide initialization
        ///
        /// - parameter source:  Error source, must be front_side
        /// - parameter type:  The section of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
        /// - parameter fileHash:  Base64-encoded hash of the file with the front side of the document
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorFrontSide` instance.
        ///
        public init(source: String, type: String, fileHash: String, message: String) {
            self.source = source
            self.type = type
            self.fileHash = fileHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHash = "file_hash"
            case message = "message"
        }

    }

    /// Represents an issue with the reverse side of a document. The error is considered resolved when the file with reverse side of the document changes.
    public class PassportElementErrorReverseSide: Codable {

        /// Error source, must be reverse_side
        public var source: String

        /// The section of the user’s Telegram Passport which has the issue, one of “driver_license”, “identity_card”
        public var type: String

        /// Base64-encoded hash of the file with the reverse side of the document
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorReverseSide initialization
        ///
        /// - parameter source:  Error source, must be reverse_side
        /// - parameter type:  The section of the user’s Telegram Passport which has the issue, one of “driver_license”, “identity_card”
        /// - parameter fileHash:  Base64-encoded hash of the file with the reverse side of the document
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorReverseSide` instance.
        ///
        public init(source: String, type: String, fileHash: String, message: String) {
            self.source = source
            self.type = type
            self.fileHash = fileHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHash = "file_hash"
            case message = "message"
        }

    }

    /// Represents an issue with the selfie with a document. The error is considered resolved when the file with the selfie changes.
    public class PassportElementErrorSelfie: Codable {

        /// Error source, must be selfie
        public var source: String

        /// The section of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
        public var type: String

        /// Base64-encoded hash of the file with the selfie
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorSelfie initialization
        ///
        /// - parameter source:  Error source, must be selfie
        /// - parameter type:  The section of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
        /// - parameter fileHash:  Base64-encoded hash of the file with the selfie
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorSelfie` instance.
        ///
        public init(source: String, type: String, fileHash: String, message: String) {
            self.source = source
            self.type = type
            self.fileHash = fileHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHash = "file_hash"
            case message = "message"
        }

    }

    /// Represents an issue with a document scan. The error is considered resolved when the file with the document scan changes.
    public class PassportElementErrorFile: Codable {

        /// Error source, must be file
        public var source: String

        /// The section of the user’s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// Base64-encoded file hash
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorFile initialization
        ///
        /// - parameter source:  Error source, must be file
        /// - parameter type:  The section of the user’s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        /// - parameter fileHash:  Base64-encoded file hash
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorFile` instance.
        ///
        public init(source: String, type: String, fileHash: String, message: String) {
            self.source = source
            self.type = type
            self.fileHash = fileHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHash = "file_hash"
            case message = "message"
        }

    }

    /// Represents an issue with a list of scans. The error is considered resolved when the list of files containing the scans changes.
    public class PassportElementErrorFiles: Codable {

        /// Error source, must be files
        public var source: String

        /// The section of the user’s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// List of base64-encoded file hashes
        public var fileHashes: [String]

        /// Error message
        public var message: String

        /// PassportElementErrorFiles initialization
        ///
        /// - parameter source:  Error source, must be files
        /// - parameter type:  The section of the user’s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        /// - parameter fileHashes:  List of base64-encoded file hashes
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorFiles` instance.
        ///
        public init(source: String, type: String, fileHashes: [String], message: String) {
            self.source = source
            self.type = type
            self.fileHashes = fileHashes
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHashes = "file_hashes"
            case message = "message"
        }

    }

    /// Represents an issue with one of the files that constitute the translation of a document. The error is considered resolved when the file changes.
    public class PassportElementErrorTranslationFile: Codable {

        /// Error source, must be translation_file
        public var source: String

        /// Type of element of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// Base64-encoded file hash
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorTranslationFile initialization
        ///
        /// - parameter source:  Error source, must be translation_file
        /// - parameter type:  Type of element of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        /// - parameter fileHash:  Base64-encoded file hash
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorTranslationFile` instance.
        ///
        public init(source: String, type: String, fileHash: String, message: String) {
            self.source = source
            self.type = type
            self.fileHash = fileHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHash = "file_hash"
            case message = "message"
        }

    }

    /// Represents an issue with the translated version of a document. The error is considered resolved when a file with the document translation change.
    public class PassportElementErrorTranslationFiles: Codable {

        /// Error source, must be translation_files
        public var source: String

        /// Type of element of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// List of base64-encoded file hashes
        public var fileHashes: [String]

        /// Error message
        public var message: String

        /// PassportElementErrorTranslationFiles initialization
        ///
        /// - parameter source:  Error source, must be translation_files
        /// - parameter type:  Type of element of the user’s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        /// - parameter fileHashes:  List of base64-encoded file hashes
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorTranslationFiles` instance.
        ///
        public init(source: String, type: String, fileHashes: [String], message: String) {
            self.source = source
            self.type = type
            self.fileHashes = fileHashes
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case fileHashes = "file_hashes"
            case message = "message"
        }

    }

    /// Represents an issue in an unspecified place. The error is considered resolved when new data is added.
    public class PassportElementErrorUnspecified: Codable {

        /// Error source, must be unspecified
        public var source: String

        /// Type of element of the user’s Telegram Passport which has the issue
        public var type: String

        /// Base64-encoded element hash
        public var elementHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorUnspecified initialization
        ///
        /// - parameter source:  Error source, must be unspecified
        /// - parameter type:  Type of element of the user’s Telegram Passport which has the issue
        /// - parameter elementHash:  Base64-encoded element hash
        /// - parameter message:  Error message
        ///
        /// - returns: The new `PassportElementErrorUnspecified` instance.
        ///
        public init(source: String, type: String, elementHash: String, message: String) {
            self.source = source
            self.type = type
            self.elementHash = elementHash
            self.message = message
        }

        private enum CodingKeys: String, CodingKey {
            case source = "source"
            case type = "type"
            case elementHash = "element_hash"
            case message = "message"
        }

    }

    /// This object represents a game. Use BotFather to create and edit games, their short names will act as unique identifiers.
    public class Game: Codable {

        /// Title of the game
        public var title: String

        /// Description of the game
        public var description: String

        /// Photo that will be displayed in the game message in chats.
        public var photo: [PhotoSize]

        /// Optional. Brief description of the game or high scores included in the game message. Can be automatically edited to include current high scores for the game when the bot calls setGameScore, or manually edited using editMessageText. 0-4096 characters.
        public var text: String?

        /// Optional. Special entities that appear in text, such as usernames, URLs, bot commands, etc.
        public var textEntities: [MessageEntity]?

        /// Optional. Animation that will be displayed in the game message in chats. Upload via [BotFather](https://t.me/botfather)
        public var animation: Animation?

        /// Game initialization
        ///
        /// - parameter title:  Title of the game
        /// - parameter description:  Description of the game
        /// - parameter photo:  Photo that will be displayed in the game message in chats.
        /// - parameter text:  Optional. Brief description of the game or high scores included in the game message. Can be automatically edited to include current high scores for the game when the bot calls setGameScore, or manually edited using editMessageText. 0-4096 characters.
        /// - parameter textEntities:  Optional. Special entities that appear in text, such as usernames, URLs, bot commands, etc.
        /// - parameter animation:  Optional. Animation that will be displayed in the game message in chats. Upload via [BotFather](https://t.me/botfather)
        ///
        /// - returns: The new `Game` instance.
        ///
        public init(title: String, description: String, photo: [PhotoSize], text: String? = nil, textEntities: [MessageEntity]? = nil, animation: Animation? = nil) {
            self.title = title
            self.description = description
            self.photo = photo
            self.text = text
            self.textEntities = textEntities
            self.animation = animation
        }

        private enum CodingKeys: String, CodingKey {
            case title = "title"
            case description = "description"
            case photo = "photo"
            case text = "text"
            case textEntities = "text_entities"
            case animation = "animation"
        }

    }

    /// A placeholder, currently holds no information. Use [BotFather](https://t.me/botfather) to set up your game.
    public struct CallbackGame: Codable {

    }

    /// This object represents one row of the high scores table for a game.
    public class GameHighScore: Codable {

        /// Position in high score table for the game
        public var position: Int

        /// User
        public var user: User

        /// Score
        public var score: Int

        /// GameHighScore initialization
        ///
        /// - parameter position:  Position in high score table for the game
        /// - parameter user:  User
        /// - parameter score:  Score
        ///
        /// - returns: The new `GameHighScore` instance.
        ///
        public init(position: Int, user: User, score: Int) {
            self.position = position
            self.user = user
            self.score = score
        }

        private enum CodingKeys: String, CodingKey {
            case position = "position"
            case user = "user"
            case score = "score"
        }

    }

}
