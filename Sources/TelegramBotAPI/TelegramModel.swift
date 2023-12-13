//
//  TelegramModel.swift
//  TelegramAPI
//
//  Created by Tbxark on 2023/12/13.
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

        /// The update’s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
        public var updateId: Int

        /// Optional. New incoming message of any kind - text, photo, sticker, etc.
        public var message: Message?

        /// Optional. New version of a message that is known to the bot and was edited
        public var editedMessage: Message?

        /// Optional. New incoming channel post of any kind - text, photo, sticker, etc.
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

        /// Optional. A chat member’s status was updated in a chat. The bot must be an administrator in the chat and must explicitly specify &quot;chat_member&quot; in the list of allowed_updates to receive these updates.
        public var chatMember: ChatMemberUpdated?

        /// Optional. A request to join the chat has been sent. The bot must have the can_invite_users administrator right in the chat to receive these updates.
        public var chatJoinRequest: ChatJoinRequest?

        /// Update initialization
        ///
        /// - parameter updateId:  The update’s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
        /// - parameter message:  Optional. New incoming message of any kind - text, photo, sticker, etc.
        /// - parameter editedMessage:  Optional. New version of a message that is known to the bot and was edited
        /// - parameter channelPost:  Optional. New incoming channel post of any kind - text, photo, sticker, etc.
        /// - parameter editedChannelPost:  Optional. New version of a channel post that is known to the bot and was edited
        /// - parameter inlineQuery:  Optional. New incoming inline query
        /// - parameter chosenInlineResult:  Optional. The result of an inline query that was chosen by a user and sent to their chat partner. Please see our documentation on the feedback collecting for details on how to enable these updates for your bot.
        /// - parameter callbackQuery:  Optional. New incoming callback query
        /// - parameter shippingQuery:  Optional. New incoming shipping query. Only for invoices with flexible price
        /// - parameter preCheckoutQuery:  Optional. New incoming pre-checkout query. Contains full information about checkout
        /// - parameter poll:  Optional. New poll state. Bots receive only updates about stopped polls and polls, which are sent by the bot
        /// - parameter pollAnswer:  Optional. A user changed their answer in a non-anonymous poll. Bots receive new votes only in polls that were sent by the bot itself.
        /// - parameter myChatMember:  Optional. The bot’s chat member status was updated in a chat. For private chats, this update is received only when the bot is blocked or unblocked by the user.
        /// - parameter chatMember:  Optional. A chat member’s status was updated in a chat. The bot must be an administrator in the chat and must explicitly specify &quot;chat_member&quot; in the list of allowed_updates to receive these updates.
        /// - parameter chatJoinRequest:  Optional. A request to join the chat has been sent. The bot must have the can_invite_users administrator right in the chat to receive these updates.
        ///
        /// - returns: The new `Update` instance.
        ///
        public init(updateId: Int, message: Message? = nil, editedMessage: Message? = nil, channelPost: Message? = nil, editedChannelPost: Message? = nil, inlineQuery: InlineQuery? = nil, chosenInlineResult: ChosenInlineResult? = nil, callbackQuery: CallbackQuery? = nil, shippingQuery: ShippingQuery? = nil, preCheckoutQuery: PreCheckoutQuery? = nil, poll: Poll? = nil, pollAnswer: PollAnswer? = nil, myChatMember: ChatMemberUpdated? = nil, chatMember: ChatMemberUpdated? = nil, chatJoinRequest: ChatJoinRequest? = nil) {
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
            self.chatJoinRequest = chatJoinRequest
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
            case chatJoinRequest = "chat_join_request"
        }

    }

    /// Describes the current status of a webhook.
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

        /// Optional. Unix time of the most recent error that happened when trying to synchronize available updates with Telegram datacenters
        public var lastSynchronizationErrorDate: Int?

        /// Optional. The maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
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
        /// - parameter lastSynchronizationErrorDate:  Optional. Unix time of the most recent error that happened when trying to synchronize available updates with Telegram datacenters
        /// - parameter maxConnections:  Optional. The maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
        /// - parameter allowedUpdates:  Optional. A list of update types the bot is subscribed to. Defaults to all update types except chat_member
        ///
        /// - returns: The new `WebhookInfo` instance.
        ///
        public init(url: String, hasCustomCertificate: Bool, pendingUpdateCount: Int, ipAddress: String? = nil, lastErrorDate: Int? = nil, lastErrorMessage: String? = nil, lastSynchronizationErrorDate: Int? = nil, maxConnections: Int? = nil, allowedUpdates: [String]? = nil) {
            self.url = url
            self.hasCustomCertificate = hasCustomCertificate
            self.pendingUpdateCount = pendingUpdateCount
            self.ipAddress = ipAddress
            self.lastErrorDate = lastErrorDate
            self.lastErrorMessage = lastErrorMessage
            self.lastSynchronizationErrorDate = lastSynchronizationErrorDate
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
            case lastSynchronizationErrorDate = "last_synchronization_error_date"
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

        /// Optional. True, if this user is a Telegram Premium user
        public var isPremium: Bool?

        /// Optional. True, if this user added the bot to the attachment menu
        public var addedToAttachmentMenu: Bool?

        /// Optional. True, if the bot can be invited to groups. Returned only in getMe.
        public var canJoinGroups: Bool?

        /// Optional. True, if privacy mode is disabled for the bot. Returned only in getMe.
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
        /// - parameter isPremium:  Optional. True, if this user is a Telegram Premium user
        /// - parameter addedToAttachmentMenu:  Optional. True, if this user added the bot to the attachment menu
        /// - parameter canJoinGroups:  Optional. True, if the bot can be invited to groups. Returned only in getMe.
        /// - parameter canReadAllGroupMessages:  Optional. True, if privacy mode is disabled for the bot. Returned only in getMe.
        /// - parameter supportsInlineQueries:  Optional. True, if the bot supports inline queries. Returned only in getMe.
        ///
        /// - returns: The new `User` instance.
        ///
        public init(id: Int, isBot: Bool, firstName: String, lastName: String? = nil, username: String? = nil, languageCode: String? = nil, isPremium: Bool? = nil, addedToAttachmentMenu: Bool? = nil, canJoinGroups: Bool? = nil, canReadAllGroupMessages: Bool? = nil, supportsInlineQueries: Bool? = nil) {
            self.id = id
            self.isBot = isBot
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.languageCode = languageCode
            self.isPremium = isPremium
            self.addedToAttachmentMenu = addedToAttachmentMenu
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
            case isPremium = "is_premium"
            case addedToAttachmentMenu = "added_to_attachment_menu"
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

        /// Optional. True, if the supergroup chat is a forum (has [topics](https://telegram.org/blog/topics-in-groups-collectible-usernames#topics-in-groups) enabled)
        public var isForum: Bool?

        /// Optional. Chat photo. Returned only in getChat.
        public var photo: ChatPhoto?

        /// Optional. If non-empty, the list of all [active chat usernames](https://telegram.org/blog/topics-in-groups-collectible-usernames#collectible-usernames); for private chats, supergroups and channels. Returned only in getChat.
        public var activeUsernames: [String]?

        /// Optional. Custom emoji identifier of emoji status of the other party in a private chat. Returned only in getChat.
        public var emojiStatusCustomEmojiId: String?

        /// Optional. Expiration date of the emoji status of the other party in a private chat in Unix time, if any. Returned only in getChat.
        public var emojiStatusExpirationDate: Int?

        /// Optional. Bio of the other party in a private chat. Returned only in getChat.
        public var bio: String?

        /// Optional. True, if privacy settings of the other party in the private chat allows to use tg://user?id=&lt;user_id&gt; links only in chats with the user. Returned only in getChat.
        public var hasPrivateForwards: Bool?

        /// Optional. True, if the privacy settings of the other party restrict sending voice and video note messages in the private chat. Returned only in getChat.
        public var hasRestrictedVoiceAndVideoMessages: Bool?

        /// Optional. True, if users need to join the supergroup before they can send messages. Returned only in getChat.
        public var joinToSendMessages: Bool?

        /// Optional. True, if all users directly joining the supergroup need to be approved by supergroup administrators. Returned only in getChat.
        public var joinByRequest: Bool?

        /// Optional. Description, for groups, supergroups and channel chats. Returned only in getChat.
        public var description: String?

        /// Optional. Primary invite link, for groups, supergroups and channel chats. Returned only in getChat.
        public var inviteLink: String?

        /// Optional. The most recent pinned message (by sending date). Returned only in getChat.
        public var pinnedMessage: Message?

        /// Optional. Default chat member permissions, for groups and supergroups. Returned only in getChat.
        public var permissions: ChatPermissions?

        /// Optional. For supergroups, the minimum allowed delay between consecutive messages sent by each unpriviledged user; in seconds. Returned only in getChat.
        public var slowModeDelay: Int?

        /// Optional. The time after which all messages sent to the chat will be automatically deleted; in seconds. Returned only in getChat.
        public var messageAutoDeleteTime: Int?

        /// Optional. True, if aggressive anti-spam checks are enabled in the supergroup. The field is only available to chat administrators. Returned only in getChat.
        public var hasAggressiveAntiSpamEnabled: Bool?

        /// Optional. True, if non-administrators can only get the list of bots and administrators in the chat. Returned only in getChat.
        public var hasHiddenMembers: Bool?

        /// Optional. True, if messages from the chat can’t be forwarded to other chats. Returned only in getChat.
        public var hasProtectedContent: Bool?

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
        /// - parameter isForum:  Optional. True, if the supergroup chat is a forum (has [topics](https://telegram.org/blog/topics-in-groups-collectible-usernames#topics-in-groups) enabled)
        /// - parameter photo:  Optional. Chat photo. Returned only in getChat.
        /// - parameter activeUsernames:  Optional. If non-empty, the list of all [active chat usernames](https://telegram.org/blog/topics-in-groups-collectible-usernames#collectible-usernames); for private chats, supergroups and channels. Returned only in getChat.
        /// - parameter emojiStatusCustomEmojiId:  Optional. Custom emoji identifier of emoji status of the other party in a private chat. Returned only in getChat.
        /// - parameter emojiStatusExpirationDate:  Optional. Expiration date of the emoji status of the other party in a private chat in Unix time, if any. Returned only in getChat.
        /// - parameter bio:  Optional. Bio of the other party in a private chat. Returned only in getChat.
        /// - parameter hasPrivateForwards:  Optional. True, if privacy settings of the other party in the private chat allows to use tg://user?id=&lt;user_id&gt; links only in chats with the user. Returned only in getChat.
        /// - parameter hasRestrictedVoiceAndVideoMessages:  Optional. True, if the privacy settings of the other party restrict sending voice and video note messages in the private chat. Returned only in getChat.
        /// - parameter joinToSendMessages:  Optional. True, if users need to join the supergroup before they can send messages. Returned only in getChat.
        /// - parameter joinByRequest:  Optional. True, if all users directly joining the supergroup need to be approved by supergroup administrators. Returned only in getChat.
        /// - parameter description:  Optional. Description, for groups, supergroups and channel chats. Returned only in getChat.
        /// - parameter inviteLink:  Optional. Primary invite link, for groups, supergroups and channel chats. Returned only in getChat.
        /// - parameter pinnedMessage:  Optional. The most recent pinned message (by sending date). Returned only in getChat.
        /// - parameter permissions:  Optional. Default chat member permissions, for groups and supergroups. Returned only in getChat.
        /// - parameter slowModeDelay:  Optional. For supergroups, the minimum allowed delay between consecutive messages sent by each unpriviledged user; in seconds. Returned only in getChat.
        /// - parameter messageAutoDeleteTime:  Optional. The time after which all messages sent to the chat will be automatically deleted; in seconds. Returned only in getChat.
        /// - parameter hasAggressiveAntiSpamEnabled:  Optional. True, if aggressive anti-spam checks are enabled in the supergroup. The field is only available to chat administrators. Returned only in getChat.
        /// - parameter hasHiddenMembers:  Optional. True, if non-administrators can only get the list of bots and administrators in the chat. Returned only in getChat.
        /// - parameter hasProtectedContent:  Optional. True, if messages from the chat can’t be forwarded to other chats. Returned only in getChat.
        /// - parameter stickerSetName:  Optional. For supergroups, name of group sticker set. Returned only in getChat.
        /// - parameter canSetStickerSet:  Optional. True, if the bot can change the group sticker set. Returned only in getChat.
        /// - parameter linkedChatId:  Optional. Unique identifier for the linked chat, i.e. the discussion group identifier for a channel and vice versa; for supergroups and channel chats. This identifier may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier. Returned only in getChat.
        /// - parameter location:  Optional. For supergroups, the location to which the supergroup is connected. Returned only in getChat.
        ///
        /// - returns: The new `Chat` instance.
        ///
        public init(id: Int, type: String, title: String? = nil, username: String? = nil, firstName: String? = nil, lastName: String? = nil, isForum: Bool? = nil, photo: ChatPhoto? = nil, activeUsernames: [String]? = nil, emojiStatusCustomEmojiId: String? = nil, emojiStatusExpirationDate: Int? = nil, bio: String? = nil, hasPrivateForwards: Bool? = nil, hasRestrictedVoiceAndVideoMessages: Bool? = nil, joinToSendMessages: Bool? = nil, joinByRequest: Bool? = nil, description: String? = nil, inviteLink: String? = nil, pinnedMessage: Message? = nil, permissions: ChatPermissions? = nil, slowModeDelay: Int? = nil, messageAutoDeleteTime: Int? = nil, hasAggressiveAntiSpamEnabled: Bool? = nil, hasHiddenMembers: Bool? = nil, hasProtectedContent: Bool? = nil, stickerSetName: String? = nil, canSetStickerSet: Bool? = nil, linkedChatId: Int? = nil, location: ChatLocation? = nil) {
            self.id = id
            self.type = type
            self.title = title
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
            self.isForum = isForum
            self.photo = photo
            self.activeUsernames = activeUsernames
            self.emojiStatusCustomEmojiId = emojiStatusCustomEmojiId
            self.emojiStatusExpirationDate = emojiStatusExpirationDate
            self.bio = bio
            self.hasPrivateForwards = hasPrivateForwards
            self.hasRestrictedVoiceAndVideoMessages = hasRestrictedVoiceAndVideoMessages
            self.joinToSendMessages = joinToSendMessages
            self.joinByRequest = joinByRequest
            self.description = description
            self.inviteLink = inviteLink
            self.pinnedMessage = pinnedMessage
            self.permissions = permissions
            self.slowModeDelay = slowModeDelay
            self.messageAutoDeleteTime = messageAutoDeleteTime
            self.hasAggressiveAntiSpamEnabled = hasAggressiveAntiSpamEnabled
            self.hasHiddenMembers = hasHiddenMembers
            self.hasProtectedContent = hasProtectedContent
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
            case isForum = "is_forum"
            case photo = "photo"
            case activeUsernames = "active_usernames"
            case emojiStatusCustomEmojiId = "emoji_status_custom_emoji_id"
            case emojiStatusExpirationDate = "emoji_status_expiration_date"
            case bio = "bio"
            case hasPrivateForwards = "has_private_forwards"
            case hasRestrictedVoiceAndVideoMessages = "has_restricted_voice_and_video_messages"
            case joinToSendMessages = "join_to_send_messages"
            case joinByRequest = "join_by_request"
            case description = "description"
            case inviteLink = "invite_link"
            case pinnedMessage = "pinned_message"
            case permissions = "permissions"
            case slowModeDelay = "slow_mode_delay"
            case messageAutoDeleteTime = "message_auto_delete_time"
            case hasAggressiveAntiSpamEnabled = "has_aggressive_anti_spam_enabled"
            case hasHiddenMembers = "has_hidden_members"
            case hasProtectedContent = "has_protected_content"
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

        /// Optional. Unique identifier of a message thread to which the message belongs; for supergroups only
        public var messageThreadId: Int?

        /// Optional. Sender of the message; empty for messages sent to channels. For backward compatibility, the field contains a fake sender user in non-channel chats, if the message was sent on behalf of a chat.
        public var from: User?

        /// Optional. Sender of the message, sent on behalf of a chat. For example, the channel itself for channel posts, the supergroup itself for messages from anonymous group administrators, the linked channel for messages automatically forwarded to the discussion group. For backward compatibility, the field from contains a fake sender user in non-channel chats, if the message was sent on behalf of a chat.
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

        /// Optional. For forwarded messages that were originally sent in channels or by an anonymous chat administrator, signature of the message sender if present
        public var forwardSignature: String?

        /// Optional. Sender’s name for messages forwarded from users who disallow adding a link to their account in forwarded messages
        public var forwardSenderName: String?

        /// Optional. For forwarded messages, date the original message was sent in Unix time
        public var forwardDate: Int?

        /// Optional. True, if the message is sent to a forum topic
        public var isTopicMessage: Bool?

        /// Optional. True, if the message is a channel post that was automatically forwarded to the connected discussion group
        public var isAutomaticForward: Bool?

        /// Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
        public var replyToMessage: Message?

        /// Optional. Bot through which the message was sent
        public var viaBot: User?

        /// Optional. Date the message was last edited in Unix time
        public var editDate: Int?

        /// Optional. True, if the message can’t be forwarded
        public var hasProtectedContent: Bool?

        /// Optional. The unique identifier of a media message group this message belongs to
        public var mediaGroupId: String?

        /// Optional. Signature of the post author for messages in channels, or the custom title of an anonymous group administrator
        public var authorSignature: String?

        /// Optional. For text messages, the actual UTF-8 text of the message
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

        /// Optional. Message is a forwarded story
        public var story: Story?

        /// Optional. Message is a video, information about the video
        public var video: Video?

        /// Optional. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message
        public var videoNote: VideoNote?

        /// Optional. Message is a voice message, information about the file
        public var voice: Voice?

        /// Optional. Caption for the animation, audio, document, photo, video or voice
        public var caption: String?

        /// Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
        public var captionEntities: [MessageEntity]?

        /// Optional. True, if the message media is covered by a spoiler animation
        public var hasMediaSpoiler: Bool?

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

        /// Optional. Service message: a user was shared with the bot
        public var userShared: UserShared?

        /// Optional. Service message: a chat was shared with the bot
        public var chatShared: ChatShared?

        /// Optional. The domain name of the website on which the user has logged in. More about Telegram Login »
        public var connectedWebsite: String?

        /// Optional. Service message: the user allowed the bot to write messages after adding it to the attachment or side menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method requestWriteAccess
        public var writeAccessAllowed: WriteAccessAllowed?

        /// Optional. Telegram Passport data
        public var passportData: PassportData?

        /// Optional. Service message. A user in the chat triggered another user’s proximity alert while sharing Live Location.
        public var proximityAlertTriggered: ProximityAlertTriggered?

        /// Optional. Service message: forum topic created
        public var forumTopicCreated: ForumTopicCreated?

        /// Optional. Service message: forum topic edited
        public var forumTopicEdited: ForumTopicEdited?

        /// Optional. Service message: forum topic closed
        public var forumTopicClosed: ForumTopicClosed?

        /// Optional. Service message: forum topic reopened
        public var forumTopicReopened: ForumTopicReopened?

        /// Optional. Service message: the ’General’ forum topic hidden
        public var generalForumTopicHidden: GeneralForumTopicHidden?

        /// Optional. Service message: the ’General’ forum topic unhidden
        public var generalForumTopicUnhidden: GeneralForumTopicUnhidden?

        /// Optional. Service message: video chat scheduled
        public var videoChatScheduled: VideoChatScheduled?

        /// Optional. Service message: video chat started
        public var videoChatStarted: VideoChatStarted?

        /// Optional. Service message: video chat ended
        public var videoChatEnded: VideoChatEnded?

        /// Optional. Service message: new participants invited to a video chat
        public var videoChatParticipantsInvited: VideoChatParticipantsInvited?

        /// Optional. Service message: data sent by a Web App
        public var webAppData: WebAppData?

        /// Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
        public var replyMarkup: InlineKeyboardMarkup?

        /// Message initialization
        ///
        /// - parameter messageId:  Unique message identifier inside this chat
        /// - parameter messageThreadId:  Optional. Unique identifier of a message thread to which the message belongs; for supergroups only
        /// - parameter from:  Optional. Sender of the message; empty for messages sent to channels. For backward compatibility, the field contains a fake sender user in non-channel chats, if the message was sent on behalf of a chat.
        /// - parameter senderChat:  Optional. Sender of the message, sent on behalf of a chat. For example, the channel itself for channel posts, the supergroup itself for messages from anonymous group administrators, the linked channel for messages automatically forwarded to the discussion group. For backward compatibility, the field from contains a fake sender user in non-channel chats, if the message was sent on behalf of a chat.
        /// - parameter date:  Date the message was sent in Unix time
        /// - parameter chat:  Conversation the message belongs to
        /// - parameter forwardFrom:  Optional. For forwarded messages, sender of the original message
        /// - parameter forwardFromChat:  Optional. For messages forwarded from channels or from anonymous administrators, information about the original sender chat
        /// - parameter forwardFromMessageId:  Optional. For messages forwarded from channels, identifier of the original message in the channel
        /// - parameter forwardSignature:  Optional. For forwarded messages that were originally sent in channels or by an anonymous chat administrator, signature of the message sender if present
        /// - parameter forwardSenderName:  Optional. Sender’s name for messages forwarded from users who disallow adding a link to their account in forwarded messages
        /// - parameter forwardDate:  Optional. For forwarded messages, date the original message was sent in Unix time
        /// - parameter isTopicMessage:  Optional. True, if the message is sent to a forum topic
        /// - parameter isAutomaticForward:  Optional. True, if the message is a channel post that was automatically forwarded to the connected discussion group
        /// - parameter replyToMessage:  Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
        /// - parameter viaBot:  Optional. Bot through which the message was sent
        /// - parameter editDate:  Optional. Date the message was last edited in Unix time
        /// - parameter hasProtectedContent:  Optional. True, if the message can’t be forwarded
        /// - parameter mediaGroupId:  Optional. The unique identifier of a media message group this message belongs to
        /// - parameter authorSignature:  Optional. Signature of the post author for messages in channels, or the custom title of an anonymous group administrator
        /// - parameter text:  Optional. For text messages, the actual UTF-8 text of the message
        /// - parameter entities:  Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
        /// - parameter animation:  Optional. Message is an animation, information about the animation. For backward compatibility, when this field is set, the document field will also be set
        /// - parameter audio:  Optional. Message is an audio file, information about the file
        /// - parameter document:  Optional. Message is a general file, information about the file
        /// - parameter photo:  Optional. Message is a photo, available sizes of the photo
        /// - parameter sticker:  Optional. Message is a sticker, information about the sticker
        /// - parameter story:  Optional. Message is a forwarded story
        /// - parameter video:  Optional. Message is a video, information about the video
        /// - parameter videoNote:  Optional. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message
        /// - parameter voice:  Optional. Message is a voice message, information about the file
        /// - parameter caption:  Optional. Caption for the animation, audio, document, photo, video or voice
        /// - parameter captionEntities:  Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
        /// - parameter hasMediaSpoiler:  Optional. True, if the message media is covered by a spoiler animation
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
        /// - parameter userShared:  Optional. Service message: a user was shared with the bot
        /// - parameter chatShared:  Optional. Service message: a chat was shared with the bot
        /// - parameter connectedWebsite:  Optional. The domain name of the website on which the user has logged in. More about Telegram Login »
        /// - parameter writeAccessAllowed:  Optional. Service message: the user allowed the bot to write messages after adding it to the attachment or side menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method requestWriteAccess
        /// - parameter passportData:  Optional. Telegram Passport data
        /// - parameter proximityAlertTriggered:  Optional. Service message. A user in the chat triggered another user’s proximity alert while sharing Live Location.
        /// - parameter forumTopicCreated:  Optional. Service message: forum topic created
        /// - parameter forumTopicEdited:  Optional. Service message: forum topic edited
        /// - parameter forumTopicClosed:  Optional. Service message: forum topic closed
        /// - parameter forumTopicReopened:  Optional. Service message: forum topic reopened
        /// - parameter generalForumTopicHidden:  Optional. Service message: the ’General’ forum topic hidden
        /// - parameter generalForumTopicUnhidden:  Optional. Service message: the ’General’ forum topic unhidden
        /// - parameter videoChatScheduled:  Optional. Service message: video chat scheduled
        /// - parameter videoChatStarted:  Optional. Service message: video chat started
        /// - parameter videoChatEnded:  Optional. Service message: video chat ended
        /// - parameter videoChatParticipantsInvited:  Optional. Service message: new participants invited to a video chat
        /// - parameter webAppData:  Optional. Service message: data sent by a Web App
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
        ///
        /// - returns: The new `Message` instance.
        ///
        public init(messageId: Int, messageThreadId: Int? = nil, from: User? = nil, senderChat: Chat? = nil, date: Int, chat: Chat, forwardFrom: User? = nil, forwardFromChat: Chat? = nil, forwardFromMessageId: Int? = nil, forwardSignature: String? = nil, forwardSenderName: String? = nil, forwardDate: Int? = nil, isTopicMessage: Bool? = nil, isAutomaticForward: Bool? = nil, replyToMessage: Message? = nil, viaBot: User? = nil, editDate: Int? = nil, hasProtectedContent: Bool? = nil, mediaGroupId: String? = nil, authorSignature: String? = nil, text: String? = nil, entities: [MessageEntity]? = nil, animation: Animation? = nil, audio: Audio? = nil, document: Document? = nil, photo: [PhotoSize]? = nil, sticker: Sticker? = nil, story: Story? = nil, video: Video? = nil, videoNote: VideoNote? = nil, voice: Voice? = nil, caption: String? = nil, captionEntities: [MessageEntity]? = nil, hasMediaSpoiler: Bool? = nil, contact: Contact? = nil, dice: Dice? = nil, game: Game? = nil, poll: Poll? = nil, venue: Venue? = nil, location: Location? = nil, newChatMembers: [User]? = nil, leftChatMember: User? = nil, newChatTitle: String? = nil, newChatPhoto: [PhotoSize]? = nil, deleteChatPhoto: Bool? = nil, groupChatCreated: Bool? = nil, supergroupChatCreated: Bool? = nil, channelChatCreated: Bool? = nil, messageAutoDeleteTimerChanged: MessageAutoDeleteTimerChanged? = nil, migrateToChatId: Int? = nil, migrateFromChatId: Int? = nil, pinnedMessage: Message? = nil, invoice: Invoice? = nil, successfulPayment: SuccessfulPayment? = nil, userShared: UserShared? = nil, chatShared: ChatShared? = nil, connectedWebsite: String? = nil, writeAccessAllowed: WriteAccessAllowed? = nil, passportData: PassportData? = nil, proximityAlertTriggered: ProximityAlertTriggered? = nil, forumTopicCreated: ForumTopicCreated? = nil, forumTopicEdited: ForumTopicEdited? = nil, forumTopicClosed: ForumTopicClosed? = nil, forumTopicReopened: ForumTopicReopened? = nil, generalForumTopicHidden: GeneralForumTopicHidden? = nil, generalForumTopicUnhidden: GeneralForumTopicUnhidden? = nil, videoChatScheduled: VideoChatScheduled? = nil, videoChatStarted: VideoChatStarted? = nil, videoChatEnded: VideoChatEnded? = nil, videoChatParticipantsInvited: VideoChatParticipantsInvited? = nil, webAppData: WebAppData? = nil, replyMarkup: InlineKeyboardMarkup? = nil) {
            self.messageId = messageId
            self.messageThreadId = messageThreadId
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
            self.isTopicMessage = isTopicMessage
            self.isAutomaticForward = isAutomaticForward
            self.replyToMessage = replyToMessage
            self.viaBot = viaBot
            self.editDate = editDate
            self.hasProtectedContent = hasProtectedContent
            self.mediaGroupId = mediaGroupId
            self.authorSignature = authorSignature
            self.text = text
            self.entities = entities
            self.animation = animation
            self.audio = audio
            self.document = document
            self.photo = photo
            self.sticker = sticker
            self.story = story
            self.video = video
            self.videoNote = videoNote
            self.voice = voice
            self.caption = caption
            self.captionEntities = captionEntities
            self.hasMediaSpoiler = hasMediaSpoiler
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
            self.userShared = userShared
            self.chatShared = chatShared
            self.connectedWebsite = connectedWebsite
            self.writeAccessAllowed = writeAccessAllowed
            self.passportData = passportData
            self.proximityAlertTriggered = proximityAlertTriggered
            self.forumTopicCreated = forumTopicCreated
            self.forumTopicEdited = forumTopicEdited
            self.forumTopicClosed = forumTopicClosed
            self.forumTopicReopened = forumTopicReopened
            self.generalForumTopicHidden = generalForumTopicHidden
            self.generalForumTopicUnhidden = generalForumTopicUnhidden
            self.videoChatScheduled = videoChatScheduled
            self.videoChatStarted = videoChatStarted
            self.videoChatEnded = videoChatEnded
            self.videoChatParticipantsInvited = videoChatParticipantsInvited
            self.webAppData = webAppData
            self.replyMarkup = replyMarkup
        }

        private enum CodingKeys: String, CodingKey {
            case messageId = "message_id"
            case messageThreadId = "message_thread_id"
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
            case isTopicMessage = "is_topic_message"
            case isAutomaticForward = "is_automatic_forward"
            case replyToMessage = "reply_to_message"
            case viaBot = "via_bot"
            case editDate = "edit_date"
            case hasProtectedContent = "has_protected_content"
            case mediaGroupId = "media_group_id"
            case authorSignature = "author_signature"
            case text = "text"
            case entities = "entities"
            case animation = "animation"
            case audio = "audio"
            case document = "document"
            case photo = "photo"
            case sticker = "sticker"
            case story = "story"
            case video = "video"
            case videoNote = "video_note"
            case voice = "voice"
            case caption = "caption"
            case captionEntities = "caption_entities"
            case hasMediaSpoiler = "has_media_spoiler"
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
            case userShared = "user_shared"
            case chatShared = "chat_shared"
            case connectedWebsite = "connected_website"
            case writeAccessAllowed = "write_access_allowed"
            case passportData = "passport_data"
            case proximityAlertTriggered = "proximity_alert_triggered"
            case forumTopicCreated = "forum_topic_created"
            case forumTopicEdited = "forum_topic_edited"
            case forumTopicClosed = "forum_topic_closed"
            case forumTopicReopened = "forum_topic_reopened"
            case generalForumTopicHidden = "general_forum_topic_hidden"
            case generalForumTopicUnhidden = "general_forum_topic_unhidden"
            case videoChatScheduled = "video_chat_scheduled"
            case videoChatStarted = "video_chat_started"
            case videoChatEnded = "video_chat_ended"
            case videoChatParticipantsInvited = "video_chat_participants_invited"
            case webAppData = "web_app_data"
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

        /// Type of the entity. Currently, can be “mention” (@username), “hashtag” (#hashtag), “cashtag” ($USD), “bot_command” (/start@jobs_bot), “url” (https://telegram.org), “email” (do-not-reply@telegram.org), “phone_number” (+1-212-555-0123), “bold” (bold text), “italic” (italic text), “underline” (underlined text), “strikethrough” (strikethrough text), “spoiler” (spoiler message), “code” (monowidth string), “pre” (monowidth block), “text_link” (for clickable text URLs), “text_mention” (for users [without usernames](https://telegram.org/blog/edit#new-mentions)), “custom_emoji” (for inline custom emoji stickers)
        public var type: String

        /// Offset in UTF-16 code units to the start of the entity
        public var offset: Int

        /// Length of the entity in UTF-16 code units
        public var length: Int

        /// Optional. For “text_link” only, URL that will be opened after user taps on the text
        public var url: String?

        /// Optional. For “text_mention” only, the mentioned user
        public var user: User?

        /// Optional. For “pre” only, the programming language of the entity text
        public var language: String?

        /// Optional. For “custom_emoji” only, unique identifier of the custom emoji. Use getCustomEmojiStickers to get full information about the sticker
        public var customEmojiId: String?

        /// MessageEntity initialization
        ///
        /// - parameter type:  Type of the entity. Currently, can be “mention” (@username), “hashtag” (#hashtag), “cashtag” ($USD), “bot_command” (/start@jobs_bot), “url” (https://telegram.org), “email” (do-not-reply@telegram.org), “phone_number” (+1-212-555-0123), “bold” (bold text), “italic” (italic text), “underline” (underlined text), “strikethrough” (strikethrough text), “spoiler” (spoiler message), “code” (monowidth string), “pre” (monowidth block), “text_link” (for clickable text URLs), “text_mention” (for users [without usernames](https://telegram.org/blog/edit#new-mentions)), “custom_emoji” (for inline custom emoji stickers)
        /// - parameter offset:  Offset in UTF-16 code units to the start of the entity
        /// - parameter length:  Length of the entity in UTF-16 code units
        /// - parameter url:  Optional. For “text_link” only, URL that will be opened after user taps on the text
        /// - parameter user:  Optional. For “text_mention” only, the mentioned user
        /// - parameter language:  Optional. For “pre” only, the programming language of the entity text
        /// - parameter customEmojiId:  Optional. For “custom_emoji” only, unique identifier of the custom emoji. Use getCustomEmojiStickers to get full information about the sticker
        ///
        /// - returns: The new `MessageEntity` instance.
        ///
        public init(type: String, offset: Int, length: Int, url: String? = nil, user: User? = nil, language: String? = nil, customEmojiId: String? = nil) {
            self.type = type
            self.offset = offset
            self.length = length
            self.url = url
            self.user = user
            self.language = language
            self.customEmojiId = customEmojiId
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case offset = "offset"
            case length = "length"
            case url = "url"
            case user = "user"
            case language = "language"
            case customEmojiId = "custom_emoji_id"
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

        /// Optional. File size in bytes
        public var fileSize: Int?

        /// PhotoSize initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Photo width
        /// - parameter height:  Photo height
        /// - parameter fileSize:  Optional. File size in bytes
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
        public var thumbnail: PhotoSize?

        /// Optional. Original animation filename as defined by sender
        public var fileName: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        public var fileSize: Int?

        /// Animation initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Video width as defined by sender
        /// - parameter height:  Video height as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumbnail:  Optional. Animation thumbnail as defined by sender
        /// - parameter fileName:  Optional. Original animation filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        ///
        /// - returns: The new `Animation` instance.
        ///
        public init(fileId: String, fileUniqueId: String, width: Int, height: Int, duration: Int, thumbnail: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.width = width
            self.height = height
            self.duration = duration
            self.thumbnail = thumbnail
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
            case thumbnail = "thumbnail"
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

        /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        public var fileSize: Int?

        /// Optional. Thumbnail of the album cover to which the music file belongs
        public var thumbnail: PhotoSize?

        /// Audio initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter duration:  Duration of the audio in seconds as defined by sender
        /// - parameter performer:  Optional. Performer of the audio as defined by sender or by audio tags
        /// - parameter title:  Optional. Title of the audio as defined by sender or by audio tags
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        /// - parameter thumbnail:  Optional. Thumbnail of the album cover to which the music file belongs
        ///
        /// - returns: The new `Audio` instance.
        ///
        public init(fileId: String, fileUniqueId: String, duration: Int, performer: String? = nil, title: String? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil, thumbnail: PhotoSize? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.duration = duration
            self.performer = performer
            self.title = title
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
            self.thumbnail = thumbnail
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
            case thumbnail = "thumbnail"
        }

    }

    /// This object represents a general file (as opposed to photos, voice messages and audio files).
    public class Document: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Optional. Document thumbnail as defined by sender
        public var thumbnail: PhotoSize?

        /// Optional. Original filename as defined by sender
        public var fileName: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        public var fileSize: Int?

        /// Document initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter thumbnail:  Optional. Document thumbnail as defined by sender
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        ///
        /// - returns: The new `Document` instance.
        ///
        public init(fileId: String, fileUniqueId: String, thumbnail: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.thumbnail = thumbnail
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case thumbnail = "thumbnail"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a message about a forwarded story in the chat. Currently holds no information.
    public struct Story: Codable {

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
        public var thumbnail: PhotoSize?

        /// Optional. Original filename as defined by sender
        public var fileName: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        public var fileSize: Int?

        /// Video initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter width:  Video width as defined by sender
        /// - parameter height:  Video height as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumbnail:  Optional. Video thumbnail
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        ///
        /// - returns: The new `Video` instance.
        ///
        public init(fileId: String, fileUniqueId: String, width: Int, height: Int, duration: Int, thumbnail: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.width = width
            self.height = height
            self.duration = duration
            self.thumbnail = thumbnail
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
            case thumbnail = "thumbnail"
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
        public var thumbnail: PhotoSize?

        /// Optional. File size in bytes
        public var fileSize: Int?

        /// VideoNote initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter length:  Video width and height (diameter of the video message) as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumbnail:  Optional. Video thumbnail
        /// - parameter fileSize:  Optional. File size in bytes
        ///
        /// - returns: The new `VideoNote` instance.
        ///
        public init(fileId: String, fileUniqueId: String, length: Int, duration: Int, thumbnail: PhotoSize? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.length = length
            self.duration = duration
            self.thumbnail = thumbnail
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case length = "length"
            case duration = "duration"
            case thumbnail = "thumbnail"
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

        /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        public var fileSize: Int?

        /// Voice initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter duration:  Duration of the audio in seconds as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
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

        /// Optional. The chat that changed the answer to the poll, if the voter is anonymous
        public var voterChat: Chat?

        /// Optional. The user that changed the answer to the poll, if the voter isn’t anonymous
        public var user: User?

        /// 0-based identifiers of chosen answer options. May be empty if the vote was retracted.
        public var optionIds: [Int]

        /// PollAnswer initialization
        ///
        /// - parameter pollId:  Unique poll identifier
        /// - parameter voterChat:  Optional. The chat that changed the answer to the poll, if the voter is anonymous
        /// - parameter user:  Optional. The user that changed the answer to the poll, if the voter isn’t anonymous
        /// - parameter optionIds:  0-based identifiers of chosen answer options. May be empty if the vote was retracted.
        ///
        /// - returns: The new `PollAnswer` instance.
        ///
        public init(pollId: String, voterChat: Chat? = nil, user: User? = nil, optionIds: [Int]) {
            self.pollId = pollId
            self.voterChat = voterChat
            self.user = user
            self.optionIds = optionIds
        }

        private enum CodingKeys: String, CodingKey {
            case pollId = "poll_id"
            case voterChat = "voter_chat"
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

        /// Optional. Time relative to the message sending date, during which the location can be updated; in seconds. For active live locations only.
        public var livePeriod: Int?

        /// Optional. The direction in which user is moving, in degrees; 1-360. For active live locations only.
        public var heading: Int?

        /// Optional. The maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.
        public var proximityAlertRadius: Int?

        /// Location initialization
        ///
        /// - parameter longitude:  Longitude as defined by sender
        /// - parameter latitude:  Latitude as defined by sender
        /// - parameter horizontalAccuracy:  Optional. The radius of uncertainty for the location, measured in meters; 0-1500
        /// - parameter livePeriod:  Optional. Time relative to the message sending date, during which the location can be updated; in seconds. For active live locations only.
        /// - parameter heading:  Optional. The direction in which user is moving, in degrees; 1-360. For active live locations only.
        /// - parameter proximityAlertRadius:  Optional. The maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.
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

    /// Describes data sent from a Web App to the bot.
    public class WebAppData: Codable {

        /// The data. Be aware that a bad client can send arbitrary data in this field.
        public var data: String

        /// Text of the web_app keyboard button from which the Web App was opened. Be aware that a bad client can send arbitrary data in this field.
        public var buttonText: String

        /// WebAppData initialization
        ///
        /// - parameter data:  The data. Be aware that a bad client can send arbitrary data in this field.
        /// - parameter buttonText:  Text of the web_app keyboard button from which the Web App was opened. Be aware that a bad client can send arbitrary data in this field.
        ///
        /// - returns: The new `WebAppData` instance.
        ///
        public init(data: String, buttonText: String) {
            self.data = data
            self.buttonText = buttonText
        }

        private enum CodingKeys: String, CodingKey {
            case data = "data"
            case buttonText = "button_text"
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

        /// New auto-delete time for messages in the chat; in seconds
        public var messageAutoDeleteTime: Int

        /// MessageAutoDeleteTimerChanged initialization
        ///
        /// - parameter messageAutoDeleteTime:  New auto-delete time for messages in the chat; in seconds
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

    /// This object represents a service message about a new forum topic created in the chat.
    public class ForumTopicCreated: Codable {

        /// Name of the topic
        public var name: String

        /// Color of the topic icon in RGB format
        public var iconColor: Int

        /// Optional. Unique identifier of the custom emoji shown as the topic icon
        public var iconCustomEmojiId: String?

        /// ForumTopicCreated initialization
        ///
        /// - parameter name:  Name of the topic
        /// - parameter iconColor:  Color of the topic icon in RGB format
        /// - parameter iconCustomEmojiId:  Optional. Unique identifier of the custom emoji shown as the topic icon
        ///
        /// - returns: The new `ForumTopicCreated` instance.
        ///
        public init(name: String, iconColor: Int, iconCustomEmojiId: String? = nil) {
            self.name = name
            self.iconColor = iconColor
            self.iconCustomEmojiId = iconCustomEmojiId
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case iconColor = "icon_color"
            case iconCustomEmojiId = "icon_custom_emoji_id"
        }

    }

    /// This object represents a service message about a forum topic closed in the chat. Currently holds no information.
    public struct ForumTopicClosed: Codable {

    }

    /// This object represents a service message about an edited forum topic.
    public class ForumTopicEdited: Codable {

        /// Optional. New name of the topic, if it was edited
        public var name: String?

        /// Optional. New identifier of the custom emoji shown as the topic icon, if it was edited; an empty string if the icon was removed
        public var iconCustomEmojiId: String?

        /// ForumTopicEdited initialization
        ///
        /// - parameter name:  Optional. New name of the topic, if it was edited
        /// - parameter iconCustomEmojiId:  Optional. New identifier of the custom emoji shown as the topic icon, if it was edited; an empty string if the icon was removed
        ///
        /// - returns: The new `ForumTopicEdited` instance.
        ///
        public init(name: String? = nil, iconCustomEmojiId: String? = nil) {
            self.name = name
            self.iconCustomEmojiId = iconCustomEmojiId
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case iconCustomEmojiId = "icon_custom_emoji_id"
        }

    }

    /// This object represents a service message about a forum topic reopened in the chat. Currently holds no information.
    public struct ForumTopicReopened: Codable {

    }

    /// This object represents a service message about General forum topic hidden in the chat. Currently holds no information.
    public struct GeneralForumTopicHidden: Codable {

    }

    /// This object represents a service message about General forum topic unhidden in the chat. Currently holds no information.
    public struct GeneralForumTopicUnhidden: Codable {

    }

    /// This object contains information about the user whose identifier was shared with the bot using a KeyboardButtonRequestUser button.
    public class UserShared: Codable {

        /// Identifier of the request
        public var requestId: Int

        /// Identifier of the shared user. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the user and could be unable to use this identifier, unless the user is already known to the bot by some other means.
        public var userId: Int

        /// UserShared initialization
        ///
        /// - parameter requestId:  Identifier of the request
        /// - parameter userId:  Identifier of the shared user. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the user and could be unable to use this identifier, unless the user is already known to the bot by some other means.
        ///
        /// - returns: The new `UserShared` instance.
        ///
        public init(requestId: Int, userId: Int) {
            self.requestId = requestId
            self.userId = userId
        }

        private enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
            case userId = "user_id"
        }

    }

    /// This object contains information about the chat whose identifier was shared with the bot using a KeyboardButtonRequestChat button.
    public class ChatShared: Codable {

        /// Identifier of the request
        public var requestId: Int

        /// Identifier of the shared chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the chat and could be unable to use this identifier, unless the chat is already known to the bot by some other means.
        public var chatId: Int

        /// ChatShared initialization
        ///
        /// - parameter requestId:  Identifier of the request
        /// - parameter chatId:  Identifier of the shared chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the chat and could be unable to use this identifier, unless the chat is already known to the bot by some other means.
        ///
        /// - returns: The new `ChatShared` instance.
        ///
        public init(requestId: Int, chatId: Int) {
            self.requestId = requestId
            self.chatId = chatId
        }

        private enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
            case chatId = "chat_id"
        }

    }

    /// This object represents a service message about a user allowing a bot to write messages after adding it to the attachment menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method requestWriteAccess.
    public class WriteAccessAllowed: Codable {

        /// Optional. True, if the access was granted after the user accepted an explicit request from a Web App sent by the method requestWriteAccess
        public var fromRequest: Bool?

        /// Optional. Name of the Web App, if the access was granted when the Web App was launched from a link
        public var webAppName: String?

        /// Optional. True, if the access was granted when the bot was added to the attachment or side menu
        public var fromAttachmentMenu: Bool?

        /// WriteAccessAllowed initialization
        ///
        /// - parameter fromRequest:  Optional. True, if the access was granted after the user accepted an explicit request from a Web App sent by the method requestWriteAccess
        /// - parameter webAppName:  Optional. Name of the Web App, if the access was granted when the Web App was launched from a link
        /// - parameter fromAttachmentMenu:  Optional. True, if the access was granted when the bot was added to the attachment or side menu
        ///
        /// - returns: The new `WriteAccessAllowed` instance.
        ///
        public init(fromRequest: Bool? = nil, webAppName: String? = nil, fromAttachmentMenu: Bool? = nil) {
            self.fromRequest = fromRequest
            self.webAppName = webAppName
            self.fromAttachmentMenu = fromAttachmentMenu
        }

        private enum CodingKeys: String, CodingKey {
            case fromRequest = "from_request"
            case webAppName = "web_app_name"
            case fromAttachmentMenu = "from_attachment_menu"
        }

    }

    /// This object represents a service message about a video chat scheduled in the chat.
    public class VideoChatScheduled: Codable {

        /// Point in time (Unix timestamp) when the video chat is supposed to be started by a chat administrator
        public var startDate: Int

        /// VideoChatScheduled initialization
        ///
        /// - parameter startDate:  Point in time (Unix timestamp) when the video chat is supposed to be started by a chat administrator
        ///
        /// - returns: The new `VideoChatScheduled` instance.
        ///
        public init(startDate: Int) {
            self.startDate = startDate
        }

        private enum CodingKeys: String, CodingKey {
            case startDate = "start_date"
        }

    }

    /// This object represents a service message about a video chat started in the chat. Currently holds no information.
    public struct VideoChatStarted: Codable {

    }

    /// This object represents a service message about a video chat ended in the chat.
    public class VideoChatEnded: Codable {

        /// Video chat duration in seconds
        public var duration: Int

        /// VideoChatEnded initialization
        ///
        /// - parameter duration:  Video chat duration in seconds
        ///
        /// - returns: The new `VideoChatEnded` instance.
        ///
        public init(duration: Int) {
            self.duration = duration
        }

        private enum CodingKeys: String, CodingKey {
            case duration = "duration"
        }

    }

    /// This object represents a service message about new members invited to a video chat.
    public class VideoChatParticipantsInvited: Codable {

        /// New members that were invited to the video chat
        public var users: [User]

        /// VideoChatParticipantsInvited initialization
        ///
        /// - parameter users:  New members that were invited to the video chat
        ///
        /// - returns: The new `VideoChatParticipantsInvited` instance.
        ///
        public init(users: [User]) {
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

    /// The maximum file size to download is 20 MB
    public class File: Codable {

        /// Identifier for this file, which can be used to download or reuse the file
        public var fileId: String

        /// Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        public var fileUniqueId: String

        /// Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
        public var fileSize: Int?

        /// Optional. File path. Use https://api.telegram.org/file/bot&lt;token&gt;/&lt;file_path&gt; to get the file.
        public var filePath: String?

        /// File initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter fileSize:  Optional. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
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

    /// Describes a Web App.
    public class WebAppInfo: Codable {

        /// An HTTPS URL of a Web App to be opened with additional data as specified in Initializing Web Apps
        public var url: String

        /// WebAppInfo initialization
        ///
        /// - parameter url:  An HTTPS URL of a Web App to be opened with additional data as specified in Initializing Web Apps
        ///
        /// - returns: The new `WebAppInfo` instance.
        ///
        public init(url: String) {
            self.url = url
        }

        private enum CodingKeys: String, CodingKey {
            case url = "url"
        }

    }

    /// This object represents a custom keyboard with reply options (see Introduction to bots for details and examples).
    public class ReplyKeyboardMarkup: Codable {

        /// Array of button rows, each represented by an Array of KeyboardButton objects
        public var keyboard: [KeyboardButton]

        /// Optional. Requests clients to always show the keyboard when the regular keyboard is hidden. Defaults to false, in which case the custom keyboard can be hidden and opened with a keyboard icon.
        public var isPersistent: Bool?

        /// Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app’s standard keyboard.
        public var resizeKeyboard: Bool?

        /// Optional. Requests clients to hide the keyboard as soon as it’s been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat - the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
        public var oneTimeKeyboard: Bool?

        /// Optional. The placeholder to be shown in the input field when the keyboard is active; 1-64 characters
        public var inputFieldPlaceholder: String?

        /// Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.Example: A user requests to change the bot’s language, bot replies to the request with a keyboard to select the new language. Other users in the group don’t see the keyboard.
        public var selective: Bool?

        /// ReplyKeyboardMarkup initialization
        ///
        /// - parameter keyboard:  Array of button rows, each represented by an Array of KeyboardButton objects
        /// - parameter isPersistent:  Optional. Requests clients to always show the keyboard when the regular keyboard is hidden. Defaults to false, in which case the custom keyboard can be hidden and opened with a keyboard icon.
        /// - parameter resizeKeyboard:  Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app’s standard keyboard.
        /// - parameter oneTimeKeyboard:  Optional. Requests clients to hide the keyboard as soon as it’s been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat - the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
        /// - parameter inputFieldPlaceholder:  Optional. The placeholder to be shown in the input field when the keyboard is active; 1-64 characters
        /// - parameter selective:  Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.Example: A user requests to change the bot’s language, bot replies to the request with a keyboard to select the new language. Other users in the group don’t see the keyboard.
        ///
        /// - returns: The new `ReplyKeyboardMarkup` instance.
        ///
        public init(keyboard: [KeyboardButton], isPersistent: Bool? = nil, resizeKeyboard: Bool? = nil, oneTimeKeyboard: Bool? = nil, inputFieldPlaceholder: String? = nil, selective: Bool? = nil) {
            self.keyboard = keyboard
            self.isPersistent = isPersistent
            self.resizeKeyboard = resizeKeyboard
            self.oneTimeKeyboard = oneTimeKeyboard
            self.inputFieldPlaceholder = inputFieldPlaceholder
            self.selective = selective
        }

        private enum CodingKeys: String, CodingKey {
            case keyboard = "keyboard"
            case isPersistent = "is_persistent"
            case resizeKeyboard = "resize_keyboard"
            case oneTimeKeyboard = "one_time_keyboard"
            case inputFieldPlaceholder = "input_field_placeholder"
            case selective = "selective"
        }

    }

    /// This object represents one button of the reply keyboard. For simple text buttons, String can be used instead of this object to specify the button text. The optional fields web_app, request_user, request_chat, request_contact, request_location, and request_poll are mutually exclusive.
    public class KeyboardButton: Codable {

        /// Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed
        public var text: String

        /// Optional. If specified, pressing the button will open a list of suitable users. Tapping on any user will send their identifier to the bot in a “user_shared” service message. Available in private chats only.
        public var requestUser: KeyboardButtonRequestUser?

        /// Optional. If specified, pressing the button will open a list of suitable chats. Tapping on a chat will send its identifier to the bot in a “chat_shared” service message. Available in private chats only.
        public var requestChat: KeyboardButtonRequestChat?

        /// Optional. If True, the user’s phone number will be sent as a contact when the button is pressed. Available in private chats only.
        public var requestContact: Bool?

        /// Optional. If True, the user’s current location will be sent when the button is pressed. Available in private chats only.
        public var requestLocation: Bool?

        /// Optional. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed. Available in private chats only.
        public var requestPoll: KeyboardButtonPollType?

        /// Optional. If specified, the described Web App will be launched when the button is pressed. The Web App will be able to send a “web_app_data” service message. Available in private chats only.
        public var webApp: WebAppInfo?

        /// KeyboardButton initialization
        ///
        /// - parameter text:  Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed
        /// - parameter requestUser:  Optional. If specified, pressing the button will open a list of suitable users. Tapping on any user will send their identifier to the bot in a “user_shared” service message. Available in private chats only.
        /// - parameter requestChat:  Optional. If specified, pressing the button will open a list of suitable chats. Tapping on a chat will send its identifier to the bot in a “chat_shared” service message. Available in private chats only.
        /// - parameter requestContact:  Optional. If True, the user’s phone number will be sent as a contact when the button is pressed. Available in private chats only.
        /// - parameter requestLocation:  Optional. If True, the user’s current location will be sent when the button is pressed. Available in private chats only.
        /// - parameter requestPoll:  Optional. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed. Available in private chats only.
        /// - parameter webApp:  Optional. If specified, the described Web App will be launched when the button is pressed. The Web App will be able to send a “web_app_data” service message. Available in private chats only.
        ///
        /// - returns: The new `KeyboardButton` instance.
        ///
        public init(text: String, requestUser: KeyboardButtonRequestUser? = nil, requestChat: KeyboardButtonRequestChat? = nil, requestContact: Bool? = nil, requestLocation: Bool? = nil, requestPoll: KeyboardButtonPollType? = nil, webApp: WebAppInfo? = nil) {
            self.text = text
            self.requestUser = requestUser
            self.requestChat = requestChat
            self.requestContact = requestContact
            self.requestLocation = requestLocation
            self.requestPoll = requestPoll
            self.webApp = webApp
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case requestUser = "request_user"
            case requestChat = "request_chat"
            case requestContact = "request_contact"
            case requestLocation = "request_location"
            case requestPoll = "request_poll"
            case webApp = "web_app"
        }

    }

    /// This object defines the criteria used to request a suitable user. The identifier of the selected user will be shared with the bot when the corresponding button is pressed. More about requesting users »
    public class KeyboardButtonRequestUser: Codable {

        /// Signed 32-bit identifier of the request, which will be received back in the UserShared object. Must be unique within the message
        public var requestId: Int

        /// Optional. Pass True to request a bot, pass False to request a regular user. If not specified, no additional restrictions are applied.
        public var userIsBot: Bool?

        /// Optional. Pass True to request a premium user, pass False to request a non-premium user. If not specified, no additional restrictions are applied.
        public var userIsPremium: Bool?

        /// KeyboardButtonRequestUser initialization
        ///
        /// - parameter requestId:  Signed 32-bit identifier of the request, which will be received back in the UserShared object. Must be unique within the message
        /// - parameter userIsBot:  Optional. Pass True to request a bot, pass False to request a regular user. If not specified, no additional restrictions are applied.
        /// - parameter userIsPremium:  Optional. Pass True to request a premium user, pass False to request a non-premium user. If not specified, no additional restrictions are applied.
        ///
        /// - returns: The new `KeyboardButtonRequestUser` instance.
        ///
        public init(requestId: Int, userIsBot: Bool? = nil, userIsPremium: Bool? = nil) {
            self.requestId = requestId
            self.userIsBot = userIsBot
            self.userIsPremium = userIsPremium
        }

        private enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
            case userIsBot = "user_is_bot"
            case userIsPremium = "user_is_premium"
        }

    }

    /// This object defines the criteria used to request a suitable chat. The identifier of the selected chat will be shared with the bot when the corresponding button is pressed. More about requesting chats »
    public class KeyboardButtonRequestChat: Codable {

        /// Signed 32-bit identifier of the request, which will be received back in the ChatShared object. Must be unique within the message
        public var requestId: Int

        /// Pass True to request a channel chat, pass False to request a group or a supergroup chat.
        public var chatIsChannel: Bool

        /// Optional. Pass True to request a forum supergroup, pass False to request a non-forum chat. If not specified, no additional restrictions are applied.
        public var chatIsForum: Bool?

        /// Optional. Pass True to request a supergroup or a channel with a username, pass False to request a chat without a username. If not specified, no additional restrictions are applied.
        public var chatHasUsername: Bool?

        /// Optional. Pass True to request a chat owned by the user. Otherwise, no additional restrictions are applied.
        public var chatIsCreated: Bool?

        /// Optional. A JSON-serialized object listing the required administrator rights of the user in the chat. The rights must be a superset of bot_administrator_rights. If not specified, no additional restrictions are applied.
        public var userAdministratorRights: ChatAdministratorRights?

        /// Optional. A JSON-serialized object listing the required administrator rights of the bot in the chat. The rights must be a subset of user_administrator_rights. If not specified, no additional restrictions are applied.
        public var botAdministratorRights: ChatAdministratorRights?

        /// Optional. Pass True to request a chat with the bot as a member. Otherwise, no additional restrictions are applied.
        public var botIsMember: Bool?

        /// KeyboardButtonRequestChat initialization
        ///
        /// - parameter requestId:  Signed 32-bit identifier of the request, which will be received back in the ChatShared object. Must be unique within the message
        /// - parameter chatIsChannel:  Pass True to request a channel chat, pass False to request a group or a supergroup chat.
        /// - parameter chatIsForum:  Optional. Pass True to request a forum supergroup, pass False to request a non-forum chat. If not specified, no additional restrictions are applied.
        /// - parameter chatHasUsername:  Optional. Pass True to request a supergroup or a channel with a username, pass False to request a chat without a username. If not specified, no additional restrictions are applied.
        /// - parameter chatIsCreated:  Optional. Pass True to request a chat owned by the user. Otherwise, no additional restrictions are applied.
        /// - parameter userAdministratorRights:  Optional. A JSON-serialized object listing the required administrator rights of the user in the chat. The rights must be a superset of bot_administrator_rights. If not specified, no additional restrictions are applied.
        /// - parameter botAdministratorRights:  Optional. A JSON-serialized object listing the required administrator rights of the bot in the chat. The rights must be a subset of user_administrator_rights. If not specified, no additional restrictions are applied.
        /// - parameter botIsMember:  Optional. Pass True to request a chat with the bot as a member. Otherwise, no additional restrictions are applied.
        ///
        /// - returns: The new `KeyboardButtonRequestChat` instance.
        ///
        public init(requestId: Int, chatIsChannel: Bool, chatIsForum: Bool? = nil, chatHasUsername: Bool? = nil, chatIsCreated: Bool? = nil, userAdministratorRights: ChatAdministratorRights? = nil, botAdministratorRights: ChatAdministratorRights? = nil, botIsMember: Bool? = nil) {
            self.requestId = requestId
            self.chatIsChannel = chatIsChannel
            self.chatIsForum = chatIsForum
            self.chatHasUsername = chatHasUsername
            self.chatIsCreated = chatIsCreated
            self.userAdministratorRights = userAdministratorRights
            self.botAdministratorRights = botAdministratorRights
            self.botIsMember = botIsMember
        }

        private enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
            case chatIsChannel = "chat_is_channel"
            case chatIsForum = "chat_is_forum"
            case chatHasUsername = "chat_has_username"
            case chatIsCreated = "chat_is_created"
            case userAdministratorRights = "user_administrator_rights"
            case botAdministratorRights = "bot_administrator_rights"
            case botIsMember = "bot_is_member"
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

    /// This object represents an inline keyboard that appears right next to the message it belongs to.
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

        /// Optional. HTTP or tg:// URL to be opened when the button is pressed. Links tg://user?id=&lt;user_id&gt; can be used to mention a user by their ID without using a username, if this is allowed by their privacy settings.
        public var url: String?

        /// Optional. Data to be sent in a callback query to the bot when button is pressed, 1-64 bytes
        public var callbackData: String?

        /// Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery. Available only in private chats between a user and the bot.
        public var webApp: WebAppInfo?

        /// Optional. An HTTPS URL used to automatically authorize the user. Can be used as a replacement for the Telegram Login Widget.
        public var loginUrl: LoginUrl?

        /// Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot’s username and the specified inline query in the input field. May be empty, in which case just the bot’s username will be inserted.
        public var switchInlineQuery: String?

        /// Optional. If set, pressing the button will insert the bot’s username and the specified inline query in the current chat’s input field. May be empty, in which case only the bot’s username will be inserted.This offers a quick way for the user to open your bot in inline mode in the same chat - good for selecting something from multiple options.
        public var switchInlineQueryCurrentChat: String?

        /// Optional. If set, pressing the button will prompt the user to select one of their chats of the specified type, open that chat and insert the bot’s username and the specified inline query in the input field
        public var switchInlineQueryChosenChat: SwitchInlineQueryChosenChat?

        /// Optional. Description of the game that will be launched when the user presses the button.NOTE: This type of button must always be the first button in the first row.
        public var callbackGame: CallbackGame?

        /// Optional. Specify True, to send a Pay button.NOTE: This type of button must always be the first button in the first row and can only be used in invoice messages.
        public var pay: Bool?

        /// InlineKeyboardButton initialization
        ///
        /// - parameter text:  Label text on the button
        /// - parameter url:  Optional. HTTP or tg:// URL to be opened when the button is pressed. Links tg://user?id=&lt;user_id&gt; can be used to mention a user by their ID without using a username, if this is allowed by their privacy settings.
        /// - parameter callbackData:  Optional. Data to be sent in a callback query to the bot when button is pressed, 1-64 bytes
        /// - parameter webApp:  Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery. Available only in private chats between a user and the bot.
        /// - parameter loginUrl:  Optional. An HTTPS URL used to automatically authorize the user. Can be used as a replacement for the Telegram Login Widget.
        /// - parameter switchInlineQuery:  Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot’s username and the specified inline query in the input field. May be empty, in which case just the bot’s username will be inserted.
        /// - parameter switchInlineQueryCurrentChat:  Optional. If set, pressing the button will insert the bot’s username and the specified inline query in the current chat’s input field. May be empty, in which case only the bot’s username will be inserted.This offers a quick way for the user to open your bot in inline mode in the same chat - good for selecting something from multiple options.
        /// - parameter switchInlineQueryChosenChat:  Optional. If set, pressing the button will prompt the user to select one of their chats of the specified type, open that chat and insert the bot’s username and the specified inline query in the input field
        /// - parameter callbackGame:  Optional. Description of the game that will be launched when the user presses the button.NOTE: This type of button must always be the first button in the first row.
        /// - parameter pay:  Optional. Specify True, to send a Pay button.NOTE: This type of button must always be the first button in the first row and can only be used in invoice messages.
        ///
        /// - returns: The new `InlineKeyboardButton` instance.
        ///
        public init(text: String, url: String? = nil, callbackData: String? = nil, webApp: WebAppInfo? = nil, loginUrl: LoginUrl? = nil, switchInlineQuery: String? = nil, switchInlineQueryCurrentChat: String? = nil, switchInlineQueryChosenChat: SwitchInlineQueryChosenChat? = nil, callbackGame: CallbackGame? = nil, pay: Bool? = nil) {
            self.text = text
            self.url = url
            self.callbackData = callbackData
            self.webApp = webApp
            self.loginUrl = loginUrl
            self.switchInlineQuery = switchInlineQuery
            self.switchInlineQueryCurrentChat = switchInlineQueryCurrentChat
            self.switchInlineQueryChosenChat = switchInlineQueryChosenChat
            self.callbackGame = callbackGame
            self.pay = pay
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case url = "url"
            case callbackData = "callback_data"
            case webApp = "web_app"
            case loginUrl = "login_url"
            case switchInlineQuery = "switch_inline_query"
            case switchInlineQueryCurrentChat = "switch_inline_query_current_chat"
            case switchInlineQueryChosenChat = "switch_inline_query_chosen_chat"
            case callbackGame = "callback_game"
            case pay = "pay"
        }

    }

    /// Sample bot: [@discussbot](https://t.me/discussbot)
    public class LoginUrl: Codable {

        /// An HTTPS URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in Receiving authorization data.NOTE: You must always check the hash of the received data to verify the authentication and the integrity of the data as described in Checking authorization.
        public var url: String

        /// Optional. New text of the button in forwarded messages.
        public var forwardText: String?

        /// Optional. Username of a bot, which will be used for user authorization. See Setting up a bot for more details. If not specified, the current bot’s username will be assumed. The url’s domain must be the same as the domain linked with the bot. See Linking your domain to the bot for more details.
        public var botUsername: String?

        /// Optional. Pass True to request the permission for your bot to send messages to the user.
        public var requestWriteAccess: Bool?

        /// LoginUrl initialization
        ///
        /// - parameter url:  An HTTPS URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in Receiving authorization data.NOTE: You must always check the hash of the received data to verify the authentication and the integrity of the data as described in Checking authorization.
        /// - parameter forwardText:  Optional. New text of the button in forwarded messages.
        /// - parameter botUsername:  Optional. Username of a bot, which will be used for user authorization. See Setting up a bot for more details. If not specified, the current bot’s username will be assumed. The url’s domain must be the same as the domain linked with the bot. See Linking your domain to the bot for more details.
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

    /// This object represents an inline button that switches the current user to inline mode in a chosen chat, with an optional default inline query.
    public class SwitchInlineQueryChosenChat: Codable {

        /// Optional. The default inline query to be inserted in the input field. If left empty, only the bot’s username will be inserted
        public var query: String?

        /// Optional. True, if private chats with users can be chosen
        public var allowUserChats: Bool?

        /// Optional. True, if private chats with bots can be chosen
        public var allowBotChats: Bool?

        /// Optional. True, if group and supergroup chats can be chosen
        public var allowGroupChats: Bool?

        /// Optional. True, if channel chats can be chosen
        public var allowChannelChats: Bool?

        /// SwitchInlineQueryChosenChat initialization
        ///
        /// - parameter query:  Optional. The default inline query to be inserted in the input field. If left empty, only the bot’s username will be inserted
        /// - parameter allowUserChats:  Optional. True, if private chats with users can be chosen
        /// - parameter allowBotChats:  Optional. True, if private chats with bots can be chosen
        /// - parameter allowGroupChats:  Optional. True, if group and supergroup chats can be chosen
        /// - parameter allowChannelChats:  Optional. True, if channel chats can be chosen
        ///
        /// - returns: The new `SwitchInlineQueryChosenChat` instance.
        ///
        public init(query: String? = nil, allowUserChats: Bool? = nil, allowBotChats: Bool? = nil, allowGroupChats: Bool? = nil, allowChannelChats: Bool? = nil) {
            self.query = query
            self.allowUserChats = allowUserChats
            self.allowBotChats = allowBotChats
            self.allowGroupChats = allowGroupChats
            self.allowChannelChats = allowChannelChats
        }

        private enum CodingKeys: String, CodingKey {
            case query = "query"
            case allowUserChats = "allow_user_chats"
            case allowBotChats = "allow_bot_chats"
            case allowGroupChats = "allow_group_chats"
            case allowChannelChats = "allow_channel_chats"
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

        /// Optional. Data associated with the callback button. Be aware that the message originated the query can contain no callback buttons with this data.
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
        /// - parameter data:  Optional. Data associated with the callback button. Be aware that the message originated the query can contain no callback buttons with this data.
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

        /// Optional. The placeholder to be shown in the input field when the reply is active; 1-64 characters
        public var inputFieldPlaceholder: String?

        /// Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.
        public var selective: Bool?

        /// ForceReply initialization
        ///
        /// - parameter forceReply:  Shows reply interface to the user, as if they manually selected the bot’s message and tapped ’Reply’
        /// - parameter inputFieldPlaceholder:  Optional. The placeholder to be shown in the input field when the reply is active; 1-64 characters
        /// - parameter selective:  Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot’s message is a reply (has reply_to_message_id), sender of the original message.
        ///
        /// - returns: The new `ForceReply` instance.
        ///
        public init(forceReply: Bool, inputFieldPlaceholder: String? = nil, selective: Bool? = nil) {
            self.forceReply = forceReply
            self.inputFieldPlaceholder = inputFieldPlaceholder
            self.selective = selective
        }

        private enum CodingKeys: String, CodingKey {
            case forceReply = "force_reply"
            case inputFieldPlaceholder = "input_field_placeholder"
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

        /// True, if users joining the chat via the link need to be approved by chat administrators
        public var createsJoinRequest: Bool

        /// True, if the link is primary
        public var isPrimary: Bool

        /// True, if the link is revoked
        public var isRevoked: Bool

        /// Optional. Invite link name
        public var name: String?

        /// Optional. Point in time (Unix timestamp) when the link will expire or has been expired
        public var expireDate: Int?

        /// Optional. The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
        public var memberLimit: Int?

        /// Optional. Number of pending join requests created using this link
        public var pendingJoinRequestCount: Int?

        /// ChatInviteLink initialization
        ///
        /// - parameter inviteLink:  The invite link. If the link was created by another chat administrator, then the second part of the link will be replaced with “…”.
        /// - parameter creator:  Creator of the link
        /// - parameter createsJoinRequest:  True, if users joining the chat via the link need to be approved by chat administrators
        /// - parameter isPrimary:  True, if the link is primary
        /// - parameter isRevoked:  True, if the link is revoked
        /// - parameter name:  Optional. Invite link name
        /// - parameter expireDate:  Optional. Point in time (Unix timestamp) when the link will expire or has been expired
        /// - parameter memberLimit:  Optional. The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
        /// - parameter pendingJoinRequestCount:  Optional. Number of pending join requests created using this link
        ///
        /// - returns: The new `ChatInviteLink` instance.
        ///
        public init(inviteLink: String, creator: User, createsJoinRequest: Bool, isPrimary: Bool, isRevoked: Bool, name: String? = nil, expireDate: Int? = nil, memberLimit: Int? = nil, pendingJoinRequestCount: Int? = nil) {
            self.inviteLink = inviteLink
            self.creator = creator
            self.createsJoinRequest = createsJoinRequest
            self.isPrimary = isPrimary
            self.isRevoked = isRevoked
            self.name = name
            self.expireDate = expireDate
            self.memberLimit = memberLimit
            self.pendingJoinRequestCount = pendingJoinRequestCount
        }

        private enum CodingKeys: String, CodingKey {
            case inviteLink = "invite_link"
            case creator = "creator"
            case createsJoinRequest = "creates_join_request"
            case isPrimary = "is_primary"
            case isRevoked = "is_revoked"
            case name = "name"
            case expireDate = "expire_date"
            case memberLimit = "member_limit"
            case pendingJoinRequestCount = "pending_join_request_count"
        }

    }

    /// Represents the rights of an administrator in a chat.
    public class ChatAdministratorRights: Codable {

        /// True, if the user’s presence in the chat is hidden
        public var isAnonymous: Bool

        /// True, if the administrator can access the chat event log, boost list in channels, see channel members, report spam messages, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
        public var canManageChat: Bool

        /// True, if the administrator can delete messages of other users
        public var canDeleteMessages: Bool

        /// True, if the administrator can manage video chats
        public var canManageVideoChats: Bool

        /// True, if the administrator can restrict, ban or unban chat members, or access supergroup statistics
        public var canRestrictMembers: Bool

        /// True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        public var canPromoteMembers: Bool

        /// True, if the user is allowed to change the chat title, photo and other settings
        public var canChangeInfo: Bool

        /// True, if the user is allowed to invite new users to the chat
        public var canInviteUsers: Bool

        /// Optional. True, if the administrator can post messages in the channel, or access channel statistics; channels only
        public var canPostMessages: Bool?

        /// Optional. True, if the administrator can edit messages of other users and can pin messages; channels only
        public var canEditMessages: Bool?

        /// Optional. True, if the user is allowed to pin messages; groups and supergroups only
        public var canPinMessages: Bool?

        /// Optional. True, if the administrator can post stories in the channel; channels only
        public var canPostStories: Bool?

        /// Optional. True, if the administrator can edit stories posted by other users; channels only
        public var canEditStories: Bool?

        /// Optional. True, if the administrator can delete stories posted by other users; channels only
        public var canDeleteStories: Bool?

        /// Optional. True, if the user is allowed to create, rename, close, and reopen forum topics; supergroups only
        public var canManageTopics: Bool?

        /// ChatAdministratorRights initialization
        ///
        /// - parameter isAnonymous:  True, if the user’s presence in the chat is hidden
        /// - parameter canManageChat:  True, if the administrator can access the chat event log, boost list in channels, see channel members, report spam messages, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
        /// - parameter canDeleteMessages:  True, if the administrator can delete messages of other users
        /// - parameter canManageVideoChats:  True, if the administrator can manage video chats
        /// - parameter canRestrictMembers:  True, if the administrator can restrict, ban or unban chat members, or access supergroup statistics
        /// - parameter canPromoteMembers:  True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        /// - parameter canChangeInfo:  True, if the user is allowed to change the chat title, photo and other settings
        /// - parameter canInviteUsers:  True, if the user is allowed to invite new users to the chat
        /// - parameter canPostMessages:  Optional. True, if the administrator can post messages in the channel, or access channel statistics; channels only
        /// - parameter canEditMessages:  Optional. True, if the administrator can edit messages of other users and can pin messages; channels only
        /// - parameter canPinMessages:  Optional. True, if the user is allowed to pin messages; groups and supergroups only
        /// - parameter canPostStories:  Optional. True, if the administrator can post stories in the channel; channels only
        /// - parameter canEditStories:  Optional. True, if the administrator can edit stories posted by other users; channels only
        /// - parameter canDeleteStories:  Optional. True, if the administrator can delete stories posted by other users; channels only
        /// - parameter canManageTopics:  Optional. True, if the user is allowed to create, rename, close, and reopen forum topics; supergroups only
        ///
        /// - returns: The new `ChatAdministratorRights` instance.
        ///
        public init(isAnonymous: Bool, canManageChat: Bool, canDeleteMessages: Bool, canManageVideoChats: Bool, canRestrictMembers: Bool, canPromoteMembers: Bool, canChangeInfo: Bool, canInviteUsers: Bool, canPostMessages: Bool? = nil, canEditMessages: Bool? = nil, canPinMessages: Bool? = nil, canPostStories: Bool? = nil, canEditStories: Bool? = nil, canDeleteStories: Bool? = nil, canManageTopics: Bool? = nil) {
            self.isAnonymous = isAnonymous
            self.canManageChat = canManageChat
            self.canDeleteMessages = canDeleteMessages
            self.canManageVideoChats = canManageVideoChats
            self.canRestrictMembers = canRestrictMembers
            self.canPromoteMembers = canPromoteMembers
            self.canChangeInfo = canChangeInfo
            self.canInviteUsers = canInviteUsers
            self.canPostMessages = canPostMessages
            self.canEditMessages = canEditMessages
            self.canPinMessages = canPinMessages
            self.canPostStories = canPostStories
            self.canEditStories = canEditStories
            self.canDeleteStories = canDeleteStories
            self.canManageTopics = canManageTopics
        }

        private enum CodingKeys: String, CodingKey {
            case isAnonymous = "is_anonymous"
            case canManageChat = "can_manage_chat"
            case canDeleteMessages = "can_delete_messages"
            case canManageVideoChats = "can_manage_video_chats"
            case canRestrictMembers = "can_restrict_members"
            case canPromoteMembers = "can_promote_members"
            case canChangeInfo = "can_change_info"
            case canInviteUsers = "can_invite_users"
            case canPostMessages = "can_post_messages"
            case canEditMessages = "can_edit_messages"
            case canPinMessages = "can_pin_messages"
            case canPostStories = "can_post_stories"
            case canEditStories = "can_edit_stories"
            case canDeleteStories = "can_delete_stories"
            case canManageTopics = "can_manage_topics"
        }

    }

    /// This object contains information about one member of a chat. Currently, the following 6 types of chat members are supported:
    public enum ChatMember: Codable {

        case owner(ChatMemberOwner)
        case administrator(ChatMemberAdministrator)
        case member(ChatMemberMember)
        case restricted(ChatMemberRestricted)
        case left(ChatMemberLeft)
        case banned(ChatMemberBanned)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let owner = try? container.decode(ChatMemberOwner.self) {
                self = .owner(owner)
            } else if let administrator = try? container.decode(ChatMemberAdministrator.self) {
                self = .administrator(administrator)
            } else if let member = try? container.decode(ChatMemberMember.self) {
                self = .member(member)
            } else if let restricted = try? container.decode(ChatMemberRestricted.self) {
                self = .restricted(restricted)
            } else if let left = try? container.decode(ChatMemberLeft.self) {
                self = .left(left)
            } else if let banned = try? container.decode(ChatMemberBanned.self) {
                self = .banned(banned)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "ChatMember"])
            }
        }

        public init(_ owner: ChatMemberOwner) {
            self = .owner(owner)
        }

        public init(_ administrator: ChatMemberAdministrator) {
            self = .administrator(administrator)
        }

        public init(_ member: ChatMemberMember) {
            self = .member(member)
        }

        public init(_ restricted: ChatMemberRestricted) {
            self = .restricted(restricted)
        }

        public init(_ left: ChatMemberLeft) {
            self = .left(left)
        }

        public init(_ banned: ChatMemberBanned) {
            self = .banned(banned)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .owner(let owner):
                try container.encode(owner)
            case .administrator(let administrator):
                try container.encode(administrator)
            case .member(let member):
                try container.encode(member)
            case .restricted(let restricted):
                try container.encode(restricted)
            case .left(let left):
                try container.encode(left)
            case .banned(let banned):
                try container.encode(banned)
            }
        }
    }
    /// Represents a chat member that owns the chat and has all administrator privileges.
    public class ChatMemberOwner: Codable {

        /// The member’s status in the chat, always “creator”
        public var status: String

        /// Information about the user
        public var user: User

        /// True, if the user’s presence in the chat is hidden
        public var isAnonymous: Bool

        /// Optional. Custom title for this user
        public var customTitle: String?

        /// ChatMemberOwner initialization
        ///
        /// - parameter status:  The member’s status in the chat, always “creator”
        /// - parameter user:  Information about the user
        /// - parameter isAnonymous:  True, if the user’s presence in the chat is hidden
        /// - parameter customTitle:  Optional. Custom title for this user
        ///
        /// - returns: The new `ChatMemberOwner` instance.
        ///
        public init(status: String, user: User, isAnonymous: Bool, customTitle: String? = nil) {
            self.status = status
            self.user = user
            self.isAnonymous = isAnonymous
            self.customTitle = customTitle
        }

        private enum CodingKeys: String, CodingKey {
            case status = "status"
            case user = "user"
            case isAnonymous = "is_anonymous"
            case customTitle = "custom_title"
        }

    }

    /// Represents a chat member that has some additional privileges.
    public class ChatMemberAdministrator: Codable {

        /// The member’s status in the chat, always “administrator”
        public var status: String

        /// Information about the user
        public var user: User

        /// True, if the bot is allowed to edit administrator privileges of that user
        public var canBeEdited: Bool

        /// True, if the user’s presence in the chat is hidden
        public var isAnonymous: Bool

        /// True, if the administrator can access the chat event log, boost list in channels, see channel members, report spam messages, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
        public var canManageChat: Bool

        /// True, if the administrator can delete messages of other users
        public var canDeleteMessages: Bool

        /// True, if the administrator can manage video chats
        public var canManageVideoChats: Bool

        /// True, if the administrator can restrict, ban or unban chat members, or access supergroup statistics
        public var canRestrictMembers: Bool

        /// True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        public var canPromoteMembers: Bool

        /// True, if the user is allowed to change the chat title, photo and other settings
        public var canChangeInfo: Bool

        /// True, if the user is allowed to invite new users to the chat
        public var canInviteUsers: Bool

        /// Optional. True, if the administrator can post messages in the channel, or access channel statistics; channels only
        public var canPostMessages: Bool?

        /// Optional. True, if the administrator can edit messages of other users and can pin messages; channels only
        public var canEditMessages: Bool?

        /// Optional. True, if the user is allowed to pin messages; groups and supergroups only
        public var canPinMessages: Bool?

        /// Optional. True, if the administrator can post stories in the channel; channels only
        public var canPostStories: Bool?

        /// Optional. True, if the administrator can edit stories posted by other users; channels only
        public var canEditStories: Bool?

        /// Optional. True, if the administrator can delete stories posted by other users; channels only
        public var canDeleteStories: Bool?

        /// Optional. True, if the user is allowed to create, rename, close, and reopen forum topics; supergroups only
        public var canManageTopics: Bool?

        /// Optional. Custom title for this user
        public var customTitle: String?

        /// ChatMemberAdministrator initialization
        ///
        /// - parameter status:  The member’s status in the chat, always “administrator”
        /// - parameter user:  Information about the user
        /// - parameter canBeEdited:  True, if the bot is allowed to edit administrator privileges of that user
        /// - parameter isAnonymous:  True, if the user’s presence in the chat is hidden
        /// - parameter canManageChat:  True, if the administrator can access the chat event log, boost list in channels, see channel members, report spam messages, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
        /// - parameter canDeleteMessages:  True, if the administrator can delete messages of other users
        /// - parameter canManageVideoChats:  True, if the administrator can manage video chats
        /// - parameter canRestrictMembers:  True, if the administrator can restrict, ban or unban chat members, or access supergroup statistics
        /// - parameter canPromoteMembers:  True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        /// - parameter canChangeInfo:  True, if the user is allowed to change the chat title, photo and other settings
        /// - parameter canInviteUsers:  True, if the user is allowed to invite new users to the chat
        /// - parameter canPostMessages:  Optional. True, if the administrator can post messages in the channel, or access channel statistics; channels only
        /// - parameter canEditMessages:  Optional. True, if the administrator can edit messages of other users and can pin messages; channels only
        /// - parameter canPinMessages:  Optional. True, if the user is allowed to pin messages; groups and supergroups only
        /// - parameter canPostStories:  Optional. True, if the administrator can post stories in the channel; channels only
        /// - parameter canEditStories:  Optional. True, if the administrator can edit stories posted by other users; channels only
        /// - parameter canDeleteStories:  Optional. True, if the administrator can delete stories posted by other users; channels only
        /// - parameter canManageTopics:  Optional. True, if the user is allowed to create, rename, close, and reopen forum topics; supergroups only
        /// - parameter customTitle:  Optional. Custom title for this user
        ///
        /// - returns: The new `ChatMemberAdministrator` instance.
        ///
        public init(status: String, user: User, canBeEdited: Bool, isAnonymous: Bool, canManageChat: Bool, canDeleteMessages: Bool, canManageVideoChats: Bool, canRestrictMembers: Bool, canPromoteMembers: Bool, canChangeInfo: Bool, canInviteUsers: Bool, canPostMessages: Bool? = nil, canEditMessages: Bool? = nil, canPinMessages: Bool? = nil, canPostStories: Bool? = nil, canEditStories: Bool? = nil, canDeleteStories: Bool? = nil, canManageTopics: Bool? = nil, customTitle: String? = nil) {
            self.status = status
            self.user = user
            self.canBeEdited = canBeEdited
            self.isAnonymous = isAnonymous
            self.canManageChat = canManageChat
            self.canDeleteMessages = canDeleteMessages
            self.canManageVideoChats = canManageVideoChats
            self.canRestrictMembers = canRestrictMembers
            self.canPromoteMembers = canPromoteMembers
            self.canChangeInfo = canChangeInfo
            self.canInviteUsers = canInviteUsers
            self.canPostMessages = canPostMessages
            self.canEditMessages = canEditMessages
            self.canPinMessages = canPinMessages
            self.canPostStories = canPostStories
            self.canEditStories = canEditStories
            self.canDeleteStories = canDeleteStories
            self.canManageTopics = canManageTopics
            self.customTitle = customTitle
        }

        private enum CodingKeys: String, CodingKey {
            case status = "status"
            case user = "user"
            case canBeEdited = "can_be_edited"
            case isAnonymous = "is_anonymous"
            case canManageChat = "can_manage_chat"
            case canDeleteMessages = "can_delete_messages"
            case canManageVideoChats = "can_manage_video_chats"
            case canRestrictMembers = "can_restrict_members"
            case canPromoteMembers = "can_promote_members"
            case canChangeInfo = "can_change_info"
            case canInviteUsers = "can_invite_users"
            case canPostMessages = "can_post_messages"
            case canEditMessages = "can_edit_messages"
            case canPinMessages = "can_pin_messages"
            case canPostStories = "can_post_stories"
            case canEditStories = "can_edit_stories"
            case canDeleteStories = "can_delete_stories"
            case canManageTopics = "can_manage_topics"
            case customTitle = "custom_title"
        }

    }

    /// Represents a chat member that has no additional privileges or restrictions.
    public class ChatMemberMember: Codable {

        /// The member’s status in the chat, always “member”
        public var status: String

        /// Information about the user
        public var user: User

        /// ChatMemberMember initialization
        ///
        /// - parameter status:  The member’s status in the chat, always “member”
        /// - parameter user:  Information about the user
        ///
        /// - returns: The new `ChatMemberMember` instance.
        ///
        public init(status: String, user: User) {
            self.status = status
            self.user = user
        }

        private enum CodingKeys: String, CodingKey {
            case status = "status"
            case user = "user"
        }

    }

    /// Represents a chat member that is under certain restrictions in the chat. Supergroups only.
    public class ChatMemberRestricted: Codable {

        /// The member’s status in the chat, always “restricted”
        public var status: String

        /// Information about the user
        public var user: User

        /// True, if the user is a member of the chat at the moment of the request
        public var isMember: Bool

        /// True, if the user is allowed to send text messages, contacts, invoices, locations and venues
        public var canSendMessages: Bool

        /// True, if the user is allowed to send audios
        public var canSendAudios: Bool

        /// True, if the user is allowed to send documents
        public var canSendDocuments: Bool

        /// True, if the user is allowed to send photos
        public var canSendPhotos: Bool

        /// True, if the user is allowed to send videos
        public var canSendVideos: Bool

        /// True, if the user is allowed to send video notes
        public var canSendVideoNotes: Bool

        /// True, if the user is allowed to send voice notes
        public var canSendVoiceNotes: Bool

        /// True, if the user is allowed to send polls
        public var canSendPolls: Bool

        /// True, if the user is allowed to send animations, games, stickers and use inline bots
        public var canSendOtherMessages: Bool

        /// True, if the user is allowed to add web page previews to their messages
        public var canAddWebPagePreviews: Bool

        /// True, if the user is allowed to change the chat title, photo and other settings
        public var canChangeInfo: Bool

        /// True, if the user is allowed to invite new users to the chat
        public var canInviteUsers: Bool

        /// True, if the user is allowed to pin messages
        public var canPinMessages: Bool

        /// True, if the user is allowed to create forum topics
        public var canManageTopics: Bool

        /// Date when restrictions will be lifted for this user; Unix time. If 0, then the user is restricted forever
        public var untilDate: Int

        /// ChatMemberRestricted initialization
        ///
        /// - parameter status:  The member’s status in the chat, always “restricted”
        /// - parameter user:  Information about the user
        /// - parameter isMember:  True, if the user is a member of the chat at the moment of the request
        /// - parameter canSendMessages:  True, if the user is allowed to send text messages, contacts, invoices, locations and venues
        /// - parameter canSendAudios:  True, if the user is allowed to send audios
        /// - parameter canSendDocuments:  True, if the user is allowed to send documents
        /// - parameter canSendPhotos:  True, if the user is allowed to send photos
        /// - parameter canSendVideos:  True, if the user is allowed to send videos
        /// - parameter canSendVideoNotes:  True, if the user is allowed to send video notes
        /// - parameter canSendVoiceNotes:  True, if the user is allowed to send voice notes
        /// - parameter canSendPolls:  True, if the user is allowed to send polls
        /// - parameter canSendOtherMessages:  True, if the user is allowed to send animations, games, stickers and use inline bots
        /// - parameter canAddWebPagePreviews:  True, if the user is allowed to add web page previews to their messages
        /// - parameter canChangeInfo:  True, if the user is allowed to change the chat title, photo and other settings
        /// - parameter canInviteUsers:  True, if the user is allowed to invite new users to the chat
        /// - parameter canPinMessages:  True, if the user is allowed to pin messages
        /// - parameter canManageTopics:  True, if the user is allowed to create forum topics
        /// - parameter untilDate:  Date when restrictions will be lifted for this user; Unix time. If 0, then the user is restricted forever
        ///
        /// - returns: The new `ChatMemberRestricted` instance.
        ///
        public init(status: String, user: User, isMember: Bool, canSendMessages: Bool, canSendAudios: Bool, canSendDocuments: Bool, canSendPhotos: Bool, canSendVideos: Bool, canSendVideoNotes: Bool, canSendVoiceNotes: Bool, canSendPolls: Bool, canSendOtherMessages: Bool, canAddWebPagePreviews: Bool, canChangeInfo: Bool, canInviteUsers: Bool, canPinMessages: Bool, canManageTopics: Bool, untilDate: Int) {
            self.status = status
            self.user = user
            self.isMember = isMember
            self.canSendMessages = canSendMessages
            self.canSendAudios = canSendAudios
            self.canSendDocuments = canSendDocuments
            self.canSendPhotos = canSendPhotos
            self.canSendVideos = canSendVideos
            self.canSendVideoNotes = canSendVideoNotes
            self.canSendVoiceNotes = canSendVoiceNotes
            self.canSendPolls = canSendPolls
            self.canSendOtherMessages = canSendOtherMessages
            self.canAddWebPagePreviews = canAddWebPagePreviews
            self.canChangeInfo = canChangeInfo
            self.canInviteUsers = canInviteUsers
            self.canPinMessages = canPinMessages
            self.canManageTopics = canManageTopics
            self.untilDate = untilDate
        }

        private enum CodingKeys: String, CodingKey {
            case status = "status"
            case user = "user"
            case isMember = "is_member"
            case canSendMessages = "can_send_messages"
            case canSendAudios = "can_send_audios"
            case canSendDocuments = "can_send_documents"
            case canSendPhotos = "can_send_photos"
            case canSendVideos = "can_send_videos"
            case canSendVideoNotes = "can_send_video_notes"
            case canSendVoiceNotes = "can_send_voice_notes"
            case canSendPolls = "can_send_polls"
            case canSendOtherMessages = "can_send_other_messages"
            case canAddWebPagePreviews = "can_add_web_page_previews"
            case canChangeInfo = "can_change_info"
            case canInviteUsers = "can_invite_users"
            case canPinMessages = "can_pin_messages"
            case canManageTopics = "can_manage_topics"
            case untilDate = "until_date"
        }

    }

    /// Represents a chat member that isn’t currently a member of the chat, but may join it themselves.
    public class ChatMemberLeft: Codable {

        /// The member’s status in the chat, always “left”
        public var status: String

        /// Information about the user
        public var user: User

        /// ChatMemberLeft initialization
        ///
        /// - parameter status:  The member’s status in the chat, always “left”
        /// - parameter user:  Information about the user
        ///
        /// - returns: The new `ChatMemberLeft` instance.
        ///
        public init(status: String, user: User) {
            self.status = status
            self.user = user
        }

        private enum CodingKeys: String, CodingKey {
            case status = "status"
            case user = "user"
        }

    }

    /// Represents a chat member that was banned in the chat and can’t return to the chat or view chat messages.
    public class ChatMemberBanned: Codable {

        /// The member’s status in the chat, always “kicked”
        public var status: String

        /// Information about the user
        public var user: User

        /// Date when restrictions will be lifted for this user; Unix time. If 0, then the user is banned forever
        public var untilDate: Int

        /// ChatMemberBanned initialization
        ///
        /// - parameter status:  The member’s status in the chat, always “kicked”
        /// - parameter user:  Information about the user
        /// - parameter untilDate:  Date when restrictions will be lifted for this user; Unix time. If 0, then the user is banned forever
        ///
        /// - returns: The new `ChatMemberBanned` instance.
        ///
        public init(status: String, user: User, untilDate: Int) {
            self.status = status
            self.user = user
            self.untilDate = untilDate
        }

        private enum CodingKeys: String, CodingKey {
            case status = "status"
            case user = "user"
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

        /// Optional. True, if the user joined the chat via a chat folder invite link
        public var viaChatFolderInviteLink: Bool?

        /// ChatMemberUpdated initialization
        ///
        /// - parameter chat:  Chat the user belongs to
        /// - parameter from:  Performer of the action, which resulted in the change
        /// - parameter date:  Date the change was done in Unix time
        /// - parameter oldChatMember:  Previous information about the chat member
        /// - parameter newChatMember:  New information about the chat member
        /// - parameter inviteLink:  Optional. Chat invite link, which was used by the user to join the chat; for joining by invite link events only.
        /// - parameter viaChatFolderInviteLink:  Optional. True, if the user joined the chat via a chat folder invite link
        ///
        /// - returns: The new `ChatMemberUpdated` instance.
        ///
        public init(chat: Chat, from: User, date: Int, oldChatMember: ChatMember, newChatMember: ChatMember, inviteLink: ChatInviteLink? = nil, viaChatFolderInviteLink: Bool? = nil) {
            self.chat = chat
            self.from = from
            self.date = date
            self.oldChatMember = oldChatMember
            self.newChatMember = newChatMember
            self.inviteLink = inviteLink
            self.viaChatFolderInviteLink = viaChatFolderInviteLink
        }

        private enum CodingKeys: String, CodingKey {
            case chat = "chat"
            case from = "from"
            case date = "date"
            case oldChatMember = "old_chat_member"
            case newChatMember = "new_chat_member"
            case inviteLink = "invite_link"
            case viaChatFolderInviteLink = "via_chat_folder_invite_link"
        }

    }

    /// Represents a join request sent to a chat.
    public class ChatJoinRequest: Codable {

        /// Chat to which the request was sent
        public var chat: Chat

        /// User that sent the join request
        public var from: User

        /// Identifier of a private chat with the user who sent the join request. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot can use this identifier for 5 minutes to send messages until the join request is processed, assuming no other administrator contacted the user.
        public var userChatId: Int

        /// Date the request was sent in Unix time
        public var date: Int

        /// Optional. Bio of the user.
        public var bio: String?

        /// Optional. Chat invite link that was used by the user to send the join request
        public var inviteLink: ChatInviteLink?

        /// ChatJoinRequest initialization
        ///
        /// - parameter chat:  Chat to which the request was sent
        /// - parameter from:  User that sent the join request
        /// - parameter userChatId:  Identifier of a private chat with the user who sent the join request. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot can use this identifier for 5 minutes to send messages until the join request is processed, assuming no other administrator contacted the user.
        /// - parameter date:  Date the request was sent in Unix time
        /// - parameter bio:  Optional. Bio of the user.
        /// - parameter inviteLink:  Optional. Chat invite link that was used by the user to send the join request
        ///
        /// - returns: The new `ChatJoinRequest` instance.
        ///
        public init(chat: Chat, from: User, userChatId: Int, date: Int, bio: String? = nil, inviteLink: ChatInviteLink? = nil) {
            self.chat = chat
            self.from = from
            self.userChatId = userChatId
            self.date = date
            self.bio = bio
            self.inviteLink = inviteLink
        }

        private enum CodingKeys: String, CodingKey {
            case chat = "chat"
            case from = "from"
            case userChatId = "user_chat_id"
            case date = "date"
            case bio = "bio"
            case inviteLink = "invite_link"
        }

    }

    /// Describes actions that a non-administrator user is allowed to take in a chat.
    public class ChatPermissions: Codable {

        /// Optional. True, if the user is allowed to send text messages, contacts, invoices, locations and venues
        public var canSendMessages: Bool?

        /// Optional. True, if the user is allowed to send audios
        public var canSendAudios: Bool?

        /// Optional. True, if the user is allowed to send documents
        public var canSendDocuments: Bool?

        /// Optional. True, if the user is allowed to send photos
        public var canSendPhotos: Bool?

        /// Optional. True, if the user is allowed to send videos
        public var canSendVideos: Bool?

        /// Optional. True, if the user is allowed to send video notes
        public var canSendVideoNotes: Bool?

        /// Optional. True, if the user is allowed to send voice notes
        public var canSendVoiceNotes: Bool?

        /// Optional. True, if the user is allowed to send polls
        public var canSendPolls: Bool?

        /// Optional. True, if the user is allowed to send animations, games, stickers and use inline bots
        public var canSendOtherMessages: Bool?

        /// Optional. True, if the user is allowed to add web page previews to their messages
        public var canAddWebPagePreviews: Bool?

        /// Optional. True, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups
        public var canChangeInfo: Bool?

        /// Optional. True, if the user is allowed to invite new users to the chat
        public var canInviteUsers: Bool?

        /// Optional. True, if the user is allowed to pin messages. Ignored in public supergroups
        public var canPinMessages: Bool?

        /// Optional. True, if the user is allowed to create forum topics. If omitted defaults to the value of can_pin_messages
        public var canManageTopics: Bool?

        /// ChatPermissions initialization
        ///
        /// - parameter canSendMessages:  Optional. True, if the user is allowed to send text messages, contacts, invoices, locations and venues
        /// - parameter canSendAudios:  Optional. True, if the user is allowed to send audios
        /// - parameter canSendDocuments:  Optional. True, if the user is allowed to send documents
        /// - parameter canSendPhotos:  Optional. True, if the user is allowed to send photos
        /// - parameter canSendVideos:  Optional. True, if the user is allowed to send videos
        /// - parameter canSendVideoNotes:  Optional. True, if the user is allowed to send video notes
        /// - parameter canSendVoiceNotes:  Optional. True, if the user is allowed to send voice notes
        /// - parameter canSendPolls:  Optional. True, if the user is allowed to send polls
        /// - parameter canSendOtherMessages:  Optional. True, if the user is allowed to send animations, games, stickers and use inline bots
        /// - parameter canAddWebPagePreviews:  Optional. True, if the user is allowed to add web page previews to their messages
        /// - parameter canChangeInfo:  Optional. True, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups
        /// - parameter canInviteUsers:  Optional. True, if the user is allowed to invite new users to the chat
        /// - parameter canPinMessages:  Optional. True, if the user is allowed to pin messages. Ignored in public supergroups
        /// - parameter canManageTopics:  Optional. True, if the user is allowed to create forum topics. If omitted defaults to the value of can_pin_messages
        ///
        /// - returns: The new `ChatPermissions` instance.
        ///
        public init(canSendMessages: Bool? = nil, canSendAudios: Bool? = nil, canSendDocuments: Bool? = nil, canSendPhotos: Bool? = nil, canSendVideos: Bool? = nil, canSendVideoNotes: Bool? = nil, canSendVoiceNotes: Bool? = nil, canSendPolls: Bool? = nil, canSendOtherMessages: Bool? = nil, canAddWebPagePreviews: Bool? = nil, canChangeInfo: Bool? = nil, canInviteUsers: Bool? = nil, canPinMessages: Bool? = nil, canManageTopics: Bool? = nil) {
            self.canSendMessages = canSendMessages
            self.canSendAudios = canSendAudios
            self.canSendDocuments = canSendDocuments
            self.canSendPhotos = canSendPhotos
            self.canSendVideos = canSendVideos
            self.canSendVideoNotes = canSendVideoNotes
            self.canSendVoiceNotes = canSendVoiceNotes
            self.canSendPolls = canSendPolls
            self.canSendOtherMessages = canSendOtherMessages
            self.canAddWebPagePreviews = canAddWebPagePreviews
            self.canChangeInfo = canChangeInfo
            self.canInviteUsers = canInviteUsers
            self.canPinMessages = canPinMessages
            self.canManageTopics = canManageTopics
        }

        private enum CodingKeys: String, CodingKey {
            case canSendMessages = "can_send_messages"
            case canSendAudios = "can_send_audios"
            case canSendDocuments = "can_send_documents"
            case canSendPhotos = "can_send_photos"
            case canSendVideos = "can_send_videos"
            case canSendVideoNotes = "can_send_video_notes"
            case canSendVoiceNotes = "can_send_voice_notes"
            case canSendPolls = "can_send_polls"
            case canSendOtherMessages = "can_send_other_messages"
            case canAddWebPagePreviews = "can_add_web_page_previews"
            case canChangeInfo = "can_change_info"
            case canInviteUsers = "can_invite_users"
            case canPinMessages = "can_pin_messages"
            case canManageTopics = "can_manage_topics"
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

    /// This object represents a forum topic.
    public class ForumTopic: Codable {

        /// Unique identifier of the forum topic
        public var messageThreadId: Int

        /// Name of the topic
        public var name: String

        /// Color of the topic icon in RGB format
        public var iconColor: Int

        /// Optional. Unique identifier of the custom emoji shown as the topic icon
        public var iconCustomEmojiId: String?

        /// ForumTopic initialization
        ///
        /// - parameter messageThreadId:  Unique identifier of the forum topic
        /// - parameter name:  Name of the topic
        /// - parameter iconColor:  Color of the topic icon in RGB format
        /// - parameter iconCustomEmojiId:  Optional. Unique identifier of the custom emoji shown as the topic icon
        ///
        /// - returns: The new `ForumTopic` instance.
        ///
        public init(messageThreadId: Int, name: String, iconColor: Int, iconCustomEmojiId: String? = nil) {
            self.messageThreadId = messageThreadId
            self.name = name
            self.iconColor = iconColor
            self.iconCustomEmojiId = iconCustomEmojiId
        }

        private enum CodingKeys: String, CodingKey {
            case messageThreadId = "message_thread_id"
            case name = "name"
            case iconColor = "icon_color"
            case iconCustomEmojiId = "icon_custom_emoji_id"
        }

    }

    /// This object represents a bot command.
    public class BotCommand: Codable {

        /// Text of the command; 1-32 characters. Can contain only lowercase English letters, digits and underscores.
        public var command: String

        /// Description of the command; 1-256 characters.
        public var description: String

        /// BotCommand initialization
        ///
        /// - parameter command:  Text of the command; 1-32 characters. Can contain only lowercase English letters, digits and underscores.
        /// - parameter description:  Description of the command; 1-256 characters.
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

    /// This object represents the scope to which bot commands are applied. Currently, the following 7 scopes are supported:
    public enum BotCommandScope: Codable {

        case defaultCase(BotCommandScopeDefault)
        case allPrivateChats(BotCommandScopeAllPrivateChats)
        case allGroupChats(BotCommandScopeAllGroupChats)
        case allChatAdministrators(BotCommandScopeAllChatAdministrators)
        case chat(BotCommandScopeChat)
        case chatAdministrators(BotCommandScopeChatAdministrators)
        case chatMember(BotCommandScopeChatMember)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let defaultCase = try? container.decode(BotCommandScopeDefault.self) {
                self = .defaultCase(defaultCase)
            } else if let allPrivateChats = try? container.decode(BotCommandScopeAllPrivateChats.self) {
                self = .allPrivateChats(allPrivateChats)
            } else if let allGroupChats = try? container.decode(BotCommandScopeAllGroupChats.self) {
                self = .allGroupChats(allGroupChats)
            } else if let allChatAdministrators = try? container.decode(BotCommandScopeAllChatAdministrators.self) {
                self = .allChatAdministrators(allChatAdministrators)
            } else if let chat = try? container.decode(BotCommandScopeChat.self) {
                self = .chat(chat)
            } else if let chatAdministrators = try? container.decode(BotCommandScopeChatAdministrators.self) {
                self = .chatAdministrators(chatAdministrators)
            } else if let chatMember = try? container.decode(BotCommandScopeChatMember.self) {
                self = .chatMember(chatMember)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "BotCommandScope"])
            }
        }

        public init(_ defaultCase: BotCommandScopeDefault) {
            self = .defaultCase(defaultCase)
        }

        public init(_ allPrivateChats: BotCommandScopeAllPrivateChats) {
            self = .allPrivateChats(allPrivateChats)
        }

        public init(_ allGroupChats: BotCommandScopeAllGroupChats) {
            self = .allGroupChats(allGroupChats)
        }

        public init(_ allChatAdministrators: BotCommandScopeAllChatAdministrators) {
            self = .allChatAdministrators(allChatAdministrators)
        }

        public init(_ chat: BotCommandScopeChat) {
            self = .chat(chat)
        }

        public init(_ chatAdministrators: BotCommandScopeChatAdministrators) {
            self = .chatAdministrators(chatAdministrators)
        }

        public init(_ chatMember: BotCommandScopeChatMember) {
            self = .chatMember(chatMember)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .defaultCase(let defaultCase):
                try container.encode(defaultCase)
            case .allPrivateChats(let allPrivateChats):
                try container.encode(allPrivateChats)
            case .allGroupChats(let allGroupChats):
                try container.encode(allGroupChats)
            case .allChatAdministrators(let allChatAdministrators):
                try container.encode(allChatAdministrators)
            case .chat(let chat):
                try container.encode(chat)
            case .chatAdministrators(let chatAdministrators):
                try container.encode(chatAdministrators)
            case .chatMember(let chatMember):
                try container.encode(chatMember)
            }
        }
    }
    /// Represents the default scope of bot commands. Default commands are used if no commands with a narrower scope are specified for the user.
    public class BotCommandScopeDefault: Codable {

        /// Scope type, must be default
        public var type: String

        /// BotCommandScopeDefault initialization
        ///
        /// - parameter type:  Scope type, must be default
        ///
        /// - returns: The new `BotCommandScopeDefault` instance.
        ///
        public init(type: String) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Represents the scope of bot commands, covering all private chats.
    public class BotCommandScopeAllPrivateChats: Codable {

        /// Scope type, must be all_private_chats
        public var type: String

        /// BotCommandScopeAllPrivateChats initialization
        ///
        /// - parameter type:  Scope type, must be all_private_chats
        ///
        /// - returns: The new `BotCommandScopeAllPrivateChats` instance.
        ///
        public init(type: String) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Represents the scope of bot commands, covering all group and supergroup chats.
    public class BotCommandScopeAllGroupChats: Codable {

        /// Scope type, must be all_group_chats
        public var type: String

        /// BotCommandScopeAllGroupChats initialization
        ///
        /// - parameter type:  Scope type, must be all_group_chats
        ///
        /// - returns: The new `BotCommandScopeAllGroupChats` instance.
        ///
        public init(type: String) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Represents the scope of bot commands, covering all group and supergroup chat administrators.
    public class BotCommandScopeAllChatAdministrators: Codable {

        /// Scope type, must be all_chat_administrators
        public var type: String

        /// BotCommandScopeAllChatAdministrators initialization
        ///
        /// - parameter type:  Scope type, must be all_chat_administrators
        ///
        /// - returns: The new `BotCommandScopeAllChatAdministrators` instance.
        ///
        public init(type: String) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Represents the scope of bot commands, covering a specific chat.
    public class BotCommandScopeChat: Codable {

        /// Scope type, must be chat
        public var type: String

        /// Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        public var chatId: ChatId

        /// BotCommandScopeChat initialization
        ///
        /// - parameter type:  Scope type, must be chat
        /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        ///
        /// - returns: The new `BotCommandScopeChat` instance.
        ///
        public init(type: String, chatId: ChatId) {
            self.type = type
            self.chatId = chatId
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case chatId = "chat_id"
        }

    }

    /// Represents the scope of bot commands, covering all administrators of a specific group or supergroup chat.
    public class BotCommandScopeChatAdministrators: Codable {

        /// Scope type, must be chat_administrators
        public var type: String

        /// Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        public var chatId: ChatId

        /// BotCommandScopeChatAdministrators initialization
        ///
        /// - parameter type:  Scope type, must be chat_administrators
        /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        ///
        /// - returns: The new `BotCommandScopeChatAdministrators` instance.
        ///
        public init(type: String, chatId: ChatId) {
            self.type = type
            self.chatId = chatId
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case chatId = "chat_id"
        }

    }

    /// Represents the scope of bot commands, covering a specific member of a group or supergroup chat.
    public class BotCommandScopeChatMember: Codable {

        /// Scope type, must be chat_member
        public var type: String

        /// Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        public var chatId: ChatId

        /// Unique identifier of the target user
        public var userId: Int

        /// BotCommandScopeChatMember initialization
        ///
        /// - parameter type:  Scope type, must be chat_member
        /// - parameter chatId:  Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        /// - parameter userId:  Unique identifier of the target user
        ///
        /// - returns: The new `BotCommandScopeChatMember` instance.
        ///
        public init(type: String, chatId: ChatId, userId: Int) {
            self.type = type
            self.chatId = chatId
            self.userId = userId
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case chatId = "chat_id"
            case userId = "user_id"
        }

    }

    /// This object represents the bot’s name.
    public class BotName: Codable {

        /// The bot’s name
        public var name: String

        /// BotName initialization
        ///
        /// - parameter name:  The bot’s name
        ///
        /// - returns: The new `BotName` instance.
        ///
        public init(name: String) {
            self.name = name
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
        }

    }

    /// This object represents the bot’s description.
    public class BotDescription: Codable {

        /// The bot’s description
        public var description: String

        /// BotDescription initialization
        ///
        /// - parameter description:  The bot’s description
        ///
        /// - returns: The new `BotDescription` instance.
        ///
        public init(description: String) {
            self.description = description
        }

        private enum CodingKeys: String, CodingKey {
            case description = "description"
        }

    }

    /// This object represents the bot’s short description.
    public class BotShortDescription: Codable {

        /// The bot’s short description
        public var shortDescription: String

        /// BotShortDescription initialization
        ///
        /// - parameter shortDescription:  The bot’s short description
        ///
        /// - returns: The new `BotShortDescription` instance.
        ///
        public init(shortDescription: String) {
            self.shortDescription = shortDescription
        }

        private enum CodingKeys: String, CodingKey {
            case shortDescription = "short_description"
        }

    }

    /// If a menu button other than MenuButtonDefault is set for a private chat, then it is applied in the chat. Otherwise the default menu button is applied. By default, the menu button opens the list of bot commands.
    public enum MenuButton: Codable {

        case commands(MenuButtonCommands)
        case webApp(MenuButtonWebApp)
        case defaultCase(MenuButtonDefault)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let commands = try? container.decode(MenuButtonCommands.self) {
                self = .commands(commands)
            } else if let webApp = try? container.decode(MenuButtonWebApp.self) {
                self = .webApp(webApp)
            } else if let defaultCase = try? container.decode(MenuButtonDefault.self) {
                self = .defaultCase(defaultCase)
            } else {
                throw NSError(domain: "org.telegram.api", code: -1, userInfo: ["name": "MenuButton"])
            }
        }

        public init(_ commands: MenuButtonCommands) {
            self = .commands(commands)
        }

        public init(_ webApp: MenuButtonWebApp) {
            self = .webApp(webApp)
        }

        public init(_ defaultCase: MenuButtonDefault) {
            self = .defaultCase(defaultCase)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .commands(let commands):
                try container.encode(commands)
            case .webApp(let webApp):
                try container.encode(webApp)
            case .defaultCase(let defaultCase):
                try container.encode(defaultCase)
            }
        }
    }
    /// Represents a menu button, which opens the bot’s list of commands.
    public class MenuButtonCommands: Codable {

        /// Type of the button, must be commands
        public var type: String

        /// MenuButtonCommands initialization
        ///
        /// - parameter type:  Type of the button, must be commands
        ///
        /// - returns: The new `MenuButtonCommands` instance.
        ///
        public init(type: String) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Represents a menu button, which launches a Web App.
    public class MenuButtonWebApp: Codable {

        /// Type of the button, must be web_app
        public var type: String

        /// Text on the button
        public var text: String

        /// Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery.
        public var webApp: WebAppInfo

        /// MenuButtonWebApp initialization
        ///
        /// - parameter type:  Type of the button, must be web_app
        /// - parameter text:  Text on the button
        /// - parameter webApp:  Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery.
        ///
        /// - returns: The new `MenuButtonWebApp` instance.
        ///
        public init(type: String, text: String, webApp: WebAppInfo) {
            self.type = type
            self.text = text
            self.webApp = webApp
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case text = "text"
            case webApp = "web_app"
        }

    }

    /// Describes that no specific value for the menu button was set.
    public class MenuButtonDefault: Codable {

        /// Type of the button, must be default
        public var type: String

        /// MenuButtonDefault initialization
        ///
        /// - parameter type:  Type of the button, must be default
        ///
        /// - returns: The new `MenuButtonDefault` instance.
        ///
        public init(type: String) {
            self.type = type
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
        }

    }

    /// Describes why a request was unsuccessful.
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

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        public var media: String

        /// Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Pass True if the photo needs to be covered with a spoiler animation
        public var hasSpoiler: Bool?

        /// InputMediaPhoto initialization
        ///
        /// - parameter type:  Type of the result, must be photo
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the photo caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter hasSpoiler:  Optional. Pass True if the photo needs to be covered with a spoiler animation
        ///
        /// - returns: The new `InputMediaPhoto` instance.
        ///
        public init(type: String, media: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, hasSpoiler: Bool? = nil) {
            self.type = type
            self.media = media
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.hasSpoiler = hasSpoiler
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case hasSpoiler = "has_spoiler"
        }

    }

    /// Represents a video to be sent.
    public class InputMediaVideo: Codable {

        /// Type of the result, must be video
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        public var thumbnail: FileOrPath?

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

        /// Optional. Video duration in seconds
        public var duration: Int?

        /// Optional. Pass True if the uploaded video is suitable for streaming
        public var supportsStreaming: Bool?

        /// Optional. Pass True if the video needs to be covered with a spoiler animation
        public var hasSpoiler: Bool?

        /// InputMediaVideo initialization
        ///
        /// - parameter type:  Type of the result, must be video
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        /// - parameter thumbnail:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the video caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter width:  Optional. Video width
        /// - parameter height:  Optional. Video height
        /// - parameter duration:  Optional. Video duration in seconds
        /// - parameter supportsStreaming:  Optional. Pass True if the uploaded video is suitable for streaming
        /// - parameter hasSpoiler:  Optional. Pass True if the video needs to be covered with a spoiler animation
        ///
        /// - returns: The new `InputMediaVideo` instance.
        ///
        public init(type: String, media: String, thumbnail: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil, supportsStreaming: Bool? = nil, hasSpoiler: Bool? = nil) {
            self.type = type
            self.media = media
            self.thumbnail = thumbnail
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.width = width
            self.height = height
            self.duration = duration
            self.supportsStreaming = supportsStreaming
            self.hasSpoiler = hasSpoiler
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumbnail = "thumbnail"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case width = "width"
            case height = "height"
            case duration = "duration"
            case supportsStreaming = "supports_streaming"
            case hasSpoiler = "has_spoiler"
        }

    }

    /// Represents an animation file (GIF or H.264/MPEG-4 AVC video without sound) to be sent.
    public class InputMediaAnimation: Codable {

        /// Type of the result, must be animation
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        public var thumbnail: FileOrPath?

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

        /// Optional. Animation duration in seconds
        public var duration: Int?

        /// Optional. Pass True if the animation needs to be covered with a spoiler animation
        public var hasSpoiler: Bool?

        /// InputMediaAnimation initialization
        ///
        /// - parameter type:  Type of the result, must be animation
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        /// - parameter thumbnail:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        /// - parameter caption:  Optional. Caption of the animation to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the animation caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter width:  Optional. Animation width
        /// - parameter height:  Optional. Animation height
        /// - parameter duration:  Optional. Animation duration in seconds
        /// - parameter hasSpoiler:  Optional. Pass True if the animation needs to be covered with a spoiler animation
        ///
        /// - returns: The new `InputMediaAnimation` instance.
        ///
        public init(type: String, media: String, thumbnail: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil, hasSpoiler: Bool? = nil) {
            self.type = type
            self.media = media
            self.thumbnail = thumbnail
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.width = width
            self.height = height
            self.duration = duration
            self.hasSpoiler = hasSpoiler
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumbnail = "thumbnail"
            case caption = "caption"
            case parseMode = "parse_mode"
            case captionEntities = "caption_entities"
            case width = "width"
            case height = "height"
            case duration = "duration"
            case hasSpoiler = "has_spoiler"
        }

    }

    /// Represents an audio file to be treated as music to be sent.
    public class InputMediaAudio: Codable {

        /// Type of the result, must be audio
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        public var thumbnail: FileOrPath?

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
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        /// - parameter thumbnail:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        /// - parameter caption:  Optional. Caption of the audio to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the audio caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter duration:  Optional. Duration of the audio in seconds
        /// - parameter performer:  Optional. Performer of the audio
        /// - parameter title:  Optional. Title of the audio
        ///
        /// - returns: The new `InputMediaAudio` instance.
        ///
        public init(type: String, media: String, thumbnail: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, duration: Int? = nil, performer: String? = nil, title: String? = nil) {
            self.type = type
            self.media = media
            self.thumbnail = thumbnail
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
            case thumbnail = "thumbnail"
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

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        public var thumbnail: FileOrPath?

        /// Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        public var caption: String?

        /// Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        public var parseMode: String?

        /// Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        public var captionEntities: [MessageEntity]?

        /// Optional. Disables automatic server-side content type detection for files uploaded using multipart/form-data. Always True, if the document is sent as part of an album.
        public var disableContentTypeDetection: Bool?

        /// InputMediaDocument initialization
        ///
        /// - parameter type:  Type of the result, must be document
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More information on Sending Files »
        /// - parameter thumbnail:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail’s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More information on Sending Files »
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter disableContentTypeDetection:  Optional. Disables automatic server-side content type detection for files uploaded using multipart/form-data. Always True, if the document is sent as part of an album.
        ///
        /// - returns: The new `InputMediaDocument` instance.
        ///
        public init(type: String, media: String, thumbnail: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, disableContentTypeDetection: Bool? = nil) {
            self.type = type
            self.media = media
            self.thumbnail = thumbnail
            self.caption = caption
            self.parseMode = parseMode
            self.captionEntities = captionEntities
            self.disableContentTypeDetection = disableContentTypeDetection
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumbnail = "thumbnail"
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

        /// Type of the sticker, currently one of “regular”, “mask”, “custom_emoji”. The type of the sticker is independent from its format, which is determined by the fields is_animated and is_video.
        public var type: String

        /// Sticker width
        public var width: Int

        /// Sticker height
        public var height: Int

        /// True, if the sticker is [animated](https://telegram.org/blog/animated-stickers)
        public var isAnimated: Bool

        /// True, if the sticker is a [video sticker](https://telegram.org/blog/video-stickers-better-reactions)
        public var isVideo: Bool

        /// Optional. Sticker thumbnail in the .WEBP or .JPG format
        public var thumbnail: PhotoSize?

        /// Optional. Emoji associated with the sticker
        public var emoji: String?

        /// Optional. Name of the sticker set to which the sticker belongs
        public var setName: String?

        /// Optional. For premium regular stickers, premium animation for the sticker
        public var premiumAnimation: File?

        /// Optional. For mask stickers, the position where the mask should be placed
        public var maskPosition: MaskPosition?

        /// Optional. For custom emoji stickers, unique identifier of the custom emoji
        public var customEmojiId: String?

        /// Optional. True, if the sticker must be repainted to a text color in messages, the color of the Telegram Premium badge in emoji status, white color on chat photos, or another appropriate color in other places
        public var needsRepainting: Bool?

        /// Optional. File size in bytes
        public var fileSize: Int?

        /// Sticker initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter type:  Type of the sticker, currently one of “regular”, “mask”, “custom_emoji”. The type of the sticker is independent from its format, which is determined by the fields is_animated and is_video.
        /// - parameter width:  Sticker width
        /// - parameter height:  Sticker height
        /// - parameter isAnimated:  True, if the sticker is [animated](https://telegram.org/blog/animated-stickers)
        /// - parameter isVideo:  True, if the sticker is a [video sticker](https://telegram.org/blog/video-stickers-better-reactions)
        /// - parameter thumbnail:  Optional. Sticker thumbnail in the .WEBP or .JPG format
        /// - parameter emoji:  Optional. Emoji associated with the sticker
        /// - parameter setName:  Optional. Name of the sticker set to which the sticker belongs
        /// - parameter premiumAnimation:  Optional. For premium regular stickers, premium animation for the sticker
        /// - parameter maskPosition:  Optional. For mask stickers, the position where the mask should be placed
        /// - parameter customEmojiId:  Optional. For custom emoji stickers, unique identifier of the custom emoji
        /// - parameter needsRepainting:  Optional. True, if the sticker must be repainted to a text color in messages, the color of the Telegram Premium badge in emoji status, white color on chat photos, or another appropriate color in other places
        /// - parameter fileSize:  Optional. File size in bytes
        ///
        /// - returns: The new `Sticker` instance.
        ///
        public init(fileId: String, fileUniqueId: String, type: String, width: Int, height: Int, isAnimated: Bool, isVideo: Bool, thumbnail: PhotoSize? = nil, emoji: String? = nil, setName: String? = nil, premiumAnimation: File? = nil, maskPosition: MaskPosition? = nil, customEmojiId: String? = nil, needsRepainting: Bool? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.fileUniqueId = fileUniqueId
            self.type = type
            self.width = width
            self.height = height
            self.isAnimated = isAnimated
            self.isVideo = isVideo
            self.thumbnail = thumbnail
            self.emoji = emoji
            self.setName = setName
            self.premiumAnimation = premiumAnimation
            self.maskPosition = maskPosition
            self.customEmojiId = customEmojiId
            self.needsRepainting = needsRepainting
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileUniqueId = "file_unique_id"
            case type = "type"
            case width = "width"
            case height = "height"
            case isAnimated = "is_animated"
            case isVideo = "is_video"
            case thumbnail = "thumbnail"
            case emoji = "emoji"
            case setName = "set_name"
            case premiumAnimation = "premium_animation"
            case maskPosition = "mask_position"
            case customEmojiId = "custom_emoji_id"
            case needsRepainting = "needs_repainting"
            case fileSize = "file_size"
        }

    }

    /// This object represents a sticker set.
    public class StickerSet: Codable {

        /// Sticker set name
        public var name: String

        /// Sticker set title
        public var title: String

        /// Type of stickers in the set, currently one of “regular”, “mask”, “custom_emoji”
        public var stickerType: String

        /// True, if the sticker set contains [animated stickers](https://telegram.org/blog/animated-stickers)
        public var isAnimated: Bool

        /// True, if the sticker set contains [video stickers](https://telegram.org/blog/video-stickers-better-reactions)
        public var isVideo: Bool

        /// List of all set stickers
        public var stickers: [Sticker]

        /// Optional. Sticker set thumbnail in the .WEBP, .TGS, or .WEBM format
        public var thumbnail: PhotoSize?

        /// StickerSet initialization
        ///
        /// - parameter name:  Sticker set name
        /// - parameter title:  Sticker set title
        /// - parameter stickerType:  Type of stickers in the set, currently one of “regular”, “mask”, “custom_emoji”
        /// - parameter isAnimated:  True, if the sticker set contains [animated stickers](https://telegram.org/blog/animated-stickers)
        /// - parameter isVideo:  True, if the sticker set contains [video stickers](https://telegram.org/blog/video-stickers-better-reactions)
        /// - parameter stickers:  List of all set stickers
        /// - parameter thumbnail:  Optional. Sticker set thumbnail in the .WEBP, .TGS, or .WEBM format
        ///
        /// - returns: The new `StickerSet` instance.
        ///
        public init(name: String, title: String, stickerType: String, isAnimated: Bool, isVideo: Bool, stickers: [Sticker], thumbnail: PhotoSize? = nil) {
            self.name = name
            self.title = title
            self.stickerType = stickerType
            self.isAnimated = isAnimated
            self.isVideo = isVideo
            self.stickers = stickers
            self.thumbnail = thumbnail
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case title = "title"
            case stickerType = "sticker_type"
            case isAnimated = "is_animated"
            case isVideo = "is_video"
            case stickers = "stickers"
            case thumbnail = "thumbnail"
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

    /// This object describes a sticker to be added to a sticker set.
    public class InputSticker: Codable {

        /// The added sticker. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, upload a new one using multipart/form-data, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. Animated and video stickers can’t be uploaded via HTTP URL. More information on Sending Files »
        public var sticker: FileOrPath

        /// List of 1-20 emoji associated with the sticker
        public var emojiList: [String]

        /// Optional. Position where the mask should be placed on faces. For “mask” stickers only.
        public var maskPosition: MaskPosition?

        /// Optional. List of 0-20 search keywords for the sticker with total length of up to 64 characters. For “regular” and “custom_emoji” stickers only.
        public var keywords: [String]?

        /// InputSticker initialization
        ///
        /// - parameter sticker:  The added sticker. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, upload a new one using multipart/form-data, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. Animated and video stickers can’t be uploaded via HTTP URL. More information on Sending Files »
        /// - parameter emojiList:  List of 1-20 emoji associated with the sticker
        /// - parameter maskPosition:  Optional. Position where the mask should be placed on faces. For “mask” stickers only.
        /// - parameter keywords:  Optional. List of 0-20 search keywords for the sticker with total length of up to 64 characters. For “regular” and “custom_emoji” stickers only.
        ///
        /// - returns: The new `InputSticker` instance.
        ///
        public init(sticker: FileOrPath, emojiList: [String], maskPosition: MaskPosition? = nil, keywords: [String]? = nil) {
            self.sticker = sticker
            self.emojiList = emojiList
            self.maskPosition = maskPosition
            self.keywords = keywords
        }

        private enum CodingKeys: String, CodingKey {
            case sticker = "sticker"
            case emojiList = "emoji_list"
            case maskPosition = "mask_position"
            case keywords = "keywords"
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

        /// Optional. Type of the chat from which the inline query was sent. Can be either “sender” for a private chat with the inline query sender, “private”, “group”, “supergroup”, or “channel”. The chat type should be always known for requests sent from official clients and most third-party clients, unless the request was sent from a secret chat
        public var chatType: String?

        /// Optional. Sender location, only for bots that request user location
        public var location: Location?

        /// InlineQuery initialization
        ///
        /// - parameter id:  Unique identifier for this query
        /// - parameter from:  Sender
        /// - parameter query:  Text of the query (up to 256 characters)
        /// - parameter offset:  Offset of the results to be returned, can be controlled by the bot
        /// - parameter chatType:  Optional. Type of the chat from which the inline query was sent. Can be either “sender” for a private chat with the inline query sender, “private”, “group”, “supergroup”, or “channel”. The chat type should be always known for requests sent from official clients and most third-party clients, unless the request was sent from a secret chat
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

    /// This object represents a button to be shown above inline query results. You must use exactly one of the optional fields.
    public class InlineQueryResultsButton: Codable {

        /// Label text on the button
        public var text: String

        /// Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to switch back to the inline mode using the method switchInlineQuery inside the Web App.
        public var webApp: WebAppInfo?

        /// Optional. Deep-linking parameter for the /start message sent to the bot when a user presses the button. 1-64 characters, only A-Z, a-z, 0-9, _ and - are allowed.Example: An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a ’Connect your YouTube account’ button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an OAuth link. Once done, the bot can offer a switch_inline button so that the user can easily return to the chat where they wanted to use the bot’s inline capabilities.
        public var startParameter: String?

        /// InlineQueryResultsButton initialization
        ///
        /// - parameter text:  Label text on the button
        /// - parameter webApp:  Optional. Description of the Web App that will be launched when the user presses the button. The Web App will be able to switch back to the inline mode using the method switchInlineQuery inside the Web App.
        /// - parameter startParameter:  Optional. Deep-linking parameter for the /start message sent to the bot when a user presses the button. 1-64 characters, only A-Z, a-z, 0-9, _ and - are allowed.Example: An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a ’Connect your YouTube account’ button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an OAuth link. Once done, the bot can offer a switch_inline button so that the user can easily return to the chat where they wanted to use the bot’s inline capabilities.
        ///
        /// - returns: The new `InlineQueryResultsButton` instance.
        ///
        public init(text: String, webApp: WebAppInfo? = nil, startParameter: String? = nil) {
            self.text = text
            self.webApp = webApp
            self.startParameter = startParameter
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case webApp = "web_app"
            case startParameter = "start_parameter"
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

        /// Optional. Pass True if you don’t want the URL to be shown in the message
        public var hideUrl: Bool?

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Url of the thumbnail for the result
        public var thumbnailUrl: String?

        /// Optional. Thumbnail width
        public var thumbnailWidth: Int?

        /// Optional. Thumbnail height
        public var thumbnailHeight: Int?

        /// InlineQueryResultArticle initialization
        ///
        /// - parameter type:  Type of the result, must be article
        /// - parameter id:  Unique identifier for this result, 1-64 Bytes
        /// - parameter title:  Title of the result
        /// - parameter inputMessageContent:  Content of the message to be sent
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter url:  Optional. URL of the result
        /// - parameter hideUrl:  Optional. Pass True if you don’t want the URL to be shown in the message
        /// - parameter description:  Optional. Short description of the result
        /// - parameter thumbnailUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbnailWidth:  Optional. Thumbnail width
        /// - parameter thumbnailHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultArticle` instance.
        ///
        public init(type: String, id: String, title: String, inputMessageContent: InputMessageContent, replyMarkup: InlineKeyboardMarkup? = nil, url: String? = nil, hideUrl: Bool? = nil, description: String? = nil, thumbnailUrl: String? = nil, thumbnailWidth: Int? = nil, thumbnailHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.title = title
            self.inputMessageContent = inputMessageContent
            self.replyMarkup = replyMarkup
            self.url = url
            self.hideUrl = hideUrl
            self.description = description
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailWidth = thumbnailWidth
            self.thumbnailHeight = thumbnailHeight
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailWidth = "thumbnail_width"
            case thumbnailHeight = "thumbnail_height"
        }

    }

    /// Represents a link to a photo. By default, this photo will be sent by the user with optional caption. Alternatively, you can use input_message_content to send a message with the specified content instead of the photo.
    public class InlineQueryResultPhoto: Codable {

        /// Type of the result, must be photo
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL of the photo. Photo must be in JPEG format. Photo size must not exceed 5MB
        public var photoUrl: String

        /// URL of the thumbnail for the photo
        public var thumbnailUrl: String

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
        /// - parameter photoUrl:  A valid URL of the photo. Photo must be in JPEG format. Photo size must not exceed 5MB
        /// - parameter thumbnailUrl:  URL of the thumbnail for the photo
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
        public init(type: String, id: String, photoUrl: String, thumbnailUrl: String, photoWidth: Int? = nil, photoHeight: Int? = nil, title: String? = nil, description: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.photoUrl = photoUrl
            self.thumbnailUrl = thumbnailUrl
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
            case thumbnailUrl = "thumbnail_url"
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

        /// Optional. Duration of the GIF in seconds
        public var gifDuration: Int?

        /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        public var thumbnailUrl: String

        /// Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        public var thumbnailMimeType: String?

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
        /// - parameter gifDuration:  Optional. Duration of the GIF in seconds
        /// - parameter thumbnailUrl:  URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        /// - parameter thumbnailMimeType:  Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the GIF animation
        ///
        /// - returns: The new `InlineQueryResultGif` instance.
        ///
        public init(type: String, id: String, gifUrl: String, gifWidth: Int? = nil, gifHeight: Int? = nil, gifDuration: Int? = nil, thumbnailUrl: String, thumbnailMimeType: String? = nil, title: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.gifUrl = gifUrl
            self.gifWidth = gifWidth
            self.gifHeight = gifHeight
            self.gifDuration = gifDuration
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailMimeType = thumbnailMimeType
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailMimeType = "thumbnail_mime_type"
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

        /// A valid URL for the MPEG4 file. File size must not exceed 1MB
        public var mpeg4Url: String

        /// Optional. Video width
        public var mpeg4Width: Int?

        /// Optional. Video height
        public var mpeg4Height: Int?

        /// Optional. Video duration in seconds
        public var mpeg4Duration: Int?

        /// URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        public var thumbnailUrl: String

        /// Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        public var thumbnailMimeType: String?

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
        /// - parameter mpeg4Url:  A valid URL for the MPEG4 file. File size must not exceed 1MB
        /// - parameter mpeg4Width:  Optional. Video width
        /// - parameter mpeg4Height:  Optional. Video height
        /// - parameter mpeg4Duration:  Optional. Video duration in seconds
        /// - parameter thumbnailUrl:  URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
        /// - parameter thumbnailMimeType:  Optional. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video animation
        ///
        /// - returns: The new `InlineQueryResultMpeg4Gif` instance.
        ///
        public init(type: String, id: String, mpeg4Url: String, mpeg4Width: Int? = nil, mpeg4Height: Int? = nil, mpeg4Duration: Int? = nil, thumbnailUrl: String, thumbnailMimeType: String? = nil, title: String? = nil, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.mpeg4Url = mpeg4Url
            self.mpeg4Width = mpeg4Width
            self.mpeg4Height = mpeg4Height
            self.mpeg4Duration = mpeg4Duration
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailMimeType = thumbnailMimeType
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailMimeType = "thumbnail_mime_type"
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

        /// MIME type of the content of the video URL, “text/html” or “video/mp4”
        public var mimeType: String

        /// URL of the thumbnail (JPEG only) for the video
        public var thumbnailUrl: String

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
        /// - parameter mimeType:  MIME type of the content of the video URL, “text/html” or “video/mp4”
        /// - parameter thumbnailUrl:  URL of the thumbnail (JPEG only) for the video
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
        public init(type: String, id: String, videoUrl: String, mimeType: String, thumbnailUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, videoWidth: Int? = nil, videoHeight: Int? = nil, videoDuration: Int? = nil, description: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.videoUrl = videoUrl
            self.mimeType = mimeType
            self.thumbnailUrl = thumbnailUrl
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
            case thumbnailUrl = "thumbnail_url"
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

        /// MIME type of the content of the file, either “application/pdf” or “application/zip”
        public var mimeType: String

        /// Optional. Short description of the result
        public var description: String?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the file
        public var inputMessageContent: InputMessageContent?

        /// Optional. URL of the thumbnail (JPEG only) for the file
        public var thumbnailUrl: String?

        /// Optional. Thumbnail width
        public var thumbnailWidth: Int?

        /// Optional. Thumbnail height
        public var thumbnailHeight: Int?

        /// InlineQueryResultDocument initialization
        ///
        /// - parameter type:  Type of the result, must be document
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter title:  Title for the result
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters after entities parsing
        /// - parameter parseMode:  Optional. Mode for parsing entities in the document caption. See formatting options for more details.
        /// - parameter captionEntities:  Optional. List of special entities that appear in the caption, which can be specified instead of parse_mode
        /// - parameter documentUrl:  A valid URL for the file
        /// - parameter mimeType:  MIME type of the content of the file, either “application/pdf” or “application/zip”
        /// - parameter description:  Optional. Short description of the result
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the file
        /// - parameter thumbnailUrl:  Optional. URL of the thumbnail (JPEG only) for the file
        /// - parameter thumbnailWidth:  Optional. Thumbnail width
        /// - parameter thumbnailHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultDocument` instance.
        ///
        public init(type: String, id: String, title: String, caption: String? = nil, parseMode: String? = nil, captionEntities: [MessageEntity]? = nil, documentUrl: String, mimeType: String, description: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbnailUrl: String? = nil, thumbnailWidth: Int? = nil, thumbnailHeight: Int? = nil) {
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
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailWidth = thumbnailWidth
            self.thumbnailHeight = thumbnailHeight
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailWidth = "thumbnail_width"
            case thumbnailHeight = "thumbnail_height"
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
        public var thumbnailUrl: String?

        /// Optional. Thumbnail width
        public var thumbnailWidth: Int?

        /// Optional. Thumbnail height
        public var thumbnailHeight: Int?

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
        /// - parameter thumbnailUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbnailWidth:  Optional. Thumbnail width
        /// - parameter thumbnailHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultLocation` instance.
        ///
        public init(type: String, id: String, latitude: Float, longitude: Float, title: String, horizontalAccuracy: Float? = nil, livePeriod: Int? = nil, heading: Int? = nil, proximityAlertRadius: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbnailUrl: String? = nil, thumbnailWidth: Int? = nil, thumbnailHeight: Int? = nil) {
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
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailWidth = thumbnailWidth
            self.thumbnailHeight = thumbnailHeight
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailWidth = "thumbnail_width"
            case thumbnailHeight = "thumbnail_height"
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
        public var thumbnailUrl: String?

        /// Optional. Thumbnail width
        public var thumbnailWidth: Int?

        /// Optional. Thumbnail height
        public var thumbnailHeight: Int?

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
        /// - parameter thumbnailUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbnailWidth:  Optional. Thumbnail width
        /// - parameter thumbnailHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultVenue` instance.
        ///
        public init(type: String, id: String, latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, googlePlaceId: String? = nil, googlePlaceType: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbnailUrl: String? = nil, thumbnailWidth: Int? = nil, thumbnailHeight: Int? = nil) {
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
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailWidth = thumbnailWidth
            self.thumbnailHeight = thumbnailHeight
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailWidth = "thumbnail_width"
            case thumbnailHeight = "thumbnail_height"
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
        public var thumbnailUrl: String?

        /// Optional. Thumbnail width
        public var thumbnailWidth: Int?

        /// Optional. Thumbnail height
        public var thumbnailHeight: Int?

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
        /// - parameter thumbnailUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbnailWidth:  Optional. Thumbnail width
        /// - parameter thumbnailHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultContact` instance.
        ///
        public init(type: String, id: String, phoneNumber: String, firstName: String, lastName: String? = nil, vcard: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbnailUrl: String? = nil, thumbnailWidth: Int? = nil, thumbnailHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.phoneNumber = phoneNumber
            self.firstName = firstName
            self.lastName = lastName
            self.vcard = vcard
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
            self.thumbnailUrl = thumbnailUrl
            self.thumbnailWidth = thumbnailWidth
            self.thumbnailHeight = thumbnailHeight
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
            case thumbnailUrl = "thumbnail_url"
            case thumbnailWidth = "thumbnail_width"
            case thumbnailHeight = "thumbnail_height"
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

        /// A valid file identifier for the MPEG4 file
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
        /// - parameter mpeg4FileId:  A valid file identifier for the MPEG4 file
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

        /// Payment provider token, obtained via [@BotFather](https://t.me/botfather)
        public var providerToken: String

        /// Three-letter ISO 4217 currency code, see more on currencies
        public var currency: String

        /// Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
        public var prices: [LabeledPrice]

        /// Optional. The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0
        public var maxTipAmount: Int?

        /// Optional. A JSON-serialized array of suggested amounts of tip in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
        public var suggestedTipAmounts: [Int]?

        /// Optional. A JSON-serialized object for data about the invoice, which will be shared with the payment provider. A detailed description of the required fields should be provided by the payment provider.
        public var providerData: String?

        /// Optional. URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service.
        public var photoUrl: String?

        /// Optional. Photo size in bytes
        public var photoSize: Int?

        /// Optional. Photo width
        public var photoWidth: Int?

        /// Optional. Photo height
        public var photoHeight: Int?

        /// Optional. Pass True if you require the user’s full name to complete the order
        public var needName: Bool?

        /// Optional. Pass True if you require the user’s phone number to complete the order
        public var needPhoneNumber: Bool?

        /// Optional. Pass True if you require the user’s email address to complete the order
        public var needEmail: Bool?

        /// Optional. Pass True if you require the user’s shipping address to complete the order
        public var needShippingAddress: Bool?

        /// Optional. Pass True if the user’s phone number should be sent to provider
        public var sendPhoneNumberToProvider: Bool?

        /// Optional. Pass True if the user’s email address should be sent to provider
        public var sendEmailToProvider: Bool?

        /// Optional. Pass True if the final price depends on the shipping method
        public var isFlexible: Bool?

        /// InputInvoiceMessageContent initialization
        ///
        /// - parameter title:  Product name, 1-32 characters
        /// - parameter description:  Product description, 1-255 characters
        /// - parameter payload:  Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use for your internal processes.
        /// - parameter providerToken:  Payment provider token, obtained via [@BotFather](https://t.me/botfather)
        /// - parameter currency:  Three-letter ISO 4217 currency code, see more on currencies
        /// - parameter prices:  Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
        /// - parameter maxTipAmount:  Optional. The maximum accepted amount for tips in the smallest units of the currency (integer, not float/double). For example, for a maximum tip of US$ 1.45 pass max_tip_amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0
        /// - parameter suggestedTipAmounts:  Optional. A JSON-serialized array of suggested amounts of tip in the smallest units of the currency (integer, not float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed max_tip_amount.
        /// - parameter providerData:  Optional. A JSON-serialized object for data about the invoice, which will be shared with the payment provider. A detailed description of the required fields should be provided by the payment provider.
        /// - parameter photoUrl:  Optional. URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service.
        /// - parameter photoSize:  Optional. Photo size in bytes
        /// - parameter photoWidth:  Optional. Photo width
        /// - parameter photoHeight:  Optional. Photo height
        /// - parameter needName:  Optional. Pass True if you require the user’s full name to complete the order
        /// - parameter needPhoneNumber:  Optional. Pass True if you require the user’s phone number to complete the order
        /// - parameter needEmail:  Optional. Pass True if you require the user’s email address to complete the order
        /// - parameter needShippingAddress:  Optional. Pass True if you require the user’s shipping address to complete the order
        /// - parameter sendPhoneNumberToProvider:  Optional. Pass True if the user’s phone number should be sent to provider
        /// - parameter sendEmailToProvider:  Optional. Pass True if the user’s email address should be sent to provider
        /// - parameter isFlexible:  Optional. Pass True if the final price depends on the shipping method
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

    /// Describes an inline message sent by a Web App on behalf of a user.
    public class SentWebAppMessage: Codable {

        /// Optional. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message.
        public var inlineMessageId: String?

        /// SentWebAppMessage initialization
        ///
        /// - parameter inlineMessageId:  Optional. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message.
        ///
        /// - returns: The new `SentWebAppMessage` instance.
        ///
        public init(inlineMessageId: String? = nil) {
            self.inlineMessageId = inlineMessageId
        }

        private enum CodingKeys: String, CodingKey {
            case inlineMessageId = "inline_message_id"
        }

    }

    /// This object represents a portion of the price for goods or services.
    public class LabeledPrice: Codable {

        /// Portion label
        public var label: String

        /// Price of the product in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var amount: Int

        /// LabeledPrice initialization
        ///
        /// - parameter label:  Portion label
        /// - parameter amount:  Price of the product in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
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

        /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var totalAmount: Int

        /// Invoice initialization
        ///
        /// - parameter title:  Product name
        /// - parameter description:  Product description
        /// - parameter startParameter:  Unique bot deep-linking parameter that can be used to generate this invoice
        /// - parameter currency:  Three-letter ISO 4217 currency code
        /// - parameter totalAmount:  Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
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

        /// Two-letter ISO 3166-1 alpha-2 country code
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
        /// - parameter countryCode:  Two-letter ISO 3166-1 alpha-2 country code
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

        /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var totalAmount: Int

        /// Bot specified invoice payload
        public var invoicePayload: String

        /// Optional. Identifier of the shipping option chosen by the user
        public var shippingOptionId: String?

        /// Optional. Order information provided by the user
        public var orderInfo: OrderInfo?

        /// Telegram payment identifier
        public var telegramPaymentChargeId: String

        /// Provider payment identifier
        public var providerPaymentChargeId: String

        /// SuccessfulPayment initialization
        ///
        /// - parameter currency:  Three-letter ISO 4217 currency code
        /// - parameter totalAmount:  Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        /// - parameter invoicePayload:  Bot specified invoice payload
        /// - parameter shippingOptionId:  Optional. Identifier of the shipping option chosen by the user
        /// - parameter orderInfo:  Optional. Order information provided by the user
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

        /// Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        public var totalAmount: Int

        /// Bot specified invoice payload
        public var invoicePayload: String

        /// Optional. Identifier of the shipping option chosen by the user
        public var shippingOptionId: String?

        /// Optional. Order information provided by the user
        public var orderInfo: OrderInfo?

        /// PreCheckoutQuery initialization
        ///
        /// - parameter id:  Unique query identifier
        /// - parameter from:  User who sent the query
        /// - parameter currency:  Three-letter ISO 4217 currency code
        /// - parameter totalAmount:  Total price in the smallest units of the currency (integer, not float/double). For example, for a price of US$ 1.45 pass amount = 145. See the exp parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
        /// - parameter invoicePayload:  Bot specified invoice payload
        /// - parameter shippingOptionId:  Optional. Identifier of the shipping option chosen by the user
        /// - parameter orderInfo:  Optional. Order information provided by the user
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

    /// Describes Telegram Passport data shared with the bot by the user.
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

        /// File size in bytes
        public var fileSize: Int

        /// Unix time when the file was uploaded
        public var fileDate: Int

        /// PassportFile initialization
        ///
        /// - parameter fileId:  Identifier for this file, which can be used to download or reuse the file
        /// - parameter fileUniqueId:  Unique identifier for this file, which is supposed to be the same over time and for different bots. Can’t be used to download or reuse the file.
        /// - parameter fileSize:  File size in bytes
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

    /// Describes documents or other Telegram Passport elements shared with the bot by the user.
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

    /// Describes data required for decrypting and authenticating EncryptedPassportElement. See the Telegram Passport Documentation for a complete description of the data decryption and authentication processes.
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
