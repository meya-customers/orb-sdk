package ai.meya.orb;

import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class OrbPlugin implements FlutterPlugin, MethodCallHandler {
  private static final String TAG = "OrbPlugin";

  public Orb.ReadyListener readyListener;
  public Orb.ConnectedListener connectedListener;
  public Orb.DisconnectedListener disconnectedListener;
  public Orb.FirstConnectListener firstConnectListener;
  public Orb.ReconnectListener reconnectListener;
  public Orb.EventListener eventListener;
  public Orb.EventStreamListener eventStreamListener;
  public Orb.CloseUiListener closeUiListener;
  private MethodChannel channel;


  static class GenericResult implements MethodChannel.Result {
    final String method;

    GenericResult(String method) {
      this.method = method;
    }

    @Override
    public void success(Object result) {
      Log.d(TAG, result.toString());
    }

    @Override
    public void error(String errorCode, String errorMessage, Object errorDetails) {
      Log.e(TAG, errorCode + ": " + errorMessage);
    }

    @Override
    public void notImplemented() {
      Log.e(TAG, "'" + method + "' method not implemented");
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "orb");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "ready":
        if (readyListener != null) readyListener.onReady();
        break;
      case "connected":
        if (connectedListener != null) connectedListener.onConnected();
        break;
      case "disconnected":
        if (disconnectedListener != null) disconnectedListener.onDisconnected();
        break;
      case "firstConnect":
        if (firstConnectListener != null) {
          Map<String, Object> arguments = call.arguments();
          firstConnectListener.onFirstConnect(extractEventStream(arguments));
        }
        break;
      case "reconnect":
        if (reconnectListener != null) {
          Map<String, Object> arguments = call.arguments();
          reconnectListener.onReconnect(extractEventStream(arguments));
        }
        break;
      case "event":
        if (eventListener != null) {
          Map<String, Object> arguments = call.arguments();
          eventListener.onEvent(extractEvent(arguments), extractEventStream(arguments));
        }
        break;
      case "eventStream":
        if (eventStreamListener != null) {
          Map<String, Object> arguments = call.arguments();
          eventStreamListener.onEventStream(extractEventStream(arguments));
        }
        break;
      case "closeUi":
        if (closeUiListener != null) closeUiListener.onCloseUi();
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void subscribe(String name) {
    Log.d(TAG, "Subscribing to '" + name + "'");
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("name", name);
    channel.invokeMethod("subscribe", arguments, new GenericResult("subscribe"));
  }

  public void unsubscribe(String name) {
    Log.d(TAG, "Un-subscribing to '" + name + "'");
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("name", name);
    channel.invokeMethod("unsubscribe", arguments, new GenericResult("unsubscribe"));
  }

  public void connect(OrbConnectionOptions options) {
    Log.d(TAG, "Connecting to '" + options.gridUrl + "'");
    channel.invokeMethod("connect", options.toMap(), new GenericResult("connect"));
  }

  public void disconnect(boolean logOut) {
    Log.d(TAG, "Disconnect");
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("logOut", logOut);
    channel.invokeMethod("disconnect", arguments, new GenericResult("disconnect"));
  }

  public void publishEvent(Map<String, Object> event) {
    Log.d(TAG, "Publish event");
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("event", event);
    channel.invokeMethod("publishEvent", arguments, new GenericResult("publishEvent"));
  }

  private List<Map<String, Object>> extractEventStream(Map<String, Object> arguments) {
    List<Map<String, Object>> eventStream = (List<Map<String, Object>>) arguments.get("eventStream");
    if (eventStream != null) {
      return eventStream;
    } else {
      return new ArrayList<>();
    }
  }

  private Map<String, Object> extractEvent(Map<String, Object> arguments) {
    Map<String, Object> event = (Map<String, Object>) arguments.get("event");
    if (event != null) {
      return event;
    } else {
      return new HashMap<>();
    }
  }

}
