package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbSplash {
    public String readyText;
    
    public OrbSplash(String readyText) {
        this.readyText = readyText;
    }
    
    public Map<String, Object> toMap() {
        HashMap<String, Object> splash = new HashMap<>();
        splash.put("readyText", readyText);
        return splash;
    }
}
