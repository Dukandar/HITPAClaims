//
//  LocationManager.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 16/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import CoreLocation

protocol Location {
    func locationWithLatLong(latitude:Double,longitude:Double,location:String)
    func currentLocation(pincode:String)
    func locationDisabled()
}

struct SingletonLocation {
    static let instance = LocationManager()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager! = nil
    var delegate:Location! = nil
    var isLocationUpdate:Bool = true
    
    class var sharedLocation:LocationManager {
        struct SingletonLocation {
            static let instance = LocationManager()
        }
        return SingletonLocation.instance
    }
    
    func checkForLocationAuthorization() -> Bool {
        var isLocation: Bool = false
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.restricted {
                isLocation = false
            }
            else
            {
                isLocation = true
            }
        }
        return isLocation
    }
    
    func locationStatus(delegate: Location) {
        self.delegate = delegate
        isLocationUpdate = true
        
        if !checkForLocationAuthorization() {
            if self.delegate != nil {
                self.delegate.locationDisabled()
            }
        }else {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            
            if #available(iOS 8.0, *) {
                locationManager.requestAlwaysAuthorization()
                
            }else {
                // fallback for previous versions
            }
            
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        
        if UIApplication.shared.applicationState == UIApplicationState.active && isLocationUpdate {
            
            isLocationUpdate = false
            
            if (self.delegate != nil) {
                self.delegate.locationWithLatLong(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, location: "")
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.denied {
            if (self.delegate != nil) {
                self.delegate.locationDisabled()
            }
        }
    }

}

extension Location  {
    func currentLocation(pincode:String) {
        
    }
    func locationDisabled(){
        
    }
}
