@objc public class OrbConfig: NSObject {
    public var theme: OrbTheme?
    public var composer: OrbComposer?
    public var header: OrbHeader?
    public var menu: OrbMenu?
    public var splash: OrbSplash?
    public var mediaUpload: OrbMediaUpload?

    public init(
        theme: OrbTheme? = nil,
        composer: OrbComposer? = nil,
        header: OrbHeader? = nil,
        menu: OrbMenu? = nil,
        splash: OrbSplash? = nil,
        mediaUpload: OrbMediaUpload? = nil
    ) {
        self.theme = theme
        self.composer = composer
        self.header = header
        self.menu = menu
        self.splash = splash
        self.mediaUpload = mediaUpload
    }

    public func toDict() -> Dictionary<String, Any?> {
        return [
            "theme": theme?.toDict(),
            "composer": composer?.toDict(),
            "header": header?.toDict(),
            "menu": menu?.toDict(),
            "splash": splash?.toDict(),
            "mediaUpload": mediaUpload?.toDict(),
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
    public var focus: String?
    public var placeholder: String?
    public var collapsePlaceholder: String?
    public var visibility: String?
    public var placeholderText: String?
    public var collapsePlaceholderText: String?
    public var fileButtonText: String?
    public var fileSendText: String?
    public var imageButtonText: String?
    public var cameraButtonText: String?
    public var galleryButtonText: String?

    public init(
        focus: String? = nil,
        placeholder: String? = nil,
        collapsePlaceholder: String? = nil,
        visibility: String? = nil,
        placeholderText: String? = nil,
        collapsePlaceholderText: String? = nil,
        fileButtonText: String? = nil,
        fileSendText: String? = nil,
        imageButtonText: String? = nil,
        cameraButtonText: String? = nil,
        galleryButtonText: String? = nil
    ) {
        self.focus = focus
        self.placeholder = placeholder
        self.collapsePlaceholder = collapsePlaceholder
        self.visibility = visibility
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
            "focus": focus,
            "placeholder": placeholder,
            "collapsePlaceholder": collapsePlaceholder,
            "visibility": visibility,
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

@objc public class OrbHeader: NSObject {
    public var buttons: [Any?]?
    public var title: Dictionary<String, Any?>?
    public var progress: Dictionary<String, Any?>?
    public var milestones: [Any?]?
    public var extraButtons: [Any?]?

    public init(
        focus: String? = nil,
        buttons: [Any?]? = nil,
        title: Dictionary<String, Any?>? = nil,
        progress: Dictionary<String, Any?>? = nil,
        milestones: [Any?]? = nil,
        extraButtons: [Any?]? = nil
    ) {
        self.buttons = buttons
        self.title = title
        self.progress = progress
        self.milestones = milestones
        self.extraButtons = extraButtons
    }

    public func toDict() -> Dictionary<String, Any?> {
        return [
            "buttons": buttons,
            "title": title,
            "progress": progress,
            "milestones": milestones,
            "extraButtons": extraButtons
        ]
    }
}


@objc public class OrbMenu: NSObject {
    public var closeText: String?
    public var backText: String?

    public init(
        closeText: String? = nil,
        backText: String? = nil
    ) {
        self.closeText = closeText
        self.backText = backText
    }

    public func toDict() -> Dictionary<String, Any?> {
        return [
            "closeText": closeText,
            "backText": backText
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

@objc public class OrbMediaUpload: NSObject {
    public var all: Bool?
    public var image: Bool?
    public var file: Bool?

    public init(
        all: Bool? = nil,
        image: Bool? = nil,
        file: Bool? = nil
    ) {
        self.all = all
        self.image = image
        self.file = file
    }

    public func toDict() -> Dictionary<String, Any?> {
        return [
            "all": all,
            "image": image,
            "file": file
        ]
    }
}
