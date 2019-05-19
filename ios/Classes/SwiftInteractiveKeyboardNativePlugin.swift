import Flutter
import UIKit

public class SwiftInteractiveKeyboardNativePlugin: NSObject, FlutterPlugin {
    
    var mainWindow : UIWindow!
    var fResp : UIView!
    var keyboardImage = UIImageView()
    
    var keyboardRect = CGRect()
    
    override init(){
        super.init()
        mainWindow = UIApplication.shared.delegate?.window!
        mainWindow.rootViewController?.view.addSubview(keyboardImage)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_interactive_keyboard", binaryMessenger: registrar.messenger())
        let instance = SwiftInteractiveKeyboardNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "startScroll":
                if let image = self.takeScreenshot() {
                    let screenshot = image.crop(rect: keyboardRect)
                    keyboardImage.image = screenshot
                    keyboardImage.frame = keyboardRect
                }
                break;
            case "closeKeyboard":
                hideKeyboard(animation: false)
                break;
            case "updateScroll":
                let over = call.arguments! as! CGFloat
                keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-keyboardImage.frame.height+over, width: UIScreen.main.bounds.size.width, height: keyboardImage.frame.height)
                break;
            case "flingClose":
                let velocity = call.arguments! as! CGFloat
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity, animations: {
                    self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.keyboardImage.frame.height)
                }, completion: nil)
                break;
            case "expand":
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - self.keyboardImage.frame.height, width: UIScreen.main.bounds.size.width, height: self.keyboardImage.frame.height)
                }, completion: { (finished: Bool) in
                    self.showKeyboard(animation: false)
                })
                break;
            default:
                break
        }
    }
    
    func showKeyboard(animation: Bool) {
        if(!animation) {
            UIView.setAnimationsEnabled(false)
        }
        fResp.becomeFirstResponder()
        if(!animation) {
            UIView.setAnimationsEnabled(true)
        }
    }
    func hideKeyboard(animation: Bool) {
        if(!animation) {
            UIView.setAnimationsEnabled(false)
        }
        fResp = mainWindow.firstResponder!
        fResp.endEditing(true)
        if(!animation) {
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func takeScreenshot() -> UIImage? {
        let imgSize = UIScreen.main.bounds.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 0)
        for window in UIApplication.shared.windows {
            if window.screen == UIScreen.main {
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            }
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        keyboardImage.isHidden = true
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            keyboardRect = keyboardFrame!
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardImage.isHidden = false
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
