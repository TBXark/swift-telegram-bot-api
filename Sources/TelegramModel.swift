import Foundation

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


	public init(updateId: Int, message: Message?, editedMessage: Message?, channelPost: Message?, editedChannelPost: Message?, inlineQuery: InlineQuery?, chosenInlineResult: ChosenInlineResult?, callbackQuery: CallbackQuery?, shippingQuery: ShippingQuery?, preCheckoutQuery: PreCheckoutQuery?) {
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


	public init(url: String, hasCustomCertificate: Bool, pendingUpdateCount: Int, lastErrorDate: Int?, lastErrorMessage: String?, maxConnections: Int?, allowedUpdates: [String]?) {
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


	public init(id: Int, isBot: Bool, firstName: String, lastName: String?, username: String?, languageCode: String?) {
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

	/// Optional. Chat invite link, for supergroups and channel chats. Returned only in getChat.
	public var inviteLink: String?

	/// Optional. Pinned message, for supergroups and channel chats. Returned only in getChat.
	public var pinnedMessage: Message?

	/// Optional. For supergroups, name of group sticker set. Returned only in getChat.
	public var stickerSetName: String?

	/// Optional. True, if the bot can change the group sticker set. Returned only in getChat.
	public var canSetStickerSet: Bool?


	public init(id: Int, type: String, title: String?, username: String?, firstName: String?, lastName: String?, allMembersAreAdministrators: Bool?, photo: ChatPhoto?, description: String?, inviteLink: String?, pinnedMessage: Message?, stickerSetName: String?, canSetStickerSet: Bool?) {
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

	/// Optional. Caption for the audio, document, photo, video or voice, 0-1024 characters
	public var caption: String?

	/// Optional. Message is a shared contact, information about the contact
	public var contact: Contact?

	/// Optional. Message is a shared location, information about the location
	public var location: Location?

	/// Optional. Message is a venue, information about the venue
	public var venue: Venue?

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


	public init(messageId: Int, from: User?, date: Int, chat: Chat, forwardFrom: User?, forwardFromChat: Chat?, forwardFromMessageId: Int?, forwardSignature: String?, forwardDate: Int?, replyToMessage: Message?, editDate: Int?, mediaGroupId: String?, authorSignature: String?, text: String?, entities: [MessageEntity]?, captionEntities: [MessageEntity]?, audio: Audio?, document: Document?, animation: Animation?, game: Game?, photo: [PhotoSize]?, sticker: Sticker?, video: Video?, voice: Voice?, videoNote: VideoNote?, caption: String?, contact: Contact?, location: Location?, venue: Venue?, newChatMembers: [User]?, leftChatMember: User?, newChatTitle: String?, newChatPhoto: [PhotoSize]?, deleteChatPhoto: Bool?, groupChatCreated: Bool?, supergroupChatCreated: Bool?, channelChatCreated: Bool?, migrateToChatId: Int?, migrateFromChatId: Int?, pinnedMessage: Message?, invoice: Invoice?, successfulPayment: SuccessfulPayment?, connectedWebsite: String?, passportData: PassportData?) {
		self.messageId = messageId 
		self.from = from 
		self.date = date 
		self.chat = chat 
		self.forwardFrom = forwardFrom 
		self.forwardFromChat = forwardFromChat 
		self.forwardFromMessageId = forwardFromMessageId 
		self.forwardSignature = forwardSignature 
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


	public init(type: String, offset: Int, length: Int, url: String?, user: User?) {
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


	public init(fileId: String, width: Int, height: Int, fileSize: Int?) {
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


	public init(fileId: String, duration: Int, performer: String?, title: String?, mimeType: String?, fileSize: Int?, thumb: PhotoSize?) {
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


	public init(fileId: String, thumb: PhotoSize?, fileName: String?, mimeType: String?, fileSize: Int?) {
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


	public init(fileId: String, width: Int, height: Int, duration: Int, thumb: PhotoSize?, mimeType: String?, fileSize: Int?) {
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


	public init(fileId: String, width: Int, height: Int, duration: Int, thumb: PhotoSize?, fileName: String?, mimeType: String?, fileSize: Int?) {
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


	public init(fileId: String, duration: Int, mimeType: String?, fileSize: Int?) {
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


	public init(fileId: String, length: Int, duration: Int, thumb: PhotoSize?, fileSize: Int?) {
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


	public init(phoneNumber: String, firstName: String, lastName: String?, userId: Int?, vcard: String?) {
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


	public init(location: Location, title: String, address: String, foursquareId: String?, foursquareType: String?) {
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



/// This object represent a user&#39;s profile pictures.
public class UserProfilePhotos: Codable {

	/// Total number of profile pictures the target user has
	public var totalCount: Int

	/// Requested profile pictures (in up to 4 sizes each)
	public var photos: [PhotoSize]


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


	public init(fileId: String, fileSize: Int?, filePath: String?) {
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


	public init(keyboard: [KeyboardButton], resizeKeyboard: Bool?, oneTimeKeyboard: Bool?, selective: Bool?) {
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


	public init(text: String, requestContact: Bool?, requestLocation: Bool?) {
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


	public init(removeKeyboard: Bool, selective: Bool?) {
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


	public init(text: String, url: String?, callbackData: String?, switchInlineQuery: String?, switchInlineQueryCurrentChat: String?, callbackGame: CallbackGame?, pay: Bool?) {
		self.text = text 
		self.url = url 
		self.callbackData = callbackData 
		self.switchInlineQuery = switchInlineQuery 
		self.switchInlineQueryCurrentChat = switchInlineQueryCurrentChat 
		self.callbackGame = callbackGame 
		self.pay = pay 
	}

	private enum CodingKeys: String, CodingKey {
		case text = "text"
		case url = "url"
		case callbackData = "callback_data"
		case switchInlineQuery = "switch_inline_query"
		case switchInlineQueryCurrentChat = "switch_inline_query_current_chat"
		case callbackGame = "callback_game"
		case pay = "pay"
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


	public init(id: String, from: User, message: Message?, inlineMessageId: String?, chatInstance: String, data: String?, gameShortName: String?) {
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


	public init(forceReply: Bool, selective: Bool?) {
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

	/// Optional. Administrators only. True, if the administrator can pin messages, supergroups only
	public var canPinMessages: Bool?

	/// Optional. Administrators only. True, if the administrator can add new administrators with a subset of his own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by the user)
	public var canPromoteMembers: Bool?

	/// Optional. Restricted only. True, if the user can send text messages, contacts, locations and venues
	public var canSendMessages: Bool?

	/// Optional. Restricted only. True, if the user can send audios, documents, photos, videos, video notes and voice notes, implies can_send_messages
	public var canSendMediaMessages: Bool?

	/// Optional. Restricted only. True, if the user can send animations, games, stickers and use inline bots, implies can_send_media_messages
	public var canSendOtherMessages: Bool?

	/// Optional. Restricted only. True, if user may add web page previews to his messages, implies can_send_media_messages
	public var canAddWebPagePreviews: Bool?


	public init(user: User, status: String, untilDate: Int?, canBeEdited: Bool?, canChangeInfo: Bool?, canPostMessages: Bool?, canEditMessages: Bool?, canDeleteMessages: Bool?, canInviteUsers: Bool?, canRestrictMembers: Bool?, canPinMessages: Bool?, canPromoteMembers: Bool?, canSendMessages: Bool?, canSendMediaMessages: Bool?, canSendOtherMessages: Bool?, canAddWebPagePreviews: Bool?) {
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


	public init(migrateToChatId: Int?, retryAfter: Int?) {
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
		}else {
			throw NSError(domain: "InputMedia", code: -1, userInfo: nil)
		}
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
}/// Represents a photo to be sent.
public class InputMediaPhoto: Codable {

	/// Type of the result, must be photo
	public var type: String

	/// File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://&lt;file_attach_name&gt;” to upload a new one using multipart/form-data under &lt;file_attach_name&gt; name. More info on Sending Files »
	public var media: String

	/// Optional. Caption of the photo to be sent, 0-1024 characters
	public var caption: String?

	/// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	public var parseMode: String?


	public init(type: String, media: String, caption: String?, parseMode: String?) {
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

	/// Optional. Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	public var thumb: Either<InputFile, String>?

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


	public init(type: String, media: String, thumb: Either<InputFile, String>?, caption: String?, parseMode: String?, width: Int?, height: Int?, duration: Int?, supportsStreaming: Bool?) {
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

	/// Optional. Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	public var thumb: Either<InputFile, String>?

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


	public init(type: String, media: String, thumb: Either<InputFile, String>?, caption: String?, parseMode: String?, width: Int?, height: Int?, duration: Int?) {
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

	/// Optional. Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	public var thumb: Either<InputFile, String>?

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


	public init(type: String, media: String, thumb: Either<InputFile, String>?, caption: String?, parseMode: String?, duration: Int?, performer: String?, title: String?) {
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

	/// Optional. Thumbnail of the file sent. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail‘s width and height should not exceed 90. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can’t be reused and can be only uploaded as a new file, so you can pass “attach://&lt;file_attach_name&gt;” if the thumbnail was uploaded using multipart/form-data under &lt;file_attach_name&gt;. More info on Sending Files »
	public var thumb: Either<InputFile, String>?

	/// Optional. Caption of the document to be sent, 0-1024 characters
	public var caption: String?

	/// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in the media caption.
	public var parseMode: String?


	public init(type: String, media: String, thumb: Either<InputFile, String>?, caption: String?, parseMode: String?) {
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


	public init(fileId: String, width: Int, height: Int, thumb: PhotoSize?, emoji: String?, setName: String?, maskPosition: MaskPosition?, fileSize: Int?) {
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


	public init(id: String, from: User, location: Location?, query: String, offset: String) {
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
		}else {
			throw NSError(domain: "InlineQueryResult", code: -1, userInfo: nil)
		}
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
}/// Represents a link to an article or web page.
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


	public init(type: String, id: String, title: String, inputMessageContent: InputMessageContent, replyMarkup: InlineKeyboardMarkup?, url: String?, hideUrl: Bool?, description: String?, thumbUrl: String?, thumbWidth: Int?, thumbHeight: Int?) {
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


	public init(type: String, id: String, photoUrl: String, thumbUrl: String, photoWidth: Int?, photoHeight: Int?, title: String?, description: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, gifUrl: String, gifWidth: Int?, gifHeight: Int?, gifDuration: Int?, thumbUrl: String, title: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, mpeg4Url: String, mpeg4Width: Int?, mpeg4Height: Int?, mpeg4Duration: Int?, thumbUrl: String, title: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, videoUrl: String, mimeType: String, thumbUrl: String, title: String, caption: String?, parseMode: String?, videoWidth: Int?, videoHeight: Int?, videoDuration: Int?, description: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, audioUrl: String, title: String, caption: String?, parseMode: String?, performer: String?, audioDuration: Int?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, voiceUrl: String, title: String, caption: String?, parseMode: String?, voiceDuration: Int?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, title: String, caption: String?, parseMode: String?, documentUrl: String, mimeType: String, description: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?, thumbUrl: String?, thumbWidth: Int?, thumbHeight: Int?) {
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


	public init(type: String, id: String, latitude: Float, longitude: Float, title: String, livePeriod: Int?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?, thumbUrl: String?, thumbWidth: Int?, thumbHeight: Int?) {
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


	public init(type: String, id: String, latitude: Float, longitude: Float, title: String, address: String, foursquareId: String?, foursquareType: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?, thumbUrl: String?, thumbWidth: Int?, thumbHeight: Int?) {
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


	public init(type: String, id: String, phoneNumber: String, firstName: String, lastName: String?, vcard: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?, thumbUrl: String?, thumbWidth: Int?, thumbHeight: Int?) {
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


	public init(type: String, id: String, gameShortName: String, replyMarkup: InlineKeyboardMarkup?) {
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


	public init(type: String, id: String, photoFileId: String, title: String?, description: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, gifFileId: String, title: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, mpeg4FileId: String, title: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, stickerFileId: String, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, title: String, documentFileId: String, description: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, videoFileId: String, title: String, description: String?, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, voiceFileId: String, title: String, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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


	public init(type: String, id: String, audioFileId: String, caption: String?, parseMode: String?, replyMarkup: InlineKeyboardMarkup?, inputMessageContent: InputMessageContent?) {
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
		}else {
			throw NSError(domain: "InputMessageContent", code: -1, userInfo: nil)
		}
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
}/// Represents the content of a text message to be sent as the result of an inline query. 
public class InputTextMessageContent: Codable {

	/// Text of the message to be sent, 1-4096 characters
	public var messageText: String

	/// Optional. Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot&#39;s message.
	public var parseMode: String?

	/// Optional. Disables link previews for links in the sent message
	public var disableWebPagePreview: Bool?


	public init(messageText: String, parseMode: String?, disableWebPagePreview: Bool?) {
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


	public init(latitude: Float, longitude: Float, livePeriod: Int?) {
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


	public init(latitude: Float, longitude: Float, title: String, address: String, foursquareId: String?, foursquareType: String?) {
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


	public init(phoneNumber: String, firstName: String, lastName: String?, vcard: String?) {
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


	public init(resultId: String, from: User, location: Location?, inlineMessageId: String?, query: String) {
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


	public init(name: String?, phoneNumber: String?, email: String?, shippingAddress: ShippingAddress?) {
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


	public init(currency: String, totalAmount: Int, invoicePayload: String, shippingOptionId: String?, orderInfo: OrderInfo?, telegramPaymentChargeId: String, providerPaymentChargeId: String) {
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


	public init(id: String, from: User, currency: String, totalAmount: Int, invoicePayload: String, shippingOptionId: String?, orderInfo: OrderInfo?) {
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


	public init(type: String, data: String?, phoneNumber: String?, email: String?, files: [PassportFile]?, frontSide: PassportFile?, reverseSide: PassportFile?, selfie: PassportFile?, translation: [PassportFile]?, hash: String) {
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
		}else {
			throw NSError(domain: "PassportElementError", code: -1, userInfo: nil)
		}
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
}/// Represents an issue in one of the data fields that was provided by the user. The error is considered resolved when the field&#39;s value changes.
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


	public init(title: String, description: String, photo: [PhotoSize], text: String?, textEntities: [MessageEntity]?, animation: Animation?) {
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



