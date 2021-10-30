//
//  HomeViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 02/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class HomeViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var viewBackground: UIView!
    
    var navigationTitle: String?
    var status : Int?
    var caseID: Int64?
    var uploadCaseID: Int64?

    var isCaseUploading : Bool = false
    var submitCases = [[NSString:AnyObject]]()
    var downloadCases = [[NSString:AnyObject]]()
    var caseUploadCount : Int = 0
    
    var fldScrollview: UIScrollView?
    var webRefNumber  = ""
    
    var menuButton:UIButton?
    var sortCaseButton: UIButton?
    var viewSortCase: UIView? = nil
    var refreshControl = UIRefreshControl()
    var lblNewCasesFound: UILabel?

    var arrayAssignedCases: [AnyObject] = []
    var arrayCaseID : [String] = []
    
    var backgroundTaskID: UIBackgroundTaskIdentifier?

    convenience init(_ status: Int) {
        self.init()
        self.status = status
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = true
        
        if webRefNumber == "" {
            webRefNumber = UserManager.sharedManager.investigatorCode!
        }
        
        createHeader()
        
        NotificationCenter.default.addObserver(self, selector: #selector(createCaseView), name: NSNotification.Name(rawValue: "casePriorityChanged"), object: nil)
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if status == nil {
            status = 1
        }
        
        self.getAssignedCases()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if HITPAUserDefaults.sharedUserDefaults.bool(forKey: "isAutoSync") && status == 1 {
            
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.uploadCaseAutoSyncQueue), userInfo: nil, repeats: false)
        }
    }
    
    func createHeader(){
        
        let frame = UIScreen.main.bounds
        var xPos:CGFloat = 0.0
        var yPos:CGFloat = 20.0
        var width:CGFloat = frame.size.width
        var height:CGFloat = 60.0
        
        let headerView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        headerView.backgroundColor = ColorConstant.kThemeColor
        self.view.addSubview(headerView)
        
        xPos = 0.0
        width = 60.0
        height = 30.0
        yPos = headerView.frame.size.height/2 - height/2
        let leftView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        leftView.backgroundColor = UIColor.clear
        headerView.addSubview(leftView)
        
        xPos = 15.0
        width = 30.0
        height = 30.0
        yPos = 0.0
        
        let buttonImage = #imageLiteral(resourceName: "menu")
        menuButton = UIButton(type: UIButtonType.custom)
        menuButton?.setBackgroundImage(buttonImage, for: UIControlState.normal)
        menuButton?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        menuButton?.addTarget(self, action: #selector(menuButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        leftView.addSubview(menuButton!)
        
        xPos = headerView.frame.size.width - 60.0
        width = 60.0
        height = 30.0
        yPos = headerView.frame.size.height/2 - height/2
        
        let rightView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        rightView.backgroundColor = UIColor.clear
        headerView.addSubview(rightView)
        
        xPos = rightView.frame.size.width - 15.0 - 30.0
        width = 30.0
        height = 30.0
        yPos = 0.0
        
        let buttonImageSort = #imageLiteral(resourceName: "ic_sort_white")
        sortCaseButton = UIButton(type: UIButtonType.custom)
        sortCaseButton?.setBackgroundImage(buttonImageSort, for: UIControlState.normal)
        sortCaseButton?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        sortCaseButton?.addTarget(self, action: #selector(filterCasesButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        rightView.addSubview(sortCaseButton!)
        
        xPos = headerView.frame.size.width - rightView.frame.size.width - 50.0
        width = 60.0
        height = 50.0
        yPos = headerView.frame.size.height/2 - height/2

        let notifyView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        notifyView.backgroundColor = UIColor.clear
        headerView.addSubview(notifyView)
        
        width = 50.0
        xPos = 5.0
        height = 50.0
        yPos = 0.0
        
        let iconNotify = UIImage.init(named: "ic_notifications_white")
        let buttonNotify = UIButton(type: UIButtonType.custom)
        buttonNotify.setBackgroundImage(iconNotify, for: UIControlState.normal)
        buttonNotify.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        buttonNotify.addTarget(self, action: #selector(resetNotificationIcon(_:)), for: UIControlEvents.touchUpInside)
        notifyView.addSubview(buttonNotify)
        
        width = 15.0
        xPos = buttonNotify.frame.origin.x + buttonNotify.frame.size.width/2
        height = 15.0
        yPos = 5.0
        
        lblNewCasesFound = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        lblNewCasesFound?.backgroundColor = UIColor.clear
        lblNewCasesFound?.textColor = UIColor.black
        lblNewCasesFound?.textAlignment = .center
        lblNewCasesFound?.text = ""
        lblNewCasesFound?.numberOfLines = 1
        lblNewCasesFound?.font = UIFont.systemFont(ofSize: 12.0)
        notifyView.addSubview(lblNewCasesFound!)
        
        lblNewCasesFound?.layer.cornerRadius = (lblNewCasesFound?.frame.size.height)! / 2
        lblNewCasesFound?.layer.masksToBounds = true
        
        xPos = leftView.frame.size.width
        width = headerView.frame.size.width - (leftView.frame.size.width + rightView.frame.size.width + notifyView.frame.size.width)
        height = 30.0
        yPos = 10.0
        
        let labelHeaderTop = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        labelHeaderTop.text = "HITPA CLAIM INVESTIGATOR"
        labelHeaderTop.textAlignment = NSTextAlignment.left
        labelHeaderTop.textColor = UIColor.white
        labelHeaderTop.numberOfLines = 2
        labelHeaderTop.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(labelHeaderTop)
        
        height = 30.0
        yPos = labelHeaderTop.frame.origin.y + labelHeaderTop.frame.size.height - 5.0
        
        let labelHeaderBottom = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        labelHeaderBottom.text = self.navigationTitle != nil ? self.navigationTitle : "inbox"
        labelHeaderBottom.textAlignment = NSTextAlignment.left
        labelHeaderBottom.textColor = UIColor.white
        
        if #available(iOS 8.2, *) {
            labelHeaderTop.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.regular)
            labelHeaderBottom.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)
        } else {
            // Fallback on earlier versions
            labelHeaderBottom.font = UIFont.systemFont(ofSize: 16.0)
            labelHeaderTop.font = UIFont.systemFont(ofSize: 18.0)
        }
        
        headerView.addSubview(labelHeaderBottom)
    }
    
    func configureMailComposer(claimsNo : String) -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([""])
        mailComposeVC.setSubject("")
        mailComposeVC.setMessageBody("", isHTML: true)
        let pdfPath = DocumentDirectory.shareDocumentDirectory.directoryPath().appendingPathComponent("\(claimsNo)/\(claimsNo).pdf")
        do {
                 let data = try Data(contentsOf: pdfPath!)
                 mailComposeVC.addAttachmentData(data, mimeType: "application/pdf", fileName: "\(claimsNo).pdf")
           }
        catch {}
        return mailComposeVC
    }
    
    
    //MARK: - MFMail compose method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    //MARK:- BTN Action
    @IBAction func resetNotificationIcon(_ sender : UIButton) {
        
        lblNewCasesFound?.text = ""
        lblNewCasesFound?.backgroundColor = UIColor.clear
        
        lblNewCasesFound?.layer.borderColor = UIColor.clear.cgColor
        lblNewCasesFound?.layer.borderWidth = 0.0
        lblNewCasesFound?.layer.masksToBounds = true
    }
    
    @IBAction func sendEmailBtnTapped(_ sender : UIButton) {
        if (status! == 4) {
            let label = sender.superview?.superview?.subviews[22] as! UILabel
            if DocumentDirectory.shareDocumentDirectory.isPDFExistWith(claimNo: "\(label.text!)/\(label.text!).pdf") {
                let mailComposeViewController = configureMailComposer(claimsNo: label.text!)
              if MFMailComposeViewController.canSendMail(){
                  self.present(mailComposeViewController, animated: true, completion: nil)
              }else{
                  print("Can't send email")
              }
                
            }else{
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Report not Found! Select View Report first and Try Again", buttonOneTitle: "Ok", buttonTwoTitle:"", tag: 0)
                self.view.addSubview(alertView)
            }
        }
        
    }

    @IBAction func btnDeclineUploadTapped(_ sender : UIButton) {
        
        if status! == 1  {
            // reject the case
            
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Do you want to delete case? You cannot revert back after deleting!", buttonOneTitle: "Cancel", buttonTwoTitle: "Delete", tag: 2)
            self.view.addSubview(alertView)
            
            caseID = Int64(sender.tag)
            
            
        }else if (status! == 3) {
            
            // upload media first and after successful upload, upload case details.
            
            self.uploadCaseMedia(caseID: "\(sender.tag)")
        }else if (status! == 4) {
            if sender.superview?.superview?.subviews[22] is UILabel{
                let label = sender.superview?.superview?.subviews[22] as! UILabel
                let assignCaseID = (self.arrayAssignedCases[sender.superview!.tag] as! AssignedCases).caseID
                if DocumentDirectory.shareDocumentDirectory.isPDFExistWith(claimNo: "\(label.text!)/\(label.text!).pdf") {
                    let pdfVCTR = PDFViewController()
                    pdfVCTR.pdfPath = ""
                    pdfVCTR.claimsNo = label.text
                    let navigationVCTR = UINavigationController(rootViewController: pdfVCTR)
                    self.present(navigationVCTR, animated: true, completion: nil)
                }else{
                    if Utility.sharedUtility.isInternetAvailable() {
                        Utility.sharedUtility.showActivity(message: "", view: self.view)
                        let PDFURL = "http://223.30.163.104:91//Home/GenerateCasePdf?ClaimNo=\(label.text!)&Caseid=\(assignCaseID)"
                        HITPAAPI.sharedAPI.getAPIWith(path: PDFURL, completionHandler: {(data,error)-> Void in
                              DispatchQueue.main.async {
                                  Utility.sharedUtility.stopActivity(view: self.view)
                                if error == nil && data!.count > 0{
                                      let pdfPath = String(data: data!, encoding: .utf8)
                                      if (pdfPath != "PDF Data Not Available"){
                                      let pdfVCTR = PDFViewController()
                                      pdfVCTR.pdfPath = pdfPath
                                      pdfVCTR.claimsNo = label.text
                                      let navigationVCTR = UINavigationController(rootViewController: pdfVCTR)
                                      self.present(navigationVCTR, animated: true, completion: nil)
                                      }else{
                                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "PDF Data Not Available", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                        self.view.addSubview(alertView)
                                     }
                                }else{
                                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "PDF Data Not Available", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                    self.view.addSubview(alertView)
                                }
                              }
                         })
                    }else{
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }
            }
        }
    }
    
    @IBAction func btnCaseDetailsTapped(_ sender : UIButton) {
        
        let vctr = DashboardViewController()
        vctr.caseType = Int16(sender.tag)
        vctr.caseID = Int64((sender.superview?.tag)!)
        
        UserDefaults.standard.setValue("\((sender.superview?.tag)!)", forKeyPath: "caseID")
        UserDefaults.standard.synchronize()
        
        if self.navigationController == nil {
            self.present(vctr, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(vctr, animated: true)
        }
    }
    
    //menu  button
    @objc func menuButtonTapped(_ sender : UIButton) -> Void {
        
        if (sender.tag == 10)
        {
            sender.tag = 0
            let viewMenuBack : UIView = view.subviews.last!
            UIView.animate(withDuration: 0.3,
                           animations: { () -> Void in
                            var frameMenu : CGRect = viewMenuBack.frame
                            frameMenu.origin.x = -1 * UIScreen.main.bounds.width
                            viewMenuBack.frame = frameMenu
                            viewMenuBack.layoutIfNeeded()
                            viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                
                viewMenuBack.removeFromSuperview()
                
            })
            
        }else
        {
            sender.isEnabled = false
            sender.tag = 10
            let menuVctr = MenuViewController(nibName: "MenuViewController", bundle: nil)
            menuVctr.delegate  = self
            
            self.view.addSubview(menuVctr.view)
            
            self.addChildViewController(menuVctr)
            
            menuVctr.view.layoutIfNeeded()
            menuVctr.view.frame = CGRect(x:  -(UIScreen.main.bounds.size.width), y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            UIView.animate(withDuration: 0.3,
                           animations: {() -> Void in
                            menuVctr.view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                            sender.isEnabled = true
                            
            }, completion: nil)
            
        }
    }
    
    //sort cases button
    @objc func filterCasesButtonTapped(_ sender : UIButton) -> Void {
        
        if (sender.isSelected) {
            self.hideFilterCaseView()
            sender.isSelected = false
        }else {
            sender.isSelected = true
            self.showFilterCaseView()
        }
    }
    
    func updateCasePriorityAfter48Hrs() {
        
        let arrayAssignedCase: [AnyObject] =  DataModel.share.getAssignedCases(investigatorID: UserManager.sharedManager.investigatorCode!)
        
        for item  in arrayAssignedCase {
            
            let caseId = (item as! AssignedCases).caseID
            
            if (item as! AssignedCases).priorityStatus != 1 {
                
                let components = Calendar.current.dateComponents([.hour], from: (item as! AssignedCases).caseAllotmentDate!, to: Date())
                let hourDifference = components.hour!
                
                if hourDifference >= 48 {
                    // update case priority
                    
                    if (DataModel.share.updateAssignedCaseWithPriority(caseID: caseId, priorityStatus: 1, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                        print("priority updated for case --> \(caseId)")
                    }
                }
            }
        }
        
    }
    
    @IBAction func createCaseView() {
        
        let frame = Configuration.sharedConfiguration.bounds()
        
        let fieldMasterDetails = DataModel.share.getFieldMasterWithSectionHeader()
        
        if (fieldMasterDetails.count > 0) {
            
            var xPos:CGFloat = 0.0
            var yPos:CGFloat = 0.0
            var width:CGFloat = frame.size.width
            var height:CGFloat = frame.size.height - 80.0
            
            fldScrollview = UIScrollView(frame: CGRect(x:xPos,y:80.0,width:width,height:height))
            fldScrollview?.backgroundColor = ColorConstant.KGrayBGColor
            fldScrollview?.showsVerticalScrollIndicator = false
            fldScrollview?.alwaysBounceVertical = true
            self.view.addSubview(fldScrollview!)
            
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControlEvents.valueChanged)
            
            if status == 1 {
                fldScrollview?.addSubview(refreshControl)
                fldScrollview?.bringSubview(toFront: refreshControl)
            }
            
            let leading: CGFloat = 20.0
            
            xPos = leading
            yPos = 20.0
            width = (fldScrollview?.frame.size.width)!
            height = 50.0
            
            if UserManager.sharedManager.isInboxSelected == true {
                status = 1
            }
            
            var assignedCases : [AnyObject] = []
            
            if (UserManager.sharedManager.casePriority == 4) {
                assignedCases = DataModel.share.getAssignedCases(status: status!, investigatorID: UserManager.sharedManager.investigatorCode!)

            }else {
                assignedCases = DataModel.share.getAssignedCasesWithPriorityStatus(priorityStatus: UserManager.sharedManager.casePriority,status: status!, investigatorID: UserManager.sharedManager.investigatorCode!)
            }
            
            for (objIndex,Object) in assignedCases.enumerated() {
                
                let caseAssigned = (Object as! AssignedCases)
                
                let caseDetailMaster = DataModel.share.getAssignedCaseDetailForHeader(caseID: caseAssigned.caseID)
                
                let fldView = UIView(frame: CGRect(x: 10.0, y: yPos, width: (width - 20), height: height ))
                fldView.layer.cornerRadius = 8.0
                fldView.layer.masksToBounds = true
                fldView.layer.shadowRadius = 4.0
                fldView.backgroundColor = UIColor.white
                fldScrollview?.addSubview(fldView)
                
                fldView.tag = Int(caseAssigned.caseID)
                
                let uploadStatusView = UIView(frame: CGRect(x:0.0, y: 10.0, width: fldView.frame.size.width, height: 50.0))
                uploadStatusView.backgroundColor = UIColor.clear
                fldView.addSubview(uploadStatusView)
                
                uploadStatusView.tag = Int(caseAssigned.caseID)
                uploadStatusView.isHidden = true
                
                let uploadLabel = UILabel(frame: CGRect(x:10.0, y: 0.0, width: uploadStatusView.frame.size.width - (2 * 10.0), height: 20.0))
                uploadLabel.text = "Uploading Data"
                uploadLabel.textAlignment = .right
                uploadLabel.textColor = UIColor.darkGray
                uploadStatusView.addSubview(uploadLabel)
                
                let progressView = UIView(frame: CGRect(x:10.0, y: (uploadLabel.frame.size.height + uploadLabel.frame.origin.y + 5.0), width: (uploadStatusView.frame.size.width - 20.0), height: 5.0))
                
                uploadStatusView.addSubview(progressView)
                
                // Call Progress Bar
                let linearBar: LinearProgressBar = LinearProgressBar(frame: CGRect(x: 0.0, y: 0.0, width: progressView.frame.size.width, height: 5.0))
                
                //Change background color
                linearBar.backgroundColor = UIColor.lightGray
                linearBar.progressBarColor = ColorConstant.kThemeColor
                
                //Change height of progressBar
                linearBar.heightForLinearBar = 5
                
                //Add it to your MainView
                progressView.addSubview(linearBar)
                
                let btnCaseDetails = UIButton(type: UIButtonType.custom)
                btnCaseDetails.frame = CGRect(x: 10.0, y: 0.0, width: fldView.frame.size.width - 20.0, height: fldView.frame.size.height - 50.0)
                btnCaseDetails.backgroundColor = UIColor.clear
                
                btnCaseDetails.isEnabled = true
                btnCaseDetails.addTarget(self, action: #selector(btnCaseDetailsTapped(_:)), for: UIControlEvents.touchUpInside)
                fldView.addSubview(btnCaseDetails)
                
                let viewPriorityBadge = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 4.0, height: fldView.frame.size.height))
                
                fldView.addSubview(viewPriorityBadge)
                
                if (status == 3 || status == 4) {
                    btnCaseDetails.isUserInteractionEnabled = false
                    viewPriorityBadge.isHidden = true
                }else {
                    btnCaseDetails.isUserInteractionEnabled = true
                    viewPriorityBadge.isHidden = false
                }
                
                switch (Object as! AssignedCases).priorityStatus {
                case 1:
                    viewPriorityBadge.backgroundColor = UIColor.red
                    break
                case 2:
                    viewPriorityBadge.backgroundColor = UIColor.orange
                    break
                case 3:
                    viewPriorityBadge.backgroundColor = UIColor.green
                    break
                default:
                    viewPriorityBadge.backgroundColor = UIColor.cyan
                    break
                }
                
                var yPosField: CGFloat = 50.0
                
                var labelValue: UILabel? = nil
                
                for (index,fldItem) in fieldMasterDetails.enumerated()
                {
                    _ = index
                    
                    var tempString: String = ""
                    
                    let fldItemWidth = (fldView.frame.size.width - (leading * 2))/2
                    
                    let fldMasterData = fldItem as! FieldMaster
                    
//                    if (fldMasterData.master_fldId == 175213) || (fldMasterData.master_fldId == 175214) || (fldMasterData.master_fldId == 175762) || (fldMasterData.master_fldId == 175212) || (fldMasterData.master_fldId == 175215){
//
//                    }else {
                    
                        if ((fldMasterData.fldType == DataType.kLabel) || (fldMasterData.fldType == DataType.kName)) {
                            
                            var heightDynamicKey: CGFloat = 0.0
                            
                            var heightDynamicValue: CGFloat = 0.0
                            
                            var heightNew: CGFloat = 50.0
                            
                            heightDynamicKey = Utility.sharedUtility.getHeightFromTextWithFrame(text: fldMasterData.fldLabel!, font: UIFont.systemFont(ofSize: 16.0), frame: CGRect(x: leading, y: yPosField, width: fldItemWidth, height: heightNew))
                            
                            for caseDetailItem in caseDetailMaster {
                                let caseMasterData = caseDetailItem as! CaseDetail
                                
                                btnCaseDetails.tag = Int(caseMasterData.caseType)
                                
                                if (caseMasterData.fieldID == fldMasterData.master_fldId) {
                                    tempString = caseMasterData.fieldValue!
                                    break
                                }else {
                                    tempString = ""
                                }
                            }
                            
                            heightDynamicValue = Utility.sharedUtility.getHeightFromTextWithFrame(text: tempString, font: UIFont.systemFont(ofSize: 16.0), frame: CGRect(x: leading, y: yPosField, width: fldItemWidth, height: heightNew))
                            
                            if (heightDynamicKey >= heightDynamicValue) {
                                heightNew = heightDynamicKey
                            }else {
                                heightNew = heightDynamicValue
                            }
                            
                            let label = UILabel(frame: CGRect(x: leading, y: yPosField, width: fldItemWidth, height: heightNew))
                            label.text = fldMasterData.fldLabel
                            label.numberOfLines = 0
                            label.font = UIFont.systemFont(ofSize: 16.0)
                            fldView.addSubview(label)
                            
                            xPos = label.frame.origin.x + label.frame.size.width + 10.0
                            
                            labelValue = UILabel(frame: CGRect(x: xPos, y: yPosField, width: fldItemWidth, height: heightNew))
                            labelValue?.font = UIFont.systemFont(ofSize: 16.0)
                            labelValue?.numberOfLines = 0
                            labelValue?.text = tempString
                            fldView.addSubview(labelValue!)
                            
                            yPosField = yPosField + heightNew + 5.0
                        }
//                    }
                }
                
                let viewBottomLine = UIView(frame: CGRect(x: 20.0, y: yPosField + 20.0, width: fldView.frame.size.width - 40.0, height: 1.0))
                fldView.addSubview(viewBottomLine)
                viewBottomLine.backgroundColor = UIColor.lightGray
                
//                if (status != 4) {
                    viewBottomLine.isHidden = false
//                }else {
//                    viewBottomLine.isHidden = true
//                }
                
                let viewDecline = UIView(frame: CGRect(x: 18.0, y: viewBottomLine.frame.origin.y + viewBottomLine.frame.size.height + 10.0, width: fldView.frame.size.width - 40.0, height: 50.0))
                viewDecline.tag = objIndex
                fldView.addSubview(viewDecline)
                viewDecline.backgroundColor = UIColor.clear
                
                let btnImage = UIImageView(frame: CGRect(x: 10.0, y: 5.0, width: 30.0, height: 30.0))
                btnImage.image = UIImage.init(named: (status == 4) ? "ic_receiptblack.png" : "ic_highlight_remove_gray")
                btnImage.contentMode = UIViewContentMode.scaleAspectFit
                viewDecline.addSubview(btnImage)
                
                //VIEW REPORT
                let lblDecline = UILabel(frame: CGRect(x: (btnImage.frame.size.width + btnImage.frame.origin.x), y: 5.0, width: 120.0, height: 30.0))
                lblDecline.text =  (status == 4) ? "VIEW REPORT" : "DECLINE"
                if #available(iOS 8.2, *) {
                    lblDecline.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
                } else {
                    // Fallback on earlier versions
                    lblDecline.font = UIFont.boldSystemFont(ofSize: 15.0)

                }
                lblDecline.textAlignment = .left
                viewDecline.addSubview(lblDecline)
                
                //SEND EMAIL
                let sendEmail =  UIView(frame: CGRect(x: lblDecline.frame.size.width + 60.0, y: viewBottomLine.frame.origin.y + viewBottomLine.frame.size.height + 10.0, width: fldView.frame.size.width - 40.0, height: 50.0))
                if  (status == 4){
                    fldView.addSubview(sendEmail)
                }
                let sendImage = UIImageView(frame: CGRect(x: 20.0, y: 5.0, width: 30.0, height: 30.0))
                sendImage.image = UIImage.init(named:"ic_email_black_24dp.png")
                sendImage.contentMode = UIViewContentMode.scaleAspectFit
                sendEmail.addSubview(sendImage)
               //VIEW REPORT
                let sendDecline = UILabel(frame: CGRect(x: (btnImage.frame.size.width + btnImage.frame.origin.x + 14.0), y: 5.0, width: 120.0, height: 30.0))
               sendDecline.text = "SEND EMAIL"
               if #available(iOS 8.2, *) {
                   sendDecline.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
               } else {
                   // Fallback on earlier versions
                   sendDecline.font = UIFont.boldSystemFont(ofSize: 15.0)

               }
               sendDecline.textAlignment = .left
               sendEmail.addSubview(sendDecline)
                //Button
               let sendBtn = UIButton(type: UIButtonType.custom)
               sendBtn.frame = CGRect(x: 0.0, y: 0.0, width: sendEmail.frame.size.width, height: sendEmail.frame.size.height)
               sendBtn.backgroundColor = UIColor.clear
               sendBtn.isEnabled = true
               sendBtn.addTarget(self, action: #selector(sendEmailBtnTapped(_:)), for: UIControlEvents.touchUpInside)
               sendEmail.addSubview(sendBtn)
               
                
                switch status! {
                case 1:
                    viewDecline.isHidden = false
                    break
                case 2:
                    viewDecline.isHidden = true
                    yPosField = yPosField - 50.0
                    viewPriorityBadge.isHidden = true
                    break
                case 3:
                    
                    if HITPAUserDefaults.sharedUserDefaults.bool(forKey: "isAutoSync")  {
                        
                        viewDecline.isHidden = true
                        yPosField = yPosField - 50.0
                        uploadStatusView.isHidden = false
                        
                        // show animation here
                        linearBar.startAnimation()
                    
                    }else {
                        
                        viewDecline.isHidden = false
                        btnImage.image = #imageLiteral(resourceName: "ic_file_upload_black_24dp")
                        lblDecline.text = "UPLOAD"
                    }
                    break
                case 4:
                    
                    viewDecline.isHidden = false
                    //yPosField = yPosField - 50.0
                    uploadStatusView.isHidden = true

                    break
                default:
                    break
                }
                
                // Decline button
                let btnDecline = UIButton(type: UIButtonType.custom)
                btnDecline.frame = CGRect(x: 0.0, y: 0.0, width: viewDecline.frame.size.width, height: viewDecline.frame.size.height)
                btnDecline.backgroundColor = UIColor.clear
                btnDecline.isEnabled = true
                btnDecline.addTarget(self, action: #selector(btnDeclineUploadTapped(_:)), for: UIControlEvents.touchUpInside)
                viewDecline.addSubview(btnDecline)
                
                btnDecline.tag = Int(caseAssigned.caseID)
                
                fldView.frame.size.height = yPosField + 80.0
                
                btnCaseDetails.frame.size.height = fldView.frame.size.height - 80.0
                
                viewPriorityBadge.frame.size.height = fldView.frame.size.height
                
                yPos = yPos + fldView.frame.size.height + 20.0
            }
            
            fldScrollview?.contentSize = CGSize(width: (fldScrollview?.frame.size.width)!, height: yPos + 60.0)
        }
    }
    
    func rejectCase(caseID: Int64) {
        
        self.view.endEditing(true)
        var params  :[String:String] = [:]
        let apiName  = "RejectCase"
        
        params["CaseID"] = "\(caseID)"
        params["AuthToken"] = (UserManager.sharedManager.authToken)!
        
        if Utility.sharedUtility.isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                Utility.sharedUtility.showActivity(message: "", view: self.view)
            }
            
            HITPAAPI.sharedAPI.postAPIWithParams(params: params, methodName: apiName, completionHandler: { (data, error) in
                
                if data == nil && error == nil {
                    DispatchQueue.main.async {
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else if(error != nil) {
                    DispatchQueue.main.async {
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else {
                    let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                    
                    if (Int((response!!["ErrorCode"]) as! String) == 0)
                    {
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
                            // remove the case from case table and reload the UI.
                            
                            if (DataModel.share.deleteAssignedCase(caseID: caseID, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                                
                                if (DataModel.share.deleteAssignedCaseDetails(caseID: caseID)) {
                                    
                                    self.removeCaseView()
                                    
                                    if((DataModel.share.getAssignedCaseDetail() as [AnyObject]).count > 0) {
                                        
                                        // reload case view here
                                        
                                        self.createCaseView()
                                        
                                    }else {
                                        self.getAssignedCases()
                                    }
                                    
                                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                    self.view.addSubview(alertView)
                                }
                            }
                        }
                        
                    }else
                    {
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                            self.view.addSubview(alertView)
                        }
                    }
                }
            })
            
        }else {
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
            self.view.addSubview(alertView)
        }
    }
    
    @objc func pullToRefresh(sender:AnyObject) {
        
        self.view.endEditing(true)
        
        self.view.isUserInteractionEnabled = false
        
        var params  :[String:String] = [:]
        let apiName  = "GetAssignedCases"
        
        params["InvestigatorCode"] = (UserManager.sharedManager.investigatorCode)!
        params["AuthToken"] = (UserManager.sharedManager.authToken)!
        
        if Utility.sharedUtility.isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                Utility.sharedUtility.showActivity(message: "", view: self.view)
            }
            
            HITPAAPI.sharedAPI.postAPIWithParams(params: params, methodName: apiName, completionHandler: { (data, error) in
                
                if data == nil && error == nil {
                    DispatchQueue.main.async {
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        self.refreshControl.endRefreshing()
                        
                        self.view.isUserInteractionEnabled = true
                        
                    }
                }else if(error != nil) {
                    DispatchQueue.main.async {
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        self.refreshControl.endRefreshing()
                        
                        self.view.isUserInteractionEnabled = true

                    }
                }else {
                    let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                    
                    if (response!!["ErrorMessage"] is NSNull)
                    {
                        DispatchQueue.main.async {
                            self.refreshControl.endRefreshing()
                            
                            self.view.isUserInteractionEnabled = true

                        }
                        
                        let arrayIDs = (response!!["CaseIDS"] as! [AnyObject])
                        
                        var arrTempFiltered : [String] = []
                        
                        var arrayAssignedCasesTemp: [AnyObject] = []
                        
                        // Check case in inbox/draft/completed/submitted
                        arrayAssignedCasesTemp =  DataModel.share.getAssignedCases(investigatorID: UserManager.sharedManager.investigatorCode!)
                        
                        if  arrayAssignedCasesTemp.count > 0{
                            
                            for item in arrayIDs {
                                
                                if arrayAssignedCasesTemp.contains(where: { $0.caseID == Int64(item as! String) }) {
                                    // found
//                                    print("found \(item)")
                                } else {
//                                    print("not found \(item)")
                                    arrTempFiltered.append(item as! String)
                                }
                            }
                            
                            if arrTempFiltered.count > 0 {
                                
                                self.arrayCaseID.removeAll()
                                
                                self.arrayCaseID = arrTempFiltered
                                
                                DispatchQueue.main.async {
                                    self.lblNewCasesFound?.text = "\(self.arrayCaseID.count)"
                                    self.lblNewCasesFound?.backgroundColor = UIColor.red
                                    self.lblNewCasesFound?.textColor = UIColor.white
                                    
                                    self.lblNewCasesFound?.layer.borderColor = UIColor.black.cgColor
                                    self.lblNewCasesFound?.layer.borderWidth = 0.5
                                    self.lblNewCasesFound?.layer.masksToBounds = true
                                }
                                
                                // new cases are added
                                
                                self.removeCaseView()
                                
                                if (DataModel.share.insertIntoAssignedCases(assignedCaseArray: arrTempFiltered as [AnyObject])) {
                                    print("cases added in DB \(arrTempFiltered)")
                                }
                                
                                self.getAssignedCaseDetails(caseIDArray: self.arrayCaseID)
                                
                            }else {
                                
                                DispatchQueue.main.async {
                                    Utility.sharedUtility.stopActivity(view: self.view)
                                    
                                    self.refreshControl.endRefreshing()
                                    
                                    self.view.isUserInteractionEnabled = true

                                    
//                                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No new cases found.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
//                                    self.view.addSubview(alertView)
                                }
                            }
                        }
                    }else if (response!!["ErrorMessage"] as! String).contains("Invalid token")
                    {
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
                            self.refreshControl.endRefreshing()
                            
                            self.view.isUserInteractionEnabled = true

                            
                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Session Expired. Please login again.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
                            self.view.addSubview(alertView)
                        }
                    }else {
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
                            self.refreshControl.endRefreshing()
                            
                            self.view.isUserInteractionEnabled = true

                        }
                    }
                }
            })
            
        }else {
            
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
            self.view.addSubview(alertView)
            
            self.refreshControl.endRefreshing()
            
            self.view.isUserInteractionEnabled = true

        }
    }
    
    func removeCaseView() {
        
        DispatchQueue.main.async {
            
            let subviews = self.view.subviews
            
            for view in subviews {
                
                if (view.isKind(of: UIScrollView.self)) {
                    view.removeFromSuperview()
                }
                
                if (view.tag == UtilityTag.kActivityTag) {
                    view.removeFromSuperview()
                }
            }
        }
    }

    @objc func getAssignedCases() {
        
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        var params  :[String:String] = [:]
        let apiName  = "GetAssignedCases"
        var arrayCaseID : [String] = []
        
        arrayAssignedCases =  DataModel.share.getAssignedCases(status: status!, investigatorID: UserManager.sharedManager.investigatorCode!)
        
        if UserManager.sharedManager.isValidUser()
        {
            if  arrayAssignedCases.count > 0{
                
                // get cases details here
                
                for item in arrayAssignedCases {
                    
                    let caseID = (item as! AssignedCases).caseID
                    
                    arrayCaseID.append("\(caseID)")
                }
                
                if (arrayCaseID.count > 0) {
                    
                    // check case allotment date here
                    self.updateCasePriorityAfter48Hrs()
                    
                    if((DataModel.share.getAssignedCaseDetail() as [AnyObject]).count > 0) {
                        // create case view here
                        
                        DispatchQueue.global(qos: .background).async {
                            self.removeCaseView()
                            
                            DispatchQueue.main.async {
                                self.createCaseView()
                            }
                            
                            DispatchQueue.main.async {
                                
                                if self.status == 1 {
                                    
                                    _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.pullToRefresh), userInfo: nil, repeats: false)
                                }
                            }
                        }
                        
                    }else {
                        self.getAssignedCaseDetails(caseIDArray: arrayCaseID)
                    }
                }
                
            }else if ((arrayAssignedCases.count == 0) && (status == 1) && (DataModel.share.getCaseDetailsForWebRefNumber(UserManager.sharedManager.investigatorCode!).count > 0)) {
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No case found in inbox", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                self.view.addSubview(alertView)
            }
            
            else {
                
                // get assigned case here when user on Inbox page
                
                if (status == 1) {
                    
                    params["InvestigatorCode"] = (UserManager.sharedManager.investigatorCode)!
                    params["AuthToken"] = (UserManager.sharedManager.authToken)!
                    
                    if Utility.sharedUtility.isInternetAvailable() {
                        
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.showActivity(message: "", view: self.view)
                        }
                        
                        
                        HITPAAPI.sharedAPI.postAPIWithParams(params: params, methodName: apiName, completionHandler: { (data, error) in
                            
                            if data == nil && error == nil {
                                DispatchQueue.main.async {
                                    Utility.sharedUtility.stopActivity(view: self.view)
                                    
                                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                    self.view.addSubview(alertView)
                                }
                            }else if(error != nil) {
                                DispatchQueue.main.async {
                                    Utility.sharedUtility.stopActivity(view: self.view)
                                    
                                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                    self.view.addSubview(alertView)
                                }
                            }else {
                                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                                
                                if (response!!["ErrorMessage"] is NSNull)
                                {
                                    DispatchQueue.main.async {
                                        // save response here
                                        
                                        if (DataModel.share.insertIntoAssignedCases(assignedCaseArray: (response!!["CaseIDS"] as! [AnyObject]))) {
                                            
                                            self.arrayAssignedCases.removeAll()
                                            
                                            self.arrayAssignedCases =  DataModel.share.getAssignedCases(status: self.status!, investigatorID: UserManager.sharedManager.investigatorCode!)
                                            
                                            if  self.arrayAssignedCases.count > 0{
                                                
                                                // get cases details here
                                                
                                                for item in self.arrayAssignedCases {
                                                    
                                                    let caseID = (item as! AssignedCases).caseID
                                                    
                                                    arrayCaseID.append("\(caseID)")
                                                }
                                                
                                                if (arrayCaseID.count > 0) {
                                                    
                                                    if((DataModel.share.getAssignedCaseDetail() as [AnyObject]).count > 0) {
                                                        // create case view here
                                                        DispatchQueue.global(qos: .background).async {
                                                            self.removeCaseView()
                                                            
                                                            DispatchQueue.main.async {
                                                                self.createCaseView()
                                                            }
                                                        }
                                                        
                                                    }else {
                                                        self.getAssignedCaseDetails(caseIDArray: arrayCaseID)
                                                    }
                                                }
                                            }else {
//                                                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No new cases assigned.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
//                                                self.view.addSubview(alertView)
                                            }
                                        }
                                        Utility.sharedUtility.stopActivity(view: self.view)
                                    }
                                    
                                }else
                                {
                                    DispatchQueue.main.async {
                                        
                                        Utility.sharedUtility.stopActivity(view: self.view)
                                        
                                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                                        self.view.addSubview(alertView)
                                    }
                                }
                            }
                        })
                        
                    }else {
                        DispatchQueue.main.async {
                            Utility.sharedUtility.stopActivity(view: self.view)

                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                            self.view.addSubview(alertView)
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        
                        Utility.sharedUtility.stopActivity(view: self.view)

//                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No cases found", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
//                        self.view.addSubview(alertView)
                    }
                }
            }
            
        }else {
            DispatchQueue.main.async {
                
                Utility.sharedUtility.stopActivity(view: self.view)
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Not a valid user.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
                self.view.addSubview(alertView)
            }
        }
    }
    
    func getAssignedCaseDetails(caseIDArray: [String]) {
        
        DispatchQueue.main.async {
            
            self.view.endEditing(true)
        }
        var params  :[String:AnyObject] = [:]
        let apiName  = "GetAssignedCaseDetails"
        
        params["CaseID"] = caseIDArray as AnyObject
        params["AuthToken"] = (UserManager.sharedManager.authToken)! as AnyObject
        
        if Utility.sharedUtility.isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                Utility.sharedUtility.showActivity(message: "", view: self.view)
            }
            
            HITPAAPI.sharedAPI.getAssignedCasesDetailsWithParams(params: params, methodName: apiName, completionHandler: { (data, error) in
                
                if data == nil && error == nil {
                    DispatchQueue.main.async {
                        
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else if(error != nil) {
                    DispatchQueue.main.async {
                        
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else {
                    let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                    
                    if (response!!["ErrorMessage"] is NSNull)
                    {
                        DispatchQueue.main.async {
                            // save response here
                            
                            self.updateCasePriority(response: (response!!["CaseDetails"] as! [NSDictionary]))
                            
                            if (DataModel.share.insertIntoCaseDetail(response: (response!!["CaseDetails"] as! [NSDictionary]))) {
                                
                                // create case view here
                                self.createCaseView()
                            }
                            Utility.sharedUtility.stopActivity(view: self.view)
                        }
                        
                    }else
                    {
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
                            self.view.addSubview(alertView)
                        }
                    }
                }
            })
            
        }else {
            DispatchQueue.main.async {
                Utility.sharedUtility.stopActivity(view: self.view)
                
                let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                self.view.addSubview(alertView)
            }
        }
    }
    
    func showFilterCaseView() {
        
        var xPos: CGFloat = UIScreen.main.bounds.size.width/2
        var yPos: CGFloat = 0.0
        var width: CGFloat = UIScreen.main.bounds.size.width/2
        var height: CGFloat = 200.0
        
        viewSortCase = UIView(frame: CGRect(x: xPos, y: 80.0, width: width, height: height))
        viewSortCase?.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        viewSortCase?.isHidden = false
        self.view.addSubview(viewSortCase!)
        
        xPos = 20.0
        yPos = 0.0
        width = (viewSortCase?.frame.size.width)! - 2 * xPos
        height = 50.0
        
        let viewHighPriority = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewHighPriority.backgroundColor = UIColor.clear
        viewSortCase?.addSubview(viewHighPriority)
        
        let tagValue = "\(UserManager.sharedManager.casePriority)"
        
        let radioButtonHigh = RadioButtonCustom(frame: CGRect(x: 0.0, y: 0.0, width: viewHighPriority.frame.size.width, height: viewHighPriority.frame.size.height), label:"High" ,  responseValue : tagValue, delegate: self,tag :1)
        
        viewHighPriority.addSubview(radioButtonHigh)
        
        yPos = viewHighPriority.frame.size.height + viewHighPriority.frame.origin.y
        
        let viewMediumPriority = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewMediumPriority.backgroundColor = UIColor.clear
        viewSortCase?.addSubview(viewMediumPriority)
        
        let radioButtonMedium = RadioButtonCustom(frame: CGRect(x: 0.0, y: 0.0, width: viewMediumPriority.frame.size.width, height: viewMediumPriority.frame.size.height), label:"Medium" ,  responseValue : tagValue, delegate: self,tag :2)
        
        viewMediumPriority.addSubview(radioButtonMedium)
        
        yPos = viewMediumPriority.frame.size.height + viewMediumPriority.frame.origin.y
        
        let viewLowPriority = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewLowPriority.backgroundColor = UIColor.clear
        viewSortCase?.addSubview(viewLowPriority)
        
        let radioButtonLow = RadioButtonCustom(frame: CGRect(x: 0.0, y: 0.0, width: viewLowPriority.frame.size.width, height: viewLowPriority.frame.size.height), label:"Low" ,  responseValue : tagValue, delegate: self,tag :3)
        
        viewLowPriority.addSubview(radioButtonLow)
        
        yPos = viewLowPriority.frame.size.height + viewLowPriority.frame.origin.y
        
        let viewPriorityAll = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewPriorityAll.backgroundColor = UIColor.clear
        viewSortCase?.addSubview(viewPriorityAll)
        
        let radioButtonAll = RadioButtonCustom(frame: CGRect(x: 0.0, y: 0.0, width: viewPriorityAll.frame.size.width, height: viewPriorityAll.frame.size.height), label:"All" ,  responseValue : tagValue, delegate: self,tag :4)
        
        viewPriorityAll.addSubview(radioButtonAll)

    }
    
    func hideFilterCaseView() {
        
        for view in (viewSortCase?.subviews)! {
            if (view.isKind(of: UIView.self)) {
                view.removeFromSuperview()
            }
        }
        
        viewSortCase?.isHidden = true
    }
    
    func checkForAppUpdate() {
        
        self.view.endEditing(true)
        var params  :[String:String] = [:]
        let apiName  = "CheckForAppUpdate"
        
        params["IMEINo"] = Configuration.sharedConfiguration.getUDID()
        params["VersionNo"] = Configuration.sharedConfiguration.getVersion()
        
        if Utility.sharedUtility.isInternetAvailable() {
            
            DispatchQueue.main.async {
                
                Utility.sharedUtility.showActivity(message: "", view: self.view)
            }
            
            HITPAAPI.sharedAPI.postAPIWithParams(params: params, methodName: apiName, completionHandler: { (data, error) in
                
                if data == nil && error == nil {
                    DispatchQueue.main.async {
                        
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else if(error != nil) {
                    DispatchQueue.main.async {
                        
                        Utility.sharedUtility.stopActivity(view: self.view)
                        
                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                        self.view.addSubview(alertView)
                    }
                }else {
                    let response = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                    
                    if (response != nil)
                    {
                        DispatchQueue.main.async {
                            // save response here
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                        }
                        
                    }else
                    {
                        DispatchQueue.main.async {
                            
                            Utility.sharedUtility.stopActivity(view: self.view)
                            
//                            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (response!!["ErrorMessage"] as! String), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
//                            self.view.addSubview(alertView)
                        }
                    }
                }
            })
            
        }else {
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
            self.view.addSubview(alertView)
        }
    }
    
    
    func updateCasePriority(response : [NSDictionary]) {
        
        for (index,_) in response.enumerated() {
            
            let dictFromResponse = ((response as NSArray).object(at: index) as? NSDictionary)
            
            let priority = ((DataModel.share.nullToNil(value: dictFromResponse!["TATStatus"] as AnyObject)) != nil ? (dictFromResponse!["TATStatus"] as! String) : "")
            
            let caseID = (Int64((DataModel.share.nullToNil(value: dictFromResponse!["CaseID"] as AnyObject)) != nil ? Int(dictFromResponse!["CaseID"] as! String)! : 0))
            
            var status = 0
            
            switch (priority) {
            case "Red" :
                status = 1
                break
            case "Orange" :
                status = 2
                break
            case "Green" :
                status = 3
                break
            default:
                status = 4
                break
            }
            
            if (DataModel.share.updateAssignedCaseWithPriority(caseID: caseID, priorityStatus: Int16(status), investigatorID: UserManager.sharedManager.investigatorCode!)) {
                print("success")
            }
        }
    }
    
    func uploadCaseMedia(caseID: String) {
        
        let vctr = ImageCompressionViewController()
        vctr.caseID = Int64(caseID)!
        vctr.webRefNumber = self.webRefNumber
        vctr.delegate = self
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vctr.modalPresentationStyle = .overFullScreen
        self.present(vctr, animated: true, completion: nil)
    }
       
}

extension HomeViewController : SliderMenuDelegate {
    
    func checkAppUpdate() {
        menuButton?.tag = 0
        
        self.checkForAppUpdate()
    }
    
    func logOut() {
        menuButton?.tag = 0

        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Do you want to logout?", buttonOneTitle: "Yes", buttonTwoTitle: "No", tag: 1)
        self.view.addSubview(alertView)
    }
    
    func openInbox() {
        menuButton?.tag = 0
        
        UserManager.sharedManager.isInboxSelected = true
        
        let vctr = HomeViewController(1)
        vctr.navigationTitle = "Inbox"

        if self.navigationController == nil {
            self.present(vctr, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(vctr, animated: true)
        }
    }
    
    func openDraft() {
        menuButton?.tag = 0
        
        UserManager.sharedManager.isInboxSelected = false
        
        let vctr = HomeViewController(2)
        vctr.navigationTitle = "Draft"
        
        if self.navigationController == nil {
            self.present(vctr, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(vctr, animated: true)
        }
    }
    
    func openCompleted() {
        menuButton?.tag = 0
        
        UserManager.sharedManager.isInboxSelected = false

        let vctr = HomeViewController(3)
        vctr.navigationTitle = "Completed"

        if self.navigationController == nil {
            self.present(vctr, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(vctr, animated: true)
        }
    }
    
    func openSubmitted() {
        menuButton?.tag = 0
        
        UserManager.sharedManager.isInboxSelected = false

        let vctr = HomeViewController(4)
        vctr.navigationTitle = "Submitted"

        if self.navigationController == nil {
            self.present(vctr, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(vctr, animated: true)
        }
    }
    
    func updateInvestigatorProfile() {
        menuButton?.tag = 0
        
        let vctr = ProfileViewController()
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        vctr.modalPresentationStyle = .overFullScreen
        self.present(vctr, animated: true, completion: nil)
    }
    
    func openSettings() {
        menuButton?.tag = 0
        let vctr = SettingsViewController()
        
        if self.navigationController == nil {
            self.present(vctr, animated: true, completion: nil)
        }else {
            self.navigationController?.pushViewController(vctr, animated: true)
        }
    }
    
    func openHealthCheck() {
        menuButton?.tag = 0
        let vctr = HealthCheckViewController()
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        vctr.modalPresentationStyle = .overFullScreen
        self.present(vctr, animated: true, completion: nil)
    }
    
}

extension HomeViewController : UtilityProtocol, RadioButtonCustomProtocol
{
    func radioButtonCustomWithSuperview(_ superView: UIView) {
        let superRadioSubViews = superView.superview?.superview?.subviews
        for (_,item) in (superRadioSubViews?.enumerated())!
        {
            let radioSubView = item.subviews
            let firstRadioGrp = radioSubView[0]
            let selectedRadioButton = firstRadioGrp.subviews[1].subviews[0]
            if firstRadioGrp.subviews[1].tag == superView.subviews[1].tag
            {
                selectedRadioButton.isHidden = false
                UserManager.sharedManager.casePriority = firstRadioGrp.subviews[1].tag
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "casePriorityChanged"), object: nil)
            }
            else
            {
                selectedRadioButton.isHidden = true
            }
        }
    }
    
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
    }
    
    func pushToViewController() {
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UIManagerNotificationKey.kUserLogout), object: nil, userInfo: nil)
    }
    
    func pushToNextViewController() {
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
        // reject the case
        self.rejectCase(caseID: caseID!)
    }
    
}

extension HomeViewController: CaseUploadProtocol,MediaUploadProtocol {
    
    // upload Media details first from Upload Queue When Auto-sync is ON

    @objc func uploadCaseAutoSyncQueue() {
        
        if Utility.sharedUtility.isInternetAvailable()
        {
            let uploadingQueueDetails = DataModel.share.getUploadQueueDetailsForInvestigatorCode(investigatorCode: UserManager.sharedManager.investigatorCode!)
            
            if uploadingQueueDetails.count > 0 {
                                
                for item in uploadingQueueDetails {
                    
                    let caseid = (item as! UploadQueue).caseId
                    
                    let status = (item as! UploadQueue).isMediaUploading
                    
                    self.uploadCaseID = caseid
                    
                    let caseView = fldScrollview?.viewWithTag(Int(caseid))
                    
                    if caseView != nil {
                        
                        let uploadStatusView = caseView?.subviews[0]
                        
                        if (uploadStatusView?.isHidden)! {
                            uploadStatusView?.isHidden = false
                        }
                    }
                    // check if Media is already uploading
//                    if status {
                        
                        MediaUpload.shareMediaUpload.uploadMediaWithWebRefNumberAndCaseID(caseID: "\(caseid)",webRefNumber: (item as! UploadQueue).webReferenceNumber!,uploadStatusLabel: UILabel(),progressView: UIProgressView(), delegate: self, completionHandler: { (success,isMediaExists) -> Void in
                            if success {
                            }
                        })
                    //}
                }
            }else {
            
            }
        }else {
            
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "No internet connection", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
            self.view.addSubview(alertView)
        }
    }
    
    // If Media uploaded successfully then upload Case Data

    func mediaUploadWithStatus(status: Bool) {
        
        if status {
            
            let caseArray = DataModel.share.getCaseDetailsForCaseID(webRefNumber: self.webRefNumber, caseID: self.uploadCaseID!) as! [CaseDetail]

            CaseUpload.shareCaseUpload.uploadResponse(webRefNumber: caseArray[0].tabReferenceNumber!,caseID: self.uploadCaseID!, delegate: self, completionHandler: {(success) -> Void in
                if success {

                }
            })
        }else {
            
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.hideProgressBar), userInfo: nil, repeats: false)

            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
            self.view.addSubview(alertView)
            
        }
    }
    
    @objc func hideProgressBar() {
        
        let caseView = fldScrollview?.viewWithTag(Int(self.uploadCaseID!))
        
        if caseView != nil {
            
            let uploadStatusView = caseView?.subviews[0]
            
            if !(uploadStatusView?.isHidden)! {
                uploadStatusView?.isHidden = true
            }
        }
    }
    
    // update UI when case uploaded successfully
    func uploadStatus(_ message: String) {
        
        let caseArray = DataModel.share.getCaseDetailsForCaseID(webRefNumber: self.webRefNumber, caseID: self.uploadCaseID!) as! [CaseDetail]
        
        if status == 3 {
            
            if message.contains(UploadStatus.kError) {
                
                DispatchQueue.main.async {
                    Utility.sharedUtility.stopActivity(view: self.view)
                    
                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "An error occured. Please try again later", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                    self.view.addSubview(alertView)
                }
                
            }else if message.contains(UploadStatus.kServerError) {
                
                DispatchQueue.main.async {
                    Utility.sharedUtility.stopActivity(view: self.view)
                    
                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Internal server error", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                    self.view.addSubview(alertView)
                }
                
            }else if message.contains(UploadStatus.kResponseSuccess){
                
                DispatchQueue.main.async {
                    
                    let caseView = self.fldScrollview?.viewWithTag(Int(self.uploadCaseID!))
                    
                    if caseView != nil {
                        
                        let uploadStatusView = caseView?.subviews[0]
                        
                        for view in (uploadStatusView?.subviews)! {
                            if view.isKind(of: UILabel.self) {
                                (view as! UILabel).text = "Case Uploaded Successfully"
                                (view as! UILabel).textColor = UIColor.green
                            }else if view.isKind(of: UIView.self) {
                                view.isHidden = true
                            }
                        }
                    }
                    
                    // save response here
                    DocumentDirectory.shareDocumentDirectory.deleteDirectoryWithWebReferenceNumber(webRefNumber: (caseArray[0].tabReferenceNumber!))
                    
                    DocumentDirectory.shareDocumentDirectory.removeCaseMedia(caseNumber: self.uploadCaseID!, webRefNumber: caseArray[0].tabReferenceNumber!)
                    
                    if( DataModel.share.updateAssignedCaseStatus(caseID: self.uploadCaseID!, status: 4, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                        
                        print("updated case status")
                    }
                    
                    // delete case from Upload Queue as well.
                    DataModel.share.deleteUploadQueueDetails(caseID: self.uploadCaseID!, webReferenceNumber: caseArray[0].tabReferenceNumber!)
                    
                    Utility.sharedUtility.stopActivity(view: self.view)
                    
                    self.removeCaseView()
                    
                    if((DataModel.share.getAssignedCaseDetail() as [AnyObject]).count > 0) {
                        
                        // reload case view here
                        
                        self.createCaseView()
                        
                    }else {
                        self.getAssignedCases()
                    }
                    
                    let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: (UploadStatus.kResponseSuccess), buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
                    self.view.addSubview(alertView)
                }
            }
        }else {
            
            if message.contains(UploadStatus.kResponseSuccess){
                
                DispatchQueue.main.async {
                    
                    let caseView = self.fldScrollview?.viewWithTag(Int(self.uploadCaseID!))
                    
                    if caseView != nil {
                        
                        let uploadStatusView = caseView?.subviews[0]
                        
                        for view in (uploadStatusView?.subviews)! {
                            if view.isKind(of: UILabel.self) {
                                (view as! UILabel).text = "Case Uploaded Successfully"
                                (view as! UILabel).textColor = UIColor.green
                            }else if view.isKind(of: UIView.self) {
                                view.isHidden = true
                            }
                        }
                    }
                     self.openCompleted()
                      DocumentDirectory.shareDocumentDirectory.deleteDirectoryWithWebReferenceNumber(webRefNumber: (caseArray[0].tabReferenceNumber!))
                                   
                       DocumentDirectory.shareDocumentDirectory.removeCaseMedia(caseNumber: self.uploadCaseID!, webRefNumber: caseArray[0].tabReferenceNumber!)
                       
                       if( DataModel.share.updateAssignedCaseStatus(caseID: self.uploadCaseID!, status: 4, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                           
                           DataModel.share.deleteUploadQueueDetails(caseID: self.uploadCaseID!, webReferenceNumber: caseArray[0].tabReferenceNumber!)
                       }
                }
            }
        }
    }
}

extension HomeViewController : ImageCompressionProtocol {
    
    func uploadCaseWithIDAndWebRefNumber(caseID: Int64, webRefNum: String) {
        
        let caseDetail = DataModel.share.getCaseDetailsForCaseID(webRefNumber: webRefNum, caseID: caseID) as! [CaseDetail]
        
        let caseView = fldScrollview?.viewWithTag(Int(caseID))
        
        self.uploadCaseID = caseID
        
        if caseView != nil {
            
            let uploadStatusView = caseView?.subviews[0]
            
            if (uploadStatusView?.isHidden)! {
                uploadStatusView?.isHidden = false
            }
            
            // show progress bar with animation here
            if (uploadStatusView?.subviews.count)! > 0 {
                
                for progress in (uploadStatusView?.subviews[1].subviews)! {
                    if progress.isKind(of: LinearProgressBar.self) {
                        (progress as! LinearProgressBar).startAnimation()
                    }
                }
            }
            
            MediaUpload.shareMediaUpload.uploadMediaWithWebRefNumberAndCaseID(caseID: "\(caseID)",webRefNumber: caseDetail[0].tabReferenceNumber!,uploadStatusLabel: UILabel(),progressView: UIProgressView(), delegate: self, completionHandler: { (success,isMediaExists) -> Void in
                if success {
                    
                }else {
                    
                }
            })
        }
    }
    
}

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

