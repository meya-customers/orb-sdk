package ai.meya.orb_example;

import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import ai.meya.orb.Orb;
import ai.meya.orb.OrbOptions;


public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d("Orb", "================================");
        Orb.engine = getFlutterEngine();

        String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;

        Map<String, Object> pageContext = new HashMap<>();
        pageContext.put("platform_version", platformVersion);
        pageContext.put("key1", 1235);

        Map<String, Object> data = new HashMap<>();
        data.put("key1", "value1");
        data.put("key2", 12345.9);
        data.put("bool", true);
        pageContext.put("data", data);

        Orb.setReadyListener(new OrbOptions.ReadyListener() {
            public void onReady() {
                Log.d("Orb", "Orb runtime ready");

                Orb.setFirstConnectListener(new OrbOptions.FirstConnectListener() {
                    public void onFirstConnect(List<Map<String, Object>> eventStream) {
                        Log.d("Orb", "================= onFirstConnect =================");
                        Log.d("Orb", "Total events: " + eventStream.size());
                    }
                });

                Orb.setReconnectListener(new OrbOptions.ReconnectListener() {
                    public void onReconnect(List<Map<String, Object>> eventStream) {
                        Log.d("Orb", "================= onReconnect =================");
                        Log.d("Orb", "Total events: " + eventStream.size());
                    }
                });

                Orb.setEventListener(new OrbOptions.EventListener() {
                    public void onEvent(Map<String, Object> event, List<Map<String, Object>> eventStream) {
                        Log.d("Orb", "================= onEvent =================");
                        Log.d("Orb", "Events: " + event);
                        Log.d("Orb", "Total events: " + eventStream.size());
                    }
                });

                Orb.setEventStreamListener(new OrbOptions.EventStreamListener() {
                    public void onEventStream(List<Map<String, Object>> eventStream) {
                        Log.d("Orb", "================= onEventStream =================");
                        Log.d("Orb", "Total events: " + eventStream.size());
                    }
                });

                Orb.connect(new OrbOptions.ConnectionOptions(
                        "https://grid-rvn-dev.meya.ai",
                        "app-edf4be8b0f984a8db8823d8074beeb83",
                        "integration.orb",
                        pageContext
                ));
            }
        });

        Orb.setConnectedListener(new OrbOptions.ConnectedListener() {
            public void onConnected() {
                Log.d("Orb", "Orb connected.");

                Map<String, Object> trackEvent = new HashMap<>();
                Map<String, Object> trackEventData = new HashMap<>();
                Map<String, Object> data = new HashMap<>();

                data.put("key1", "value1");
                data.put("key2", 1234.1);
                data.put("key3", false);
                data.put("key4", 1234);

                trackEventData.put("event", "orb.connected");
                trackEventData.put("data", data);
                trackEventData.put("timestamp", System.currentTimeMillis() / 1000L);

                trackEvent.put("type", "meya.analytics.event.track");
                trackEvent.put("data", trackEventData);

                Orb.publishEvent(trackEvent);
            }
        });

        Orb.setDisconnectedListener(new OrbOptions.DisconnectedListener() {
            public void onDisconnected() {
                Log.d("Orb", "Orb disconnected.");
            }
        });
    }
}
