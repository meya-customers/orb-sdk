package ai.meya.orb;

import java.util.HashMap;
import java.util.Map;

public class OrbConnectionOptions {
    public String gridUrl;
    public String appId;
    public String integrationId;
    public Map<String, Object> pageContext;
    public String gridUserId;
    public String userId;
    public String threadId;
    public String sessionToken;
    public String magicLinkId;
    public String url;
    public String referrer;
    public String deviceId;
    public String deviceToken;
    public boolean enableCloseButton = true;

    public OrbConnectionOptions(
            String gridUrl,
            String appId,
            String integrationId
    ) {
        this.gridUrl = gridUrl;
        this.appId = appId;
        this.integrationId = integrationId;
    }

    public OrbConnectionOptions(
            String gridUrl,
            String appId,
            String integrationId,
            Map<String, Object> pageContext
    ) {
        this.gridUrl = gridUrl;
        this.appId = appId;
        this.integrationId = integrationId;
        this.pageContext = pageContext;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> options = new HashMap<>();
        options.put("gridUrl", gridUrl);
        options.put("appId", appId);
        options.put("integrationId", integrationId);
        options.put("pageContext", pageContext);
        options.put("gridUserId", gridUserId);
        options.put("userId", userId);
        options.put("threadId", threadId);
        options.put("sessionToken", sessionToken);
        options.put("magicLinkId", magicLinkId);
        options.put("url", url);
        options.put("referrer", referrer);
        options.put("deviceId", deviceId);
        options.put("deviceToken", deviceToken);
        options.put("enableCloseButton", enableCloseButton);
        return options;
    }
}
