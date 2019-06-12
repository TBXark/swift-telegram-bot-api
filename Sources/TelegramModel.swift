import Foundation

extension TelegramAPI {

    /// Telegram Request wrapper
    public struct Request {
        public let method: String
        public let body: [String: Any]
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
                throw NSError(domain: "ReplyMarkup", code: -1, userInfo: nil)
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
                throw NSError(domain: "ChatId", code: -1, userInfo: nil)
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
                throw NSError(domain: "FileOrPath", code: -1, userInfo: nil)
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

        /// The update‘s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
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

        /// Update initialization
        ///
        /// - parameter updateId:  The update‘s unique identifier. Update identifiers start from a certain positive number and increase sequentially. This ID becomes especially handy if you’re using Webhooks, since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.
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
        ///
        /// - returns: The new `Update` instance.
        ///
        public init(updateId: Int, message: Message? = nil, editedMessage: Message? = nil, channelPost: Message? = nil, editedChannelPost: Message? = nil, inlineQuery: InlineQuery? = nil, chosenInlineResult: ChosenInlineResult? = nil, callbackQuery: CallbackQuery? = nil, shippingQuery: ShippingQuery? = nil, preCheckoutQuery: PreCheckoutQuery? = nil, poll: Poll? = nil) {
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

        /// Optional. Unix time for the most recent error that happened when trying to deliver an update via webhook
        public var lastErrorDate: Int?

        /// Optional. Error message in human-readable format for the most recent error that happened when trying to deliver an update via webhook
        public var lastErrorMessage: String?

        /// Optional. Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
        public var maxConnections: Int?

        /// Optional. A list of update types the bot is subscribed to. Defaults to all update types
        public var allowedUpdates: [String]?

        /// WebhookInfo initialization
        ///
        /// - parameter url:  Webhook URL, may be empty if webhook is not set up
        /// - parameter hasCustomCertificate:  True, if a custom certificate was provided for webhook certificate checks
        /// - parameter pendingUpdateCount:  Number of updates awaiting delivery
        /// - parameter lastErrorDate:  Optional. Unix time for the most recent error that happened when trying to deliver an update via webhook
        /// - parameter lastErrorMessage:  Optional. Error message in human-readable format for the most recent error that happened when trying to deliver an update via webhook
        /// - parameter maxConnections:  Optional. Maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery
        /// - parameter allowedUpdates:  Optional. A list of update types the bot is subscribed to. Defaults to all update types
        ///
        /// - returns: The new `WebhookInfo` instance.
        ///
        public init(url: String, hasCustomCertificate: Bool, pendingUpdateCount: Int, lastErrorDate: Int? = nil, lastErrorMessage: String? = nil, maxConnections: Int? = nil, allowedUpdates: [String]? = nil) {
            self.url = url
            self.hasCustomCertificate = hasCustomCertificate
            self.pendingUpdateCount = pendingUpdateCount
            self.lastErrorDate = lastErrorDate
            self.lastErrorMessage = lastErrorMessage
            self.maxConnections = maxConnections
            self.allowedUpdates = allowedUpdates
        }

        private enum CodingKeys: String, CodingKey {
            case url = "url"
            case hasCustomCertificate = "has_custom_certificate"
            case pendingUpdateCount = "pending_update_count"
            case lastErrorDate = "last_error_date"
            case lastErrorMessage = "last_error_message"
            case maxConnections = "max_connections"
            case allowedUpdates = "allowed_updates"
        }

    }

    /// This object represents a Telegram user or bot.
    public class User: Codable {

        /// Unique identifier for this user or bot
        public var id: Int

        /// True, if this user is a bot
        public var isBot: Bool

        /// User‘s or bot’s first name
        public var firstName: String

        /// Optional. User‘s or bot’s last name
        public var lastName: String?

        /// Optional. User‘s or bot’s username
        public var username: String?

        /// Optional. [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) of the user&#39;s language
        public var languageCode: String?

        /// User initialization
        ///
        /// - parameter id:  Unique identifier for this user or bot
        /// - parameter isBot:  True, if this user is a bot
        /// - parameter firstName:  User‘s or bot’s first name
        /// - parameter lastName:  Optional. User‘s or bot’s last name
        /// - parameter username:  Optional. User‘s or bot’s username
        /// - parameter languageCode:  Optional. [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) of the user&#39;s language
        ///
        /// - returns: The new `User` instance.
        ///
        public init(id: Int, isBot: Bool, firstName: String, lastName: String? = nil, username: String? = nil, languageCode: String? = nil) {
            self.id = id
            self.isBot = isBot
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.languageCode = languageCode
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case isBot = "is_bot"
            case firstName = "first_name"
            case lastName = "last_name"
            case username = "username"
            case languageCode = "language_code"
        }

    }

    /// This object represents a chat.
    public class Chat: Codable {

        /// Unique identifier for this chat. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
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

        /// Optional. True if a group has ‘All Members Are Admins’ enabled.
        public var allMembersAreAdministrators: Bool?

        /// Optional. Chat photo. Returned only in getChat.
        public var photo: ChatPhoto?

        /// Optional. Description, for supergroups and channel chats. Returned only in getChat.
        public var description: String?

        /// Optional. Chat invite link, for supergroups and channel chats. Each administrator in a chat generates their own invite links, so the bot must first generate the link using exportChatInviteLink. Returned only in getChat.
        public var inviteLink: String?

        /// Optional. Pinned message, for groups, supergroups and channels. Returned only in getChat.
        public var pinnedMessage: Message?

        /// Optional. For supergroups, name of group sticker set. Returned only in getChat.
        public var stickerSetName: String?

        /// Optional. True, if the bot can change the group sticker set. Returned only in getChat.
        public var canSetStickerSet: Bool?

        /// Chat initialization
        ///
        /// - parameter id:  Unique identifier for this chat. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter type:  Type of chat, can be either “private”, “group”, “supergroup” or “channel”
        /// - parameter title:  Optional. Title, for supergroups, channels and group chats
        /// - parameter username:  Optional. Username, for private chats, supergroups and channels if available
        /// - parameter firstName:  Optional. First name of the other party in a private chat
        /// - parameter lastName:  Optional. Last name of the other party in a private chat
        /// - parameter allMembersAreAdministrators:  Optional. True if a group has ‘All Members Are Admins’ enabled.
        /// - parameter photo:  Optional. Chat photo. Returned only in getChat.
        /// - parameter description:  Optional. Description, for supergroups and channel chats. Returned only in getChat.
        /// - parameter inviteLink:  Optional. Chat invite link, for supergroups and channel chats. Each administrator in a chat generates their own invite links, so the bot must first generate the link using exportChatInviteLink. Returned only in getChat.
        /// - parameter pinnedMessage:  Optional. Pinned message, for groups, supergroups and channels. Returned only in getChat.
        /// - parameter stickerSetName:  Optional. For supergroups, name of group sticker set. Returned only in getChat.
        /// - parameter canSetStickerSet:  Optional. True, if the bot can change the group sticker set. Returned only in getChat.
        ///
        /// - returns: The new `Chat` instance.
        ///
        public init(id: Int, type: String, title: String? = nil, username: String? = nil, firstName: String? = nil, lastName: String? = nil, allMembersAreAdministrators: Bool? = nil, photo: ChatPhoto? = nil, description: String? = nil, inviteLink: String? = nil, pinnedMessage: Message? = nil, stickerSetName: String? = nil, canSetStickerSet: Bool? = nil) {
            self.id = id
            self.type = type
            self.title = title
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
            self.allMembersAreAdministrators = allMembersAreAdministrators
            self.photo = photo
            self.description = description
            self.inviteLink = inviteLink
            self.pinnedMessage = pinnedMessage
            self.stickerSetName = stickerSetName
            self.canSetStickerSet = canSetStickerSet
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case type = "type"
            case title = "title"
            case username = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case allMembersAreAdministrators = "all_members_are_administrators"
            case photo = "photo"
            case description = "description"
            case inviteLink = "invite_link"
            case pinnedMessage = "pinned_message"
            case stickerSetName = "sticker_set_name"
            case canSetStickerSet = "can_set_sticker_set"
        }

    }

    /// This object represents a message.
    public class Message: Codable {

        /// Unique message identifier inside this chat
        public var messageId: Int

        /// Optional. Sender, empty for messages sent to channels
        public var from: User?

        /// Date the message was sent in Unix time
        public var date: Int

        /// Conversation the message belongs to
        public var chat: Chat

        /// Optional. For forwarded messages, sender of the original message
        public var forwardFrom: User?

        /// Optional. For messages forwarded from channels, information about the original channel
        public var forwardFromChat: Chat?

        /// Optional. For messages forwarded from channels, identifier of the original message in the channel
        public var forwardFromMessageId: Int?

        /// Optional. For messages forwarded from channels, signature of the post author if present
        public var forwardSignature: String?

        /// Optional. Sender&#39;s name for messages forwarded from users who disallow adding a link to their account in forwarded messages
        public var forwardSenderName: String?

        /// Optional. For forwarded messages, date the original message was sent in Unix time
        public var forwardDate: Int?

        /// Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
        public var replyToMessage: Message?

        /// Optional. Date the message was last edited in Unix time
        public var editDate: Int?

        /// Optional. The unique identifier of a media message group this message belongs to
        public var mediaGroupId: String?

        /// Optional. Signature of the post author for messages in channels
        public var authorSignature: String?

        /// Optional. For text messages, the actual UTF-8 text of the message, 0-4096 characters.
        public var text: String?

        /// Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
        public var entities: [MessageEntity]?

        /// Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
        public var captionEntities: [MessageEntity]?

        /// Optional. Message is an audio file, information about the file
        public var audio: Audio?

        /// Optional. Message is a general file, information about the file
        public var document: Document?

        /// Optional. Message is an animation, information about the animation. For backward compatibility, when this field is set, the document field will also be set
        public var animation: Animation?

        /// Optional. Message is a game, information about the game. More about games »
        public var game: Game?

        /// Optional. Message is a photo, available sizes of the photo
        public var photo: [PhotoSize]?

        /// Optional. Message is a sticker, information about the sticker
        public var sticker: Sticker?

        /// Optional. Message is a video, information about the video
        public var video: Video?

        /// Optional. Message is a voice message, information about the file
        public var voice: Voice?

        /// Optional. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message
        public var videoNote: VideoNote?

        /// Optional. Caption for the animation, audio, document, photo, video or voice, 0-1024 characters
        public var caption: String?

        /// Optional. Message is a shared contact, information about the contact
        public var contact: Contact?

        /// Optional. Message is a shared location, information about the location
        public var location: Location?

        /// Optional. Message is a venue, information about the venue
        public var venue: Venue?

        /// Optional. Message is a native poll, information about the poll
        public var poll: Poll?

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

        /// Optional. Service message: the supergroup has been created. This field can‘t be received in a message coming through updates, because bot can’t be a member of a supergroup when it is created. It can only be found in reply_to_message if someone replies to a very first message in a directly created supergroup.
        public var supergroupChatCreated: Bool?

        /// Optional. Service message: the channel has been created. This field can‘t be received in a message coming through updates, because bot can’t be a member of a channel when it is created. It can only be found in reply_to_message if someone replies to a very first message in a channel.
        public var channelChatCreated: Bool?

        /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
        public var migrateToChatId: Int?

        /// Optional. The supergroup has been migrated from a group with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
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

        /// Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
        public var replyMarkup: InlineKeyboardMarkup?

        /// Message initialization
        ///
        /// - parameter messageId:  Unique message identifier inside this chat
        /// - parameter from:  Optional. Sender, empty for messages sent to channels
        /// - parameter date:  Date the message was sent in Unix time
        /// - parameter chat:  Conversation the message belongs to
        /// - parameter forwardFrom:  Optional. For forwarded messages, sender of the original message
        /// - parameter forwardFromChat:  Optional. For messages forwarded from channels, information about the original channel
        /// - parameter forwardFromMessageId:  Optional. For messages forwarded from channels, identifier of the original message in the channel
        /// - parameter forwardSignature:  Optional. For messages forwarded from channels, signature of the post author if present
        /// - parameter forwardSenderName:  Optional. Sender&#39;s name for messages forwarded from users who disallow adding a link to their account in forwarded messages
        /// - parameter forwardDate:  Optional. For forwarded messages, date the original message was sent in Unix time
        /// - parameter replyToMessage:  Optional. For replies, the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
        /// - parameter editDate:  Optional. Date the message was last edited in Unix time
        /// - parameter mediaGroupId:  Optional. The unique identifier of a media message group this message belongs to
        /// - parameter authorSignature:  Optional. Signature of the post author for messages in channels
        /// - parameter text:  Optional. For text messages, the actual UTF-8 text of the message, 0-4096 characters.
        /// - parameter entities:  Optional. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text
        /// - parameter captionEntities:  Optional. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption
        /// - parameter audio:  Optional. Message is an audio file, information about the file
        /// - parameter document:  Optional. Message is a general file, information about the file
        /// - parameter animation:  Optional. Message is an animation, information about the animation. For backward compatibility, when this field is set, the document field will also be set
        /// - parameter game:  Optional. Message is a game, information about the game. More about games »
        /// - parameter photo:  Optional. Message is a photo, available sizes of the photo
        /// - parameter sticker:  Optional. Message is a sticker, information about the sticker
        /// - parameter video:  Optional. Message is a video, information about the video
        /// - parameter voice:  Optional. Message is a voice message, information about the file
        /// - parameter videoNote:  Optional. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message
        /// - parameter caption:  Optional. Caption for the animation, audio, document, photo, video or voice, 0-1024 characters
        /// - parameter contact:  Optional. Message is a shared contact, information about the contact
        /// - parameter location:  Optional. Message is a shared location, information about the location
        /// - parameter venue:  Optional. Message is a venue, information about the venue
        /// - parameter poll:  Optional. Message is a native poll, information about the poll
        /// - parameter newChatMembers:  Optional. New members that were added to the group or supergroup and information about them (the bot itself may be one of these members)
        /// - parameter leftChatMember:  Optional. A member was removed from the group, information about them (this member may be the bot itself)
        /// - parameter newChatTitle:  Optional. A chat title was changed to this value
        /// - parameter newChatPhoto:  Optional. A chat photo was change to this value
        /// - parameter deleteChatPhoto:  Optional. Service message: the chat photo was deleted
        /// - parameter groupChatCreated:  Optional. Service message: the group has been created
        /// - parameter supergroupChatCreated:  Optional. Service message: the supergroup has been created. This field can‘t be received in a message coming through updates, because bot can’t be a member of a supergroup when it is created. It can only be found in reply_to_message if someone replies to a very first message in a directly created supergroup.
        /// - parameter channelChatCreated:  Optional. Service message: the channel has been created. This field can‘t be received in a message coming through updates, because bot can’t be a member of a channel when it is created. It can only be found in reply_to_message if someone replies to a very first message in a channel.
        /// - parameter migrateToChatId:  Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter migrateFromChatId:  Optional. The supergroup has been migrated from a group with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
        /// - parameter pinnedMessage:  Optional. Specified message was pinned. Note that the Message object in this field will not contain further reply_to_message fields even if it is itself a reply.
        /// - parameter invoice:  Optional. Message is an invoice for a payment, information about the invoice. More about payments »
        /// - parameter successfulPayment:  Optional. Message is a service message about a successful payment, information about the payment. More about payments »
        /// - parameter connectedWebsite:  Optional. The domain name of the website on which the user has logged in. More about Telegram Login »
        /// - parameter passportData:  Optional. Telegram Passport data
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message. login_url buttons are represented as ordinary url buttons.
        ///
        /// - returns: The new `Message` instance.
        ///
        public init(messageId: Int, from: User? = nil, date: Int, chat: Chat, forwardFrom: User? = nil, forwardFromChat: Chat? = nil, forwardFromMessageId: Int? = nil, forwardSignature: String? = nil, forwardSenderName: String? = nil, forwardDate: Int? = nil, replyToMessage: Message? = nil, editDate: Int? = nil, mediaGroupId: String? = nil, authorSignature: String? = nil, text: String? = nil, entities: [MessageEntity]? = nil, captionEntities: [MessageEntity]? = nil, audio: Audio? = nil, document: Document? = nil, animation: Animation? = nil, game: Game? = nil, photo: [PhotoSize]? = nil, sticker: Sticker? = nil, video: Video? = nil, voice: Voice? = nil, videoNote: VideoNote? = nil, caption: String? = nil, contact: Contact? = nil, location: Location? = nil, venue: Venue? = nil, poll: Poll? = nil, newChatMembers: [User]? = nil, leftChatMember: User? = nil, newChatTitle: String? = nil, newChatPhoto: [PhotoSize]? = nil, deleteChatPhoto: Bool? = nil, groupChatCreated: Bool? = nil, supergroupChatCreated: Bool? = nil, channelChatCreated: Bool? = nil, migrateToChatId: Int? = nil, migrateFromChatId: Int? = nil, pinnedMessage: Message? = nil, invoice: Invoice? = nil, successfulPayment: SuccessfulPayment? = nil, connectedWebsite: String? = nil, passportData: PassportData? = nil, replyMarkup: InlineKeyboardMarkup? = nil) {
            self.messageId = messageId
            self.from = from
            self.date = date
            self.chat = chat
            self.forwardFrom = forwardFrom
            self.forwardFromChat = forwardFromChat
            self.forwardFromMessageId = forwardFromMessageId
            self.forwardSignature = forwardSignature
            self.forwardSenderName = forwardSenderName
            self.forwardDate = forwardDate
            self.replyToMessage = replyToMessage
            self.editDate = editDate
            self.mediaGroupId = mediaGroupId
            self.authorSignature = authorSignature
            self.text = text
            self.entities = entities
            self.captionEntities = captionEntities
            self.audio = audio
            self.document = document
            self.animation = animation
            self.game = game
            self.photo = photo
            self.sticker = sticker
            self.video = video
            self.voice = voice
            self.videoNote = videoNote
            self.caption = caption
            self.contact = contact
            self.location = location
            self.venue = venue
            self.poll = poll
            self.newChatMembers = newChatMembers
            self.leftChatMember = leftChatMember
            self.newChatTitle = newChatTitle
            self.newChatPhoto = newChatPhoto
            self.deleteChatPhoto = deleteChatPhoto
            self.groupChatCreated = groupChatCreated
            self.supergroupChatCreated = supergroupChatCreated
            self.channelChatCreated = channelChatCreated
            self.migrateToChatId = migrateToChatId
            self.migrateFromChatId = migrateFromChatId
            self.pinnedMessage = pinnedMessage
            self.invoice = invoice
            self.successfulPayment = successfulPayment
            self.connectedWebsite = connectedWebsite
            self.passportData = passportData
            self.replyMarkup = replyMarkup
        }

        private enum CodingKeys: String, CodingKey {
            case messageId = "message_id"
            case from = "from"
            case date = "date"
            case chat = "chat"
            case forwardFrom = "forward_from"
            case forwardFromChat = "forward_from_chat"
            case forwardFromMessageId = "forward_from_message_id"
            case forwardSignature = "forward_signature"
            case forwardSenderName = "forward_sender_name"
            case forwardDate = "forward_date"
            case replyToMessage = "reply_to_message"
            case editDate = "edit_date"
            case mediaGroupId = "media_group_id"
            case authorSignature = "author_signature"
            case text = "text"
            case entities = "entities"
            case captionEntities = "caption_entities"
            case audio = "audio"
            case document = "document"
            case animation = "animation"
            case game = "game"
            case photo = "photo"
            case sticker = "sticker"
            case video = "video"
            case voice = "voice"
            case videoNote = "video_note"
            case caption = "caption"
            case contact = "contact"
            case location = "location"
            case venue = "venue"
            case poll = "poll"
            case newChatMembers = "new_chat_members"
            case leftChatMember = "left_chat_member"
            case newChatTitle = "new_chat_title"
            case newChatPhoto = "new_chat_photo"
            case deleteChatPhoto = "delete_chat_photo"
            case groupChatCreated = "group_chat_created"
            case supergroupChatCreated = "supergroup_chat_created"
            case channelChatCreated = "channel_chat_created"
            case migrateToChatId = "migrate_to_chat_id"
            case migrateFromChatId = "migrate_from_chat_id"
            case pinnedMessage = "pinned_message"
            case invoice = "invoice"
            case successfulPayment = "successful_payment"
            case connectedWebsite = "connected_website"
            case passportData = "passport_data"
            case replyMarkup = "reply_markup"
        }

    }

    /// This object represents one special entity in a text message. For example, hashtags, usernames, URLs, etc.
    public class MessageEntity: Codable {

        /// Type of the entity. Can be mention (@username), hashtag, cashtag, bot_command, url, email, phone_number, bold (bold text), italic (italic text), code (monowidth string), pre (monowidth block), text_link (for clickable text URLs), text_mention (for users [without usernames](https://telegram.org/blog/edit#new-mentions))
        public var type: String

        /// Offset in UTF-16 code units to the start of the entity
        public var offset: Int

        /// Length of the entity in UTF-16 code units
        public var length: Int

        /// Optional. For “text_link” only, url that will be opened after user taps on the text
        public var url: String?

        /// Optional. For “text_mention” only, the mentioned user
        public var user: User?

        /// MessageEntity initialization
        ///
        /// - parameter type:  Type of the entity. Can be mention (@username), hashtag, cashtag, bot_command, url, email, phone_number, bold (bold text), italic (italic text), code (monowidth string), pre (monowidth block), text_link (for clickable text URLs), text_mention (for users [without usernames](https://telegram.org/blog/edit#new-mentions))
        /// - parameter offset:  Offset in UTF-16 code units to the start of the entity
        /// - parameter length:  Length of the entity in UTF-16 code units
        /// - parameter url:  Optional. For “text_link” only, url that will be opened after user taps on the text
        /// - parameter user:  Optional. For “text_mention” only, the mentioned user
        ///
        /// - returns: The new `MessageEntity` instance.
        ///
        public init(type: String, offset: Int, length: Int, url: String? = nil, user: User? = nil) {
            self.type = type
            self.offset = offset
            self.length = length
            self.url = url
            self.user = user
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case offset = "offset"
            case length = "length"
            case url = "url"
            case user = "user"
        }

    }

    /// This object represents one size of a photo or a file / sticker thumbnail.
    public class PhotoSize: Codable {

        /// Unique identifier for this file
        public var fileId: String

        /// Photo width
        public var width: Int

        /// Photo height
        public var height: Int

        /// Optional. File size
        public var fileSize: Int?

        /// PhotoSize initialization
        ///
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter width:  Photo width
        /// - parameter height:  Photo height
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `PhotoSize` instance.
        ///
        public init(fileId: String, width: Int, height: Int, fileSize: Int? = nil) {
            self.fileId = fileId
            self.width = width
            self.height = height
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case width = "width"
            case height = "height"
            case fileSize = "file_size"
        }

    }

    /// This object represents an audio file to be treated as music by the Telegram clients.
    public class Audio: Codable {

        /// Unique identifier for this file
        public var fileId: String

        /// Duration of the audio in seconds as defined by sender
        public var duration: Int

        /// Optional. Performer of the audio as defined by sender or by audio tags
        public var performer: String?

        /// Optional. Title of the audio as defined by sender or by audio tags
        public var title: String?

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Optional. Thumbnail of the album cover to which the music file belongs
        public var thumb: PhotoSize?

        /// Audio initialization
        ///
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter duration:  Duration of the audio in seconds as defined by sender
        /// - parameter performer:  Optional. Performer of the audio as defined by sender or by audio tags
        /// - parameter title:  Optional. Title of the audio as defined by sender or by audio tags
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        /// - parameter thumb:  Optional. Thumbnail of the album cover to which the music file belongs
        ///
        /// - returns: The new `Audio` instance.
        ///
        public init(fileId: String, duration: Int, performer: String? = nil, title: String? = nil, mimeType: String? = nil, fileSize: Int? = nil, thumb: PhotoSize? = nil) {
            self.fileId = fileId
            self.duration = duration
            self.performer = performer
            self.title = title
            self.mimeType = mimeType
            self.fileSize = fileSize
            self.thumb = thumb
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case duration = "duration"
            case performer = "performer"
            case title = "title"
            case mimeType = "mime_type"
            case fileSize = "file_size"
            case thumb = "thumb"
        }

    }

    /// This object represents a general file (as opposed to photos, voice messages and audio files).
    public class Document: Codable {

        /// Unique file identifier
        public var fileId: String

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
        /// - parameter fileId:  Unique file identifier
        /// - parameter thumb:  Optional. Document thumbnail as defined by sender
        /// - parameter fileName:  Optional. Original filename as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Document` instance.
        ///
        public init(fileId: String, thumb: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.thumb = thumb
            self.fileName = fileName
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case thumb = "thumb"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a video file.
    public class Video: Codable {

        /// Unique identifier for this file
        public var fileId: String

        /// Video width as defined by sender
        public var width: Int

        /// Video height as defined by sender
        public var height: Int

        /// Duration of the video in seconds as defined by sender
        public var duration: Int

        /// Optional. Video thumbnail
        public var thumb: PhotoSize?

        /// Optional. Mime type of a file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Video initialization
        ///
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter width:  Video width as defined by sender
        /// - parameter height:  Video height as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumb:  Optional. Video thumbnail
        /// - parameter mimeType:  Optional. Mime type of a file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Video` instance.
        ///
        public init(fileId: String, width: Int, height: Int, duration: Int, thumb: PhotoSize? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.width = width
            self.height = height
            self.duration = duration
            self.thumb = thumb
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case width = "width"
            case height = "height"
            case duration = "duration"
            case thumb = "thumb"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents an animation file (GIF or H.264/MPEG-4 AVC video without sound).
    public class Animation: Codable {

        /// Unique file identifier
        public var fileId: String

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
        /// - parameter fileId:  Unique file identifier
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
        public init(fileId: String, width: Int, height: Int, duration: Int, thumb: PhotoSize? = nil, fileName: String? = nil, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
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
            case width = "width"
            case height = "height"
            case duration = "duration"
            case thumb = "thumb"
            case fileName = "file_name"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a voice note.
    public class Voice: Codable {

        /// Unique identifier for this file
        public var fileId: String

        /// Duration of the audio in seconds as defined by sender
        public var duration: Int

        /// Optional. MIME type of the file as defined by sender
        public var mimeType: String?

        /// Optional. File size
        public var fileSize: Int?

        /// Voice initialization
        ///
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter duration:  Duration of the audio in seconds as defined by sender
        /// - parameter mimeType:  Optional. MIME type of the file as defined by sender
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Voice` instance.
        ///
        public init(fileId: String, duration: Int, mimeType: String? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.duration = duration
            self.mimeType = mimeType
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case duration = "duration"
            case mimeType = "mime_type"
            case fileSize = "file_size"
        }

    }

    /// This object represents a [video message](https://telegram.org/blog/video-messages-and-telescope) (available in Telegram apps as of [v.4.0](https://telegram.org/blog/video-messages-and-telescope)).
    public class VideoNote: Codable {

        /// Unique identifier for this file
        public var fileId: String

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
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter length:  Video width and height (diameter of the video message) as defined by sender
        /// - parameter duration:  Duration of the video in seconds as defined by sender
        /// - parameter thumb:  Optional. Video thumbnail
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `VideoNote` instance.
        ///
        public init(fileId: String, length: Int, duration: Int, thumb: PhotoSize? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.length = length
            self.duration = duration
            self.thumb = thumb
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case length = "length"
            case duration = "duration"
            case thumb = "thumb"
            case fileSize = "file_size"
        }

    }

    /// This object represents a phone contact.
    public class Contact: Codable {

        /// Contact&#39;s phone number
        public var phoneNumber: String

        /// Contact&#39;s first name
        public var firstName: String

        /// Optional. Contact&#39;s last name
        public var lastName: String?

        /// Optional. Contact&#39;s user identifier in Telegram
        public var userId: Int?

        /// Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard)
        public var vcard: String?

        /// Contact initialization
        ///
        /// - parameter phoneNumber:  Contact&#39;s phone number
        /// - parameter firstName:  Contact&#39;s first name
        /// - parameter lastName:  Optional. Contact&#39;s last name
        /// - parameter userId:  Optional. Contact&#39;s user identifier in Telegram
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

    /// This object represents a point on the map.
    public class Location: Codable {

        /// Longitude as defined by sender
        public var longitude: Float

        /// Latitude as defined by sender
        public var latitude: Float

        /// Location initialization
        ///
        /// - parameter longitude:  Longitude as defined by sender
        /// - parameter latitude:  Latitude as defined by sender
        ///
        /// - returns: The new `Location` instance.
        ///
        public init(longitude: Float, latitude: Float) {
            self.longitude = longitude
            self.latitude = latitude
        }

        private enum CodingKeys: String, CodingKey {
            case longitude = "longitude"
            case latitude = "latitude"
        }

    }

    /// This object represents a venue.
    public class Venue: Codable {

        /// Venue location
        public var location: Location

        /// Name of the venue
        public var title: String

        /// Address of the venue
        public var address: String

        /// Optional. Foursquare identifier of the venue
        public var foursquareId: String?

        /// Optional. Foursquare type of the venue. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        public var foursquareType: String?

        /// Venue initialization
        ///
        /// - parameter location:  Venue location
        /// - parameter title:  Name of the venue
        /// - parameter address:  Address of the venue
        /// - parameter foursquareId:  Optional. Foursquare identifier of the venue
        /// - parameter foursquareType:  Optional. Foursquare type of the venue. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        ///
        /// - returns: The new `Venue` instance.
        ///
        public init(location: Location, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil) {
            self.location = location
            self.title = title
            self.address = address
            self.foursquareId = foursquareId
            self.foursquareType = foursquareType
        }

        private enum CodingKeys: String, CodingKey {
            case location = "location"
            case title = "title"
            case address = "address"
            case foursquareId = "foursquare_id"
            case foursquareType = "foursquare_type"
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

    /// This object contains information about a poll.
    public class Poll: Codable {

        /// Unique poll identifier
        public var id: String

        /// Poll question, 1-255 characters
        public var question: String

        /// List of poll options
        public var options: [PollOption]

        /// True, if the poll is closed
        public var isClosed: Bool

        /// Poll initialization
        ///
        /// - parameter id:  Unique poll identifier
        /// - parameter question:  Poll question, 1-255 characters
        /// - parameter options:  List of poll options
        /// - parameter isClosed:  True, if the poll is closed
        ///
        /// - returns: The new `Poll` instance.
        ///
        public init(id: String, question: String, options: [PollOption], isClosed: Bool) {
            self.id = id
            self.question = question
            self.options = options
            self.isClosed = isClosed
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case question = "question"
            case options = "options"
            case isClosed = "is_closed"
        }

    }

    /// This object represent a user&#39;s profile pictures.
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

        /// Unique identifier for this file
        public var fileId: String

        /// Optional. File size, if known
        public var fileSize: Int?

        /// Optional. File path. Use https://api.telegram.org/file/bot&lt;token&gt;/&lt;file_path&gt; to get the file.
        public var filePath: String?

        /// File initialization
        ///
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter fileSize:  Optional. File size, if known
        /// - parameter filePath:  Optional. File path. Use https://api.telegram.org/file/bot&lt;token&gt;/&lt;file_path&gt; to get the file.
        ///
        /// - returns: The new `File` instance.
        ///
        public init(fileId: String, fileSize: Int? = nil, filePath: String? = nil) {
            self.fileId = fileId
            self.fileSize = fileSize
            self.filePath = filePath
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case fileSize = "file_size"
            case filePath = "file_path"
        }

    }

    /// This object represents a [custom keyboard](https://core.telegram.org/bots#keyboards) with reply options (see [Introduction to bots](https://core.telegram.org/bots#keyboards) for details and examples).
    public class ReplyKeyboardMarkup: Codable {

        /// Array of button rows, each represented by an Array of KeyboardButton objects
        public var keyboard: [KeyboardButton]

        /// Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app&#39;s standard keyboard.
        public var resizeKeyboard: Bool?

        /// Optional. Requests clients to hide the keyboard as soon as it&#39;s been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat – the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
        public var oneTimeKeyboard: Bool?

        /// Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot&#39;s message is a reply (has reply_to_message_id), sender of the original message.Example: A user requests to change the bot‘s language, bot replies to the request with a keyboard to select the new language. Other users in the group don’t see the keyboard.
        public var selective: Bool?

        /// ReplyKeyboardMarkup initialization
        ///
        /// - parameter keyboard:  Array of button rows, each represented by an Array of KeyboardButton objects
        /// - parameter resizeKeyboard:  Optional. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to false, in which case the custom keyboard is always of the same height as the app&#39;s standard keyboard.
        /// - parameter oneTimeKeyboard:  Optional. Requests clients to hide the keyboard as soon as it&#39;s been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat – the user can press a special button in the input field to see the custom keyboard again. Defaults to false.
        /// - parameter selective:  Optional. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot&#39;s message is a reply (has reply_to_message_id), sender of the original message.Example: A user requests to change the bot‘s language, bot replies to the request with a keyboard to select the new language. Other users in the group don’t see the keyboard.
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

    /// This object represents one button of the reply keyboard. For simple text buttons String can be used instead of this object to specify text of the button. Optional fields are mutually exclusive.
    public class KeyboardButton: Codable {

        /// Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed
        public var text: String

        /// Optional. If True, the user&#39;s phone number will be sent as a contact when the button is pressed. Available in private chats only
        public var requestContact: Bool?

        /// Optional. If True, the user&#39;s current location will be sent when the button is pressed. Available in private chats only
        public var requestLocation: Bool?

        /// KeyboardButton initialization
        ///
        /// - parameter text:  Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed
        /// - parameter requestContact:  Optional. If True, the user&#39;s phone number will be sent as a contact when the button is pressed. Available in private chats only
        /// - parameter requestLocation:  Optional. If True, the user&#39;s current location will be sent when the button is pressed. Available in private chats only
        ///
        /// - returns: The new `KeyboardButton` instance.
        ///
        public init(text: String, requestContact: Bool? = nil, requestLocation: Bool? = nil) {
            self.text = text
            self.requestContact = requestContact
            self.requestLocation = requestLocation
        }

        private enum CodingKeys: String, CodingKey {
            case text = "text"
            case requestContact = "request_contact"
            case requestLocation = "request_location"
        }

    }

    /// Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard. By default, custom keyboards are displayed until a new keyboard is sent by a bot. An exception is made for one-time keyboards that are hidden immediately after the user presses a button (see ReplyKeyboardMarkup).
    public class ReplyKeyboardRemove: Codable {

        /// Requests clients to remove the custom keyboard (user will not be able to summon this keyboard; if you want to hide the keyboard from sight but keep it accessible, use one_time_keyboard in ReplyKeyboardMarkup)
        public var removeKeyboard: Bool

        /// Optional. Use this parameter if you want to remove the keyboard for specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot&#39;s message is a reply (has reply_to_message_id), sender of the original message.Example: A user votes in a poll, bot returns confirmation message in reply to the vote and removes the keyboard for that user, while still showing the keyboard with poll options to users who haven&#39;t voted yet.
        public var selective: Bool?

        /// ReplyKeyboardRemove initialization
        ///
        /// - parameter removeKeyboard:  Requests clients to remove the custom keyboard (user will not be able to summon this keyboard; if you want to hide the keyboard from sight but keep it accessible, use one_time_keyboard in ReplyKeyboardMarkup)
        /// - parameter selective:  Optional. Use this parameter if you want to remove the keyboard for specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot&#39;s message is a reply (has reply_to_message_id), sender of the original message.Example: A user votes in a poll, bot returns confirmation message in reply to the vote and removes the keyboard for that user, while still showing the keyboard with poll options to users who haven&#39;t voted yet.
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

        /// Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot‘s username and the specified inline query in the input field. Can be empty, in which case just the bot’s username will be inserted.Note: This offers an easy way for users to start using your bot in inline mode when they are currently in a private chat with it. Especially useful when combined with switch_pm… actions – in this case the user will be automatically returned to the chat they switched from, skipping the chat selection screen.
        public var switchInlineQuery: String?

        /// Optional. If set, pressing the button will insert the bot‘s username and the specified inline query in the current chat&#39;s input field. Can be empty, in which case only the bot’s username will be inserted.This offers a quick way for the user to open your bot in inline mode in the same chat – good for selecting something from multiple options.
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
        /// - parameter switchInlineQuery:  Optional. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot‘s username and the specified inline query in the input field. Can be empty, in which case just the bot’s username will be inserted.Note: This offers an easy way for users to start using your bot in inline mode when they are currently in a private chat with it. Especially useful when combined with switch_pm… actions – in this case the user will be automatically returned to the chat they switched from, skipping the chat selection screen.
        /// - parameter switchInlineQueryCurrentChat:  Optional. If set, pressing the button will insert the bot‘s username and the specified inline query in the current chat&#39;s input field. Can be empty, in which case only the bot’s username will be inserted.This offers a quick way for the user to open your bot in inline mode in the same chat – good for selecting something from multiple options.
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

        /// Optional. Username of a bot, which will be used for user authorization. See [Setting up a bot](https://core.telegram.org/widgets/login#setting-up-a-bot) for more details. If not specified, the current bot&#39;s username will be assumed. The url&#39;s domain must be the same as the domain linked with the bot. See [Linking your domain to the bot](https://core.telegram.org/widgets/login#linking-your-domain-to-the-bot) for more details.
        public var botUsername: String?

        /// Optional. Pass True to request the permission for your bot to send messages to the user.
        public var requestWriteAccess: Bool?

        /// LoginUrl initialization
        ///
        /// - parameter url:  An HTTP URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in [Receiving authorization data](https://core.telegram.org/widgets/login#receiving-authorization-data).NOTE: You must always check the hash of the received data to verify the authentication and the integrity of the data as described in [Checking authorization](https://core.telegram.org/widgets/login#checking-authorization).
        /// - parameter forwardText:  Optional. New text of the button in forwarded messages.
        /// - parameter botUsername:  Optional. Username of a bot, which will be used for user authorization. See [Setting up a bot](https://core.telegram.org/widgets/login#setting-up-a-bot) for more details. If not specified, the current bot&#39;s username will be assumed. The url&#39;s domain must be the same as the domain linked with the bot. See [Linking your domain to the bot](https://core.telegram.org/widgets/login#linking-your-domain-to-the-bot) for more details.
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

    /// Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot‘s message and tapped ’Reply&#39;). This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice privacy mode.
    public class ForceReply: Codable {

        /// Shows reply interface to the user, as if they manually selected the bot‘s message and tapped ’Reply&#39;
        public var forceReply: Bool

        /// Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot&#39;s message is a reply (has reply_to_message_id), sender of the original message.
        public var selective: Bool?

        /// ForceReply initialization
        ///
        /// - parameter forceReply:  Shows reply interface to the user, as if they manually selected the bot‘s message and tapped ’Reply&#39;
        /// - parameter selective:  Optional. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the text of the Message object; 2) if the bot&#39;s message is a reply (has reply_to_message_id), sender of the original message.
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

        /// Unique file identifier of small (160x160) chat photo. This file_id can be used only for photo download.
        public var smallFileId: String

        /// Unique file identifier of big (640x640) chat photo. This file_id can be used only for photo download.
        public var bigFileId: String

        /// ChatPhoto initialization
        ///
        /// - parameter smallFileId:  Unique file identifier of small (160x160) chat photo. This file_id can be used only for photo download.
        /// - parameter bigFileId:  Unique file identifier of big (640x640) chat photo. This file_id can be used only for photo download.
        ///
        /// - returns: The new `ChatPhoto` instance.
        ///
        public init(smallFileId: String, bigFileId: String) {
            self.smallFileId = smallFileId
            self.bigFileId = bigFileId
        }

        private enum CodingKeys: String, CodingKey {
            case smallFileId = "small_file_id"
            case bigFileId = "big_file_id"
        }

    }

    /// This object contains information about one member of a chat.
    public class ChatMember: Codable {

        /// Information about the user
        public var user: User

        /// The member&#39;s status in the chat. Can be “creator”, “administrator”, “member”, “restricted”, “left” or “kicked”
        public var status: String

        /// Optional. Restricted and kicked only. Date when restrictions will be lifted for this user, unix time
        public var untilDate: Int?

        /// Optional. Administrators only. True, if the bot is allowed to edit administrator privileges of that user
        public var canBeEdited: Bool?

        /// Optional. Administrators only. True, if the administrator can change the chat title, photo and other settings
        public var canChangeInfo: Bool?

        /// Optional. Administrators only. True, if the administrator can post in the channel, channels only
        public var canPostMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can edit messages of other users and can pin messages, channels only
        public var canEditMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can delete messages of other users
        public var canDeleteMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can invite new users to the chat
        public var canInviteUsers: Bool?

        /// Optional. Administrators only. True, if the administrator can restrict, ban or unban chat members
        public var canRestrictMembers: Bool?

        /// Optional. Administrators only. True, if the administrator can pin messages, groups and supergroups only
        public var canPinMessages: Bool?

        /// Optional. Administrators only. True, if the administrator can add new administrators with a subset of his own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        public var canPromoteMembers: Bool?

        /// Optional. Restricted only. True, if the user is a member of the chat at the moment of the request
        public var isMember: Bool?

        /// Optional. Restricted only. True, if the user can send text messages, contacts, locations and venues
        public var canSendMessages: Bool?

        /// Optional. Restricted only. True, if the user can send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
        public var canSendMediaMessages: Bool?

        /// Optional. Restricted only. True, if the user can send animations, games, stickers and use inline bots, implies can_send_media_messages
        public var canSendOtherMessages: Bool?

        /// Optional. Restricted only. True, if user may add web page previews to his messages, implies can_send_media_messages
        public var canAddWebPagePreviews: Bool?

        /// ChatMember initialization
        ///
        /// - parameter user:  Information about the user
        /// - parameter status:  The member&#39;s status in the chat. Can be “creator”, “administrator”, “member”, “restricted”, “left” or “kicked”
        /// - parameter untilDate:  Optional. Restricted and kicked only. Date when restrictions will be lifted for this user, unix time
        /// - parameter canBeEdited:  Optional. Administrators only. True, if the bot is allowed to edit administrator privileges of that user
        /// - parameter canChangeInfo:  Optional. Administrators only. True, if the administrator can change the chat title, photo and other settings
        /// - parameter canPostMessages:  Optional. Administrators only. True, if the administrator can post in the channel, channels only
        /// - parameter canEditMessages:  Optional. Administrators only. True, if the administrator can edit messages of other users and can pin messages, channels only
        /// - parameter canDeleteMessages:  Optional. Administrators only. True, if the administrator can delete messages of other users
        /// - parameter canInviteUsers:  Optional. Administrators only. True, if the administrator can invite new users to the chat
        /// - parameter canRestrictMembers:  Optional. Administrators only. True, if the administrator can restrict, ban or unban chat members
        /// - parameter canPinMessages:  Optional. Administrators only. True, if the administrator can pin messages, groups and supergroups only
        /// - parameter canPromoteMembers:  Optional. Administrators only. True, if the administrator can add new administrators with a subset of his own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by the user)
        /// - parameter isMember:  Optional. Restricted only. True, if the user is a member of the chat at the moment of the request
        /// - parameter canSendMessages:  Optional. Restricted only. True, if the user can send text messages, contacts, locations and venues
        /// - parameter canSendMediaMessages:  Optional. Restricted only. True, if the user can send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
        /// - parameter canSendOtherMessages:  Optional. Restricted only. True, if the user can send animations, games, stickers and use inline bots, implies can_send_media_messages
        /// - parameter canAddWebPagePreviews:  Optional. Restricted only. True, if user may add web page previews to his messages, implies can_send_media_messages
        ///
        /// - returns: The new `ChatMember` instance.
        ///
        public init(user: User, status: String, untilDate: Int? = nil, canBeEdited: Bool? = nil, canChangeInfo: Bool? = nil, canPostMessages: Bool? = nil, canEditMessages: Bool? = nil, canDeleteMessages: Bool? = nil, canInviteUsers: Bool? = nil, canRestrictMembers: Bool? = nil, canPinMessages: Bool? = nil, canPromoteMembers: Bool? = nil, isMember: Bool? = nil, canSendMessages: Bool? = nil, canSendMediaMessages: Bool? = nil, canSendOtherMessages: Bool? = nil, canAddWebPagePreviews: Bool? = nil) {
            self.user = user
            self.status = status
            self.untilDate = untilDate
            self.canBeEdited = canBeEdited
            self.canChangeInfo = canChangeInfo
            self.canPostMessages = canPostMessages
            self.canEditMessages = canEditMessages
            self.canDeleteMessages = canDeleteMessages
            self.canInviteUsers = canInviteUsers
            self.canRestrictMembers = canRestrictMembers
            self.canPinMessages = canPinMessages
            self.canPromoteMembers = canPromoteMembers
            self.isMember = isMember
            self.canSendMessages = canSendMessages
            self.canSendMediaMessages = canSendMediaMessages
            self.canSendOtherMessages = canSendOtherMessages
            self.canAddWebPagePreviews = canAddWebPagePreviews
        }

        private enum CodingKeys: String, CodingKey {
            case user = "user"
            case status = "status"
            case untilDate = "until_date"
            case canBeEdited = "can_be_edited"
            case canChangeInfo = "can_change_info"
            case canPostMessages = "can_post_messages"
            case canEditMessages = "can_edit_messages"
            case canDeleteMessages = "can_delete_messages"
            case canInviteUsers = "can_invite_users"
            case canRestrictMembers = "can_restrict_members"
            case canPinMessages = "can_pin_messages"
            case canPromoteMembers = "can_promote_members"
            case isMember = "is_member"
            case canSendMessages = "can_send_messages"
            case canSendMediaMessages = "can_send_media_messages"
            case canSendOtherMessages = "can_send_other_messages"
            case canAddWebPagePreviews = "can_add_web_page_previews"
        }

    }

    /// Contains information about why a request was unsuccessful.
    public class ResponseParameters: Codable {

        /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
        public var migrateToChatId: Int?

        /// Optional. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated
        public var retryAfter: Int?

        /// ResponseParameters initialization
        ///
        /// - parameter migrateToChatId:  Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
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
                throw NSError(domain: "InputMedia", code: -1, userInfo: nil)
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

        /// Optional. Caption of the photo to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

        /// InputMediaPhoto initialization
        ///
        /// - parameter type:  Type of the result, must be photo
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        ///
        /// - returns: The new `InputMediaPhoto` instance.
        ///
        public init(type: String, media: String, caption: String? = nil, parseMode: String? = nil) {
            self.type = type
            self.media = media
            self.caption = caption
            self.parseMode = parseMode
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case caption = "caption"
            case parseMode = "parse_mode"
        }

    }

    /// Represents a video to be sent.
    public class InputMediaVideo: Codable {

        /// Type of the result, must be video
        public var type: String

        /// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        public var media: String

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the video to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter width:  Optional. Video width
        /// - parameter height:  Optional. Video height
        /// - parameter duration:  Optional. Video duration
        /// - parameter supportsStreaming:  Optional. Pass True, if the uploaded video is suitable for streaming
        ///
        /// - returns: The new `InputMediaVideo` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil, supportsStreaming: Bool? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the animation to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the animation to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter width:  Optional. Animation width
        /// - parameter height:  Optional. Animation height
        /// - parameter duration:  Optional. Animation duration
        ///
        /// - returns: The new `InputMediaAnimation` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, width: Int? = nil, height: Int? = nil, duration: Int? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the audio to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the audio to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter duration:  Optional. Duration of the audio in seconds
        /// - parameter performer:  Optional. Performer of the audio
        /// - parameter title:  Optional. Title of the audio
        ///
        /// - returns: The new `InputMediaAudio` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil, duration: Int? = nil, performer: String? = nil, title: String? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        public var thumb: FileOrPath?

        /// Optional. Caption of the document to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

        /// InputMediaDocument initialization
        ///
        /// - parameter type:  Type of the result, must be document
        /// - parameter media:  File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
        /// - parameter thumb:  Optional. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        ///
        /// - returns: The new `InputMediaDocument` instance.
        ///
        public init(type: String, media: String, thumb: FileOrPath? = nil, caption: String? = nil, parseMode: String? = nil) {
            self.type = type
            self.media = media
            self.thumb = thumb
            self.caption = caption
            self.parseMode = parseMode
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case media = "media"
            case thumb = "thumb"
            case caption = "caption"
            case parseMode = "parse_mode"
        }

    }

    /// This object represents the contents of a file to be uploaded. Must be posted using multipart/form-data in the usual way that files are uploaded via the browser.
    public struct InputFile: Codable {

    }

    /// This object represents a sticker.
    public class Sticker: Codable {

        /// Unique identifier for this file
        public var fileId: String

        /// Sticker width
        public var width: Int

        /// Sticker height
        public var height: Int

        /// Optional. Sticker thumbnail in the .webp or .jpg format
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
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter width:  Sticker width
        /// - parameter height:  Sticker height
        /// - parameter thumb:  Optional. Sticker thumbnail in the .webp or .jpg format
        /// - parameter emoji:  Optional. Emoji associated with the sticker
        /// - parameter setName:  Optional. Name of the sticker set to which the sticker belongs
        /// - parameter maskPosition:  Optional. For mask stickers, the position where the mask should be placed
        /// - parameter fileSize:  Optional. File size
        ///
        /// - returns: The new `Sticker` instance.
        ///
        public init(fileId: String, width: Int, height: Int, thumb: PhotoSize? = nil, emoji: String? = nil, setName: String? = nil, maskPosition: MaskPosition? = nil, fileSize: Int? = nil) {
            self.fileId = fileId
            self.width = width
            self.height = height
            self.thumb = thumb
            self.emoji = emoji
            self.setName = setName
            self.maskPosition = maskPosition
            self.fileSize = fileSize
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case width = "width"
            case height = "height"
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

        /// True, if the sticker set contains masks
        public var containsMasks: Bool

        /// List of all set stickers
        public var stickers: [Sticker]

        /// StickerSet initialization
        ///
        /// - parameter name:  Sticker set name
        /// - parameter title:  Sticker set title
        /// - parameter containsMasks:  True, if the sticker set contains masks
        /// - parameter stickers:  List of all set stickers
        ///
        /// - returns: The new `StickerSet` instance.
        ///
        public init(name: String, title: String, containsMasks: Bool, stickers: [Sticker]) {
            self.name = name
            self.title = title
            self.containsMasks = containsMasks
            self.stickers = stickers
        }

        private enum CodingKeys: String, CodingKey {
            case name = "name"
            case title = "title"
            case containsMasks = "contains_masks"
            case stickers = "stickers"
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

        /// Optional. Sender location, only for bots that request user location
        public var location: Location?

        /// Text of the query (up to 512 characters)
        public var query: String

        /// Offset of the results to be returned, can be controlled by the bot
        public var offset: String

        /// InlineQuery initialization
        ///
        /// - parameter id:  Unique identifier for this query
        /// - parameter from:  Sender
        /// - parameter location:  Optional. Sender location, only for bots that request user location
        /// - parameter query:  Text of the query (up to 512 characters)
        /// - parameter offset:  Offset of the results to be returned, can be controlled by the bot
        ///
        /// - returns: The new `InlineQuery` instance.
        ///
        public init(id: String, from: User, location: Location? = nil, query: String, offset: String) {
            self.id = id
            self.from = from
            self.location = location
            self.query = query
            self.offset = offset
        }

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case from = "from"
            case location = "location"
            case query = "query"
            case offset = "offset"
        }

    }

    /// This object represents one result of an inline query. Telegram clients currently support results of the following 20 types:
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
                throw NSError(domain: "InlineQueryResult", code: -1, userInfo: nil)
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

        /// Optional. Pass True, if you don&#39;t want the URL to be shown in the message
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
        /// - parameter hideUrl:  Optional. Pass True, if you don&#39;t want the URL to be shown in the message
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

        /// Optional. Caption of the photo to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the photo
        ///
        /// - returns: The new `InlineQueryResultPhoto` instance.
        ///
        public init(type: String, id: String, photoUrl: String, thumbUrl: String, photoWidth: Int? = nil, photoHeight: Int? = nil, title: String? = nil, description: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
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

        /// URL of the static thumbnail for the result (jpeg or gif)
        public var thumbUrl: String

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Caption of the GIF file to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter thumbUrl:  URL of the static thumbnail for the result (jpeg or gif)
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the GIF file to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the GIF animation
        ///
        /// - returns: The new `InlineQueryResultGif` instance.
        ///
        public init(type: String, id: String, gifUrl: String, gifWidth: Int? = nil, gifHeight: Int? = nil, gifDuration: Int? = nil, thumbUrl: String, title: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.gifUrl = gifUrl
            self.gifWidth = gifWidth
            self.gifHeight = gifHeight
            self.gifDuration = gifDuration
            self.thumbUrl = thumbUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
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

        /// URL of the static thumbnail (jpeg or gif) for the result
        public var thumbUrl: String

        /// Optional. Title for the result
        public var title: String?

        /// Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter thumbUrl:  URL of the static thumbnail (jpeg or gif) for the result
        /// - parameter title:  Optional. Title for the result
        /// - parameter caption:  Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video animation
        ///
        /// - returns: The new `InlineQueryResultMpeg4Gif` instance.
        ///
        public init(type: String, id: String, mpeg4Url: String, mpeg4Width: Int? = nil, mpeg4Height: Int? = nil, mpeg4Duration: Int? = nil, thumbUrl: String, title: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.mpeg4Url = mpeg4Url
            self.mpeg4Width = mpeg4Width
            self.mpeg4Height = mpeg4Height
            self.mpeg4Duration = mpeg4Duration
            self.thumbUrl = thumbUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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
            case title = "title"
            case caption = "caption"
            case parseMode = "parse_mode"
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

        /// Optional. Caption of the video to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter videoWidth:  Optional. Video width
        /// - parameter videoHeight:  Optional. Video height
        /// - parameter videoDuration:  Optional. Video duration in seconds
        /// - parameter description:  Optional. Short description of the result
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video. This field is required if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a YouTube video).
        ///
        /// - returns: The new `InlineQueryResultVideo` instance.
        ///
        public init(type: String, id: String, videoUrl: String, mimeType: String, thumbUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, videoWidth: Int? = nil, videoHeight: Int? = nil, videoDuration: Int? = nil, description: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.videoUrl = videoUrl
            self.mimeType = mimeType
            self.thumbUrl = thumbUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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
            case videoWidth = "video_width"
            case videoHeight = "video_height"
            case videoDuration = "video_duration"
            case description = "description"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to an mp3 audio file. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
    public class InlineQueryResultAudio: Codable {

        /// Type of the result, must be audio
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the audio file
        public var audioUrl: String

        /// Title
        public var title: String

        /// Optional. Caption, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter performer:  Optional. Performer
        /// - parameter audioDuration:  Optional. Audio duration in seconds
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the audio
        ///
        /// - returns: The new `InlineQueryResultAudio` instance.
        ///
        public init(type: String, id: String, audioUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, performer: String? = nil, audioDuration: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.audioUrl = audioUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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
            case performer = "performer"
            case audioDuration = "audio_duration"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to a voice recording in an .ogg container encoded with OPUS. By default, this voice recording will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the the voice message.
    public class InlineQueryResultVoice: Codable {

        /// Type of the result, must be voice
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid URL for the voice recording
        public var voiceUrl: String

        /// Recording title
        public var title: String

        /// Optional. Caption, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter voiceDuration:  Optional. Recording duration in seconds
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the voice recording
        ///
        /// - returns: The new `InlineQueryResultVoice` instance.
        ///
        public init(type: String, id: String, voiceUrl: String, title: String, caption: String? = nil, parseMode: String? = nil, voiceDuration: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.voiceUrl = voiceUrl
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Caption of the document to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
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
        public init(type: String, id: String, title: String, caption: String? = nil, parseMode: String? = nil, documentUrl: String, mimeType: String, description: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        public var livePeriod: Int?

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
        /// - parameter livePeriod:  Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the location
        /// - parameter thumbUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultLocation` instance.
        ///
        public init(type: String, id: String, latitude: Float, longitude: Float, title: String, livePeriod: Int? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.livePeriod = livePeriod
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
            case livePeriod = "live_period"
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
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the venue
        /// - parameter thumbUrl:  Optional. Url of the thumbnail for the result
        /// - parameter thumbWidth:  Optional. Thumbnail width
        /// - parameter thumbHeight:  Optional. Thumbnail height
        ///
        /// - returns: The new `InlineQueryResultVenue` instance.
        ///
        public init(type: String, id: String, latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil, thumbUrl: String? = nil, thumbWidth: Int? = nil, thumbHeight: Int? = nil) {
            self.type = type
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.address = address
            self.foursquareId = foursquareId
            self.foursquareType = foursquareType
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

        /// Contact&#39;s phone number
        public var phoneNumber: String

        /// Contact&#39;s first name
        public var firstName: String

        /// Optional. Contact&#39;s last name
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
        /// - parameter phoneNumber:  Contact&#39;s phone number
        /// - parameter firstName:  Contact&#39;s first name
        /// - parameter lastName:  Optional. Contact&#39;s last name
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

        /// Optional. Caption of the photo to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the photo to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the photo
        ///
        /// - returns: The new `InlineQueryResultCachedPhoto` instance.
        ///
        public init(type: String, id: String, photoFileId: String, title: String? = nil, description: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.photoFileId = photoFileId
            self.title = title
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Caption of the GIF file to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the GIF file to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the GIF animation
        ///
        /// - returns: The new `InlineQueryResultCachedGif` instance.
        ///
        public init(type: String, id: String, gifFileId: String, title: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.gifFileId = gifFileId
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the MPEG-4 file to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video animation
        ///
        /// - returns: The new `InlineQueryResultCachedMpeg4Gif` instance.
        ///
        public init(type: String, id: String, mpeg4FileId: String, title: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.mpeg4FileId = mpeg4FileId
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Caption of the document to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the document to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the file
        ///
        /// - returns: The new `InlineQueryResultCachedDocument` instance.
        ///
        public init(type: String, id: String, title: String, documentFileId: String, description: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.title = title
            self.documentFileId = documentFileId
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Caption of the video to be sent, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption of the video to be sent, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the video
        ///
        /// - returns: The new `InlineQueryResultCachedVideo` instance.
        ///
        public init(type: String, id: String, videoFileId: String, title: String, description: String? = nil, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.videoFileId = videoFileId
            self.title = title
            self.description = description
            self.caption = caption
            self.parseMode = parseMode
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

        /// Optional. Caption, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

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
        /// - parameter caption:  Optional. Caption, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the voice message
        ///
        /// - returns: The new `InlineQueryResultCachedVoice` instance.
        ///
        public init(type: String, id: String, voiceFileId: String, title: String, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.voiceFileId = voiceFileId
            self.title = title
            self.caption = caption
            self.parseMode = parseMode
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
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// Represents a link to an mp3 audio file stored on the Telegram servers. By default, this audio file will be sent by the user. Alternatively, you can use input_message_content to send a message with the specified content instead of the audio.
    public class InlineQueryResultCachedAudio: Codable {

        /// Type of the result, must be audio
        public var type: String

        /// Unique identifier for this result, 1-64 bytes
        public var id: String

        /// A valid file identifier for the audio file
        public var audioFileId: String

        /// Optional. Caption, 0-1024 characters
        public var caption: String?

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        public var parseMode: String?

        /// Optional. Inline keyboard attached to the message
        public var replyMarkup: InlineKeyboardMarkup?

        /// Optional. Content of the message to be sent instead of the audio
        public var inputMessageContent: InputMessageContent?

        /// InlineQueryResultCachedAudio initialization
        ///
        /// - parameter type:  Type of the result, must be audio
        /// - parameter id:  Unique identifier for this result, 1-64 bytes
        /// - parameter audioFileId:  A valid file identifier for the audio file
        /// - parameter caption:  Optional. Caption, 0-1024 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
        /// - parameter replyMarkup:  Optional. Inline keyboard attached to the message
        /// - parameter inputMessageContent:  Optional. Content of the message to be sent instead of the audio
        ///
        /// - returns: The new `InlineQueryResultCachedAudio` instance.
        ///
        public init(type: String, id: String, audioFileId: String, caption: String? = nil, parseMode: String? = nil, replyMarkup: InlineKeyboardMarkup? = nil, inputMessageContent: InputMessageContent? = nil) {
            self.type = type
            self.id = id
            self.audioFileId = audioFileId
            self.caption = caption
            self.parseMode = parseMode
            self.replyMarkup = replyMarkup
            self.inputMessageContent = inputMessageContent
        }

        private enum CodingKeys: String, CodingKey {
            case type = "type"
            case id = "id"
            case audioFileId = "audio_file_id"
            case caption = "caption"
            case parseMode = "parse_mode"
            case replyMarkup = "reply_markup"
            case inputMessageContent = "input_message_content"
        }

    }

    /// This object represents the content of a message to be sent as a result of an inline query. Telegram clients currently support the following 4 types:
    public enum InputMessageContent: Codable {

        case text(InputTextMessageContent)
        case location(InputLocationMessageContent)
        case venue(InputVenueMessageContent)
        case contact(InputContactMessageContent)

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
            } else {
                throw NSError(domain: "InputMessageContent", code: -1, userInfo: nil)
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
            }
        }
    }
    /// Represents the content of a text message to be sent as the result of an inline query.
    public class InputTextMessageContent: Codable {

        /// Text of the message to be sent, 1-4096 characters
        public var messageText: String

        /// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot&#39;s message.
        public var parseMode: String?

        /// Optional. Disables link previews for links in the sent message
        public var disableWebPagePreview: Bool?

        /// InputTextMessageContent initialization
        ///
        /// - parameter messageText:  Text of the message to be sent, 1-4096 characters
        /// - parameter parseMode:  Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot&#39;s message.
        /// - parameter disableWebPagePreview:  Optional. Disables link previews for links in the sent message
        ///
        /// - returns: The new `InputTextMessageContent` instance.
        ///
        public init(messageText: String, parseMode: String? = nil, disableWebPagePreview: Bool? = nil) {
            self.messageText = messageText
            self.parseMode = parseMode
            self.disableWebPagePreview = disableWebPagePreview
        }

        private enum CodingKeys: String, CodingKey {
            case messageText = "message_text"
            case parseMode = "parse_mode"
            case disableWebPagePreview = "disable_web_page_preview"
        }

    }

    /// Represents the content of a location message to be sent as the result of an inline query.
    public class InputLocationMessageContent: Codable {

        /// Latitude of the location in degrees
        public var latitude: Float

        /// Longitude of the location in degrees
        public var longitude: Float

        /// Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        public var livePeriod: Int?

        /// InputLocationMessageContent initialization
        ///
        /// - parameter latitude:  Latitude of the location in degrees
        /// - parameter longitude:  Longitude of the location in degrees
        /// - parameter livePeriod:  Optional. Period in seconds for which the location can be updated, should be between 60 and 86400.
        ///
        /// - returns: The new `InputLocationMessageContent` instance.
        ///
        public init(latitude: Float, longitude: Float, livePeriod: Int? = nil) {
            self.latitude = latitude
            self.longitude = longitude
            self.livePeriod = livePeriod
        }

        private enum CodingKeys: String, CodingKey {
            case latitude = "latitude"
            case longitude = "longitude"
            case livePeriod = "live_period"
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

        /// InputVenueMessageContent initialization
        ///
        /// - parameter latitude:  Latitude of the venue in degrees
        /// - parameter longitude:  Longitude of the venue in degrees
        /// - parameter title:  Name of the venue
        /// - parameter address:  Address of the venue
        /// - parameter foursquareId:  Optional. Foursquare identifier of the venue, if known
        /// - parameter foursquareType:  Optional. Foursquare type of the venue, if known. (For example, “arts_entertainment/default”, “arts_entertainment/aquarium” or “food/icecream”.)
        ///
        /// - returns: The new `InputVenueMessageContent` instance.
        ///
        public init(latitude: Float, longitude: Float, title: String, address: String, foursquareId: String? = nil, foursquareType: String? = nil) {
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.address = address
            self.foursquareId = foursquareId
            self.foursquareType = foursquareType
        }

        private enum CodingKeys: String, CodingKey {
            case latitude = "latitude"
            case longitude = "longitude"
            case title = "title"
            case address = "address"
            case foursquareId = "foursquare_id"
            case foursquareType = "foursquare_type"
        }

    }

    /// Represents the content of a contact message to be sent as the result of an inline query.
    public class InputContactMessageContent: Codable {

        /// Contact&#39;s phone number
        public var phoneNumber: String

        /// Contact&#39;s first name
        public var firstName: String

        /// Optional. Contact&#39;s last name
        public var lastName: String?

        /// Optional. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes
        public var vcard: String?

        /// InputContactMessageContent initialization
        ///
        /// - parameter phoneNumber:  Contact&#39;s phone number
        /// - parameter firstName:  Contact&#39;s first name
        /// - parameter lastName:  Optional. Contact&#39;s last name
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

        /// Optional. User&#39;s phone number
        public var phoneNumber: String?

        /// Optional. User email
        public var email: String?

        /// Optional. User shipping address
        public var shippingAddress: ShippingAddress?

        /// OrderInfo initialization
        ///
        /// - parameter name:  Optional. User name
        /// - parameter phoneNumber:  Optional. User&#39;s phone number
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

    /// This object represents a file uploaded to Telegram Passport. Currently all Telegram Passport files are in JPEG format when decrypted and don&#39;t exceed 10MB.
    public class PassportFile: Codable {

        /// Unique identifier for this file
        public var fileId: String

        /// File size
        public var fileSize: Int

        /// Unix time when the file was uploaded
        public var fileDate: Int

        /// PassportFile initialization
        ///
        /// - parameter fileId:  Unique identifier for this file
        /// - parameter fileSize:  File size
        /// - parameter fileDate:  Unix time when the file was uploaded
        ///
        /// - returns: The new `PassportFile` instance.
        ///
        public init(fileId: String, fileSize: Int, fileDate: Int) {
            self.fileId = fileId
            self.fileSize = fileSize
            self.fileDate = fileDate
        }

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
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

        /// Optional. User&#39;s verified phone number, available only for “phone_number” type
        public var phoneNumber: String?

        /// Optional. User&#39;s verified email address, available only for “email” type
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
        /// - parameter phoneNumber:  Optional. User&#39;s verified phone number, available only for “phone_number” type
        /// - parameter email:  Optional. User&#39;s verified email address, available only for “email” type
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

        /// Base64-encoded encrypted JSON-serialized data with unique user&#39;s payload, data hashes and secrets required for EncryptedPassportElement decryption and authentication
        public var data: String

        /// Base64-encoded data hash for data authentication
        public var hash: String

        /// Base64-encoded secret, encrypted with the bot&#39;s public RSA key, required for data decryption
        public var secret: String

        /// EncryptedCredentials initialization
        ///
        /// - parameter data:  Base64-encoded encrypted JSON-serialized data with unique user&#39;s payload, data hashes and secrets required for EncryptedPassportElement decryption and authentication
        /// - parameter hash:  Base64-encoded data hash for data authentication
        /// - parameter secret:  Base64-encoded secret, encrypted with the bot&#39;s public RSA key, required for data decryption
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
                throw NSError(domain: "PassportElementError", code: -1, userInfo: nil)
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
    /// Represents an issue in one of the data fields that was provided by the user. The error is considered resolved when the field&#39;s value changes.
    public class PassportElementErrorDataField: Codable {

        /// Error source, must be data
        public var source: String

        /// The section of the user&#39;s Telegram Passport which has the error, one of “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”
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
        /// - parameter type:  The section of the user&#39;s Telegram Passport which has the error, one of “personal_details”, “passport”, “driver_license”, “identity_card”, “internal_passport”, “address”
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

        /// The section of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
        public var type: String

        /// Base64-encoded hash of the file with the front side of the document
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorFrontSide initialization
        ///
        /// - parameter source:  Error source, must be front_side
        /// - parameter type:  The section of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
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

        /// The section of the user&#39;s Telegram Passport which has the issue, one of “driver_license”, “identity_card”
        public var type: String

        /// Base64-encoded hash of the file with the reverse side of the document
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorReverseSide initialization
        ///
        /// - parameter source:  Error source, must be reverse_side
        /// - parameter type:  The section of the user&#39;s Telegram Passport which has the issue, one of “driver_license”, “identity_card”
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

        /// The section of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
        public var type: String

        /// Base64-encoded hash of the file with the selfie
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorSelfie initialization
        ///
        /// - parameter source:  Error source, must be selfie
        /// - parameter type:  The section of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”
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

        /// The section of the user&#39;s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// Base64-encoded file hash
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorFile initialization
        ///
        /// - parameter source:  Error source, must be file
        /// - parameter type:  The section of the user&#39;s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
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

        /// The section of the user&#39;s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// List of base64-encoded file hashes
        public var fileHashes: [String]

        /// Error message
        public var message: String

        /// PassportElementErrorFiles initialization
        ///
        /// - parameter source:  Error source, must be files
        /// - parameter type:  The section of the user&#39;s Telegram Passport which has the issue, one of “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
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

        /// Type of element of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// Base64-encoded file hash
        public var fileHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorTranslationFile initialization
        ///
        /// - parameter source:  Error source, must be translation_file
        /// - parameter type:  Type of element of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
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

        /// Type of element of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
        public var type: String

        /// List of base64-encoded file hashes
        public var fileHashes: [String]

        /// Error message
        public var message: String

        /// PassportElementErrorTranslationFiles initialization
        ///
        /// - parameter source:  Error source, must be translation_files
        /// - parameter type:  Type of element of the user&#39;s Telegram Passport which has the issue, one of “passport”, “driver_license”, “identity_card”, “internal_passport”, “utility_bill”, “bank_statement”, “rental_agreement”, “passport_registration”, “temporary_registration”
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

        /// Type of element of the user&#39;s Telegram Passport which has the issue
        public var type: String

        /// Base64-encoded element hash
        public var elementHash: String

        /// Error message
        public var message: String

        /// PassportElementErrorUnspecified initialization
        ///
        /// - parameter source:  Error source, must be unspecified
        /// - parameter type:  Type of element of the user&#39;s Telegram Passport which has the issue
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