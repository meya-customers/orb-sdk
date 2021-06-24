import file_picker
import flutter_secure_storage
import image_picker
import orb
import package_info_plus
import path_provider
import url_launcher


extension Orb {
    public func initialize() {
        // Start the Flutter engine
        engine.run()
        
        // Register all required Flutter plugins
        if let registrar = engine.registrar(forPlugin: "OrbPlugin") {
            OrbPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FilePickerPlugin") {
            FilePickerPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FlutterSecureStoragePlugin") {
            FlutterSecureStoragePlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTImagePickerPlugin") {
            FLTImagePickerPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTPackageInfoPlusPlugin") {
            FLTPackageInfoPlusPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTPathProviderPlugin") {
            FLTPathProviderPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTURLLauncherPlugin") {
            FLTURLLauncherPlugin.register(with: registrar)
        }
        
        self.initCallbacks()
    }
}
