package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbMediaUpload {
    public Boolean all;
    public Boolean image;
    public Boolean file;

    public OrbMediaUpload(Boolean all, Boolean image, Boolean file) {
        this.all = all;
        this.image = image;
        this.file = file;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> mediaUpload = new HashMap<>();
        mediaUpload.put("all", all);
        mediaUpload.put("image", image);
        mediaUpload.put("file", file);
        return mediaUpload;
    }
}
