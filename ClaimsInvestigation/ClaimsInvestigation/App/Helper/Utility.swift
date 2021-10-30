//
//  Utility.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 20/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit
import SystemConfiguration
import AVFoundation
import CoreTelephony

protocol UtilityProtocol {
    
    func dismissAlert()
    func pushToViewController()
    func pushToNextViewController()
}

struct UtilityTag {
    static let kActivityTag = 12312
}

private var utilityInstance: Utility? = nil

class Utility: NSObject {
    
    var delegate:UtilityProtocol? = nil
    
    static var sharedUtility : Utility {
        
        if utilityInstance == nil {
            utilityInstance = Utility()
        }
        return utilityInstance!
    }
    
    //alert
    func alertView(controller: UIViewController, delegate :UtilityProtocol ,title: String, message: String, buttonOneTitle: String, buttonTwoTitle: String, tag: Int) -> UIView {
        
        self.delegate = delegate
        
        let frame = UIScreen.main.bounds
        var xPos:CGFloat = 0.0
        var yPos:CGFloat = 0.0
        var width:CGFloat = frame.size.width
        var height:CGFloat = frame.size.height
        var alertMessageHeight = getHeightFromText(text: message, font:  DeviceType.IPAD ? FontsFamily.kRegular :  FontsFamily.kRegular)
        let bgView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        bgView.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.6)
        
        width = DeviceType.IPAD ? 350.0 : 250.0
        xPos = (frame.size.width - width) / 2.0
        
        
        let alertLabel = UILabel(frame: CGRect(x: 0.0, y: yPos, width: width, height: height))
        alertLabel.text = message
        alertLabel.font = DeviceType.IPAD ? FontsFamily.kRegular :  FontsFamily.kRegular
        alertLabel.numberOfLines = 0
        alertLabel.textAlignment = .center
        alertLabel.sizeToFit()
        
        if DeviceType.IPAD {
            height = alertMessageHeight > 100.0 ? ((345.0 + alertMessageHeight) > 780) ? 780 : (345.0 + alertMessageHeight) : 240.0
        }else {
            height = alertMessageHeight > 80.0 ? (80.0 + alertMessageHeight) : 140.0
        }
        alertMessageHeight = height
        yPos = (frame.size.height - height) / 2.0
        let headerFooterheight : CGFloat = 120.0
        let alertViewHeight = DeviceType.IPAD ? ((alertLabel.frame.size.height + headerFooterheight) <= 180.0) ? 180.0 : (alertLabel.frame.size.height + headerFooterheight) : (alertLabel.frame.size.height + headerFooterheight)
        let frameHeight : CGFloat = frame.size.height - headerFooterheight
        let alertView = UIView(frame: CGRect(x: xPos, y: ((alertViewHeight + 60.0) > frameHeight ) ? 20.0 : yPos , width: width, height: (alertViewHeight > frameHeight) ? frameHeight : alertViewHeight))
        alertView.backgroundColor = UIColor.white
        alertView.layer.cornerRadius = 10.0
        bgView.addSubview(alertView)
        
        xPos = 0.0
        height = DeviceType.IPAD ? 60.0 : 40.0
        yPos = alertView.frame.size.height - (DeviceType.IPAD ? 60.0 : 40.0)
        width = (buttonTwoTitle.count > 0) ? (alertView.frame.size.width - 1) / 2.0 : alertView.frame.size.width
        let buttonOne = Button(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        buttonOne.clipsToBounds = false
        buttonOne.backgroundColor = UIColor.clear
        buttonOne.tag = tag
        buttonOne.titleLabel?.font = DeviceType.IPAD ? FontsFamily.kRegular :  FontsFamily.kRegular
        buttonOne.setTitleColor(UIColor.white, for: UIControlState.normal)
        buttonOne.setTitle(buttonOneTitle, for: UIControlState.normal)
        buttonOne.addTarget(self, action: #selector(buttonOneTapped(_:)), for: UIControlEvents.touchUpInside)
        alertView.addSubview(buttonOne)
        
        
        if buttonTwoTitle.count > 0 {
            xPos = buttonOne.frame.size.width
            width = 1.0
            let lineView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
            lineView.backgroundColor = UIColor.clear
            alertView.addSubview(lineView)
            
            xPos = lineView.frame.origin.x + lineView.frame.size.width
            width = (alertView.frame.size.width - 1) / 2.0
            let buttonTwo = Button(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
            buttonTwo.clipsToBounds = false
            buttonTwo.backgroundColor = UIColor.clear
            buttonTwo.tag = tag
            buttonTwo.titleLabel?.font = DeviceType.IPAD ? FontsFamily.kRegular :  FontsFamily.kRegular
            buttonTwo.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonTwo.setTitle(buttonTwoTitle, for: UIControlState.normal)
            buttonTwo.addTarget(self, action: #selector(buttonTwoTapped(_:)), for: UIControlEvents.touchUpInside)
            alertView.addSubview(buttonTwo)
        }
        
        xPos = 5.0
        yPos = 0.0
        width = alertView.frame.size.width - 2 * xPos
        height = DeviceType.IPAD ? 60.0 : 40.0
        let alertTitle = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        alertTitle.text = title
        alertTitle.font = DeviceType.IPAD ? FontsFamily.kRegular :  FontsFamily.kRegular
        alertTitle.textAlignment = .center
        alertView.addSubview(alertTitle)
        
        xPos = 0.0
        yPos = alertTitle.frame.size.height
        width = alertView.frame.size.width
        height = 1.0
        let titleLineView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        titleLineView.backgroundColor = UIColor.gray
        alertView.addSubview(titleLineView)
        
        xPos = 0.0
        yPos = alertTitle.frame.size.height
        width = alertView.frame.size.width
        
        
        height = alertView.frame.size.height - buttonOne.frame.size.height - alertTitle.frame.size.height
        let scrollView = UIScrollView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        scrollView.showsHorizontalScrollIndicator = false
        alertView.addSubview(scrollView)
        
        xPos = 5.0
        yPos = 0.0
        width = scrollView.frame.size.width - 2 * xPos
        if DeviceType.IPAD {
            height = alertMessageHeight < scrollView.frame.size.height ?  scrollView.frame.size.height : alertMessageHeight + 30.0
        }else {
            height = alertMessageHeight < scrollView.frame.size.height ?  scrollView.frame.size.height : alertMessageHeight
            
        }
        
        scrollView.addSubview(alertLabel)
        
        
        //Alert view width
        var labelNewFrame = alertLabel.frame
        labelNewFrame.size.width = alertView.frame.size.width
        alertLabel.frame = labelNewFrame
        
        //Scroll View height
        var newFrame = scrollView.frame
        newFrame.origin.y =  60.0
        newFrame.size.height = ((alertViewHeight > frameHeight) ? frameHeight : alertViewHeight) - headerFooterheight
        scrollView.frame = newFrame
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: alertLabel.frame.size.height + 60.0)
        
        scrollView.isScrollEnabled = false // vivek
        
        alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .allowUserInteraction, animations: {
            alertView.transform = .identity
        }) { _ in
            
        }
        
        return bgView
        
    }
    
    @IBAction func buttonOneTapped(_ sender:UIButton) {
        
        guard let delegate = self.delegate else {
            return
        }
        if sender.tag == 1
        {
            delegate.pushToViewController()
        }else
        {
            delegate.dismissAlert()
        }
    }
    
    @IBAction func buttonTwoTapped(_ sender:UIButton) {
        
        guard let delegate = self.delegate else {
            return
        }
        if sender.tag == 0
        {
            delegate.pushToViewController()
        }else if sender.tag == 2
        {
            delegate.pushToNextViewController()
        }else
        {
            delegate.dismissAlert()
        }
    }
    
    //MARK : Activity Indicator
    func showActivity(message:String ,view:UIView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let frame : CGRect = UIScreen.main.bounds
        var xPos, yPos, width, height : CGFloat
        xPos = 0.0
        yPos = 0.0
        width = frame.size.width
        height = frame.size.height
        // background view
        let backGroundView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        backGroundView.backgroundColor = UIColor.init(red: 58.0/255.0, green: 71.0/255.0, blue: 88.0/255.0, alpha: 0.7)
        backGroundView.tag = UtilityTag.kActivityTag
        view.addSubview(backGroundView)
        
        //progress view
        let paddindg : CGFloat = 80.0
        width = backGroundView.frame.size.width - 20.0
        height = self.getHeightFromText(text: message, font: UIFont.systemFont(ofSize: 13.0)) + paddindg
        xPos = round((backGroundView.frame.size.width - width)/2)
        yPos = round((backGroundView.frame.size.height - height - 64.0)/2) - 40.0
        let progressView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        progressView.backgroundColor = ColorConstant.kThemeColor

//        progressView.backgroundColor = UIColor.init(red: 58.0/255.0, green: 71.0/255.0, blue: 88.0/255.0, alpha: 0.9)
        //backGroundView.addSubview(progressView)
        progressView.layer.cornerRadius = 5.0
        progressView.layer.masksToBounds = true
        progressView.layer.borderWidth = 0.5
        progressView.layer.borderColor = UIColor.white.cgColor
        
        // title
        xPos = 0.0
        yPos = 0.0
        width = progressView.frame.size.width
        height = 40.0
        let title = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        title.backgroundColor = UIColor.clear
        title.text = "HITPA"
        title.textAlignment = .center
        title.textColor = UIColor.white
        progressView.addSubview(title)
        // line
        xPos = 0.0
        yPos = title.frame.size.height
        width = progressView.frame.size.width
        height = 0.5
        let line = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        line.backgroundColor = UIColor.white
        progressView.addSubview(line)
        
        //activity
        
        width = 60.0
        height = 60.0
        xPos = (backGroundView.frame.size.width - width)/2.0
        yPos = (backGroundView.frame.size.height - height - 64.0)/2.0
        let imageView = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        imageView.image = UIImage(named: "")
        let animatingImages: [UIImage] = [UIImage(named: "Activity1")!, UIImage(named: "Activity2")!, UIImage(named: "Activity3")!, UIImage(named: "Activity4")!, UIImage(named: "Activity5")!, UIImage(named: "Activity6")!, UIImage(named: "Activity7")!,UIImage(named: "Activity8")!,UIImage(named: "Activity9")!,UIImage(named: "Activity10")!,UIImage(named: "Activity11")!,UIImage(named: "Activity2")!]
        imageView.animationImages = animatingImages
        imageView.animationDuration = 1.0
        imageView.startAnimating()
        backGroundView.addSubview(imageView)
        // message
        xPos = imageView.frame.size.width + 8.0
        yPos = title.frame.size.height
        width = progressView.frame.size.width - imageView.frame.size.width
        height = progressView.frame.size.height - (title.frame.size.height + 10.0)
        let messageLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.text = message
        messageLabel.textAlignment = .left
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        progressView.addSubview(messageLabel)
        
    }
    // stop activity
    func stopActivity(view:UIView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let subViews = view.subviews
        for subview in subViews
        {
            if subview.tag == UtilityTag.kActivityTag
            {
                DispatchQueue.main.async(execute: {
                    subview.removeFromSuperview()
                })
                
            }
        }
    }
    
    //show label animation
    func labelAnimation(textfield: UITextField, isHidden: Bool) {
        let subviews = textfield.subviews
        
        var placeholderLbl:UILabel?
        for obj in subviews {
            if obj is UILabel {
                if (obj as? UILabel)?.text == textfield.placeholder {
                    placeholderLbl = obj as? UILabel
                    break
                }
            }
        }
        UIView.animate(withDuration: 0.4, animations: {
            placeholderLbl?.isHidden = isHidden
            placeholderLbl?.frame = CGRect(x: (placeholderLbl?.frame.origin.x)!, y: (isHidden) ? 20.0 : -5.0, width: (placeholderLbl?.frame.size.width)!, height: (placeholderLbl?.frame.size.height)!)
            print("")
        }, completion: { finished in
            
        })
        
    }
    
    //show textview label animation
    func textviewLabelAnimation(textview: UITextView, isHidden: Bool) {
        let subviews = textview.subviews
        for obj in subviews {
            if obj is UILabel {
                let placeholderLbl = obj as! UILabel
                UIView.animate(withDuration: 0.4, animations: {
                    placeholderLbl.isHidden = isHidden
                    placeholderLbl.numberOfLines = 2  // vivek
                    placeholderLbl.adjustsFontSizeToFitWidth = true  // vivek
                    placeholderLbl.textColor = UIColor.lightGray      // vivek
                    placeholderLbl.frame = CGRect(x: (placeholderLbl.frame.origin.x), y: (isHidden) ? 20.0 : 0.0, width: (placeholderLbl.frame.size.width), height: (placeholderLbl.frame.size.height))
                    print("")
                }, completion: { finished in
                    
                })
            }
        }
    }
    
    //Get height from text with given frame
    func getHeightFromText(text : String, font :UIFont)-> CGFloat
    {
        let frame = UIScreen.main.bounds
        let xPos : CGFloat = 8.0
        let yPos : CGFloat = 0.0
        let width : CGFloat = frame.size.width - (xPos * 2)
        let height : CGFloat = 1000.0
        
        let lable = UILabel(frame: CGRect(x: xPos, y: yPos, width: width , height: height
        ))
        lable.text = text
        lable.textColor = UIColor.white
        lable.font = font
        lable.numberOfLines = 0
        lable.sizeToFit()
        return lable.frame.size.height
    }
    
    
    func getHeightFromTextWithGivenFrame(frame: CGRect,text : String, font :UIFont)-> CGFloat
    {
        let xPos : CGFloat = frame.origin.x
        let yPos : CGFloat = frame.origin.y
        let width : CGFloat = frame.size.width - (xPos * 2)
        let height : CGFloat = 1000.0
        
        let label = UILabel(frame: CGRect(x: xPos, y: yPos, width: width , height: height
        ))
        label.text = text
        label.textColor = UIColor.white
        label.font = font
        label.numberOfLines = 0
        label.sizeToFit()
        return label.frame.size.height
    }
    
    
    func isInternetAvailable() -> Bool
    {
        // Update to address IPv6 requirements
        let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "https://google.com")
        
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        
        if SCNetworkReachabilityGetFlags(reachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
    func getInternetConnectionType() -> (String,String) {
        let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "https://google.com")
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        let _ = SCNetworkReachabilityGetFlags(reachability!, &flags)
        
        var isRunningOnDevice = false
        #if targetEnvironment(simulator)
        isRunningOnDevice = false
        #else
        isRunningOnDevice = true
        #endif
        if flags.contains(.reachable) && isRunningOnDevice && !flags.contains(.isWWAN) {
            return ("WiFi","WiFi")
        }
        
        return ("Mobile Data",getMobileDataType())
    }
    
    func getMobileDataType() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrierType = networkInfo.currentRadioAccessTechnology
        switch carrierType{
        case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?: return "2G"
        case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?: return "3G"
        case CTRadioAccessTechnologyLTE?: return "4G"
        default: return ""
        }
    }
    
    // device model name
    func deviceModelName() -> String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    //MARK : Date to millisecound
    func getMilliSecondWithDateString(dateString : String)-> Int64
    {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd MMM yyyy HH MM SS"
        let date = dateFormater.date(from: dateString)
        let since1970 = date?.timeIntervalSince1970
        return Int64(since1970! * 1000)
        
    }
    
    //MARK : Date to millisecound
    func getCalenderMilliSecoundWithDateString(dateString : String)-> Int64
    {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MMM/yyyy"
        let date = dateFormater.date(from: dateString)
        let since1970 = date?.timeIntervalSince1970
        return Int64(since1970! * 1000)
        
    }
    
    //date formatter
    func getDateStringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    //time formatter
    func getMillisecondsFromDateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyhhmmss"
        return dateFormatter.string(from: date)
    }
    
//    //time formatter
    func getTimeStringFromTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    //MARK: - ViewController
    func getViewController(view : UIView)-> UIViewController
    {
        var responder : UIResponder? = view
        while !(responder is UIViewController)
        {
            responder = responder?.next
            if nil == responder
            {
                break;
            }
        }
        return (responder as? UIViewController)!
    }
    
    
    //date formatter
    func getDateTimeStringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.string(from: date)
    }
    
    //Get feature date
    func getFeatureDateWithNoOfYear(noOfYear : Int)-> String
    {
        let toDate = Calendar.current.date(byAdding: .year, value:noOfYear, to: Date())
        return getDateStringFromDate(toDate!)
    }
    
    func getLabelWithSuperView(superView : UITextField) -> UILabel
    {
        let subViews = superView.subviews
        for item in subViews
        {
            if item is UILabel
            {
                return item as! UILabel
            }
        }
        return UILabel()
    }
    
    //MARK : Label height
    func getHeightFromTextWithFrame(text : String, font :UIFont, frame:CGRect)-> CGFloat
    {
        let xPos : CGFloat = 8.0
        let yPos : CGFloat = 0.0
        let width : CGFloat = frame.size.width - (xPos * 2)
        let height : CGFloat = 1000.0
        
        let lable = UILabel(frame: CGRect(x: xPos, y: yPos, width: width , height: height
        ))
        lable.text = text
        lable.textColor = UIColor.white
        lable.font = font
        lable.numberOfLines = 0
        lable.sizeToFit()
        return lable.frame.size.height
    }
    
    //Jusfy Label
    func justifyLabel(str: String) -> NSAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let attributedString = NSAttributedString(string: str,
                                                  attributes: [
                                                    NSAttributedStringKey.paragraphStyle: paragraphStyle,
                                                    NSAttributedStringKey.baselineOffset: NSNumber(value: 0)
            ])
        
        return attributedString
    }
    
    func getThumbImageFromVideoWithURL(url : URL)-> UIImage
    {
        let asset = AVURLAsset(url: URL(fileURLWithPath: url.path) as URL, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do
        {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }catch
        {
            return UIImage()
        }
    }
    
    func createWebRefNumber() -> String {
        var webReferenceNumber = "\(String(describing: UserManager.sharedManager.investigatorCode!))"
        //var webReferenceNumber = "SAMVAS78"
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = dateFormatter.string(from: date)
        webReferenceNumber.append(dateString)
        webReferenceNumber.append("1234")
        //Creating media directory
        DocumentDirectory.shareDocumentDirectory.createDirectoryWithRefNumber(refNumber: webReferenceNumber)
        
        return webReferenceNumber
    }
    
}

extension UtilityProtocol {
    
    func pushToViewController() {
        
    }
    func pushToNextViewController() {
        
    }

}

extension Date
{
    func years(from date: Date) -> Int
    {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    func months(from date: Date) -> Int
    {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
}

