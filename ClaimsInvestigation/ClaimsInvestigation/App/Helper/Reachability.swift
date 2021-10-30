//
//  Reachability.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 03/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import CoreTelephony

public let ReachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"

public enum ReachabilityType : CustomStringConvertible {
    
    case WWAN
    case WiFi
    
    public var description: String {
        
        switch self {
        case .WWAN:
            return "Mobile Data"
        case .WiFi:
            return "WiFi"
        }
    }
}

public enum ReachabilityStatus : CustomStringConvertible {
    
    case Offline
    case Online(ReachabilityType)
    case Unknown
    
    public var description: String {
        
        switch self {
        case .Offline:
            return "Offline"
        case .Online(let type):
            return "\(type)"
        case .Unknown:
            return "Unknown"
        }
    }
}

public class Reachability: NSObject  {
    
    func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = (withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return .Unknown
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .Unknown
        }
        return ReachabilityStatus(reachabilityFlags: flags)
    }
    
    func monitorReachabilityChanges() {
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let status = ReachabilityStatus(reachabilityFlags: flags)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil, userInfo: ["Status": status.description])}, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
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
    
    public func getWiFiNumberOfActiveBars() -> Int? {
        let app = UIApplication.shared
        var numberOfActiveBars: Int?
        let exception = tryBlock {
            guard let containerBar = app.value(forKey: "statusBar") as? UIView else { return }
            guard let statusBarMorden = NSClassFromString("UIStatusBar_Modern"), containerBar .isKind(of: statusBarMorden), let statusBar = containerBar.value(forKey: "statusBar") as? UIView else { return }
            
            guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else { return }
            
            for view in foregroundView.subviews {
                for v in view.subviews {
                    if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarWifiSignalView"), v .isKind(of: statusBarWifiSignalView) {
                        if let val = v.value(forKey: "numberOfActiveBars") as? Int {
                            numberOfActiveBars = val
                            break
                        }
                    }
                }
                if let _ = numberOfActiveBars {
                    break
                }
            }
        }
        if let exception = exception {
            print("getWiFiNumberOfActiveBars exception: \(exception)")
        }
        
        return numberOfActiveBars
    }
    
    public func wifiStrength() -> Int? {
        let app = UIApplication.shared
        var rssi: Int?
        guard let statusBar = app.value(forKey: "statusBar") as? UIView, let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else {
            return rssi
        }
        for view in foregroundView.subviews {
            if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarDataNetworkItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                if let val = view.value(forKey: "wifiStrengthRaw") as? Int {
                    
                    print("rssi: \(val)")
                    
                    rssi = val
                    break
                }
            }
        }
        return rssi
    }

        
}

extension ReachabilityStatus {
    
    public init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if !connectionRequired && isReachable {
            if isWWAN {
                self = .Online(.WWAN)
            } else {
                self = .Online(.WiFi)
            }
        } else {
            self =  .Offline
        }
    }
}
