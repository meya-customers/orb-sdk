package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbTheme {
    public String brandColor;
    public double backgroundTranslucency = 0.44;

    public OrbTheme(String brandColor, double backgroundTranslucency) {
        this.brandColor = brandColor;
        this.backgroundTranslucency = backgroundTranslucency;
    }
    
    public OrbTheme(String brandColor) {
        this.brandColor = brandColor;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> theme = new HashMap<>();
        theme.put("brandColor", brandColor);
        theme.put("backgroundTranslucency", backgroundTranslucency);
        return theme;
    }
}
