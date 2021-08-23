import Flutter
import UIKit
import os.log

public class SwiftOrbPlugin: NSObject, FlutterPlugin {
    let channel: FlutterMethodChannel

    public var ready: (() -> Void)? = nil
    public var connected: (() -> Void)? = nil
    public var disconnected: (() -> Void)? = nil
    public var firstConnect: (([Dictionary<String, Any?>]) -> Void)? = nil
    public var reconnect: (([Dictionary<String, Any?>]) -> Void)? = nil
    public var event: ((Dictionary<String, Any?>, [Dictionary<String, Any?>]) -> Void)? = nil
    public var eventStream: (([Dictionary<String, Any?>]) -> Void)? = nil
    public var closeUi: (() -> Void)? = nil

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "orb", binaryMessenger: registrar.messenger())
        let instance = SwiftOrbPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.publish(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "ready":
            if let _ready = self.ready {
                _ready()
            }
        case "connected":
            if let _connected = connected {
                _connected()
            }
        case "disconnected":
            if let _disconnected = disconnected {
                _disconnected()
            }
        case "firstConnect":
            if let _firstConnect = firstConnect {
                let arguments = extractArguments(call.arguments)
                let eventStream = extractEventStream(arguments)
                _firstConnect(eventStream)
            }
        case "reconnect":
            if let _reconnect = reconnect {
                let arguments = extractArguments(call.arguments)
                let eventStream = extractEventStream(arguments)
                _reconnect(eventStream)
            }
        case "event":
            if let _event = event {
                let arguments = extractArguments(call.arguments)
                let event = extractEvent(arguments)
                let eventStream = extractEventStream(arguments)
                _event(event, eventStream)
            }
        case "eventStream":
            if let _eventStream = eventStream {
                let arguments = extractArguments(call.arguments)
                let eventStream = extractEventStream(arguments)
                _eventStream(eventStream)
            }
        case "closeUi":
            if let _closeUi = closeUi {
                _closeUi()
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func subscribe(name: String, result: FlutterResult?) {
        channel.invokeMethod("subscribe", arguments: ["name": name], result: result)
    }

    public func unsubscribe(name: String, result: FlutterResult?) {
        channel.invokeMethod("unsubscribe", arguments: ["name": name], result: result)
    }

    public func configure(config: OrbConfig, result: FlutterResult?) {
        channel.invokeMethod("configure", arguments: config.toDict(), result: result)
    }
    
    public func connect(options: OrbConnectionOptions, result callback: FlutterResult?) {
        channel.invokeMethod("connect", arguments: options.toDict()) { result in
            switch result {
            case is FlutterError:
                self.log("Error connecting to Orb")
            default:
                self.log("Success")
            }
            if let callback = callback {
                callback(result)
            }
        }
    }

    public func disconnect(logOut: Bool, result: FlutterResult?) {
        channel.invokeMethod("disconnect", arguments: ["logOut": logOut], result: result)
    }

    public func publishEvent(event: Dictionary<String, Any?>, result: FlutterResult?) {
        channel.invokeMethod(
            "publishEvent",
            arguments: [
                "event": event,
            ],
            result: result
        )
    }

    func extractArguments(_ arguments: Any?) -> Dictionary<String, Any?> {
        return (arguments ?? [:]) as! Dictionary<String, Any?>
    }

    func extractEventStream(_ arguments: Dictionary<String, Any?>) -> [Dictionary<String, Any?>] {
        return (arguments["eventStream"] ?? []) as! [Dictionary<String, Any?>]
    }

    func extractEvent(_ arguments: Dictionary<String, Any?>) -> Dictionary<String, Any?> {
        return (arguments["event"] ?? [:]) as! Dictionary<String, Any?>
    }

    func log(_ message: StaticString, _ args: CVarArg...) {
        if #available(iOS 10.0, *) {
            os_log(message, log: OSLog.orb, args)
        } else {
            print(message)
        }
    }
}
