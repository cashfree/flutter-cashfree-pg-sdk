import Flutter
import UIKit
import CashfreePGCoreSDK
import CashfreePG
import CashfreePGUISDK

/*
 Predefining a structure to send back response in json string to flutter layer
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

public class SwiftFlutterCashfreePgSdkPlugin: NSObject, FlutterPlugin, CFResponseDelegate {
    
    private var flutterResult: FlutterResult?
    private var cfPaymentGatewayService: CFPaymentGatewayService!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_cashfree_pg_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCashfreePgSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.flutterResult = result
        self.cfPaymentGatewayService = CFPaymentGatewayService.getInstance()
        self.cfPaymentGatewayService.setCallback(self)
        let method = call.method
        let args = call.arguments as? Dictionary<String, Any> ?? [:]
        if method == "doNetbankingPayment" {
            do {
                let session = args["session"] as? Dictionary<String, String> ?? [:]
                let netbanking = args["net_banking"] as? Dictionary<String, String> ?? [:]
                let finalSession = try self.createSession(session: session)
                let cfnetbanking = try self.createNetbanking(netbanking: netbanking)
                let netbankingPayment = try CFNetbankingPayment.CFNetbankingPaymentBuilder()
                    .setSession(finalSession)
                    .setNetbanking(cfnetbanking)
                    .build()
                let systemVersion = UIDevice.current.systemVersion
                netbankingPayment.setPlatform("iflt-e-2.1.1-3.13.3-m-s-x-i-\(systemVersion.prefix(4))")
                if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                    try self.cfPaymentGatewayService.doPayment(netbankingPayment, viewController: vc)
                } else {
                    self.sendException(message: "unable to get an instance of rootViewController")
                }
            } catch let e {
                let err = e as! CashfreeError
                self.sendException(message: err.localizedDescription)
            }
        } else if method == "doUPIPayment" {
            do {
                let session = args["session"] as? Dictionary<String, String> ?? [:]
                let upi = args["upi"] as? Dictionary<String, String> ?? [:]
                let finalSession = try self.createSession(session: session)
                let cfupi = try self.createUPI(upi: upi)
                let upiPayment = try CFUPIPayment.CFUPIPaymentBuilder()
                    .setSession(finalSession)
                    .setUPI(cfupi)
                    .build()
                let systemVersion = UIDevice.current.systemVersion
                upiPayment.setPlatform("iflt-e-2.1.1-3.13.3-m-s-x-i-\(systemVersion.prefix(4))")
                if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                    try self.cfPaymentGatewayService.doPayment(upiPayment, viewController: vc)
                } else {
                    self.sendException(message: "unable to get an instance of rootViewController")
                }
            } catch let e {
                let err = e as! CashfreeError
                self.sendException(message: err.localizedDescription)
            }
        } else if method == "getupiapps" {
            let upiApplications = CFUPIUtils().getInstalledUPIApplications()
            var appsToSend: [NSDictionary] = []
            for upi in upiApplications {
                if (upi["id"] ?? "").contains("cred") {
                    continue
                }
                appsToSend.append([
                    "id": upi["id"] ?? "",
                    "base64Icon": upi["icon"] ?? "",
                    "icon": upi["icon"] ?? "",
                    "displayName": upi["displayName"] ?? ""
                ])
            }
            result(appsToSend)
        } else if method == "doCardPayment" {
            let session = args["session"] as? Dictionary<String, String> ?? [:]
            let card = args["card"] as? Dictionary<String, String> ?? [:]
            let savePaymentMethod = args["save_payment_method"] as? Bool ?? false
            do {
                let finalSession = try self.createSession(session: session)
                let cfCard = try self.createCard(card: card)
                let cardPayment = try CFCardPayment.CFCardPaymentBuilder()
                    .setCard(cfCard)
                    .setSession(finalSession)
                    .saveInstrument(savePaymentMethod)
                    .build()
                let systemVersion = UIDevice.current.systemVersion
                cardPayment.setPlatform("iflt-e-2.1.1-3.13.3-m-s-x-i-\(systemVersion.prefix(4))")
                if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                    try self.cfPaymentGatewayService.doPayment(cardPayment, viewController: vc)
                } else {
                    self.sendException(message: "unable to get an instance of rootViewController")
                }
            } catch let e {
                let err = e as! CashfreeError
                self.sendException(message: err.localizedDescription)
            }
        } else if method == "doPayment" {
            let session = args["session"] as? Dictionary<String, String> ?? [:]
            let theme = args["theme"] as? Dictionary<String, String> ?? [:]
            let paymentComponents = args["paymentComponents"] as? Dictionary<String, AnyObject> ?? [:]
            let components = paymentComponents["components"] as? [String] ?? []
            
            do {
                let finalSession = try self.createSession(session: session)
                let cfTheme = try self.createTheme(theme: theme)
                var dropCheckoutPayment: CFDropCheckoutPayment!
                if let paymentComponent = try self.createPaymentComponents(components: components) {
                    dropCheckoutPayment = try CFDropCheckoutPayment.CFDropCheckoutPaymentBuilder()
                        .setSession(finalSession)
                        .setComponent(paymentComponent)
                        .setTheme(cfTheme)
                        .build()
                } else {
                    dropCheckoutPayment = try CFDropCheckoutPayment.CFDropCheckoutPaymentBuilder()
                                            .setSession(finalSession)
                                            .setTheme(cfTheme)
                                            .build()
                }
                let systemVersion = UIDevice.current.systemVersion
                dropCheckoutPayment.setPlatform("iflt-d-2.1.1-3.13.3-m-s-x-i-\(systemVersion.prefix(4))")
                if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                    try self.cfPaymentGatewayService.doPayment(dropCheckoutPayment, viewController: vc)
                } else {
                    self.sendException(message: "unable to get an instance of rootViewController")
                }
            } catch let e {
                let err = e as! CashfreeError
                self.sendException(message: err.localizedDescription)
            }
        } else if method == "doWebPayment" {
            let session = args["session"] as? Dictionary<String, String> ?? [:]
            do {
                let finalSession = try self.createSession(session: session)
                let webCheckoutPayment = try CFWebCheckoutPayment.CFWebCheckoutPaymentBuilder()
                                .setSession(finalSession)
                                .build()
                let systemVersion = UIDevice.current.systemVersion
                webCheckoutPayment.setPlatform("iflt-c-2.1.1-3.13.3-m-s-x-i-\(systemVersion.prefix(4))")
                if let vc = UIApplication.shared.delegate?.window??.rootViewController {
                    try self.cfPaymentGatewayService.doPayment(webCheckoutPayment, viewController: vc)
                } else {
                    self.sendException(message: "unable to get an instance of rootViewController")
                }
            } catch let e {
                let err = e as! CashfreeError
                self.sendException(message: err.localizedDescription)
            }
        }
    }
    
    private func createSession(session: Dictionary<String, String>) throws -> CFSession {
        do {
            var environment = CFENVIRONMENT.SANDBOX
            if let env = session["environment"] {
                if env == "PRODUCTION" {
                    environment = .PRODUCTION
                }
            }
            let cfSession = try CFSession.CFSessionBuilder()
                .setEnvironment(environment)
                .setOrderID(session["order_id"] ?? "")
                .setPaymentSessionId(session["payment_session_id"] ?? "")
                .build()
            
            return cfSession
        } catch let e {
            let err = e as! CashfreeError
            throw err
        }
    }
    
    private func createPaymentComponents(components: [String]) throws -> CFPaymentComponent? {
        var componentBuilder = CFPaymentComponent.CFPaymentComponentBuilder()
        var newComponents: [String] = []
        if !components.isEmpty {
            newComponents.append("order-details")
            for component in components {
                newComponents.append(component)
            }
            componentBuilder = componentBuilder.enableComponents(newComponents)
            do {
                return try componentBuilder.build()
            } catch let e {
                let err = e as! CashfreeError
                throw err
            }
        }
        return nil
    }
    
    private func createTheme(theme: Dictionary<String, String>) throws -> CFTheme {
        do {
            let cfTheme = try CFTheme.CFThemeBuilder()
                .setPrimaryFont(theme["primaryFont"] ?? "")
                .setSecondaryFont(theme["secondaryFont"] ?? "")
                .setPrimaryTextColor(theme["primaryTextColor"] ?? "")
                .setSecondaryTextColor(theme["secondaryTextColor"] ?? "")
                .setNavigationBarBackgroundColor(theme["navigationBarBackgroundColor"] ?? "")
                .setNavigationBarTextColor(theme["navigationBarTextColor"] ?? "")
                .setButtonBackgroundColor(theme["buttonBackgroundColor"] ?? "")
                .setButtonTextColor(theme["buttonTextColor"] ?? "")
                .build()
            return cfTheme
        } catch let e {
            let err = e as! CashfreeError
            throw err
        }
    }
    
    private func createNetbanking(netbanking: Dictionary<String, String>) throws -> CFNetbanking {
        do {
            let cfNetbanking = try CFNetbanking.CFNetbankingBuilder()
                .setBankCode(Int(netbanking["net_banking_code"] as? String ?? "0")!)
                .build()
            return cfNetbanking
        } catch let e {
            let err = e as! CashfreeError
            throw err
        }
    }
    
    private func createUPI(upi: Dictionary<String, String>) throws -> CFUPI {
        do {
            let cfUPI = try CFUPI.CFUPIBuilder()
                .setChannel(upi["channel"] ?? "" == "collect" ? .COLLECT : .INTENT)
                            .setUPIID(upi["upi_id"] ?? "") // Here you have to send the "id" of the app that was clicked from the list that you received earlier
                            .build()
            return cfUPI
        } catch let e {
            let err = e as! CashfreeError
            throw err
        }
    }
    
    private func createCard(card: Dictionary<String, String>) throws -> CFCard {
        do {
            var cardObject: CFCard!
            if card["instrument_id"] != nil && card["instrument_id"] != "" {
                cardObject = try CFCard.CFCardBuilder()
                    .setCVV(card["card_cvv"] ?? "")
                    .setInstrumentId(card["instrument_id"] ?? "")
                    .build()
            } else {
                cardObject = try CFCard.CFCardBuilder()
                    .setCVV(card["card_cvv"] ?? "")
                    .setCardNumber(card["card_number"] ?? "")
                    .setCardExpiryYear(card["card_expiry_year"] ?? "")
                    .setCardExpiryMonth(card["card_expiry_month"] ?? "")
                    .setCardHolderName(card["card_holder_name"] ?? "")
                    .build()
            }
            return cardObject
        } catch let e {
            let err = e as! CashfreeError
            throw err
        }
    }
    
    public func verifyPayment(order_id: String) {
        let success = [
            "status": "success",
            "data": [
                "order_id": order_id
            ]
        ] as Dictionary<String, Any>
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: success, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            if let result = self.flutterResult {
                result(jsonString)
            }
        } catch let e {
            self.sendException(message: e.localizedDescription)
        }
    }
    
    public func onError(_ error: CFErrorResponse, order_id: String) {
        let failed = [
            "status": "failed",
            "data": [
                "order_id": order_id,
                "message": error.message,
                "code": error.code,
                "type": error.type,
                "status": error.status
            ]
        ] as Dictionary<String, Any>
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: failed, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            if let result = self.flutterResult {
                result(jsonString)
            }
        } catch let e {
            self.sendException(message: e.localizedDescription)
        }
    }
    
    private func sendException(message: String) {
        let exception = [
            "status": "exception",
            "data": [
                "message": message
            ]
        ] as Dictionary<String, Any>
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exception, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            if let result = self.flutterResult {
                result(jsonString)
            }
        } catch {
            let jsonData = "{\"status\": \"exception\", \"data\":{\"message\": \"something went wrong. please try again\"}}"
            if let result = self.flutterResult {
                result(jsonData)
            }
        }
    }
}
