package ai.meya.orb_example;

import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.HashMap;
import java.util.Map;

import ai.meya.orb.OrbConnectionOptions;
import ai.meya.orb.config.OrbComposer;
import ai.meya.orb.config.OrbConfig;
import ai.meya.orb.config.OrbMediaUpload;
import ai.meya.orb.config.OrbSplash;
import ai.meya.orb.config.OrbTheme;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import ai.meya.orb.Orb;


public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";

    public Orb orb;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getFlutterEngine() != null) {
            orb = new Orb(getContext(), getFlutterEngine());
        } else {
            orb = new Orb(getContext());
        }

        FirebaseMessaging.getInstance().getToken().addOnCompleteListener(new OnCompleteListener<String>() {
            @Override
            public void onComplete(@NonNull Task<String> task) {
                if (!task.isSuccessful()) {
                    Log.w(TAG, "Fetching FCM registration token failed", task.getException());
                    return;
                }
                orb.deviceToken = task.getResult();
                orbConnect();
            }
        });

    }

    private void orbConnect() {
        String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;

        Map<String, Object> pageContext = new HashMap<>();
        pageContext.put("platform_version", platformVersion);
        pageContext.put("key1", 1235);

        Map<String, Object> data = new HashMap<>();
        data.put("key1", "value1");
        data.put("key2", 12345.9);
        data.put("bool", true);
        pageContext.put("data", data);

        OrbConnectionOptions connectionOptions = new OrbConnectionOptions(
                Params.GRID_URL,
                Params.APP_ID,
                "integration.orb.mobile",
                pageContext
        );

        OrbConfig config = new OrbConfig(
                new OrbTheme(
                        "#691ac9"
                ),
                new OrbComposer(
                        "Enter text here...",
                        "Anything else to say?",
                        "File",
                        "Send ",
                        "Photo",
                        "Camera",
                        "Gallery"
                ),
                new OrbSplash(
                        "Example app is ready..."
                ),
                new OrbMediaUpload(
                        null,
                        null,
                        null
                )
        );

        if (!orb.ready) {
            orb.setOnReadyListener(new Orb.ReadyListener() {
                public void onReady() {
                    orb.configure(config);
                    orb.connect(connectionOptions);
                }
            });
        } else {
            orb.configure(config);
            orb.connect(connectionOptions);
        }

        orb.setOnConnectedListener(new Orb.ConnectedListener() {
            public void onConnected() {
                Log.d(TAG, "Orb connected.");
            }
        });

        orb.setOnDisconnectedListener(new Orb.DisconnectedListener() {
            public void onDisconnected() {
                Log.d(TAG, "Orb disconnected.");
            }
        });

        orb.setOnCloseUiListener(new Orb.CloseUiListener() {
            public void onCloseUi() {
                Log.d(TAG, "Close activity");
                finish();
            }
        });
    }
}
