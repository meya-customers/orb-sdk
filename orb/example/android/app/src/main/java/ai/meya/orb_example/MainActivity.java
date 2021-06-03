package ai.meya.orb_example;

import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ai.meya.orb.OrbConnectionOptions;
import io.flutter.embedding.android.FlutterActivity;
import ai.meya.orb.Orb;


public class MainActivity extends FlutterActivity {
    public Orb orb;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d("Orb", "================================");
        if (getFlutterEngine() != null) {
            orb = new Orb(getFlutterEngine());
        } else {
            orb = new Orb(getContext());
        }

        String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;

        Map<String, Object> pageContext = new HashMap<>();
        pageContext.put("platform_version", platformVersion);
        pageContext.put("key1", 1235);

        Map<String, Object> data = new HashMap<>();
        data.put("key1", "value1");
        data.put("key2", 12345.9);
        data.put("bool", true);
        pageContext.put("data", data);

        orb.setOnReadyListener(new Orb.ReadyListener() {
            public void onReady() {
                Log.d("Orb", "Orb runtime ready");

                orb.connect(new OrbConnectionOptions(
                        "https://grid.meya.ai",
                        "app-73c6d31d4f544a72941e21fb518b5737",
                        "integration.orb",
                        pageContext
                ));
            }
        });

        orb.setOnConnectedListener(new Orb.ConnectedListener() {
            public void onConnected() {
                Log.d("Orb", "Orb connected.");
            }
        });

        orb.setOnDisconnectedListener(new Orb.DisconnectedListener() {
            public void onDisconnected() {
                Log.d("Orb", "Orb disconnected.");
            }
        });
    }
}
