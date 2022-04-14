package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbMenu {
    public String closeText;
    public String backText;
    
    public OrbMenu(String closeText, String backText) {
        this.closeText = closeText;
        this.backText = backText;
    }
    
    public Map<String, Object> toMap() {
        HashMap<String, Object> splash = new HashMap<>();
        splash.put("closeText", closeText);
        splash.put("backText", backText);
        return splash;
    }
}
