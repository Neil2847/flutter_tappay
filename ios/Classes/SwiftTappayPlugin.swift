import Flutter
import UIKit
import TPDirect

public class SwiftTappayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tappay/bridge", binaryMessenger: registrar.messenger())
    let instance = SwiftTappayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
    case "initTapPay":
        self.initTapPay()
        break
    case "validCard":
        let argsArr = call.arguments as? Dictionary<String,AnyObject>
        
        self.validCard(number: argsArr?["number"] as! String, dueMonth: argsArr?["dueMonth"] as! String, dueYear: argsArr!["dueYear"] as! String, CCV: argsArr?["CCV"] as! String,flutterResult: result)
        break
    case "getTapPayToken":
        let argsArr = call.arguments as? Dictionary<String,AnyObject>
        
        self.getTapPayToken(number: argsArr?["number"] as! String, dueMonth: argsArr?["dueMonth"] as! String, dueYear: argsArr!["dueYear"] as! String, CCV: argsArr?["CCV"] as! String,flutterResult: result)
        break
    default:
        break
    }
  }
    
    
  func initTapPay(){
      
  }
    
    func validCard(number :String,dueMonth:String,dueYear:String,CCV:String,flutterResult:FlutterResult) {
      let result = TPDCard.validate(withCardNumber: number, withDueMonth: dueMonth, withDueYear: dueYear, withCCV: CCV)
    
    if result != nil {
        if(result!.isCardNumberValid){
            flutterResult(FlutterError(code: "-1",
            message: "Invalid Card Number.",
            details: nil))
        }else if(result!.isExpiryDateValid){
            flutterResult(FlutterError(code: "-1",
            message: "Invalid Expiration Date.",
            details: nil))
        }else if((result?.isCCVValid) != nil){
            flutterResult(FlutterError(code: "-1",
            message: "Invalid CCV.",
            details: nil))
        }else{
            flutterResult(true)
        }
    }else{
        flutterResult(FlutterError(code: "-1",
        message: "TapPay connection error.",
        details: nil))
    }
  }
    
    func getTapPayToken(number :String,dueMonth:String,dueYear:String,CCV:String,flutterResult:@escaping FlutterResult) {
    
    TPDCard.setWithCardNumber(number,
        withDueMonth: dueMonth,
        withDueYear: dueYear,
        withCCV: CCV)
    .onSuccessCallback { (prime, cardInfo, cardIdentifier) in
        flutterResult(prime)
    }
    .onFailureCallback { (status, errorMessage) in
        flutterResult(FlutterError(code: "\(status)",
            message: errorMessage,
            details: nil))
    }
    .createToken(withGeoLocation: "UNKNOWN")
    
  }
}