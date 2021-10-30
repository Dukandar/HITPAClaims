//
//  ClaimsInvestigation
//  UserDefaults.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 26/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

private var userDefaultsInstance = UserDefaults(suiteName: Configuration.sharedConfiguration.appName())

class HITPAUserDefaults: NSObject {
    
    static var sharedUserDefaults: UserDefaults {
        return userDefaultsInstance!
    }
}
