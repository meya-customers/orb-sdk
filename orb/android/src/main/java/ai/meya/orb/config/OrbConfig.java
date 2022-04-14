package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbConfig {
    public OrbTheme theme = null;
    public OrbComposer composer = null;
    public OrbHeader header = null;
    public OrbMenu menu = null;
    public OrbSplash splash = null;
    public OrbMediaUpload mediaUpload = null;

    public OrbConfig(OrbTheme theme, OrbComposer composer, OrbSplash splash) {
        this.theme = theme;
        this.composer = composer;
        this.splash = splash;
    }

    public OrbConfig(OrbTheme theme, OrbComposer composer, OrbSplash splash, OrbMediaUpload mediaUpload) {
        this.theme = theme;
        this.composer = composer;
        this.splash = splash;
        this.mediaUpload = mediaUpload;
    }

    public OrbConfig(OrbTheme theme, OrbComposer composer, OrbHeader header, OrbMenu menu, OrbSplash splash, OrbMediaUpload mediaUpload) {
        this.theme = theme;
        this.composer = composer;
        this.header = header;
        this.menu = menu;
        this.splash = splash;
        this.mediaUpload = mediaUpload;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> config = new HashMap<>();
        config.put("theme", theme != null ? theme.toMap() : null);
        config.put("composer", composer != null ? composer.toMap() : null);
        config.put("header", header != null ? header.toMap() : null);
        config.put("menu", menu != null ? menu.toMap() : null);
        config.put("splash", splash != null ? splash.toMap() : null);
        config.put("mediaUpload", mediaUpload != null ? mediaUpload.toMap() : null);
        return config;
    }
}
