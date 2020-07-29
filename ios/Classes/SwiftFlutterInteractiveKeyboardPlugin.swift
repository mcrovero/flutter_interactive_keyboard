import Flutter
import UIKit

public class SwiftFlutterInteractiveKeyboardPlugin: NSObject, FlutterPlugin {
    
    var mainWindow : UIWindow!
    var keyboardView = UIView()
    var keyboardBackground = UIView()
    var keyboardRect = CGRect()
    var takingScreenshot = false
    var keyboardOpen = false
    var firstResponder = UIView()
    var channel = FlutterMethodChannel()
    
    init(ch : FlutterMethodChannel){
        super.init()
        channel = ch
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_interactive_keyboard", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterInteractiveKeyboardPlugin(ch: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "init":
                mainWindow = UIApplication.shared.delegate?.window!
                keyboardBackground.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0)
                keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0)
                mainWindow.rootViewController?.view.addSubview(keyboardBackground)
                mainWindow.rootViewController?.view.addSubview(keyboardView)
                UIView.setAnimationsEnabled(true)
                
                break;
            case "showKeyboard":
                UIView.setAnimationsEnabled(false)
                let show = (call.arguments! as! Bool)
                if(show) {
                    showKeyboard()
                } else {
                    hideKeyboard()
                }
                UIView.setAnimationsEnabled(true)
                result(true)
                break;
            case "animate":
                let animate = call.arguments! as! Bool
                UIView.setAnimationsEnabled(animate)
                result(true)
                break;
            case "startScroll":
                if(keyboardOpen) {
                    takeScreenshot()
                }
                result(true)
                break;
            case "updateScroll":
                var over = call.arguments! as! CGFloat
                if(over < 0) {
                    over = 0;
                }
                keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-keyboardView.frame.height+over, width: keyboardView.frame.width, height: keyboardView.frame.height)
                result(true)
                break;
            case "fling":
                let velocity = call.arguments! as! CGFloat
                if(velocity < 0){
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity * -1, animations: {
                        self.keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-self.keyboardView.frame.height, width: UIScreen.main.bounds.size.width, height: self.keyboardView.frame.height)
                    }, completion: { (finished: Bool) in
                        if(finished) {
                            result(true)
                        }
                    })
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity, animations: {
                        self.keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.keyboardView.frame.height)
                    }, completion: { (finished: Bool) in
                        if(finished) {
                            result(true)
                        }
                    })
                }
                break;
            case "expand":
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, animations: {
                    self.keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-self.keyboardView.frame.height, width: UIScreen.main.bounds.size.width, height: self.keyboardView.frame.height)
                }, completion: { (finished: Bool) in
                    if(finished) {
                        result(true)
                    }
                })
                break;
            default:
                break
        }
    }
    
    func takeScreenshot() {
        var w = UIWindow()
        for view in keyboardView.subviews {
            view.removeFromSuperview()
        }
        for window in UIApplication.shared.windows {
            if window.screen == UIScreen.main {
                w = window
            }
        }
        let v = w.resizableSnapshotView(from: keyboardRect, afterScreenUpdates: false, withCapInsets: .zero)!
        keyboardView.addSubview(v)
        keyboardView.frame = keyboardRect
        channel.invokeMethod("screenshotTaken", arguments: nil)
    }
    
    func showKeyboard() {
        firstResponder.becomeFirstResponder()
    }
    func hideKeyboard() {
        if let fR = mainWindow.rootViewController?.view.window?.firstResponder {
            firstResponder = fR
            fR.endEditing(true)
        }
    }
    
    @objc func handleKeyboard(_ notification: Notification) {
        let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        if(isKeyboardShowing) {
            if let userInfo = notification.userInfo {
                let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
                keyboardOpen = true
                keyboardRect = keyboardFrame!
            }
        } else {
            keyboardOpen = false
        }
        keyboardBackground.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height -  (isKeyboardShowing ? keyboardRect.size.height : 0), width: keyboardRect.size.width, height: keyboardRect.size.height)
        if #available(iOS 12.0, *) {
            keyboardBackground.backgroundColor = firstResponder.traitCollection.userInterfaceStyle == .dark ? .black : .white
        } else {
            keyboardBackground.backgroundColor = .white
        }
        keyboardView.isHidden = isKeyboardShowing
        if(UIView.areAnimationsEnabled) {
            keyboardView.isHidden = true
        }

        UIView.animate(withDuration: 0, animations: { () -> Void in
            self.keyboardBackground.layoutIfNeeded()
        })
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        //print("keyboardDidShow"
    }
    @objc func keyboardDidHide(_ notification: Notification) {
        //print("keyboardDidHide")
    }
}
extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}
