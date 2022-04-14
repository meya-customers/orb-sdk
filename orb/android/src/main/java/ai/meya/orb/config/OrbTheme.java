package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbTheme {
    public String brandColor;
    public Double backgroundTranslucency;

    public OrbTheme(String brandColor, Double backgroundTranslucency) {
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
