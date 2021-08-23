package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbConfig {
    public OrbTheme theme;
    public OrbComposer composer;
    public OrbSplash splash;

    public OrbConfig(OrbTheme theme, OrbComposer composer, OrbSplash splash) {
        this.theme = theme;
        this.composer = composer;
        this.splash = splash;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> config = new HashMap<>();
        config.put("theme", theme.toMap());
        config.put("composer", composer.toMap());
        config.put("splash", splash.toMap());
        return config;
    }
}
