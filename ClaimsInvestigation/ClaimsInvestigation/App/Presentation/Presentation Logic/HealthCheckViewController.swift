//
//  HealthCheckViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 02/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import CoreLocation
import SystemConfiguration


class HealthCheckViewController: UIViewController {

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblConnSpeed: UILabel!
    @IBOutlet weak var lblInternetConnection: UILabel!
    @IBOutlet weak var lblWarningTitle: UILabel!
    @IBOutlet weak var lblLocationHigh: UILabel!
    @IBOutlet weak var lblNetworkType: UILabel!
    @IBOutlet weak var imgLocationFound: UIImageView!
    @IBOutlet weak var imgInternetConnected: UIImageView!
    @IBOutlet weak var lblInternetSpeed: UILabel!
    @IBOutlet weak var lblInternetMode: UILabel!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblWarning_widthLayout: NSLayoutConstraint!
    @IBOutlet weak var lblInternetMode_widthLayout: NSLayoutConstraint!
    @IBOutlet weak var lblInternetSpeed_widthLayout: NSLayoutConstraint!
    @IBOutlet weak var lblLocationHigh_widthLayout: NSLayoutConstraint!

    var reachability: Reachability!
    
    typealias speedTestCompletionHandler = (_ megabytesPerSecond: Double? , _ error: Error?) -> Void
    
    var speedTestCompletionBlock : speedTestCompletionHandler?
    
    var startTime: CFAbsoluteTime!
    var stopTime: CFAbsoluteTime!
    var bytesReceived: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationController?.isNavigationBarHidden = true
        
        self.locationStatusUpdate()
        
        reachability = Reachability()
        
        if UIScreen.main.bounds.size.width > 320.0 {
             lblLocation.font = UIFont.systemFont(ofSize: 17.0)
            lblConnSpeed.font = UIFont.systemFont(ofSize: 17.0)
            lblInternetConnection.font = UIFont.systemFont(ofSize: 17.0)
            lblWarningTitle.font = UIFont.systemFont(ofSize: 17.0)
            lblLocationHigh.font = UIFont.systemFont(ofSize: 17.0)
            lblNetworkType.font = UIFont.systemFont(ofSize: 17.0)
            lblInternetSpeed.font = UIFont.systemFont(ofSize: 17.0)
            lblInternetMode.font = UIFont.systemFont(ofSize: 17.0)
            
        }else {
            lblLocation.font = UIFont.systemFont(ofSize: 15.0)
            lblConnSpeed.font = UIFont.systemFont(ofSize: 14.0)
            lblInternetConnection.font = UIFont.systemFont(ofSize: 15.0)
            lblWarningTitle.font = UIFont.systemFont(ofSize: 14.0)
            lblLocationHigh.font = UIFont.systemFont(ofSize: 14.0)
            lblNetworkType.font = UIFont.systemFont(ofSize: 15.0)
            lblInternetSpeed.font = UIFont.systemFont(ofSize: 15.0)
            lblInternetMode.font = UIFont.systemFont(ofSize: 15.0)
        }
        
        self.networkCheck()

        self.locationCheck()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkCheck), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationCheck), name: NSNotification.Name(rawValue: LocationEnableStatus.kLocationEnabled), object: nil)
    }
    
    @objc func networkCheck() {
        
        // check for internet
        if reachability.isConnectedToNetwork() {
            if(reachability.connectionStatus().description ) .elementsEqual(ReachabilityType.WiFi.description) {
                lblInternetMode.text = (reachability.connectionStatus().description)
                lblInternetSpeed.text = "72 Mbps"
                
                self.testDownloadSpeedWithTimout(timeout: 10.0) { (speed, error) in
                    print("Download Speed:", speed ?? "NA")
                    
                    DispatchQueue.main.async {
                        if error == nil {
                            self.lblInternetSpeed.text = String.init(format: "%.2f Mbps", (speed! < 0 ? (-1 * speed!) : speed!) )
                        }else {
                            self.lblInternetSpeed.text = error as? String
                        }
                    }
                }
            }else {
                lblInternetMode.text = (reachability.connectionStatus().description)
                lblInternetSpeed.text = reachability.getMobileDataType()
            }
            
            imgInternetConnected.image = #imageLiteral(resourceName: "success")
            lblInternetMode_widthLayout.constant = 145.0
            lblInternetSpeed_widthLayout.constant  = 145.0
            
        }else {
            lblInternetMode.text = LabelNamesConstant.kNoInternet
            imgInternetConnected.image = UIImage.init(named: "ic_error_red")
            lblInternetSpeed.text = LabelNamesConstant.kNotApplicable
            
            lblInternetMode_widthLayout.constant = 0.0
            lblInternetSpeed_widthLayout.constant  = 0.0
        }
    }
    
    @objc func locationCheck() {
        
        if LocationManager.sharedLocation.checkForLocationAuthorization() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                lblNetworkType.text = LabelNamesConstant.kNetworkBased
                lblLocationHigh.text = LabelNamesConstant.kEnableLocationPreciseMode
                imgLocationFound.image = #imageLiteral(resourceName: "warning")
                
                lblWarning_widthLayout.constant = 0.0
                lblLocationHigh_widthLayout.constant = 0.0

            case .authorizedAlways, .authorizedWhenInUse:
                lblNetworkType.text = LabelNamesConstant.kGPSBased
                lblLocationHigh.text = LabelNamesConstant.kLocationHighPreciseMode
                imgLocationFound.image = #imageLiteral(resourceName: "success")
                lblWarning_widthLayout.constant = 0.0
                lblLocationHigh_widthLayout.constant = 80.0
            }
        } else {
            
            lblNetworkType.text = LabelNamesConstant.kNetworkBased
            lblLocationHigh.text = LabelNamesConstant.kEnableLocationPreciseMode
            imgLocationFound.image = UIImage.init(named: "ic_error_red")
            lblWarning_widthLayout.constant = 0.0
            lblLocationHigh_widthLayout.constant = 0.0
        }
    }
   
    @IBAction func enableDisableInternet(_ sender: UITapGestureRecognizer) {
        
        try? PreferencesExplorer.openUrl(PreferenceType.network)
    }
    
    @IBAction func setLocation(_ sender: UITapGestureRecognizer) {
        try? PreferencesExplorer.openUrl(PreferenceType.locationServices)
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
                
        self.dismiss(animated: true, completion: nil)
    }
}

extension HealthCheckViewController : Location {
    
    func locationWithLatLong(latitude: Double, longitude: Double, location: String) {
        print(longitude)
        print(latitude)
    }

    
    @IBAction func locationStatusUpdate() {
        LocationManager.sharedLocation.locationStatus(delegate: self)
    }
}

extension HealthCheckViewController: URLSessionDataDelegate,URLSessionDelegate {
    
    func testDownloadSpeedWithTimout(timeout: TimeInterval, withCompletionBlock: @escaping speedTestCompletionHandler) {
        
        guard let url = URL(string: "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg") else { return }
        
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        
        speedTestCompletionBlock = withCompletionBlock
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
        session.dataTask(with: url).resume()
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived! += data.count
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let elapsed = stopTime - startTime
        
        if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
            speedTestCompletionBlock?(nil, error)
            return
        }
        
        let speed = elapsed != 0 ? Double(bytesReceived) / elapsed / 1024.0 / 1024.0 : -1
        speedTestCompletionBlock?(speed, nil)
        
    }
}
