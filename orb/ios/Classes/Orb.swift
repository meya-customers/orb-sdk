import Flutter
import os.log


@available(iOS 10.0, *)
extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let orb = OSLog(subsystem: subsystem, category: "Orb")
}


@objc public class Orb: NSObject {
    public let engine: FlutterEngine
    
    public init(engine: FlutterEngine? = nil, name: String = "meya") {
        self.engine = engine ?? FlutterEngine(name: name)
    }
    
    public func connect(options: OrbConnectionOptions, result: FlutterResult? = nil) {
        getPlugin()?.connect(options: options, result: result)
    }
    
    public func disconnect(result: FlutterResult? = nil) {
        getPlugin()?.disconnect(result: result)
    }
    
    public func publishEvent(
        event: Dictionary<String, Any?>,
        result: FlutterResult? = nil
    ) {
        getPlugin()?.publishEvent(event: event, result: result)
    }
    
    public func onReady(_ callback: @escaping () -> Void) {
        getPlugin()?.ready = callback
    }
    
    public func onConnnected(_ callback: @escaping () -> Void) {
        getPlugin()?.connected = callback
    }
    
    public func onDisconnected(_ callback: @escaping () -> Void) {
        getPlugin()?.disconnected = callback
    }
    
    public func onFirstConnect(
        _ callback: @escaping ([Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = getPlugin() {
            plugin.subscribe(name: "firstConnect", result: result)
            plugin.firstConnect = callback
        }
    }
    
    public func onReconnect(
        _ callback: @escaping ([Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = getPlugin() {
            plugin.subscribe(name: "reconnect", result: result)
            plugin.reconnect = callback
        }
    }
    
    public func onEvent(
        _ callback: @escaping (Dictionary<String, Any>, [Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = getPlugin() {
            plugin.subscribe(name: "event", result: result)
            plugin.event = callback
        }
    }
    
    public func onEventStream(
        _ callback: @escaping ([Dictionary<String, Any?>]) -> Void,
        result: FlutterResult? = nil
    ) {
        if let plugin = getPlugin() {
            plugin.subscribe(name: "eventStream", result: result)
            plugin.eventStream = callback
        }
    }
    
    public func viewController(nibName: String? = nil, bundle: Bundle? = nil) -> FlutterViewController {
        return FlutterViewController(engine: engine, nibName: nibName, bundle: bundle)
    }
    
    func getPlugin() -> SwiftOrbPlugin? {
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
