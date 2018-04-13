package com.example.flingonassister;

import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), "platform").setMethodCallHandler(
      new MethodChannel.MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, MethodChannel.Result result) {
          if (call.method.equals("openURL")) {
            Intent opener = new Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments.toString()));
            startActivity(opener);
          } else {
            result.notImplemented();
          }
        }
    });
  }
}
