package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbHeader {
    public Object[] buttons;
    public Map<String, Object> title;
    public Map<String, Object> progress;
    public Object[] milestones;
    public Object[] extraButtons;

    public OrbHeader(
            Object[] buttons,
            Map<String, Object> title,
            Map<String, Object> progress,
            Object[] milestones,
            Object[] extraButtons
    ) {
        this.buttons = buttons;
        this.title = title;
        this.progress = progress;
        this.milestones = milestones;
        this.extraButtons = extraButtons;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> composer = new HashMap<>();
        composer.put("buttons", buttons);
        composer.put("title", title);
        composer.put("progress", progress);
        composer.put("milestones", milestones);
        composer.put("extraButtons", extraButtons);
        return composer;
    }
}
