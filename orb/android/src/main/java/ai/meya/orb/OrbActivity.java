package ai.meya.orb;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;


public class OrbActivity extends FlutterActivity {
    public Orb orb;

    @NonNull
    public static Intent createDefaultIntent(
            @NonNull Context launchContext, @NonNull Class<? extends OrbActivity> activityClass
    ) {
        return new NewEngineIntentBuilder(activityClass).build(launchContext);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getFlutterEngine() != null) {
            orb = new Orb(getContext(), getFlutterEngine());
        } else {
            orb = new Orb(getContext());
        }
    }
}
