package tw.com.cutaway.tappay;

import android.content.Context;
import android.widget.Toast;

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
import tw.com.cutaway.tappay.model.CardValid;

/** TappayPlugin */
public class TappayPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String CHANNEL_NAME = "tappay/bridge";

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
      case "initTapPay":
        initTapPay(call.argument("appId"),call.argument("appKey"));
        break;
      case "cardValid":
        result.success(getCardValid(call.argument("cardNumber"),call.argument("dueMonth"),call.argument("dueYear"),call.argument("CCV")));
        break;
      case "getDirectPayToken":
        getDirectPayToken(call.argument("cardNumber"),call.argument("dueMonth"),call.argument("dueYear"),call.argument("CCV"));
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
  private CardValid getCardValid(String cardNumber, String dueMonth, String dueYear, String CCV){
    TPDCardValidationResult result = TPDCard.validate(new StringBuffer(cardNumber), new StringBuffer(dueMonth), new StringBuffer(dueYear), new StringBuffer(CCV));
    CardValid valid = new CardValid(true,"");
    if (result.isCardNumberValid()){
      valid = new CardValid(false,"Invalid Card Number");
    }else if (result.isExpiryDateValid()){
      valid = new CardValid(false,"Invalid Expiration Date");
    }else if (result.isCCVValid()){
      valid = new CardValid(false,"Invalid CCV");
    }

    return valid;
  }

  // ----------------------------------
  private void getDirectPayToken(String cardNumber, String dueMonth, String dueYear, String CCV){

    TPDCard card = new TPDCard(context, new StringBuffer(cardNumber), new StringBuffer(dueMonth), new StringBuffer(dueYear), new StringBuffer(CCV))
            .onSuccessCallback((prime, tpdCardInfo, cardIdentifier) -> {
              Toast.makeText(context,"token1 :"+prime,Toast.LENGTH_LONG).show();
            })
            .onFailureCallback((status, reportMsg) -> {
              Toast.makeText(context,"失敗 :"+reportMsg,Toast.LENGTH_LONG).show();
            });

    card.createToken("UNKNOWN");
  }

  // ----------------------------------
}
