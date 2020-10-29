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
import tech.cherri.tpdirect.api.TPDCardInfo;
import tech.cherri.tpdirect.api.TPDCardValidationResult;
import tech.cherri.tpdirect.api.TPDServerType;
import tech.cherri.tpdirect.api.TPDSetup;

/** TappayPlugin */
public class TappayPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String CHANNEL_NAME = "tappay/bridge";
  private static final String INIT = "initTapPay";
  private static final String VALID = "cardValid";
  private static final String GET_TOKEN = "getDirectPayToken";
  private static final String CARD_TYPE = "cardType";
  private static final String LAST_FOUR = "lastFour";
  private static final String IDENTIFIER = "identifier";

  private Context context;
  private MethodChannel channel;
  private TPDCardInfo cardInfo;
  private String cardIdentifier;

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
        if (hasValue(call,"appId","appKey")){
          initTapPay(call.argument("appId"),call.argument("appKey"));
        }
        break;
      case VALID:
        if (hasValue(call,"cardNumber","dueMonth","dueYear","CCV")){
          getCardValid(call.argument("cardNumber"),call.argument("dueMonth"),call.argument("dueYear"),call.argument("CCV"),result);
        }
        break;
      case GET_TOKEN:
        if (hasValue(call,"cardNumber","dueMonth","dueYear","CCV")){
          getDirectPayToken(call.argument("cardNumber"),call.argument("dueMonth"),call.argument("dueYear"),call.argument("CCV"),result);
        }
        break;
      case CARD_TYPE:
        if(cardInfo!=null){
          result.success(cardInfo.getCardType());
          return;
        }
        result.error("-5","Not get card type.",null);
        break;
      case LAST_FOUR:
        if(cardInfo!=null){
          result.success(cardInfo.getLastFour());
          return;
        }
        result.error("-6","Not get card information.",null);
        break;
      case IDENTIFIER:
        if(cardIdentifier!=null && !cardIdentifier.isEmpty()){
          result.success(cardIdentifier);
          return;
        }
        result.error("-4","Not get card identifier",null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  // ----------------------------------
  boolean hasValue(MethodCall call,String ... keys){

    for (String key:keys) {
      if (!call.hasArgument(key)){
        return false;
      }
    }

    return true;
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
      result.error("-2","Invalid Expiration Date",null);
    }else if (validResult.isCCVValid()){
      result.error("-3","Invalid CCV",null);
    }else {
      result.success(true);
    }
  }

  // ----------------------------------
  private void getDirectPayToken(String cardNumber, String dueMonth, String dueYear, String CCV,Result result){
    TPDCard card = new TPDCard(context, new StringBuffer(cardNumber), new StringBuffer(dueMonth), new StringBuffer(dueYear), new StringBuffer(CCV))
            .onSuccessCallback((prime, tpdCardInfo, cardIdentifier) -> {
              this.cardInfo = tpdCardInfo;
              this.cardIdentifier = cardIdentifier;
              result.success(prime);
            })
            .onFailureCallback((status, reportMsg) -> result.error(String.valueOf(status),reportMsg,null));


    card.createToken("UNKNOWN");
  }

  // ----------------------------------
}