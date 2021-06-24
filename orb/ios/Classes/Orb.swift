import Flutter
import os.log


@available(iOS 10.0, *)
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let orb = OSLog(subsystem: subsystem, category: "Orb")
}


@objc public class Orb: NSObject {
    public let engine: FlutterEngine
    public let deviceId: String?
    public var deviceToken: String?
    public var ready: Bool {
        get { return _ready }
    }
    private var _ready: Bool = false
    private var _onReady: (() -> Void)? = nil
    
    public init(engine: FlutterEngine? = nil, name: String = "meya") {
        self.engine = engine ?? FlutterEngine(name: name)
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString
    }
    
    deinit {
        Orb.log("Orb is being deinitialized")
    }
    
    public func initCallbacks() {
        if let plugin = Orb.getPlugin(self.engine) {
            plugin.ready = { [unowned self] in
                self._ready = true
                if let onReady = self._onReady {
                    onReady()
                }
            }
        } else {
            Orb.log("Orb plugin is not registered with the Flutter engine. Make sure you initialize Orb correctly")
        }
    }
    
    public func connect(options: OrbConnectionOptions, result: FlutterResult? = nil) {
        options.deviceId = options.deviceId ?? self.deviceId
        options.deviceToken = options.deviceToken ?? self.deviceToken
        Orb.getPlugin(self.engine)?.connect(options: options, result: result)
    }
    
    public func disconnect(logOut: Bool = false, result: FlutterResult? = nil) {
        Orb.getPlugin(self.engine)?.disconnect(logOut: logOut, result: result)
    }
    
    public func publishEvent(
        event: Dictionary<String, Any?>,
        result: FlutterResult? = nil
    ) {
        Orb.getPlugin(self.engine)?.publishEvent(event: event, result: result)
    }
    
    public func onReady(_ callback: @escaping () -> Void) {
        if (ready) {
            Orb.log("Orb is already running, this callback will not be called until the provided engine is restarted")
        }
        _onReady = callback
    }
    
    public func onConnnected(_ callback: @escaping () -> Void) {
        Orb.getPlugin(engine)?.connected = callback
    }
    
    public func onDisconnected(_ callback: @escaping () -> Void) {
        Orb.getPlugin(engine)?.disconnected = callback
    }
    
    public func onFirstConnect(
        _ callback: @escaping ([Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = Orb.getPlugin(self.engine) {
            plugin.subscribe(name: "firstConnect", result: result)
            plugin.firstConnect = callback
        }
    }
    
    public func onReconnect(
        _ callback: @escaping ([Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = Orb.getPlugin(self.engine) {
            plugin.subscribe(name: "reconnect", result: result)
            plugin.reconnect = callback
        }
    }
    
    public func onEvent(
        _ callback: @escaping (Dictionary<String, Any>, [Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = Orb.getPlugin(self.engine) {
            plugin.subscribe(name: "event", result: result)
            plugin.event = callback
        }
    }
    
    public func onEventStream(
        _ callback: @escaping ([Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = Orb.getPlugin(self.engine) {
            plugin.subscribe(name: "eventStream", result: result)
            plugin.eventStream = callback
        }
    }
    
    public func onCloseUi(_ callback: @escaping () -> Void) {
        Orb.getPlugin(engine)?.closeUi = callback
    }
    
    public func viewController(nibName: String? = nil, bundle: Bundle? = nil) -> FlutterViewController {
        return FlutterViewController(engine: engine, nibName: nibName, bundle: bundle)
    }
    
    static func getPlugin(_ engine: FlutterEngine) -> SwiftOrbPlugin? {
        return engine.valuePublished(byPlugin: "OrbPlugin") as? SwiftOrbPlugin
    }
    
    static func log(_ message: StaticString, _ args: CVarArg...) {
        if #available(iOS 10.0, *) {
            os_log(message, log: OSLog.orb, args)
        } else {
            print(message)
        }
    }
}
