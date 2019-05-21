import Flutter
import UIKit

public class SwiftFlutterInteractiveKeyboardPlugin: NSObject, FlutterPlugin {
    
    var mainWindow : UIWindow!
    var keyboardView = UIView()
    var keyboardBackground = UIView()
    var keyboardRect = CGRect()
    // To dismiss keyboard
    var textField = UITextField()
    var takingScreenshot = false
    
    override init(){
        super.init()
        mainWindow = UIApplication.shared.delegate?.window!
        keyboardBackground.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0)
        keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0)
        mainWindow.rootViewController?.view.addSubview(keyboardBackground)
        mainWindow.rootViewController?.view.addSubview(keyboardView)
        mainWindow.rootViewController?.view.addSubview(textField)
        UIView.setAnimationsEnabled(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_interactive_keyboard", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterInteractiveKeyboardPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "startScroll":
                takeScreenshot {
                    UIView.setAnimationsEnabled(false)
                    self.textField.becomeFirstResponder()
                    self.textField.resignFirstResponder()
                }
                break;
            case "updateScroll":
                let over = call.arguments! as! CGFloat
                keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-keyboardView.frame.height+over, width: UIScreen.main.bounds.size.width, height: keyboardView.frame.height)
                break;
            case "fling":
                UIView.setAnimationsEnabled(true)
                let velocity = call.arguments! as! CGFloat
                if(velocity < 0){
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity * -1, animations: {
                        self.keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-self.keyboardView.frame.height, width: UIScreen.main.bounds.size.width, height: self.keyboardView.frame.height)
                    }, completion: { (finished: Bool) in
                        if(finished) {
                            UIView.setAnimationsEnabled(false)
                            result(true)
                        }
                    })
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity, animations: {
                        self.keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.keyboardView.frame.height)
                    }, completion: { (finished: Bool) in
                        if(finished) {
                            result(true)
                        }
                    })
                }
                break;
            case "expand":
                UIView.setAnimationsEnabled(true)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    self.keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - self.keyboardRect.height, width: UIScreen.main.bounds.size.width, height: self.keyboardRect.height)
                }, completion: { (finished: Bool) in
                    if(finished) {
                        UIView.setAnimationsEnabled(false)
                        result(true)
                    }
                })
                break;
            default:
                break
        }
    }
    
    func takeScreenshot(completionHandler: @escaping ()->()) {
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
        completionHandler()

    }
    
    @objc func handleKeyboard(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            keyboardRect = keyboardFrame!
            if(isKeyboardShowing) {
                keyboardView.isHidden = true
                keyboardView.frame = keyboardRect
            } else {
                keyboardView.isHidden = false
            }
            keyboardBackground.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height -  (isKeyboardShowing ? keyboardRect.size.height : 0), width: keyboardRect.size.width, height: keyboardRect.size.height)
            keyboardBackground.backgroundColor = .white
            UIView.animate(withDuration: 0, animations: { () -> Void in
                self.keyboardBackground.layoutIfNeeded()
            })
        }
    }
}

extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
