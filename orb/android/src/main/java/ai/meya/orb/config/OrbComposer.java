package ai.meya.orb.config;

import java.util.HashMap;
import java.util.Map;

public class OrbComposer {
    public String focus;
    public String placeholder;
    public String collapsePlaceholder;
    public String visibility;
    public String placeholderText;
    public String collapsePlaceholderText;
    public String fileButtonText;
    public String fileSendText;
    public String imageButtonText;
    public String cameraButtonText;
    public String galleryButtonText;

    public OrbComposer(
            String placeholderText,
            String collapsePlaceholderText,
            String fileButtonText,
            String fileSendText,
            String imageButtonText,
            String cameraButtonText,
            String galleryButtonText
    ) {
        this.placeholderText = placeholderText;
        this.collapsePlaceholderText = collapsePlaceholderText;
        this.fileButtonText = fileButtonText;
        this.fileSendText = fileSendText;
        this.imageButtonText = imageButtonText;
        this.cameraButtonText = cameraButtonText;
        this.galleryButtonText = galleryButtonText;
    }

    public OrbComposer(
            String focus,
            String placeholder,
            String collapsePlaceholder,
            String visibility,
            String placeholderText,
            String collapsePlaceholderText,
            String fileButtonText,
            String fileSendText,
            String imageButtonText,
            String cameraButtonText,
            String galleryButtonText
    ) {
        this.focus = focus;
        this.placeholder = placeholder;
        this.collapsePlaceholder = collapsePlaceholder;
        this.visibility = visibility;
        this.placeholderText = placeholderText;
        this.collapsePlaceholderText = collapsePlaceholderText;
        this.fileButtonText = fileButtonText;
        this.fileSendText = fileSendText;
        this.imageButtonText = imageButtonText;
        this.cameraButtonText = cameraButtonText;
        this.galleryButtonText = galleryButtonText;
    }

    public Map<String, Object> toMap() {
        HashMap<String, Object> composer = new HashMap<>();
        composer.put("focus", focus);
        composer.put("placeholder", placeholder);
        composer.put("collapsePlaceholder", collapsePlaceholder);
        composer.put("visibility", visibility);
        composer.put("placeholderText", placeholderText);
        composer.put("collapsePlaceholderText", collapsePlaceholderText);
        composer.put("fileButtonText", fileButtonText);
        composer.put("fileSendText", fileSendText);
        composer.put("imageButtonText", imageButtonText);
        composer.put("cameraButtonText", cameraButtonText);
        composer.put("galleryButtonText", galleryButtonText);
        return composer;
    }
}
