package ai.meya.orb;

import android.annotation.SuppressLint;
import android.content.Context;
import android.provider.Settings;
import android.util.Log;

import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.PluginRegistry;


public class Orb {
    private static final String TAG = "Orb";

    public String deviceId;
    public String deviceToken;
    public boolean ready = false;

    private ReadyListener _onReady;

    public interface ReadyListener {
        void onReady();
    }

    public interface ConnectedListener {
        void onConnected();
    }

    public interface DisconnectedListener {
        void onDisconnected();
    }

    public interface  FirstConnectListener {
        void onFirstConnect(List<Map<String, Object>> eventStream);
    }

    public interface  ReconnectListener {
        void onReconnect(List<Map<String, Object>> eventStream);
    }

    public interface  EventListener {
        void onEvent(Map<String, Object> event, List<Map<String, Object>> eventStream);
    }

    public interface  EventStreamListener {
        void onEventStream(List<Map<String, Object>> eventStream);
    }

    public interface CloseUiListener {
        void onCloseUi();
    }

    public FlutterEngine engine;

    @SuppressLint("HardwareIds")
    public Orb(@NonNull Context context, @NonNull FlutterEngine engine) {
        this.engine = engine;
        this.deviceId = Settings.Secure.getString(
                context.getContentResolver(), Settings.Secure.ANDROID_ID
        );
        OrbPlugin plugin = getPlugin(engine);
        if (plugin != null) {
            plugin.readyListener = new ReadyListener() {
                @Override
                public void onReady() {
                    Log.d(TAG, "Orb runtime ready");
                    ready = true;
                    if (_onReady != null) _onReady.onReady();
                }
            };
        } else {
            Log.e(
                    TAG,
                    "The Orb plugin has not been registered with the provided Flutter engine. Please ensure you've initialized Orb correctly."
            );
        }
    }

    public Orb(@NonNull Context context) {
        this(context, new FlutterEngine(context));
    }

    public void initialize() {
        engine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        );
    }

    public void connect(OrbConnectionOptions options) {
        if (options.deviceId == null) options.deviceId = deviceId;
        if (options.deviceToken == null) options.deviceToken = deviceToken;
        OrbPlugin plugin = getPlugin(engine);
        if (plugin != null) plugin.connect(options);
    }

    public void disconnect() {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin != null) plugin.disconnect(false);
    }
    
    public void disconnect(boolean logOut) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin != null) plugin.disconnect(logOut);
    }

    public void publishEvent(Map<String, Object> event) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin != null) plugin.publishEvent(event);
    }

    public void setOnReadyListener(Orb.ReadyListener listener) {
        if (ready) Log.d(TAG, "Orb is already running, this listener will not be called until the provided engine is restarted.");
        _onReady = listener;
    }

    public void setOnConnectedListener(Orb.ConnectedListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.connectedListener = listener;
    }

    public void setOnDisconnectedListener(Orb.DisconnectedListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.disconnectedListener = listener;
    }

    public void setOnFirstConnectListener(Orb.FirstConnectListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.subscribe("firstConnect");
        plugin.firstConnectListener = listener;
    }

    public void setOnReconnectListener(Orb.ReconnectListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.subscribe("reconnect");
        plugin.reconnectListener = listener;
    }

    public void setOnEventListener(Orb.EventListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.subscribe("event");
        plugin.eventListener = listener;
    }

    public void setOnEventStreamListener(Orb.EventStreamListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.subscribe("eventStream");
        plugin.eventStreamListener = listener;
    }

    public void setOnCloseUiListener(Orb.CloseUiListener listener) {
        OrbPlugin plugin = getPlugin(engine);
        if (plugin == null) return;
        plugin.closeUiListener = listener;
    }

    @Nullable
    public static OrbPlugin getPlugin(FlutterEngine engine) {
        if (!checkEngine(engine)) return null;

        PluginRegistry registry = engine.getPlugins();
        OrbPlugin plugin = (OrbPlugin) registry.get(OrbPlugin.class);

        if (plugin == null) {
            Log.e(TAG, "Could not get OrbPlugin.");
            return null;
        } else {
            return plugin;
        }
    }

    private static boolean checkEngine(FlutterEngine engine) {
        if (engine == null) {
            Log.e(TAG, "Orb not initialized yet.");
            return false;
        } else {
            return true;
        }
    }
}
