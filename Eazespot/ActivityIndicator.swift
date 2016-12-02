/*
import Foundation
import UIKit

open class ActivityIndicator {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    var pinchImageView = UIImageView()
    
    open class var shared: ActivityIndicator {
        struct Static {
            static let instance: ActivityIndicator = ActivityIndicator()
        }
        return Static.instance
    }
    
    open func showProgressView(_ uiView: UIView, text:String="Loading...") {
        containerView.frame = CGRect(x: 0, y: 0, width: uiView.frame.width, height: uiView.frame.height)
        containerView.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.2)
        
        let spinnerImageData = try? Data(contentsOf: Bundle.main.url(forResource: "loadingSpinner", withExtension: "gif")!)
        let animatedImage = UIImage.animatedImageWithData(spinnerImageData!)
        pinchImageView = UIImageView(image: animatedImage)
        
        progressView.frame = CGRect(x: 0, y: 0, width: (pinchImageView.frame.size.width), height: 60)
        progressView.center = uiView.center
        
        for view in progressView.subviews {
            view.removeFromSuperview()
        }
        
        progressView.addSubview(pinchImageView)
        containerView.addSubview(progressView)
        uiView.addSubview(containerView)
    }
    
    open func hideProgressView() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        pinchImageView.removeFromSuperview()
        progressView.removeFromSuperview()
        containerView.removeFromSuperview()
    }
    
    open func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
*/





import Foundation
import UIKit

public class ActivityIndicator {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var label = UILabel()
    
    public class var shared: ActivityIndicator {
        struct Static {
            static let instance: ActivityIndicator = ActivityIndicator()
        }
        return Static.instance
    }
    
    public func showProgressView(uiView: UIView, text:String="Loading...") {
        containerView.frame = uiView.frame
        containerView.center = uiView.center
        containerView.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        progressView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: 30.0, y: 30.0)
        
        label.text=text
        label.textColor=UIColor.white
        let maxHeight : CGFloat = 60
        let rect = label.attributedText?.boundingRect(with: CGSize(width: containerView.frame.size.width - 80.0, height: maxHeight),
                                                      options: .usesLineFragmentOrigin, context: nil)
        var frame = label.frame
        frame.origin.x = 60
        frame.origin.y = 0
        frame.size.height = 60
        frame.size.width = rect!.width + 30
        label.frame = frame
        
        progressView.frame = CGRect(x: 0.0, y: 0.0, width: activityIndicator.frame.size.width + label.frame.size.width, height: 60.0)
        progressView.center = uiView.center
        progressView.addSubview(activityIndicator)
        progressView.addSubview(label)
        
        containerView.addSubview(progressView)
        uiView.addSubview(containerView)
        activityIndicator.startAnimating()
    }
    public func hideProgressView() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        label.removeFromSuperview()
        progressView.removeFromSuperview()
        containerView.removeFromSuperview()
    }
    
    public func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}


