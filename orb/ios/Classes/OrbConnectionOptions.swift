@objc public class OrbConnectionOptions: NSObject {
    public var gridUrl: String
    public var appId: String
    public var integrationId: String
    public var pageContext: Dictionary<String, Any?>?
    public var gridUserId: String?
    public var userId: String?
    public var threadId: String?
    public var sessionToken: String?
    public var magicLinkId: String?
    public var url: String?
    public var referrer: String?
    public var deviceId: String?
    public var deviceToken: String?
    public var enableCloseButton: Bool?
        
    public init(
        gridUrl: String,
        appId: String,
        integrationId: String,
        pageContext: Dictionary<String, Any?>? = nil,
        gridUserId: String? = nil,
        userId: String? = nil,
        threadId: String? = nil,
        sessionToken: String? = nil,
        magicLinkId: String? = nil,
        url: String? = nil,
        referrer: String? = nil,
        deviceId: String? = nil,
        deviceToken: String? = nil,
        enableCloseButton: Bool? = true
    ) {
        self.gridUrl = gridUrl
        self.appId = appId
        self.integrationId = integrationId
        self.pageContext = pageContext
        self.gridUserId = gridUserId
        self.userId = userId
        self.threadId = threadId
        self.sessionToken = sessionToken
        self.magicLinkId = magicLinkId
        self.url = url
        self.referrer = referrer
        self.deviceId = deviceId
        self.deviceToken = deviceToken
        self.enableCloseButton = enableCloseButton
    }
    
    public func toDict() -> Dictionary<String, Any?> {
        return [
            "gridUrl": gridUrl,
            "appId": appId,
            "integrationId": integrationId,
            "pageContext": pageContext,
            "gridUserId": gridUserId,
            "userId": userId,
            "threadId": threadId,
            "sessionToken": sessionToken,
            "magicLinkId": magicLinkId,
            "url": url,
            "referrer": referrer,
            "deviceId": deviceId,
            "deviceToken": deviceToken,
            "enableCloseButton": enableCloseButton,
        ]
    }
}
