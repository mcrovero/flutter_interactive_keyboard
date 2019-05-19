import Flutter
import UIKit

public class SwiftFlutterInteractiveKeyboardPlugin: NSObject, FlutterPlugin {
    
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
        let instance = SwiftFlutterInteractiveKeyboardPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "startScroll":
                UIView.setAnimationsEnabled(false)
                if let image = self.takeScreenshot() {
                    let screenshot = image.crop(rect: keyboardRect)
                    keyboardImage.image = screenshot
                    keyboardImage.frame = keyboardRect
                }
                break;
            case "updateScroll":
                let over = call.arguments! as! CGFloat
                keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-keyboardImage.frame.height+over, width: UIScreen.main.bounds.size.width, height: keyboardImage.frame.height)
                break;
            case "flingClose":
                UIView.setAnimationsEnabled(true)
                let velocity = call.arguments! as! CGFloat
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity, animations: {
                    self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.keyboardImage.frame.height)
                }, completion: { (finished: Bool) in
                    UIView.setAnimationsEnabled(false)
                })
                break;
            case "expand":
                UIView.setAnimationsEnabled(true)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - self.keyboardImage.frame.height, width: UIScreen.main.bounds.size.width, height: self.keyboardImage.frame.height)
                }, completion: { (finished: Bool) in
                    result(true)
                    UIView.setAnimationsEnabled(false)
                })
                break;
            default:
                break
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
