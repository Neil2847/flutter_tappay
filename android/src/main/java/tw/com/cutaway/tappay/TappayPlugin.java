package tw.com.cutaway.tappay;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import tech.cherri.tpdirect.api.TPDCard;
import tech.cherri.tpdirect.api.TPDCardValidationResult;
import tech.cherri.tpdirect.api.TPDServerType;
import tech.cherri.tpdirect.api.TPDSetup;

/** TappayPlugin */
public class TappayPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String CHANNEL_NAME = "tappay/bridge";
  private static final String INIT = "initTapPay";
  private static final String VALID = "cardValid";
  private static final String GET_TOKEN = "getDirectPayToken";

  private Context context;
  private MethodChannel channel;

  // ----------------------------------
  public static void registerWith(Registrar registrar) {
    TappayPlugin instance = new TappayPlugin();
    instance.initInstance(registrar.messenger(), registrar.context());
  }

  // ----------------------------------
  @VisibleForTesting
  public void initInstance(BinaryMessenger messenger, Context context) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    this.context = context;
  }

  // ----------------------------------
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger(),binding.getApplicationContext());
  }

  // ----------------------------------
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    switch (call.method){
      case INIT:
        initTapPay(call.argument("appId"),call.argument("appKey"));
        break;
      case VALID:
        getCardValid(call.argument("cardNumber"),call.argument("dueMonth"),call.argument("dueYear"),call.argument("CCV"),result);
        break;
      case GET_TOKEN:
        getDirectPayToken(call.argument("cardNumber"),call.argument("dueMonth"),call.argument("dueYear"),call.argument("CCV"),result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  // ----------------------------------
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
      dispose();
  }

  // ----------------------------------
  private void dispose(){
    channel.setMethodCallHandler(null);
    channel = null;
  }

  // ----------------------------------
  private void initTapPay(int appId,String appKey){
    TPDSetup.initInstance(context, appId, appKey, TPDServerType.Sandbox);
  }

  // ----------------------------------
  private void getCardValid(String cardNumber, String dueMonth, String dueYear, String CCV,Result result){
    TPDCardValidationResult validResult = TPDCard.validate(new StringBuffer(cardNumber), new StringBuffer(dueMonth), new StringBuffer(dueYear), new StringBuffer(CCV));
    if (validResult.isCardNumberValid()){
      result.error("-1","Invalid Card Number",null);
    }else if (validResult.isExpiryDateValid()){
      result.error("-1","Invalid Expiration Date",null);
    }else if (validResult.isCCVValid()){
      result.error("-1","Invalid CCV",null);
    }else {
      result.success(true);
    }
  }

  // ----------------------------------
  private void getDirectPayToken(String cardNumber, String dueMonth, String dueYear, String CCV,Result result){
    TPDCard card = new TPDCard(context, new StringBuffer(cardNumber), new StringBuffer(dueMonth), new StringBuffer(dueYear), new StringBuffer(CCV))
            .onSuccessCallback((prime, tpdCardInfo, cardIdentifier) -> result.success(prime))
            .onFailureCallback((status, reportMsg) -> result.error(String.valueOf(status),reportMsg,null));

    card.createToken("UNKNOWN");
  }

  // ----------------------------------
}
