package ai.meya.orb;

import android.content.Context;
import android.util.Log;

import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.PluginRegistry;

public class Orb {
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

    public FlutterEngine engine;

    public Orb(@NonNull FlutterEngine engine) {
        this.engine = engine;
    }

    public Orb(@NonNull Context context) {
        this.engine = new FlutterEngine(context);
    }

    public void initialize() {
        engine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        );
    }

    public void connect(OrbConnectionOptions options) {
        OrbPlugin plugin = getPlugin();
        if (plugin != null) plugin.connect(options);
    }

    public void disconnect() {
        OrbPlugin plugin = getPlugin();
        if (plugin != null) plugin.disconnect();
    }

    public void publishEvent(Map<String, Object> event) {
        OrbPlugin plugin = getPlugin();
        if (plugin != null) plugin.publishEvent(event);
    }

    public void setOnReadyListener(Orb.ReadyListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.readyListener = listener;
    }

    public void setOnConnectedListener(Orb.ConnectedListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.connectedListener = listener;
    }

    public void setOnDisconnectedListener(Orb.DisconnectedListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.disconnectedListener = listener;
    }

    public void setOnFirstConnectListener(Orb.FirstConnectListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.subscribe("firstConnect");
        plugin.firstConnectListener = listener;
    }

    public void setOnReconnectListener(Orb.ReconnectListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.subscribe("reconnect");
        plugin.reconnectListener = listener;
    }

    public void setOnEventListener(Orb.EventListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.subscribe("event");
        plugin.eventListener = listener;
    }

    public void setOnEventStreamListener(Orb.EventStreamListener listener) {
        OrbPlugin plugin = getPlugin();
        if (plugin == null) return;
        plugin.subscribe("eventStream");
        plugin.eventStreamListener = listener;
    }

    @Nullable
    public OrbPlugin getPlugin() {
        if (!checkEngine()) return null;

        PluginRegistry registry = engine.getPlugins();
        OrbPlugin plugin = (OrbPlugin) registry.get(OrbPlugin.class);

        if (plugin == null) {
            Log.e("OrbPlugin", "Could not get OrbPlugin.");
            return null;
        } else {
            return plugin;
        }
    }

    private boolean checkEngine() {
        if (engine == null) {
            Log.e("OrbPlugin", "Orb not initialized yet.");
            return false;
        } else {
            return true;
        }
    }
}
