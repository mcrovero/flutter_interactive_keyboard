import Flutter
import UIKit

public class SwiftFlutterInteractiveKeyboardPlugin: NSObject, FlutterPlugin {
    
    var mainWindow : UIWindow!
    var fResp : UIView!
    var keyboardImage = UIImageView()
    
    var keyboardRect = CGRect()
    
    var textField = UITextField()
    
    var takingScreenshot = false
    
    override init(){
        super.init()
        mainWindow = UIApplication.shared.delegate?.window!
        mainWindow.rootViewController?.view.addSubview(keyboardImage)
        mainWindow.rootViewController?.view.addSubview(textField)

        UIView.setAnimationsEnabled(true)
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
                takingScreenshot = true
                takeScreenshot{
                    image in
                    DispatchQueue.main.async {
                        let screenshot = image//.crop(rect: self.keyboardRect)
                        self.keyboardImage.image = screenshot
                        self.keyboardImage.frame = self.keyboardRect
                        self.keyboardImage.contentMode = .scaleAspectFit

                        //self.keyboardImage.frame = self.keyboardRect
                        self.textField.becomeFirstResponder()
                        self.textField.resignFirstResponder()
                        self.takingScreenshot = false
                    }
                }
                break;
            case "updateScroll":
                if(!takingScreenshot) {
                    DispatchQueue.main.async {
                        let over = call.arguments! as! CGFloat
                        self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-self.keyboardRect.height+over, width: UIScreen.main.bounds.size.width, height: self.keyboardRect.height)
                    }
                }
                break;
            case "flingClose":
                UIView.setAnimationsEnabled(true)
                let velocity = call.arguments! as! CGFloat
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity, animations: {
                    self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.keyboardImage.frame.height)
                }, completion: { (finished: Bool) in
                    DispatchQueue.main.async {
                        UIView.setAnimationsEnabled(false)
                    }
                })
                break;
            case "expand":
                UIView.setAnimationsEnabled(true)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                    self.keyboardImage.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - self.keyboardImage.frame.height, width: UIScreen.main.bounds.size.width, height: self.keyboardImage.frame.height)
                }, completion: { (finished: Bool) in
                    result(true)
                    DispatchQueue.main.async {
                        UIView.setAnimationsEnabled(false)
                    }
                })
                break;
            default:
                break
        }
    }
    
    var img = UIImage()
    func takeScreenshot(completionHandler: @escaping (_ screenshot: UIImage)->()) {
        var layers = [CALayer]()
        for window in UIApplication.shared.windows {
            //if window.screen == UIScreen.main {
            layers.append(window.layer)
            print(window.screen.scale)
            //}
        }
        //let layer = w.layer
        let mainSize = mainWindow.screen.applicationFrame.size
        DispatchQueue.global(qos: .background).async {
            UIGraphicsBeginImageContextWithOptions(mainSize, false, 3)
            //w.drawHierarchy(in: bounds, afterScreenUpdates: false)
            for layer in layers {
                layer.render(in: UIGraphicsGetCurrentContext()!)
                layer.contentsScale = 0.5
            }
            
            self.img = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                completionHandler(self.img)
            }
        }
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
        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(true)
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
