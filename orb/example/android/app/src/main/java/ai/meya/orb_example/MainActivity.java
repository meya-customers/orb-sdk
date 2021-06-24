package ai.meya.orb_example;

import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.HashMap;
import java.util.Map;

import ai.meya.orb.OrbConnectionOptions;
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
                "https://grid.meya.ai",
                "app-73c6d31d4f544a72941e21fb518b5737",
                "integration.orb.mobile",
                pageContext
        );

        if (!orb.ready) {
            orb.setOnReadyListener(new Orb.ReadyListener() {
                public void onReady() {
                    orb.connect(connectionOptions);
                }
            });
        } else {
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
