import UIKit
import orb
import Flutter
import UserNotifications


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    lazy var orb: Orb = Orb()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        launchOrb()
        registerForPushNotifications()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if
            let aps = userInfo["aps"] as? [String: AnyObject],
            let meyaIntegrationId = userInfo["meya_integration_id"] as? String
        {
            // Handle Meya notifications
            print(meyaIntegrationId)
            print(aps)
            if
                let alert = aps["alert"],
                let title = alert["title"],
                let body = alert["body"]
            {
                sendNotification(title: title as! String, body: body as! String)
            }
        } else {
            completionHandler(.failed)
            return
        }
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data)}
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        orb.deviceToken = token
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "MEYA_ORB"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(
            identifier: "MEYA_ORB",
            content: content,
            trigger: trigger
        )

        let center =  UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if error != nil {
                print("Notification error: \(String(describing: error))")
            }
        }
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .sound, .alert])
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle Meya local notification action
        if let _ = userInfo["meya_integration_id"] {
            launchOrb()
        }
        
        completionHandler()
    }
    
    func launchOrb() {
        orb.initialize()
        
        let platformVersion = "iOS " + UIDevice.current.systemVersion
        let connectionOptions = OrbConnectionOptions(
            gridUrl: Params.gridUrl,
            appId: Params.appId,
            integrationId: "integration.orb.mobile",
            pageContext: [
                "platform_version": platformVersion,
                "a": 1234,
                "data": [
                    "key1": "value1",
                    "key2": 123123.3,
                    "bool": true
                ]
            ] as [String: Any?]
        )
        let config = OrbConfig(
            theme: OrbTheme(
                brandColor: "#691ac9"
            ),
            composer: OrbComposer(
                placeholderText: "Enter text here...",
                collapsePlaceholderText: "Anything else to say?",
                fileButtonText: "File",
                fileSendText: "Send ",
                imageButtonText: "Photo",
                cameraButtonText: "Camera",
                galleryButtonText: "Gallery"
            ),
            splash: OrbSplash(
                readyText: "Example app is ready..."
            ),
            mediaUpload: OrbMediaUpload(
                all: nil,
                image: nil,
                file: nil
            )
        )
        
        if (!orb.ready) {
            orb.onReady {
                /*
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
                */
                self.orb.configure(config: config)
                self.orb.connect(options: connectionOptions)
            }
        } else {
            self.orb.configure(config: config)
            self.orb.connect(options: connectionOptions)
        }
        orb.onConnnected {
            print("Orb connected.")
            /*
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
            */
        }
        orb.onDisconnected {
            print("Orb disconnected.")
        }
        orb.onCloseUi {
            print("Close orb view controller")
            // Close the app
            UIControl().sendAction(
                #selector(NSXPCConnection.suspend),
                to: UIApplication.shared, for: nil
            )
        }
        self.window.rootViewController = orb.viewController()
    }
}
