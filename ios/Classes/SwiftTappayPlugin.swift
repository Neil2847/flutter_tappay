import Flutter
import UIKit
import TPDirect

public class SwiftTappayPlugin: NSObject, FlutterPlugin {
    
    var cardType:Int = 0
    var lastFour:String = ""
    var cardIdentifier:String = ""
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tappay/bridge", binaryMessenger: registrar.messenger())
        let instance = SwiftTappayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "initTapPay":
             let args = call.arguments as? Dictionary<String,AnyObject>
             self.initTapPay(id:args?["appId"] as! Int32,token:args?["appKey"] as! String,type: args?["type"] as! Int32)
            break
        case "cardValid":
            let argsArr = call.arguments as? Dictionary<String,AnyObject>
            
            self.validCard(number: argsArr?["cardNumber"] as! String, dueMonth: argsArr?["dueMonth"] as! String, dueYear: argsArr!["dueYear"] as! String, CCV: argsArr?["CCV"] as! String,flutterResult: result)
            break
        case "getDirectPayToken":
            let argsArr = call.arguments as? Dictionary<String,AnyObject>

            self.getTapPayToken(number: argsArr?["cardNumber"] as! String, dueMonth: argsArr?["dueMonth"] as! String, dueYear: argsArr!["dueYear"] as! String, CCV: argsArr?["CCV"] as! String,flutterResult: result)
            break
        case "cardType":
            if(cardType != 0){
                result(cardType)
                return
            }
            result(FlutterError(code: "-5",
            message: "Not get card type.",
            details: nil))
            break
        case "lastFour":
            if(lastFour.count > 0){
                result(lastFour)
                return
            }
            result(FlutterError(code: "-6",
            message: "Not get card information.",
            details: nil))
            break
        case "identifier":
            if(cardIdentifier.count > 0){
                result(cardIdentifier)
                return
            }
            result(FlutterError(code: "-4",
            message: "Not get card identifier.",
            details: nil))
            break
        default:
            result(FlutterError(code: "-1",
            message: "NotFind",
            details: nil))
            break
        }
    }
    
    
    func initTapPay(id :Int32,token :String,type :Int32){
        let serverType = type == 0 ? TPDServerType.sandBox : TPDServerType.production
        TPDSetup.setWithAppId(id, withAppKey: token, with: serverType)
        //    TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        TPDSetup.shareInstance().serverSync()
    }
    
    func validCard(number :String,dueMonth:String,dueYear:String,CCV:String,flutterResult:FlutterResult) {
        let result = TPDCard.validate(withCardNumber: number, withDueMonth: dueMonth, withDueYear: dueYear, withCCV: CCV)
        
        if result != nil {
            if(result!.isCardNumberValid){
                flutterResult(FlutterError(code: "-1",
                                           message: "Invalid Card Number.",
                                           details: nil))
            }else if(result!.isExpiryDateValid){
                flutterResult(FlutterError(code: "-2",
                                           message: "Invalid Expiration Date.",
                                           details: nil))
            }else if((result?.isCCVValid) != nil){
                flutterResult(FlutterError(code: "-3",
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
                self.cardType = cardInfo?.cardType ?? 0
                self.lastFour = cardInfo?.lastFour ?? ""
                self.cardIdentifier = cardIdentifier ?? ""
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
