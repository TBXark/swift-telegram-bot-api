# Swift framework for Telegram Bot API


## Build
```shell
swift run Generate -f ./Sources/TelegramBotAPI
```

### English
This is a Telegram Bot API  crawler written in Swift. Use [`Generate`](https://github.com/TBXark/swift-telegram-bot-api/blob/master/Sources/Generate/main.swift) to automatically grab content from the [Telegram Bot API](https://core.telegram.org/bots/api) web page and automatically generate the corresponding model files and API files.
If you just want to use the Swift wrapper of the Telegram Bot API, you can use the code in the `Sources` directory directly.
You can find a Vapor-based server demo here [https://github.com/TBXark/telegram-bot-vapor-example](https://github.com/TBXark/telegram-bot-vapor-example).

#### API
```swift
public struct TelegramAPI {

    /// Use this method to receive incoming updates using long polling ([wiki](http://en.wikipedia.org/wiki/Push_technology#Long_polling)). An Array of Update objects is returned.
    ///
    /// - parameter offset:  Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. All previous updates will forgotten.
    /// - parameter limit:  Limits the number of updates to be retrieved. Values between 1—100 are accepted. Defaults to 100.
    /// - parameter timeout:  Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.
    /// - parameter allowedUpdates:  List the types of updates you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all updates regardless of type (default). If not specified, the previous setting will be used.Please note that this parameter doesn&#39;t affect updates created before the call to the getUpdates, so unwanted updates may be received for a short period of time.
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
    
    ...
```

#### Model

```swift
public extension TelegramAPI {

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
        
        
        ...
```





### 中文
这是一个Telegram机器人的API的Swift封装的自动生成脚本，使用[`Generate`](https://github.com/TBXark/swift-telegram-bot-api/blob/master/Sources/Generate/main.swift) 中的爬虫会自动从[Telegram Bot API](https://core.telegram.org/bots/api) 的网页获取最新的数据并生成相应的Swift代码。生成的代码可以在`Sources`中找到。你也可以直接使用`Sources`中的代码进行开发。
你能在这里 [https://github.com/TBXark/telegram-bot-vapor-example](https://github.com/TBXark/telegram-bot-vapor-example) 找到一个基于 Vapor 的服务器demo。

#### API
```swift
public struct TelegramAPI {

    /// Use this method to receive incoming updates using long polling ([wiki](http://en.wikipedia.org/wiki/Push_technology#Long_polling)). An Array of Update objects is returned.
    ///
    /// - parameter offset:  Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. All previous updates will forgotten.
    /// - parameter limit:  Limits the number of updates to be retrieved. Values between 1—100 are accepted. Defaults to 100.
    /// - parameter timeout:  Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.
    /// - parameter allowedUpdates:  List the types of updates you want your bot to receive. For example, specify [“message”, “edited_channel_post”, “callback_query”] to only receive updates of these types. See Update for a complete list of available update types. Specify an empty list to receive all updates regardless of type (default). If not specified, the previous setting will be used.Please note that this parameter doesn&#39;t affect updates created before the call to the getUpdates, so unwanted updates may be received for a short period of time.
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
    
    ...
```

#### Model

```swift
public extension TelegramAPI {

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
        
        
        ...
```


