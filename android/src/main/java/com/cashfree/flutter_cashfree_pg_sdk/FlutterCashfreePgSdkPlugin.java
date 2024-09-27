package com.cashfree.flutter_cashfree_pg_sdk;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.cashfree.pg.api.CFPaymentGatewayService;
import com.cashfree.pg.core.api.CFSession;
import com.cashfree.pg.core.api.CFTheme;
import com.cashfree.pg.core.api.base.CFPayment;
import com.cashfree.pg.core.api.callback.CFCheckoutResponseCallback;
import com.cashfree.pg.core.api.card.CFCard;
import com.cashfree.pg.core.api.card.CFCardPayment;
import com.cashfree.pg.core.api.exception.CFException;
import com.cashfree.pg.core.api.netbanking.CFNetBanking;
import com.cashfree.pg.core.api.netbanking.CFNetBankingPayment;
import com.cashfree.pg.core.api.upi.CFUPI;
import com.cashfree.pg.core.api.upi.CFUPIPayment;
import com.cashfree.pg.core.api.utils.CFErrorResponse;
import com.cashfree.pg.core.api.utils.CFUPIApp;
import com.cashfree.pg.core.api.utils.CFUPIUtil;
import com.cashfree.pg.core.api.webcheckout.CFWebCheckoutPayment;
import com.cashfree.pg.core.api.webcheckout.CFWebCheckoutTheme;
import com.cashfree.pg.ui.api.CFDropCheckoutPayment;
import com.cashfree.pg.ui.api.CFPaymentComponent;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 Predefining a structure to send back response in json string
 onSuccess
 {
 "status": "success",
 "data": {
 "order_id": ""
 }
 }

 onFailure
 {
 "status": "failed",
 "data": {
  "order_id":"",
   "message":"",
   "code":"",
   "type":"",
   "":""
 }
 }

 onException
 {
 "status": "exception",
 "data": {
 "message": ""
 }
 }
*/

/** FlutterCashfreePgSdkPlugin */
public class FlutterCashfreePgSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, CFCheckoutResponseCallback {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Result result;
  private JSONObject finalResponse;

  private Activity activity;
  private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

  void FlutterCashfreePgSdkPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_cashfree_pg_sdk");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    this.result = result;

    if(call.method.equals("doNetbankingPayment")) {
      Map<String, Object> request = (Map<String, Object>) call.arguments;
      Map<String, String> session = (Map<String, String>) request.get("session");
      Map<String, String> netbanking = (Map<String, String>) request.get("net_banking");
      try {
        // Create Session
        CFSession cfSession = createSession(session);
        // Create Netbanking Object
        CFNetBanking cfNetBanking = createNetbankingObject(netbanking);

        CFNetBankingPayment cfNetBankingPayment = new CFNetBankingPayment.CFNetBankingPaymentBuilder()
                .setSession(cfSession)
                .setCfNetBanking(cfNetBanking)
                .build();

        CFPayment.CFSDKFramework.FLUTTER.withVersion("2.1.7");
        cfNetBankingPayment.setCfsdkFramework(CFPayment.CFSDKFramework.FLUTTER);
        cfNetBankingPayment.setCfSDKFlavour(CFPayment.CFSDKFlavour.ELEMENT);
        CFPaymentGatewayService gatewayService = CFPaymentGatewayService.getInstance();
        gatewayService.doPayment(this.activity, cfNetBankingPayment);
      } catch (CFException e) {
        handleExceptions(e.getMessage());
      }
    } else if(call.method.equals("doUPIPayment")) {
      Map<String, Object> request = (Map<String, Object>) call.arguments;
      Map<String, String> session = (Map<String, String>) request.get("session");
      Map<String, String> upi = (Map<String, String>) request.get("upi");
      try {
        // Create Session
        CFSession cfSession = createSession(session);
        // Create UPI
        CFUPI cfupi = createUPIObject(upi);

        CFUPIPayment cfupiPayment = new CFUPIPayment.CFUPIPaymentBuilder()
                .setSession(cfSession)
                .setCfUPI(cfupi)
                .build();

        CFPayment.CFSDKFramework.FLUTTER.withVersion("2.1.7");
        cfupiPayment.setCfsdkFramework(CFPayment.CFSDKFramework.FLUTTER);
        cfupiPayment.setCfSDKFlavour(CFPayment.CFSDKFlavour.ELEMENT);
        CFPaymentGatewayService gatewayService = CFPaymentGatewayService.getInstance();
        gatewayService.doPayment(this.activity, cfupiPayment);
      } catch (CFException e) {
        handleExceptions(e.getMessage());
      }
    } else if(call.method.equals("getupiapps")) {
      CFUPIUtil.getInstalledUPIApps(this.activity, upiAppsList -> {
        ArrayList<Map<String, String>> apps = new ArrayList<>();
        for (CFUPIApp cfUPIApp: upiAppsList) {
          apps.add(cfUPIApp.toMap());
        }
        uiThreadHandler.post(() -> {
          try {
            if(result != null) {
              result.success(apps);
            }
          } catch(Exception e) {
          }
        });
      });
    } else if (call.method.equals("doCardPayment")) {
      Map<String, Object> request = (Map<String, Object>) call.arguments;
      Map<String, String> session = (Map<String, String>) request.get("session");
      Map<String, String> card = (Map<String, String>) request.get("card");
      Boolean savePaymentMethod = (Boolean) request.get("save_payment_method");
      try {
        // Create Session
        CFSession cfSession = createSession(session);
        // Create Card
        CFCard cfCard = createCardObject(card);

        CFCardPayment cfCardPayment = new CFCardPayment.CFCardPaymentBuilder()
                .setCard(cfCard)
                .setSession(cfSession)
                .setSaveCardDetail(savePaymentMethod)
                .build();
        cfCardPayment.setCfSDKFlow(CFPayment.CFSDKFlow.WITH_CASHFREE_FULLSCREEN_LOADER);
        CFPayment.CFSDKFramework.FLUTTER.withVersion("2.1.7");
        cfCardPayment.setCfsdkFramework(CFPayment.CFSDKFramework.FLUTTER);
        cfCardPayment.setCfSDKFlavour(CFPayment.CFSDKFlavour.ELEMENT);
        CFPaymentGatewayService gatewayService = CFPaymentGatewayService.getInstance();
        gatewayService.doPayment(this.activity, cfCardPayment);
      } catch (CFException e) {
        handleExceptions(e.getMessage());
      }
    } else if (call.method.equals("doPayment")) {
      Map<String, Object> request = (Map<String, Object>) call.arguments;
      Map<String, String> session = (Map<String, String>) request.get("session");
      Map<String, Object> paymentComponent = (Map<String, Object>) request.get("paymentComponents");
      Map<String, String> theme = (Map<String, String>) request.get("theme");
      try {
        // Create Session
        CFSession cfSession = createSession(session);
        // Create Components
        CFPaymentComponent component = createPaymentComponent(paymentComponent);
        //Create Theme
        CFTheme cfTheme = createTheme(theme);

        CFDropCheckoutPayment cfDropCheckoutPayment = new CFDropCheckoutPayment.CFDropCheckoutPaymentBuilder()
                .setSession(cfSession)
                .setCFUIPaymentModes(component)
                .setCFNativeCheckoutUITheme(cfTheme)
                .build();
        CFPayment.CFSDKFramework.FLUTTER.withVersion("2.1.7");
        cfDropCheckoutPayment.setCfsdkFramework(CFPayment.CFSDKFramework.FLUTTER);
        cfDropCheckoutPayment.setCfSDKFlavour(CFPayment.CFSDKFlavour.DROP);
        CFPaymentGatewayService gatewayService = CFPaymentGatewayService.getInstance();
        gatewayService.doPayment(this.activity, cfDropCheckoutPayment);
      } catch (CFException e) {
        handleExceptions(e.getMessage());
      }
    } else if (call.method.equals("doWebPayment")) {
      Map<String, Object> request = (Map<String, Object>) call.arguments;
      Map<String, String> session = (Map<String, String>) request.get("session");
      Map<String, String> theme = (Map<String, String>) request.get("theme");
      try {
        // Create Session
        CFSession cfSession = createSession(session);
        CFWebCheckoutTheme cfTheme = createWebCheckoutTheme(theme);

        CFWebCheckoutPayment cfWebCheckoutPayment = new CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                .setSession(cfSession)
                .setCFWebCheckoutUITheme(cfTheme)
                .build();
        CFPayment.CFSDKFramework.FLUTTER.withVersion("2.1.7");
        cfWebCheckoutPayment.setCfsdkFramework(CFPayment.CFSDKFramework.FLUTTER);
        cfWebCheckoutPayment.setCfSDKFlavour(CFPayment.CFSDKFlavour.WEB_CHECKOUT);
        CFPaymentGatewayService gatewayService = CFPaymentGatewayService.getInstance();
        gatewayService.doPayment(this.activity, cfWebCheckoutPayment);
      } catch (CFException e) {
        handleExceptions(e.getMessage());
      }
    } else if (call.method.equals("response")) {
        try {
          if(finalResponse != null) {
            if(result != null) {
              result.success(finalResponse.toString());
              finalResponse = null;
            }
          }
        } catch(Exception e) {
        }
    } else {
      try {
        if(result != null) {
          result.notImplemented();
        }
      } catch(Exception e) {
      }
    }
  }

  private CFTheme createTheme(Map<String, String> theme) throws CFException {
    try {
      CFTheme cfTheme = new CFTheme.CFThemeBuilder()
              .setNavigationBarBackgroundColor(theme.get("navigationBarBackgroundColor"))
              .setNavigationBarTextColor(theme.get("navigationBarTextColor"))
              .setButtonBackgroundColor(theme.get("buttonBackgroundColor"))
              .setButtonTextColor(theme.get("buttonTextColor"))
              .setPrimaryTextColor(theme.get("primaryTextColor"))
              .setSecondaryTextColor(theme.get("secondaryTextColor"))
              .build();
      return cfTheme;
    } catch (CFException e) {
      throw e;
    }
  }

  private CFWebCheckoutTheme createWebCheckoutTheme(Map<String, String> theme) throws CFException {
    try {
      CFWebCheckoutTheme cfTheme = new CFWebCheckoutTheme.CFWebCheckoutThemeBuilder()
              .setNavigationBarBackgroundColor(theme.get("navigationBarBackgroundColor"))
              .setNavigationBarTextColor(theme.get("navigationBarTextColor"))
              .build();
      return cfTheme;
    } catch (CFException e) {
      throw e;
    }
  }

  private CFPaymentComponent createPaymentComponent(Map<String, Object> paymentComponent) {
    List<String> components = (List<String>) paymentComponent.get("components");
    int i = 0;
    CFPaymentComponent.CFPaymentComponentBuilder cfPaymentComponentBuilder = new CFPaymentComponent.CFPaymentComponentBuilder();
    for(i = 0; i < components.size(); i++) {
      String value = components.get(i);
      switch (value) {
        case "card":
          cfPaymentComponentBuilder.add(CFPaymentComponent.CFPaymentModes.CARD);
          break;
        case "netbanking":
          cfPaymentComponentBuilder.add(CFPaymentComponent.CFPaymentModes.NB);
          break;
        case "wallet":
          cfPaymentComponentBuilder.add(CFPaymentComponent.CFPaymentModes.WALLET);
          break;
        case "paylater":
          cfPaymentComponentBuilder.add(CFPaymentComponent.CFPaymentModes.PAY_LATER);
          break;
        case "emi":
          cfPaymentComponentBuilder.add(CFPaymentComponent.CFPaymentModes.EMI);
          break;
        case "upi":
          cfPaymentComponentBuilder.add(CFPaymentComponent.CFPaymentModes.UPI);
          break;
      }
    }

    CFPaymentComponent cfPaymentComponent = cfPaymentComponentBuilder.build();
    return cfPaymentComponent;
  }

  private CFNetBanking createNetbankingObject(Map<String, String> netbanking) throws CFException {
    try {
      CFNetBanking cfNetBanking = new CFNetBanking.CFNetBankingBuilder()
              .setBankCode(Integer.parseInt(netbanking.get("net_banking_code")))
              .build();
      return cfNetBanking;
    } catch (CFException e) {
      throw e;
    }
  }

  private CFUPI createUPIObject(Map<String, String> upi) throws CFException {
    try {
      CFUPI.Mode mode = CFUPI.Mode.COLLECT;
      if(upi.get("channel").equals("intent")) {
        mode = CFUPI.Mode.INTENT;
      }
      CFUPI cfupi = new CFUPI.CFUPIBuilder()
              .setMode(mode)
              .setUPIID(upi.get("upi_id"))
              .build();
      return cfupi;
    } catch (CFException e) {
      throw e;
    }
  }

  private CFCard createCardObject(Map<String, String> card) throws CFException {
    try {
      CFCard cfCard;
      if(card.get("instrument_id") != null) {
        cfCard = new CFCard.CFCardBuilder()
                .setInstrumentId(card.get("instrument_id"))
                .setCVV(card.get("card_cvv"))
                .setChannel("post")
                .build();
      } else {
        cfCard = new CFCard.CFCardBuilder()
                .setCardExpiryMonth(card.get("card_expiry_month"))
                .setCardExpiryYear(card.get("card_expiry_year"))
                .setCardNumber(card.get("card_number"))
                .setCardHolderName(card.get("card_holder_name"))
                .setCVV(card.get("card_cvv"))
                .setChannel("post")
                .build();
      }
      return cfCard;
    } catch (CFException e) {
      throw e;
    }
  }

  private CFSession createSession(Map<String, String> session) throws CFException {
    try {
      String environment = session.get("environment");
      CFSession.Environment sessionEnvironment = CFSession.Environment.SANDBOX;
      if(environment.equals("PRODUCTION")) {
        sessionEnvironment = CFSession.Environment.PRODUCTION;
      }
      String payment_session_id = session.get("payment_session_id");
      String orderId = session.get("order_id");
      CFSession cfSession = new CFSession.CFSessionBuilder()
              .setEnvironment(sessionEnvironment)
              .setPaymentSessionID(payment_session_id)
              .setOrderId(orderId)
              .build();
      return cfSession;
    } catch (CFException e) {
      throw e;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onPaymentVerify(String s) {
    Map<String, Object> successReponse = new HashMap<>();
    Map<String, String> order = new HashMap<>();
    order.put("order_id", s);
    successReponse.put("status", "success");
    successReponse.put("data", order);
    JSONObject jsonResponse = new JSONObject(successReponse);
    try {
      if(result != null) {
        result.success(jsonResponse.toString());
        result = null;
      } else {
        finalResponse = jsonResponse;
      }
    } catch(Exception e) {
    }
  }

  @Override
  public void onPaymentFailure(CFErrorResponse cfErrorResponse, String s) {
    Map<String, String> errorResponse = new HashMap<>();
    errorResponse.put("message", cfErrorResponse.getMessage());
    errorResponse.put("code", cfErrorResponse.getCode());
    errorResponse.put("type", cfErrorResponse.getType());
    errorResponse.put("status", cfErrorResponse.getStatus());
    errorResponse.put("order_id", s);
    Map<String, Object> finalMap = new HashMap<>();
    finalMap.put("status", "failed");
    finalMap.put("data", errorResponse);
    JSONObject jsonObject = new JSONObject(finalMap);
    try {
      if(result != null) {
        result.success(jsonObject.toString());
        result = null;
      } else {
        finalResponse = jsonObject;
      }
    } catch(Exception e) {
    }
  }

  private void handleExceptions(String message) {
    Map<String, String> exceptions = new HashMap<>();
    exceptions.put("message", message);
    Map<String, Object> finalMap = new HashMap<>();
    finalMap.put("status", "exception");
    finalMap.put("data", exceptions);
    JSONObject jsonObject = new JSONObject(finalMap);
    try {
      if(result != null) {
        result.success(jsonObject.toString());
        result = null;
      }
    } catch(Exception e) {
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
    try {
      CFPaymentGatewayService.getInstance().setCheckoutCallback(this);
    } catch (CFException e) {
      handleExceptions(e.getMessage());
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
