@objc public class OrbConfig: NSObject {
    public var theme: OrbTheme?
    public var composer: OrbComposer?
    public var splash: OrbSplash?
        
    public init(
        theme: OrbTheme?,
        composer: OrbComposer?,
        splash: OrbSplash?
    ) {
        self.theme = theme
        self.composer = composer
        self.splash = splash
    }
    
    public func toDict() -> Dictionary<String, Any?> {
        return [
            "theme": theme?.toDict(),
            "composer": composer?.toDict(),
            "splash": splash?.toDict(),
        ]
    }
}

@objc public class OrbTheme: NSObject {
    public var brandColor: String?
    public var backgroundTranslucency: Double?
    
    public init(
        brandColor: String? = nil,
        backgroundTranslucency: Double? = nil
    ) {
        self.brandColor = brandColor
        self.backgroundTranslucency = backgroundTranslucency
    }
    
    public func toDict() -> Dictionary<String, Any?> {
        return [
            "brandColor": brandColor,
            "backgroundTranslucency": backgroundTranslucency
        ]
    }
}

@objc public class OrbComposer: NSObject {
    public var placeholderText: String?
    public var collapsePlaceholderText: String?
    public var fileButtonText: String?
    public var fileSendText: String?
    public var imageButtonText: String?
    public var cameraButtonText: String?
    public var galleryButtonText: String?
    
    public init(
        placeholderText: String? = nil,
        collapsePlaceholderText: String? = nil,
        fileButtonText: String? = nil,
        fileSendText: String? = nil,
        imageButtonText: String? = nil,
        cameraButtonText: String? = nil,
        galleryButtonText: String? = nil
    ) {
        self.placeholderText = placeholderText
        self.collapsePlaceholderText = collapsePlaceholderText
        self.fileButtonText = fileButtonText
        self.fileSendText = fileSendText
        self.imageButtonText = imageButtonText
        self.cameraButtonText = cameraButtonText
        self.galleryButtonText = galleryButtonText
    }
    
    public func toDict() -> Dictionary<String, Any?> {
        return [
            "placeholderText": placeholderText,
            "collapsePlaceholderText": collapsePlaceholderText,
            "fileButtonText": fileButtonText,
            "fileSendText": fileSendText,
            "imageButtonText": imageButtonText,
            "cameraButtonText": cameraButtonText,
            "galleryButtonText": galleryButtonText
        ]
    }
}


@objc public class OrbSplash: NSObject {
    public var readyText: String?
    
    public init(
        readyText: String? = nil
    ) {
        self.readyText = readyText
    }
    
    public func toDict() -> Dictionary<String, Any?> {
        return [
            "readyText": readyText
        ]
    }
}
