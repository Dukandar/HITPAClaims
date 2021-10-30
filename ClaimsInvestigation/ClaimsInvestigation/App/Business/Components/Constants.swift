//
//  Constants.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 27/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit
import Foundation

struct HeaderFooterHeightConstant {
    static let kHeaderHeight = 80.0
    static let kFooterHeight = 60.0
    static let kNavigationHeight = 64.0
}

struct DeviceType {
    static let IPAD = (UI_USER_INTERFACE_IDIOM() == .pad)
}

extension Notification.Name {
    static let kImageCapturedNotification = Notification.Name("imageCaptured")
}

struct CaseType {
    static let kReimbursementLessThan1Lakh = "Reimbursement Claim Less than 1Lakh"
    static let kCashlessMoreThan1Lakh = "Cashless Claim More than 1Lakh"
    static let kCashlessLessThan1Lakh = "Cashless Claim Less than 1Lakh"
    static let kReimbursementMoreThan1Lakh = "Reimbursement Claim More than 1Lakh"
}


struct ColorConstant {
    static let kBorderColor = UIColor.init(red: 0.0/255.0, green: 47.0/255.0, blue: 103.0/255.0, alpha: 1.0).cgColor
    static let kThemeColor = UIColor.init(red: 0.0/255.0, green: 47.0/255.0, blue: 103.0/255.0, alpha: 1.0)
    static let KGrayBGColor = UIColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    static let kHighPriorityColor = UIColor.red
    static let kMediumPriorityColor = UIColor.brown
    static let kLowPriorityColor = UIColor.blue
}

struct LabelNamesConstant {
    static let kNotApplicable = "Tap here to enable internet"
    static let kNoInternet = "Internet not Connected"
    static let kNetworkBased = "Location not Enabled"
    static let kGPSBased = "GPS Based"
    static let kLocationHighPreciseMode = "Location is in high precise mode"
    static let kEnableLocationPreciseMode = "Tap here to enable location"
}

struct LocationEnableStatus {
    static let kLocationEnabled = "Location Enabled"
}


class Constants: NSObject {
    
    
}
