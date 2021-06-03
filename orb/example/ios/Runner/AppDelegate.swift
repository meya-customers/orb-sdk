import UIKit
import orb
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    lazy var orb: Orb = Orb()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        orb.initialize()
        orb.onReady {
            self.orb.onFirstConnect({ eventStream in
                    print("================ onFirstConnect =================")
                    print("Total events: \(eventStream.count)")
                },
                result: { result in
                    print("Set the first connect listener: \(String(describing: result)).")
                }
            )
            self.orb.onReconnect({ eventStream in
                    print("================ onReconnect =================")
                    print("Total events: \(eventStream.count)")
                },
                result: { result in
                    print("Set the reconnect listener: \(String(describing: result)).")
                }
            )
            self.orb.onEvent({ event, eventStream in
                    print("================ onEvent =================")
                    print(event)
                    print("Total events: \(eventStream.count)")
                },
                result: { result in
                    print("Set the event listener: \(String(describing: result)).")
                }
            )
            self.orb.onEventStream({ eventStream in
                    print("================ onEventStream =================")
                    print("Total events: \(eventStream.count)")
                },
                result: { result in
                    print("Set the event stream listener: \(String(describing: result)).")
                }
            )

            let platformVersion = "iOS " + UIDevice.current.systemVersion
            self.orb.connect(
                options: OrbConnectionOptions(
                    gridUrl: "https://grid.meya.ai",
                    appId: "app-73c6d31d4f544a72941e21fb518b5737",
                    integrationId: "integration.orb",
                    pageContext: [
                        "platform_version": platformVersion,
                        "a": 1234,
                        "data": [
                            "key1": "value1",
                            "key2": 123123.3,
                            "bool": true
                        ]
                    ] as [String: Any?]
                ),
                result: { result in
                    print("Connect result: \(String(describing: result))")
                }
            )
        }
        orb.onConnnected {
            print("Orb connected.")
            self.orb.publishEvent(
                event: [
                    "type": "meya.analytics.event.track",
                    "data": [
                        "event": "orb.connected",
                        "data": [
                            "key1": "value1",
                            "key2": 12345.1,
                            "key3": false,
                            "key4": 1234,
                        ] as [String: Any],
                        "timestamp": NSDate().timeIntervalSince1970,
                    ] as [String: Any],
                ] as [String: Any]
            )
        }
        orb.onDisconnected {
            print("Orb disconnected.")
        }
        self.window.rootViewController = orb.viewController()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
