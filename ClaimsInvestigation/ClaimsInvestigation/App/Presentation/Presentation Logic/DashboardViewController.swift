//
//  DashboardViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 07/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    let navigationTitle = ""
    var saveInformationButton: UIButton?
    var sendInformationButton: UIButton?
    var leftSwipeButton: UIButton?
    var rightSwipeButton: UIButton?
    
    var mainScrollView: UIScrollView?
    var sectionSubSectionResponse = [Int : AnyObject]()
    var counterSection = 0
    var currentSection: Int = 0
    var sectionMaster : [AnyObject] = []
    var sectionID: Int64 = 0
    var caseID: Int64 = 0
    var caseType: Int16 = 0
    var webRefNumber  = ""
    var tabRefNumber = ""
    var sectionDetails = [Int : AnyObject]()
    var arrDependentFields = [Int64]()
    var uploadCaseID: Int64?
    
    
    //MARK:- View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if webRefNumber == "" {
            webRefNumber = UserManager.sharedManager.investigatorCode!
        }
        
        let assignedCase = DataModel.share.getAssignedCaseDataForCaseID(investigatorID: webRefNumber, caseID: caseID) as! [AssignedCases]
        
        tabRefNumber = (assignedCase.count > 0) ? assignedCase[0].tabReferenceNumber! : ""
        
        createHeader()
        
        prepareFieldData()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //menu  button
    @objc func backButtonTapped(_ sender : UIButton) -> Void {
        
        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Are you sure, you want to exit?", buttonOneTitle: "Yes", buttonTwoTitle: "No", tag: 1)
        self.view.addSubview(alertView)
    }
    
    //MARK:- Case Info
    @objc func infoButtonTapped(_ sender : UIButton) -> Void {
        
        let vctr = CaseInfoViewController()
        vctr.caseID = caseID
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vctr.modalPresentationStyle = .overFullScreen
        self.present(vctr, animated: true, completion: nil)
    }
    
    //MARK:- Setting
    @objc func showSettingView(_ sender : UIButton) -> Void {
        
        let vctr = SettingsViewController()
        vctr.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vctr.modalPresentationStyle = .overFullScreen
        self.present(vctr, animated: true, completion: nil)
    }
    
    //MARK:- Prepare DB & UI
    
    func createHeader() {
        
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
        
        let buttonImage = #imageLiteral(resourceName: "ic_arrow_backward_white")
        let backButton = UIButton(type: UIButtonType.custom)
        backButton.setBackgroundImage(buttonImage, for: UIControlState.normal)
        backButton.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        leftView.addSubview(backButton)
        
        xPos = headerView.frame.size.width - 100.0
        width = 100.0
        height = 30.0
        yPos = headerView.frame.size.height/2 - height/2
        let rightView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        rightView.backgroundColor = UIColor.clear
        headerView.addSubview(rightView)
        
        xPos = 10.0
        width = 30.0
        height = 30.0
        yPos = 0.0
        
        let buttonImageInfo = #imageLiteral(resourceName: "ic_info_outline_white")
        let infoButton = UIButton(type: UIButtonType.custom)
        infoButton.setBackgroundImage(buttonImageInfo, for: UIControlState.normal)
        infoButton.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        infoButton.addTarget(self, action: #selector(infoButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        rightView.addSubview(infoButton)
        
        // setting button image
        xPos = infoButton.frame.size.width + infoButton.frame.origin.x + 10.0
        
        let settingImage = #imageLiteral(resourceName: "ic_settings_white")
        let btnSetting = UIButton(type: UIButtonType.custom)
        btnSetting.setBackgroundImage(settingImage, for: UIControlState.normal)
        btnSetting.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        btnSetting.addTarget(self, action: #selector(showSettingView(_:)), for: UIControlEvents.touchUpInside)
        rightView.addSubview(btnSetting)
        
        xPos = leftView.frame.size.width
        width = headerView.frame.size.width - (leftView.frame.size.width + rightView.frame.size.width)
        
        let labelHeaderTop = UILabel(frame: CGRect(x: xPos, y: 10.0, width: width, height: 40.0))
        labelHeaderTop.text = "HITPA CLAIM INVESTIGATOR"
        labelHeaderTop.textAlignment = NSTextAlignment.center
        labelHeaderTop.textColor = UIColor.white
        
        if #available(iOS 8.2, *) {
            labelHeaderTop.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
        } else {
            // Fallback on earlier versions
            labelHeaderTop.font = UIFont.systemFont(ofSize: 20.0)
            
        }
        labelHeaderTop.adjustsFontSizeToFitWidth = true
        headerView.addSubview(labelHeaderTop)
        
    }

    @objc func prepareFieldData() {
        
        if caseType != 0 {
            
            let sectionMaster = DataModel.share.getSectionMasterWithCaseType(caseType: caseType)
            
            for item in sectionMaster as! [SectionMaster] {
                
                let sectionID = (item).secId
                
                let fieldsFromFieldSectionMap = DataModel.share.getFieldsFromFieldSectionMap(sectionID: Int(sectionID))
                
                if fieldsFromFieldSectionMap.count > 0 {
                    
                    var subSectionDetails = [AnyObject]()
                    var subSectionResponse = [AnyObject]()
                    
                    for field in fieldsFromFieldSectionMap as! [FieldSectionMap] {
                        
                      
                        let fieldID = (field).fieldsec_fieldid
                        
                        if fieldID ==  175654{
                            print("")
                        }
                        let fldMaster = DataModel.share.getFieldMasterWithFieldID(fieldID: Int(fieldID)) as! [FieldMaster]
                        
                        subSectionDetails.append(fldMaster[0] as AnyObject)
                        
                        let caseDetails  = DataModel.share.getAssignedCaseDetailsForFieldIDAndCaseID(Int(fieldID), webRefNumber: webRefNumber, caseID: caseID) as! [CaseDetail]
                        
                        let date = Date()
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ssZ"
                        let updatedDateString = dateformatter.string(from: date)
                        
                        let fieldData = ["fieldID" : Int(fldMaster[0].master_fldId) , "fieldName" : fldMaster[0].fldLabel!,"status": (caseDetails.count > 0) ? caseDetails[0].status : 0 ,"sectionID": sectionID , "fieldType" :  fldMaster[0].fldType!, "isHeaderShown" : fldMaster[0].isHeader, "isMandatory" : fldMaster[0].fldIsMandatory ,"surveyID" : Configuration.sharedConfiguration.getSurveyID() as AnyObject, "validationMsg" : fldMaster[0].fldValidationMsg!,"fieldValue":(caseDetails.count > 0) ? caseDetails[0].fieldValue as AnyObject : "","caseType":caseType as AnyObject,"webRefNumber":webRefNumber as AnyObject,"lastUpdatedBy":UserManager.sharedManager.investigatorCode!,"lastUpdatedOn":updatedDateString,"caseID":caseID,"tabReferenceNumber": (caseDetails.count > 0) ? caseDetails[0].tabReferenceNumber as Any : "","mappingLabel" : (fldMaster[0].mappingLabel) as Any] as [String : Any]
                        
                        subSectionResponse.append(fieldData as AnyObject)
                    }
                    sectionDetails[Int(sectionID)] = subSectionDetails as AnyObject
                    sectionSubSectionResponse[Int(sectionID)] = subSectionResponse as AnyObject
                }
            }
            createSectionDetail(sectionDetails: sectionDetails)
        }
    }
    
    func createSectionDetail(sectionDetails : [Int : AnyObject]) {
        
        let frame = Configuration.sharedConfiguration.bounds()
        
        var sectionX: CGFloat = 0.0
        let sectionY: CGFloat = CGFloat(HeaderFooterHeightConstant.kHeaderHeight)
        let sectionWidth: CGFloat = frame.size.width
        let sectionHeight: CGFloat = frame.size.height - sectionY
            
        mainScrollView = UIScrollView(frame: CGRect(x: sectionX, y: sectionY, width: sectionWidth, height: sectionHeight))
        mainScrollView?.backgroundColor = UIColor.white
        mainScrollView?.showsVerticalScrollIndicator = false
        mainScrollView?.showsHorizontalScrollIndicator = false
        mainScrollView?.isPagingEnabled = true
        mainScrollView?.delegate = self
        self.view.addSubview(mainScrollView!)
        
        var xPos:CGFloat = 0.0
        var height: CGFloat = 40.0
        var yPos:CGFloat = (frame.size.height - height)/2
        var width: CGFloat = 40.0
        
        let buttonLeftSwipe = #imageLiteral(resourceName: "icon_left_swipe")
        leftSwipeButton = UIButton(type: UIButtonType.custom)
        leftSwipeButton?.setBackgroundImage(buttonLeftSwipe, for: UIControlState.normal)
        leftSwipeButton?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        leftSwipeButton?.isHidden = true
        leftSwipeButton?.addTarget(self, action: #selector(leftSwipeButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(leftSwipeButton!)
        view.bringSubview(toFront: leftSwipeButton!)
        
        width = 40.0
        height = 40.0
        xPos = frame.size.width - width
        yPos = (frame.size.height - height)/2
        
        let buttonRightSwipe = #imageLiteral(resourceName: "icon_right_swipe")
        rightSwipeButton = UIButton(type: UIButtonType.custom)
        rightSwipeButton?.setBackgroundImage(buttonRightSwipe, for: UIControlState.normal)
        rightSwipeButton?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        rightSwipeButton?.addTarget(self, action: #selector(rightSwipeButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        rightSwipeButton?.isHidden = false
        view.addSubview(rightSwipeButton!)
        view.bringSubview(toFront: rightSwipeButton!)
        
        let sectionKeys = sectionDetails.keys.sorted()
        
        for i in 0..<sectionKeys.count {
            
            counterSection = i
            
            let sectionMaster = DataModel.share.getSectionNameWithId(sectionid: sectionKeys[i])[0] as! SectionMaster
            
            let sectionDetail : [AnyObject] = sectionDetails[sectionKeys[i]] as! [AnyObject]
            
            var xPos:CGFloat = 0.0
            var yPos:CGFloat = 0.0
            var width: CGFloat = frame.size.width
            var height: CGFloat = mainScrollView!.frame.size.height
            
            let viewInner = UIView(frame: CGRect(x: sectionX, y: yPos, width: width, height: height))
            viewInner.backgroundColor = UIColor.white
            mainScrollView?.addSubview(viewInner)
            viewInner.tag = sectionKeys[i]
            
            height = 60.0
            
            let viewHeader = UIView(frame: CGRect(x: xPos, y: yPos, width: viewInner.frame.size.width, height: 60.0))
            viewHeader.backgroundColor = UIColor.white
            viewInner.addSubview(viewHeader)
            
            xPos = 20.0
            height = 40.0
            yPos = (viewHeader.frame.size.height - height)/2
            
            if (counterSection < sectionKeys.count - 1) {
                width = (viewHeader.frame.size.width - (2 * xPos) - 50.0)
            }else {
                width = (viewHeader.frame.size.width - (2 * xPos) - 100.0)
            }
            
            let sectionTitle = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
            sectionTitle.textColor = UIColor.black
            sectionTitle.text = (sectionMaster.sechead)!.uppercased()
            sectionTitle.textAlignment = .left
            sectionTitle.numberOfLines = 2
            sectionTitle.adjustsFontSizeToFitWidth = true
            viewInner.addSubview(sectionTitle)
            
            if #available(iOS 8.2, *) {
                sectionTitle.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
            } else {
                // Fallback on earlier versions
                sectionTitle.font = UIFont.systemFont(ofSize: 20.0)
            }
            
            xPos = sectionTitle.frame.origin.x + sectionTitle.frame.size.width + 10.0
            width = 40.0
            height = 40.0
            yPos = (viewHeader.frame.size.height - height)/2
            
            let buttonImageSave = #imageLiteral(resourceName: "ic_save_black")
            saveInformationButton = UIButton(type: UIButtonType.custom)
            saveInformationButton?.setBackgroundImage(buttonImageSave, for: UIControlState.normal)
            saveInformationButton?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
            saveInformationButton?.addTarget(self, action: #selector(saveInformationButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            viewInner.addSubview(saveInformationButton!)
            
            xPos = (saveInformationButton?.frame.origin.x)! + (saveInformationButton?.frame.size.width)! + 10.0
            width = 40.0
            height = 40.0
            yPos = (viewHeader.frame.size.height - height)/2
            
            let buttonImageSend = #imageLiteral(resourceName: "ic_submit_black")
            sendInformationButton = UIButton(type: UIButtonType.custom)
            sendInformationButton?.setBackgroundImage(buttonImageSend, for: UIControlState.normal)
            sendInformationButton?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
            sendInformationButton?.addTarget(self, action: #selector(sendInformationButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            sendInformationButton?.isHidden = true
            viewInner.addSubview(sendInformationButton!)
            
            let viewSeparator = UIView(frame: CGRect(x: 0.0, y: viewHeader.frame.size.height, width: frame.size.width, height: 1.0))
            viewSeparator.backgroundColor = ColorConstant.KGrayBGColor
            viewInner.addSubview(viewSeparator)
            
            xPos = 0.0
            height = viewInner.frame.size.height - viewHeader.frame.size.height - 1.0
            yPos = viewSeparator.frame.size.height + viewSeparator.frame.origin.y
            width = viewInner.frame.size.width
            
            let fldScrollView = UIScrollView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
            fldScrollView.backgroundColor = UIColor.white
            fldScrollView.showsVerticalScrollIndicator = false
            fldScrollView.showsHorizontalScrollIndicator = false
            fldScrollView.isScrollEnabled = true
            fldScrollView.tag = sectionKeys[i]
            viewInner.addSubview(fldScrollView)
            
            var fldYPos: CGFloat = 10.0
            var fldHeight: CGFloat = 50.0
            let leading: CGFloat = 20.0
            let fldWidth: CGFloat = fldScrollView.frame.size.width - 2 * leading
            let lineHeight: CGFloat = DeviceType.IPAD ? 1.0 : 0.5
            var y : CGFloat = 0.0
            
            for (fldIndex,fldItem) in (sectionDetail as! [FieldMaster]).enumerated() {
                
                let fieldValue = ((sectionSubSectionResponse[sectionKeys[i]] as! [AnyObject])[fldIndex] as! [String:AnyObject])["fieldValue"]
                
                let fldMasterData = fldItem
                
                if (fldMasterData.fldType == DataType.kTextArea) {
                    fldHeight = DeviceType.IPAD ? 120.0 : 100.0
                }else {
                    fldHeight = DeviceType.IPAD ? 80.0 : 60.0
                }
                
                xPos = 0.0
                yPos = y
                width = fldScrollView.frame.size.width
                height = fldHeight
                
                let fldView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
                
                fldView.backgroundColor = UIColor.white
                fldView.tag = Int(fldItem.master_fldId)
                fldScrollView.addSubview(fldView)
                
                fldYPos = 0.0
                
                if (fldMasterData.fldType == DataType.kEmail) || (fldMasterData.fldType == DataType.kDecimal) || (fldMasterData.fldType == DataType.kContact) || (fldMasterData.fldType == DataType.kNumeric) || (fldMasterData.fldType == DataType.kTextBox) {
                    
                    let textBox = TextBox.init(frame: CGRect(x:leading,y: fldYPos,width:fldWidth,height:fldHeight), placeHolder: fldItem.fldLabel!, isMandatory: fldItem.fldIsMandatory, isDependent: fldItem.fldIsDependent, responseValue: fieldValue as! String, type: fldItem.fldType!, delegate: self,hideWarningView: true,warningText: "Please enter"+" " + fldItem.fldLabel!,isReadOnly: fldItem.isReadOnly,fieldID:fldMasterData.master_fldId)
                    
                    textBox.tag = fldIndex
                    fldView.addSubview(textBox)
                    
                    if fldItem.isReadOnly {
                        textBox.alpha = 0.6
                    }
                    
                }else if (fldMasterData.fldType == DataType.kDatePicker) {
                    
                    let time = Utility.sharedUtility.getDateStringFromDate(Date())
                    var value = ""
                    
                    if ((fieldValue as! String) == "") && (fldItem.isReadOnly) {
                    
                        value = time
                        
                        var sectionDict :  [AnyObject] = (sectionSubSectionResponse[sectionKeys[i]] as! [AnyObject])
                        var fieldDict = sectionDict[fldIndex] as! [String : AnyObject]
                        fieldDict["fieldValue"] = value as AnyObject
                        sectionDict[fldIndex] = fieldDict as AnyObject
                        sectionSubSectionResponse[sectionKeys[i]] = sectionDict as AnyObject
                        
                    }else {
                        value = fieldValue as! String
                    }
                    
                    let datePicker = DatePicker.init(frame: CGRect(x:leading,y: fldYPos,width:fldWidth,height:fldHeight), placeholder: fldItem.fldLabel!, responseValue: value, isMandatory: fldItem.fldIsMandatory, delegate: self, isDependent: fldItem.fldIsDependent,hideWarningView: true,warningText: "Please enter"+" " + fldItem.fldLabel!,isReadOnly: fldItem.isReadOnly)
                    
                    datePicker.tag = fldIndex
                    fldView.addSubview(datePicker)
                    
                }else if (fldMasterData.fldType == DataType.kLabel) || (fldMasterData.fldType == DataType.kName){
                    
                    fldHeight = DeviceType.IPAD ? 60.0 : 40.0
                    var newFrame = fldView.frame
                    newFrame.size.height = fldHeight
                    fldView.frame = newFrame
                    height = fldView.frame.size.height
                    
                    let label = UILabel(frame: CGRect(x: leading, y: fldYPos, width: fldWidth, height: height))
                    label.font = UIFont.systemFont(ofSize: 17.0)
                    label.text = fldItem.fldLabel!
                    label.textColor = UIColor.black
                    label.textAlignment = .left
                    label.adjustsFontSizeToFitWidth = true
                    fldView.addSubview(label)
                    label.tag = fldIndex
                    label.isUserInteractionEnabled = fldItem.isReadOnly
                    
                }else if (fldMasterData.fldType == DataType.kTextArea){
                    
                    fldHeight = DeviceType.IPAD ? 100.0 : 80.0
                    var newFrame = fldView.frame
                    newFrame.size.height = fldHeight
                    fldView.frame = newFrame
                    height = fldView.frame.size.height
                    
                    let textArea = TextArea(frame: CGRect(x: leading, y: fldYPos, width: fldWidth, height: height), placeHolderText: fldItem.fldLabel!, responseValue: fieldValue as! String, isMandatory: fldItem.fldIsMandatory, delegate: self,hideWarningView: true,warningText: "Please enter"+" " + fldItem.fldLabel!,isReadOnly: fldItem.isReadOnly,isDependent:fldItem.fldIsDependent)
                    
                    textArea.tag = fldIndex
                    fldView.addSubview(textArea)
                }
                else if fldMasterData.fldType == DataType.kSpinner {
                    
                    let spinner = Spinner(frame: CGRect(x: leading, y: fldYPos, width: fldWidth, height: fldHeight), fieldId: Int(fldItem.master_fldId), placeholder: fldItem.fldLabel!, responseValue: fieldValue as! String, isMandatory: fldItem.fldIsMandatory, delegate: self, isDependent: fldItem.fldIsDependent, hideWarningView: true, warningText: "Please enter"+" " + fldItem.fldLabel!,isReadOnly: fldItem.isReadOnly)
                    
                    spinner.tag = fldIndex
                    fldView.addSubview(spinner)
                    
                }else if fldMasterData.fldType == DataType.kCheckBox
                {
                    let fieldDataDetails = DataModel.share.getFieldDataMaster(fieldID: Int(fldMasterData.master_fldId))
                    
                    if (fieldDataDetails.count > 0)
                    {
                        var newFrame = fldView.frame
                        newFrame.size.height = newFrame.size.height + CGFloat((fieldDataDetails.count)) * (DeviceType.IPAD ? 60.0 : 40.0)
                        fldView.frame = newFrame
                        height = fldView.frame.height
                        
                        let labelHeight =  Utility.sharedUtility.getHeightFromText(text: fldMasterData.fldLabel!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                        
                        let mandatoryImage = UIImageView(frame: CGRect(x: leading, y: 5.0, width: 10.0, height: 10.0))
                        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
                        mandatoryImage.isHidden = (Bool(truncating: fldItem.fldIsMandatory as NSNumber) && (fieldValue as! String == "" || fieldValue == nil)) ? false : true
                        mandatoryImage.tag = Int(truncating: fldMasterData.fldIsMandatory as Bool as NSNumber)
                        fldView.addSubview(mandatoryImage)
                        
                        let checkBoxLabel = UILabel(frame: CGRect(x: mandatoryImage.frame.size.width + mandatoryImage.frame.origin.x , y: fldYPos, width: fldWidth, height: (labelHeight > 40.0) ? labelHeight : 40.0))
                        
                        checkBoxLabel.text = fldItem.fldLabel
                        checkBoxLabel.numberOfLines = 0
                        checkBoxLabel.sizeToFit()
                        checkBoxLabel.tag = fldIndex
                        fldView.addSubview(checkBoxLabel)
                        
                        var value = ""
                        var stringArr = [String]()
                        
                        if (fieldValue as! String) != "" {
                            stringArr = (fieldValue as! String).components(separatedBy: ",")
                        }
                        
                        var checkBoxYpos : CGFloat = checkBoxLabel.frame.origin.y  + checkBoxLabel.frame.size.height + (DeviceType.IPAD ? 10.0 : 5.0)
                        
                        var checkBoxViewHeight : CGFloat = 0.0
                        for i in 0..<(fieldDataDetails.count ) {
                            
                            xPos = leading
                            yPos = checkBoxYpos
                            width = fldView.frame.size.width - 2 * xPos
                            height = DeviceType.IPAD ? 60.0 : 40.0
                            
                            let checkBoxView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
                            checkBoxView.backgroundColor = UIColor.clear
                            fldView.addSubview(checkBoxView)
                            
                            checkBoxViewHeight =  Utility.sharedUtility.getHeightFromText(text: (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                            
                            checkBoxViewHeight = (checkBoxViewHeight >= 40.0) ? checkBoxViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                            
                            if stringArr.contains(obj: (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues!) {
                                value = (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues!
                            }else {
                                value = ""
                            }
                            
                            xPos = 0.0
                            yPos = 0.0
                            width = (checkBoxView.frame.size.width - 10.0)/2.0
                            height = (checkBoxViewHeight >= 40.0) ? checkBoxViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                            
                            let checkBox = CheckBox(frame: CGRect(x: xPos, y: yPos, width: width, height: height), placeHolderText: (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues!, responseValue: value, isMandatory: false, type: fldMasterData.fldType!, isDependent: false, fieldID: Int((fieldDataDetails[i] as! FieldDataMaster).id),delegate:self,isReadOnly: false)
                            
                            checkBox.tag = Int((fieldDataDetails[i] as! FieldDataMaster).id)
                            checkBoxView.addSubview(checkBox)
                            
                            var newFrame = checkBoxView.frame
                            newFrame.size.height = checkBoxViewHeight
                            checkBoxView.frame = newFrame
                            
                            checkBoxYpos = checkBoxYpos + checkBoxViewHeight
                        }
                        
                        var fldNewFrame = fldView.frame
                        fldNewFrame.size.height = checkBoxYpos < fldHeight ? fldHeight : checkBoxYpos
                        fldView.frame = fldNewFrame
                    }
                    
                }else if(fldMasterData.fldType == DataType.kTimePicker) {
                    
                    let time = Utility.sharedUtility.getTimeStringFromTime(Date())
                    var value = ""
                    
                    if ((fieldValue as! String) == "") && (fldItem.isReadOnly) {
                    
                        value = time
                        
                        var sectionDict :  [AnyObject] = (sectionSubSectionResponse[sectionKeys[i]] as! [AnyObject])
                        var fieldDict = sectionDict[fldIndex] as! [String : AnyObject]
                        fieldDict["fieldValue"] = value as AnyObject
                        sectionDict[fldIndex] = fieldDict as AnyObject
                        sectionSubSectionResponse[sectionKeys[i]] = sectionDict as AnyObject
                        
                    }else {
                        value = fieldValue as! String
                    }
                    
                    let timePicker = TimePicker.init(frame: CGRect(x:leading,y: fldYPos,width:fldWidth,height:fldHeight), placeHolderText: fldItem.fldLabel!, responseValue: value, isMandatory: fldItem.fldIsMandatory, delegate: self, isDependent: fldItem.fldIsDependent ,hideWarningView: true, warningText: "Please enter"+" " + fldItem.fldLabel!,isReadOnly: fldItem.isReadOnly)
                    
                    timePicker.tag = fldIndex
                    fldView.addSubview(timePicker)
                    
                }else if (fldMasterData.fldType == DataType.kMediaControl) {
                    
                    let mediaControlBox = MediaControl(frame: CGRect(x: leading, y: fldYPos, width: fldWidth, height: fldHeight), placeHolderText: fldItem.fldLabel!, responseValue: fieldValue as! String, refNumber: tabRefNumber, isMandatory: fldItem.fldIsMandatory, mediaDetails: ["fieldID":fldMasterData.master_fldId as AnyObject], delegate: self, hideWarningView: true, warningText: "Enter the Name",isReadOnly: fldItem.isReadOnly,isDependent: fldItem.fldIsDependent)
                    
                    mediaControlBox.tag = fldIndex
                    fldView.addSubview(mediaControlBox)
                    
                }else if fldMasterData.fldType == DataType.kRadioGroup {
                    
                    let fieldDataDetails = DataModel.share.getFieldDataMaster(fieldID: Int(fldMasterData.master_fldId))
                    
                    if fieldDataDetails.count > 2 {
                        
                        let labelHeight =  Utility.sharedUtility.getHeightFromText(text: fldMasterData.fldLabel!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                        
                        var newFrame = fldView.frame
                        newFrame.size.height = newFrame.size.height + CGFloat(fieldDataDetails.count) * (DeviceType.IPAD ? 60.0 : 40.0)
                        fldView.frame = newFrame
                        height = fldView.frame.height
                        
                        let mandatoryImage = UIImageView(frame: CGRect(x: leading, y: 5.0, width: 10.0, height: 10.0))
                        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
                        mandatoryImage.isHidden = (Bool(truncating: fldItem.fldIsMandatory as NSNumber) && (fieldValue as! String == "" || fieldValue == nil)) ? false : true
                        mandatoryImage.tag = Int(truncating: fldMasterData.fldIsMandatory as Bool as NSNumber)
                        fldView.addSubview(mandatoryImage)
                        if(fldMasterData.master_fldId == 175654){
                            print("")
                        }
                        let radioLabel = UILabel(frame: CGRect(x: mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width + 5.0, y: fldYPos, width: fldWidth, height: (labelHeight > 40.0) ? labelHeight : 40.0))
                        let labelText = (fldMasterData.master_fldId == 175654) ? "Mode of payment(cash/credit card/in one go/multiple time,In case of reimbursement)" : fldItem.fldLabel
                        radioLabel.text = labelText
                        radioLabel.numberOfLines = 0
                        radioLabel.sizeToFit()
                        radioLabel.tag = fldIndex
                        fldView.addSubview(radioLabel)
                        
                        var radioYpos : CGFloat = radioLabel.frame.origin.y  + radioLabel.frame.size.height + (DeviceType.IPAD ? 10.0 : 5.0)
                        var radioViewHeight : CGFloat = 0.0
                        for i in 0..<(fieldDataDetails.count) {
                            
                            xPos = leading + 10.0
                            yPos = radioYpos
                            width = fldView.frame.size.width - 2 * xPos
                            height = DeviceType.IPAD ? 60.0 : 40.0
                            
                            let radioView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
                            radioView.backgroundColor = UIColor.clear
                            fldView.addSubview(radioView)
                            
                            radioViewHeight =  Utility.sharedUtility.getHeightFromText(text: (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                            
                            radioViewHeight = (radioViewHeight >= 40.0) ? radioViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                            
                            xPos = 0.0
                            yPos = 0.0
                            width = (radioView.frame.size.width - leading)
                            height = (radioViewHeight >= 40.0) ? radioViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                            
                            let radioButtonOne = RadioButton(frame: CGRect(x: xPos, y: yPos, width: width, height: height), label: (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues,  responseValue : (fieldValue as! String), delegate: self,tag :Int((fieldDataDetails[i] as! FieldDataMaster).id))
                            
                            radioButtonOne.tag = Int((fieldDataDetails[i] as! FieldDataMaster).id)
                            radioView.addSubview(radioButtonOne)
                            
                            var newFrame = radioView.frame
                            newFrame.size.height = radioViewHeight
                            radioView.frame = newFrame
                            
                            radioYpos = radioYpos + radioViewHeight
                        }
                        
                        var fldNewFrame = fldView.frame
                        fldNewFrame.size.height = radioYpos < fldHeight ? fldHeight : radioYpos
                        fldView.frame = fldNewFrame
                        
                    }else
                    {
                        let labelHeight =  Utility.sharedUtility.getHeightFromText(text: fldMasterData.fldLabel!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                        
                        var newFrame = fldView.frame
                        newFrame.size.height = newFrame.size.height + CGFloat(fieldDataDetails.count) * (DeviceType.IPAD ? 60.0 : 40.0)
                        fldView.frame = newFrame
                        height = fldView.frame.height
                        
                        let mandatoryImage = UIImageView(frame: CGRect(x: leading, y: 5.0, width: 10.0, height: 10.0))
                        mandatoryImage.image = #imageLiteral(resourceName: "icon_mandatory")
                        mandatoryImage.isHidden = (Bool(truncating: fldItem.fldIsMandatory as NSNumber) && (fieldValue as! String == "" || fieldValue == nil)) ? false : true
                        mandatoryImage.tag = Int(truncating: fldMasterData.fldIsMandatory as Bool as NSNumber)
                        fldView.addSubview(mandatoryImage)
                        
                        let radioLabel = UILabel(frame: CGRect(x: mandatoryImage.frame.origin.x + mandatoryImage.frame.size.width + 5.0, y: fldYPos, width: fldWidth, height: (labelHeight > 40.0) ? labelHeight : 40.0))
                        
                        radioLabel.text = fldItem.fldLabel
                        radioLabel.numberOfLines = 0
                        radioLabel.sizeToFit()
                        radioLabel.tag = fldIndex
                        fldView.addSubview(radioLabel)
                        
                        var radioYpos : CGFloat = radioLabel.frame.origin.y  + radioLabel.frame.size.height + 5.0
                        var radioViewHeight : CGFloat = 0.0
                        for i in 0..<(fieldDataDetails.count + 1)/2 {
                            
                            xPos = leading + 10.0
                            yPos = radioYpos
                            width = fldView.frame.size.width - 2 * xPos
                            height = DeviceType.IPAD ? 60.0 : 40.0
                            
                            let radioView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
                            radioView.backgroundColor = UIColor.clear
                            fldView.addSubview(radioView)
                            
                            radioViewHeight =  Utility.sharedUtility.getHeightFromText(text: (fieldDataDetails[i] as! FieldDataMaster).fieldata_optionvalues!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                            
                            radioViewHeight = (radioViewHeight >= 40.0) ? radioViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                            
                            xPos = 0.0
                            yPos = 0.0
                            width = (radioView.frame.size.width - leading)/2.0
                            height = (radioViewHeight >= 40.0) ? radioViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                            
                            let radioButtonOne = RadioButton(frame: CGRect(x: xPos, y: yPos, width: width, height: height), label: (fieldDataDetails[i * i] as! FieldDataMaster).fieldata_optionvalues,  responseValue : (fieldValue as! String), delegate: self,tag :Int((fieldDataDetails[i * i] as! FieldDataMaster).id))
                            
                            radioButtonOne.tag = Int((fieldDataDetails[i * i] as! FieldDataMaster).id)
                            radioView.addSubview(radioButtonOne)
                            
                            var iCount = 0
                            if fieldDataDetails.count > 2 {
                                iCount = (i * i + 2)
                            } else {
                                iCount = (i * i + 1)
                            }
                            
                            if iCount < fieldDataDetails.count {
                                
                                let secondRadioViewHeight =  Utility.sharedUtility.getHeightFromText(text: (fieldDataDetails[iCount] as! FieldDataMaster).fieldata_optionvalues!, font: DeviceType.IPAD ? UIFont.systemFont(ofSize: 18.0): UIFont.systemFont(ofSize: 16.0))
                                
                                radioViewHeight = (radioViewHeight >= 40.0) ? radioViewHeight : DeviceType.IPAD ? 60.0 : 40.0
                                
                                xPos = radioButtonOne.frame.origin.x  + radioButtonOne.frame.size.width + 10.0
                                yPos = 0.0
                                width = (fldView.frame.size.width - 10.0)/2.0
                                height = (secondRadioViewHeight >= 40.0) ? secondRadioViewHeight : 40.0
                                
                                let radioButtonTwo = RadioButton(frame: CGRect(x: xPos, y: yPos, width: width, height: height), label: (fieldDataDetails[iCount] as! FieldDataMaster).fieldata_optionvalues,  responseValue : (fieldValue as! String), delegate: self,tag :Int((fieldDataDetails[iCount] as! FieldDataMaster).id))
                                
                                radioButtonTwo.tag = Int((fieldDataDetails[iCount] as! FieldDataMaster).id)
                                radioView.addSubview(radioButtonTwo)
                            }
                            var newFrame = radioView.frame
                            newFrame.size.height = radioViewHeight
                            radioView.frame = newFrame
                            
                            radioYpos = radioYpos + radioViewHeight
                        }
                        var fldNewFrame = fldView.frame
                        fldNewFrame.size.height = radioYpos < fldHeight ? fldHeight : radioYpos
                        fldView.frame = fldNewFrame
                    }
                }
                
                y = y + fldView.frame.size.height + 10.0
                
                if fldItem.fldType != DataType.kLabel  {
                    //Bottom line
                    xPos = leading
                    yPos = fldView.frame.size.height - lineHeight
                    width = fldView.frame.size.width - 2 * leading
                    height = lineHeight
                    let lineView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
                    lineView.backgroundColor = UIColor.lightGray
                    lineView.tag = 1000
                    fldView.addSubview(lineView)
                }
            }
            fldScrollView.contentSize = CGSize(width: fldScrollView.frame.size.width, height: y + 50.0)
            
            sectionX  = sectionX + frame.size.width
        }
        mainScrollView?.contentSize = CGSize(width: sectionX, height: ((mainScrollView?.frame.size.height)!))
        
        self.adjustHiddenViewsSpaceInitially()
        
        self.ShowRadioDependentsIfSelected()
    }
    
    //MARK:- Show Radio Dependents Initially if Selected earlier
    func ShowRadioDependentsIfSelected() {
        
        let sectionKeys = sectionSubSectionResponse.keys.sorted()
        
        // enumerate each section
        for (_,object) in sectionKeys.enumerated() {
            
            let view = self.mainScrollView!.viewWithTag(object)
            
            for scrollView in (view?.subviews)!{
                
                if scrollView.isKind(of: UIScrollView.self) {
                    
                    let sectionDetails = sectionSubSectionResponse[object] as! [AnyObject]
                    
                    for (_,item) in (sectionDetails as! [[String : AnyObject]]).enumerated() {
                        
                      
                        // check for RadioGroup Only
                        if ((item["fieldType"] as! String) == DataType.kRadioGroup) {
                            
                            let fieldDataDetails = DataModel.share.getFieldDataMaster(fieldID: item["fieldID"]! as! Int) as! [FieldDataMaster]
                            
                            for (_,radioField) in fieldDataDetails.enumerated() {
                                var bool = false
                                if ((((item["sectionID"] as! Int) == 110627) || ((item["sectionID"] as! Int) == 110617) || ((item["sectionID"] as! Int) == 110609)) && (item["fieldValue"]! as! String).count > 0){
                                    bool = true
                                }else  if radioField.id == Int64(item["fieldValue"]! as! String) {
                                     bool = true
                                }
                                
                                if bool {
                                    
                                    // get radio dependent field here
                                    let radioDependents = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: Int(radioField.id))
                                    
                                    if (radioDependents.count > 0) {
                                        
                                        for (index,_) in radioDependents.enumerated() {
                                            
                                            let fldView = self.view.viewWithTag((Int((radioDependents[index] as! TableFieldDependency).fielddependencyfieldid)))
                                            
                                            if fldView != nil {
                                                fldView?.isHidden = false
                                                
                                                for subView in (fldView?.subviews)! {
                                                    
                                                    if subView.isHidden {
                                                        subView.isHidden = false
                                                    }
                                                }
                                            }
                                        } // for -each
                                    }
                                    //LOOP FROM Field TO LAST
                                    
                                    let preViewIndex = getIndexWithSubViews(subViews: scrollView.subviews,fieldId: ((mainScrollView?.viewWithTag(object))!.superview?.superview?.tag)!)
                                    
                                    let preView = scrollView.subviews[preViewIndex]
                                    
                                    self.nextConditonIndexWithPrevView(preView: preView, scrollView: scrollView as! UIScrollView, prevIndex: preViewIndex)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    //MARK:- Save Case Details
    @objc func saveInformationButtonTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let pageWidth : CGFloat = self.mainScrollView!.frame.size.width;
        let page : Int = Int(floor((self.mainScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        let sectionView = self.mainScrollView!.subviews[page]
        let errorMessage = checkForMandatoryInSectionSave(sectionView.tag)
        if errorMessage {
            
        }else {
            if DataModel.share.getCaseDetailsForSectionIDAndCaseID(sectionID: sectionView.tag, webRefNumber: webRefNumber, caseID: caseID).count > 0 {
                
                DispatchQueue.main.async {
                    
                    DataModel.share.updateCaseDetailsForCaseID(self.sectionSubSectionResponse[sectionView.tag] as! [[String : AnyObject]], status: 2)
                    
                    if( DataModel.share.updateAssignedCaseStatus(caseID: self.caseID, status: 2, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                        print("case added in Draft Queue")
                    }
                }
            }
            else {
                
                if DataModel.share.insertCaseDetails(sectionSubSectionResponse[sectionView.tag] as! [[String : AnyObject]], status : 2) {
                    print("inserted successfully")
                    
                    if( DataModel.share.updateAssignedCaseStatus(caseID: caseID, status: 2, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                        print("case added in Draft Queue")
                    }
                }
            }
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Case saved successfully", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 0)
            self.view.addSubview(alertView)
        }
    }
    
    //MARK:- Submit Case
    @objc func sendInformationButtonTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let pageWidth : CGFloat = self.mainScrollView!.frame.size.width;
        let page : Int = Int(floor((self.mainScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        
        let sectionKeys = sectionSubSectionResponse.keys.sorted()
        
        if sectionSubSectionResponse.count == page + 1
        {
            print("Last page")
            var sectionCount = 0
            for (index,item) in sectionKeys.enumerated() {
                
                let errorMessage = checkForMandatoryInSection(item)
                
                if errorMessage.count > 0 {
                    
                    let page = index
                    var frame = self.mainScrollView?.frame
                    frame!.origin.x = (frame?.size.width)! * CGFloat(page)
                    frame!.origin.y = 0
                    
                    DispatchQueue.main.async {
                        
                        self.mainScrollView?.scrollRectToVisible(frame!, animated: true)
                        
                        let subviews = self.view.subviews
                        let leftView = subviews[2]
                        let rightView = subviews[3]
                        if sectionKeys.count > 1 {
                            if page == 0
                            {
                                leftView.isHidden = true
                                rightView.isHidden = false
                            }else if page + 1 != sectionKeys.count {
                                leftView.isHidden = false
                                rightView.isHidden = false
                            }
                        }else {
                            leftView.isHidden = true
                            rightView.isHidden = true
                        }
                    }
                    
                    break
                    
                }else {
                    
                    sectionCount = sectionCount + 1
                    
                    if DataModel.share.getCaseDetailsForSectionIDAndCaseID(sectionID: item, webRefNumber: webRefNumber, caseID: caseID).count > 0 {
                        
                        DataModel.share.updateCaseDetailsForCaseID(self.sectionSubSectionResponse[item] as! [[String : AnyObject]], status: 1)
                        
                        if( DataModel.share.updateAssignedCaseStatus(caseID: self.caseID, status: 1, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                            print("case is in same Queue.")
                        }
                    }
                    else {
                        
                        if DataModel.share.insertCaseDetails(sectionSubSectionResponse[item] as! [[String : AnyObject]], status : 1) {
                            print("inserted successfully")
                            
                            if( DataModel.share.updateAssignedCaseStatus(caseID: caseID, status: 1, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                                print("case is in same Queue.")
                            }
                        }
                    }
                    
                    // add case in completed Queue if all information is added.
                    if sectionCount == sectionSubSectionResponse.count {

                        let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Once submitted, you cannot modify any information. Are you sure you want to submit?", buttonOneTitle: "Cancel", buttonTwoTitle: "Confirm", tag: 2)
                        
                        self.view.addSubview(alertView)
                    }
                }
            }
        }
    }
    
    func submitCase() {
        
        if DataModel.share.getCaseDetailsForCaseID(webRefNumber: webRefNumber, caseID: caseID).count > 0 {
            
            if( DataModel.share.updateAssignedCaseStatus(caseID: self.caseID, status: 3, investigatorID: UserManager.sharedManager.investigatorCode!)) {
                print("case added in Completed Queue.")
            }
            
            let uploadQueueDict = ["caseID": caseID,"isAutoSync":HITPAUserDefaults.sharedUserDefaults.bool(forKey: "isAutoSync") as AnyObject,"webReferenceNumber":tabRefNumber as AnyObject,"uploadLabelValue":"Uploading Data (10%)" as AnyObject,"progressValue":10 as AnyObject] as [String:AnyObject]
            
            if DataModel.share.insertIntoUploadQueue(uploadQueueDict) {
                print("case added in the Upload Queue")
            }
            
            let alertView = Utility.sharedUtility.alertView(controller: self, delegate: self, title: Configuration.sharedConfiguration.appName(), message: "Case submitted successfully.", buttonOneTitle: "OK", buttonTwoTitle: "", tag: 1)
            self.view.addSubview(alertView)
        }
    }
    
    //MARK:- IBActions
    @objc func leftSwipeButtonTapped(_ sender : UIButton) {
        
        self.view.endEditing(true)
        var frame = self.mainScrollView!.frame
        let pageWidth : CGFloat = self.mainScrollView!.frame.size.width;
        let page : Int = Int(floor((self.mainScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        frame.origin.x = frame.size.width * CGFloat(page - 1)
        frame.origin.y = 0
        self.mainScrollView!.scrollRectToVisible(frame, animated: true)
        
        let subviews = self.view.subviews
        let leftView = subviews[2]
        let rightView = subviews[3]
        if page == 1
        {
            leftView.isHidden = true
            rightView.isHidden = false
        }else{
            leftView.isHidden = false
            rightView.isHidden = false
        }
    }
    
    @objc func rightSwipeButtonTapped(_ sender : UIButton) {
        
        self.view.endEditing(true)
        var frame = self.mainScrollView!.frame
        let pageWidth : CGFloat = self.mainScrollView!.frame.size.width;
        let page : Int = Int(floor((self.mainScrollView!.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
        frame.origin.x = frame.size.width * CGFloat(page + 1)
        frame.origin.y = 0
        self.mainScrollView!.scrollRectToVisible(frame, animated: true)
        
        let subviews = self.view.subviews
        let leftView = subviews[2]
        let rightView = subviews[3]
        if page + 2 == sectionDetails.count
        {
            leftView.isHidden = false
            rightView.isHidden = true
        }else{
            leftView.isHidden = false
            rightView.isHidden = false
        }
    }
    
    //MARK:- Adjust hidden views initially
    func adjustHiddenViewsSpaceInitially() {
        let listValues = DataModel.share.getDependentFieldsFromTableFieldDependency() as! [TableFieldDependency]
        
        for scrollSubViews in self.mainScrollView!.subviews
        {
            let scrollView = scrollSubViews.subviews[5] as! UIScrollView
            var scrollViewContentHeight : CGFloat = 0.0
            for (i,item) in scrollView.subviews.enumerated()
            {
                let conditionView = item
                
                let filteredListTemp = (listValues).filter({ (item : TableFieldDependency) -> Bool in
                    
                    let filteredString = (item.fielddependencyfieldid == conditionView.tag)
                    
                    return filteredString
                })
                
                if filteredListTemp.count > 0 {
                    
                    conditionView.isHidden = true
                    scrollViewContentHeight = scrollViewContentHeight + conditionView.frame.size.height
                    for nextIndex in (i + 1)..<scrollView.subviews.count
                    {
                        let innerView = scrollView.subviews[nextIndex]
                        var newFrame = innerView.frame
                        newFrame.origin.y = innerView.frame.origin.y - (conditionView.frame.size.height)
                        innerView.frame = newFrame
                    }
                }
            }
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: (scrollView.contentSize.height - scrollViewContentHeight))
        }
    }
    
    //MARK:- Page Validations
    func checkForMandatoryInSection(_ sectionID : Int) -> [NSString] {
        
        let scrollView = self.mainScrollView?.viewWithTag(sectionID)?.subviews[5] as! UIScrollView
        
        var errorMessage = [NSString]()
        let sectionDetails = sectionSubSectionResponse[sectionID] as! [AnyObject]
        for (index,item) in (sectionDetails as! [[String : AnyObject]]).enumerated() {
            
            if (item["isMandatory"] as! Bool) && (scrollView.viewWithTag(index) != nil) && (item["fieldValue"] == nil || (item["fieldValue"] as! String).count <= 0) {
                
                if ((scrollView.viewWithTag(index)?.isHidden)! == false && scrollView.viewWithTag(index)!.isUserInteractionEnabled)
                {
                    print(item)
                    if ((item["validationMsg"]! as! String) == "") || ((item["validationMsg"]! as! String) == " "){
                        
                        if errorMessage.contains("Please Enter \(String(describing: item["fieldName"]!))" as NSString) {
                            
                        }else {
                            errorMessage.append("Please Enter \(String(describing: item["fieldName"]!))" as NSString)
                        }
                    }else {
                        
                        if errorMessage.contains("\(String(describing: item["validationMsg"]!))" as NSString) {
                            
                        }else {
                            errorMessage.append("\(String(describing: item["validationMsg"]!))" as NSString)
                        }
                    }
                }
            }
        }
        return errorMessage
    }
    
    //MARK:- Case Validations
    func checkForMandatoryInSectionSave(_ sectionID : Int) -> Bool {
        
        let pageNumber = Int(self.mainScrollView!.contentOffset.x / self.mainScrollView!.bounds.size.width)
        let scrollSubViews = self.mainScrollView!.subviews[pageNumber]
        
        let scrollView = scrollSubViews.subviews[5] as! UIScrollView
        
        var errorStatus  = false
        let sectionDetails = sectionSubSectionResponse[sectionID] as! [AnyObject]
        for (index,item) in (sectionDetails as! [[String : AnyObject]]).enumerated() {
            
            if (item["isMandatory"] as! Bool) && (scrollView.viewWithTag(index) != nil) && (item["fieldValue"] == nil || (item["fieldValue"] as! String).count <= 0) {
                
    
                if (scrollView.subviews[index].isHidden) == false  {
                    
                    //175486
                    if (item["fieldID"] as! Int) == 175486{
                        print("")
                    }
                if ((item["fieldType"] as! String) == DataType.kTextBox)  || ((item["fieldType"] as! String) == DataType.kDatePicker){
                        
                        let mediaSubview = scrollView.subviews[index].subviews[0].subviews
                        
                        if (mediaSubview.count) > 0 {
                            
                            for view in (mediaSubview[0].subviews) {
                                
                                if (view.isKind(of: TextField.self)) {
                                    if (((view as! TextField).text)?.isEmpty)! {
                                        (scrollView.subviews[index].subviews[1]).layer.borderColor = UIColor.red.cgColor
                                        (scrollView.subviews[index].subviews[1]).layer.borderWidth = 1.0
                                        //view.becomeFirstResponder()
                                        errorStatus = true
                                       // return errorStatus
                                    }
                                }
                            }
                        }
                    }
                    else if ((item["fieldType"] as! String) == DataType.kMediaControl) || ((item["fieldType"] as! String) == DataType.kTextArea) {
                        
                        let mediaSubview = scrollView.subviews[index].subviews[0].subviews
                        if (mediaSubview.count) > 0 {
                            
                            for view in (mediaSubview[0].subviews) {
                                if (view.isKind(of: UITextView.self)) {
                                    if ((item["fieldValue"] as! String).count <= 0)  {
                                        (scrollView.subviews[index].subviews[1]).layer.borderColor = UIColor.red.cgColor
                                        (scrollView.subviews[index].subviews[1]).layer.borderWidth = 0.5
                                       // view.becomeFirstResponder()
                                        errorStatus = true
                                       // return errorStatus
                                    }
                                }
                            }
                        }
                }else if ((item["fieldType"] as! String) == DataType.kSpinner){
                        
                        let mediaSubview = scrollView.subviews[index].subviews[0].subviews
                        
                        if (mediaSubview.count) > 0 {
                            
                            for view in (mediaSubview[0].subviews) {
                                if (view.isKind(of: TextField.self)) {
                                    if ((item["fieldValue"] as! String).count <= 0)  {
                                        (scrollView.subviews[index].subviews[1]).layer.borderColor = UIColor.red.cgColor
                                        (scrollView.subviews[index].subviews[1]).layer.borderWidth = 0.5
                                     //   view.becomeFirstResponder()
                                        errorStatus = true
                                       // return errorStatus
                                    }
                                }
                            }
                        }
                    }else if ((item["fieldType"] as! String) == DataType.kRadioGroup){
                    
                        for view in scrollView.subviews[index].subviews{

                            if ((item["fieldValue"] as! String).count <= 0 && view.tag == 1000)  {
                                view.layer.borderColor = UIColor.red.cgColor
                                view.layer.borderWidth = 0.5
                                errorStatus = true
                               // return errorStatus
                            }
                        }
                }else if ((item["fieldType"] as! String) == DataType.kCheckBox){
                    
                        for view in scrollView.subviews[index].subviews{

                            if ((item["fieldValue"] as! String).count <= 0 && view.tag == 1000)  {
                                view.layer.borderColor = UIColor.red.cgColor
                                view.layer.borderWidth = 0.5
                                errorStatus = true
                               // return errorStatus
                            }
                        }
                    }
                }
            }
        }
        return errorStatus
    }
    
    func hideUnhideSpinnerDependents(tag : Int,sectionID : Int,fieldValue : Int) {
        let pageNumber = Int(self.mainScrollView!.contentOffset.x / self.mainScrollView!.bounds.size.width)
        let scrollSubViews = self.mainScrollView!.subviews[pageNumber]
        
        let scrollView = scrollSubViews.subviews[5] as! UIScrollView
        
        let view = mainScrollView?.viewWithTag(tag)
        
        let textField = view?.subviews[0].subviews[0].subviews[2]
        if (textField?.isKind(of: UITextField.self))! {
            
            if ((textField as! UITextField).text == "Yes") {
                
                // hide dependent fields for NO
                let fldDependentsNo = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: fieldValue)
                
                if (fldDependentsNo.count > 0) {
                    
                    for (index,_) in fldDependentsNo.enumerated() {
                        
                        let fldView = self.view.viewWithTag((Int((fldDependentsNo[index] as! TableFieldDependency).fielddependencyfieldid)))
                        
                        fldView?.isHidden = true
                    } // for -each
                }
                
                // show dependent fields for yes
                let fldDependentsYes = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: ( fieldValue))
                
                if (fldDependentsYes.count > 0) {
                    
                    for (index,_) in fldDependentsYes.enumerated() {
                        
                        let fldView = self.view.viewWithTag((Int((fldDependentsYes[index] as! TableFieldDependency).fielddependencyfieldid)))
                        
                        if fldView != nil {
                            
                            fldView?.isHidden = false
                            
                            for subView in (fldView?.subviews)! {
                                
                                if subView.isHidden {
                                    subView.isHidden = false
                                }
                            }
                        }
                    } // for -each
                }
                //LOOP FROM YES TO NO TO LAST
                
                let preViewIndex = getIndexWithSubViews(subViews: scrollView.subviews,fieldId: ((mainScrollView?.viewWithTag(tag))!.superview?.superview?.tag)!)
                
                let preView = scrollView.subviews[preViewIndex]
                
                self.nextConditonIndexWithPrevView(preView: preView, scrollView: scrollView, prevIndex: preViewIndex)
            }else {
                
                // hide dependent fields for YES
                let fldDependentsYes = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: ( fieldValue - 1))
                
                if (fldDependentsYes.count > 0) {
                    for (index,_) in fldDependentsYes.enumerated() {
                        if (sectionID == 110627 || sectionID == 110617 || sectionID == 110609) || (tag == 187769 && sectionID == 110601) {
                        let fldView = self.view.viewWithTag((Int((fldDependentsYes[index] as! TableFieldDependency).fielddependencyfieldid)))
                           if fldView != nil {
                               
                               fldView?.isHidden = false
                               
                               for subView in (fldView?.subviews)! {
                                   
                                   if subView.isHidden {
                                       subView.isHidden = false
                                   }
                               }
                           }
                        }else{
                            let fldView = self.view.viewWithTag((Int((fldDependentsYes[index] as! TableFieldDependency).fielddependencyfieldid)))
                            fldView?.isHidden = true
                        }
                    }
                }
                
                // show dependent fields for NO
                let fldDependentsNo = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: (fieldValue))
                
                if (fldDependentsNo.count > 0) {
                    
                    for (index,_) in fldDependentsNo.enumerated() {
                        
                        let fldView = self.view.viewWithTag((Int((fldDependentsNo[index] as! TableFieldDependency).fielddependencyfieldid)))
                        
                        if fldView != nil {
                            
                            fldView?.isHidden = false
                            
                            for subView in (fldView?.subviews)! {
                                
                                if subView.isHidden {
                                    subView.isHidden = false
                                }
                            }
                        }
                    } // for -each
                }
                
                //LOOP FROM NO TO YES TO LAST
                
                let preViewIndex = getIndexWithSubViews(subViews: scrollView.subviews,fieldId: ((mainScrollView?.viewWithTag(tag))!.superview?.superview?.tag)!)
                
                let preView = scrollView.subviews[preViewIndex]
                
                self.nextConditonIndexWithPrevView(preView: preView, scrollView: scrollView, prevIndex: preViewIndex)
            }
        }
    }
    
    
    func hideUnhideRadioDependents(tag : Int,sectionID : Int) {
        let pageNumber = Int(self.mainScrollView!.contentOffset.x / self.mainScrollView!.bounds.size.width)
        let scrollSubViews = self.mainScrollView!.subviews[pageNumber]
        
        let scrollView = scrollSubViews.subviews[5] as! UIScrollView
        
        let view = mainScrollView?.viewWithTag(tag)
        
        let label = (view?.subviews[1])
        if (label?.isKind(of: UILabel.self))! {
            
            if ((label as! UILabel).text == "Yes") {
                
                // hide dependent fields for NO
                let fldDependentsNo = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: (tag + 1))
                
                if (fldDependentsNo.count > 0) {
                    
                    for (index,_) in fldDependentsNo.enumerated() {
                        
                        let fldView = self.view.viewWithTag((Int((fldDependentsNo[index] as! TableFieldDependency).fielddependencyfieldid)))
                        
                        fldView?.isHidden = true
                    } // for -each
                }
                
                // show dependent fields for yes
                let fldDependentsYes = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: (tag))
                
                if (fldDependentsYes.count > 0) {
                    
                    for (index,_) in fldDependentsYes.enumerated() {
                        
                        let fldView = self.view.viewWithTag((Int((fldDependentsYes[index] as! TableFieldDependency).fielddependencyfieldid)))
                        
                        if fldView != nil {
                            
                            fldView?.isHidden = false
                            
                            for subView in (fldView?.subviews)! {
                                
                                if subView.isHidden {
                                    subView.isHidden = false
                                }
                            }
                        }
                    } // for -each
                }
                //LOOP FROM YES TO NO TO LAST
                
                let preViewIndex = getIndexWithSubViews(subViews: scrollView.subviews,fieldId: ((mainScrollView?.viewWithTag(tag))!.superview?.superview?.tag)!)
                
                let preView = scrollView.subviews[preViewIndex]
                
                self.nextConditonIndexWithPrevView(preView: preView, scrollView: scrollView, prevIndex: preViewIndex)
            }else {
                
                // hide dependent fields for YES
                let fldDependentsYes = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: (tag - 1))
                
                if (fldDependentsYes.count > 0) {
                    for (index,_) in fldDependentsYes.enumerated() {
                        if (sectionID == 110627 || sectionID == 110617 || sectionID == 110609) || (tag == 187769 && sectionID == 110601) {
                        let fldView = self.view.viewWithTag((Int((fldDependentsYes[index] as! TableFieldDependency).fielddependencyfieldid)))
                           if fldView != nil {
                               
                               fldView?.isHidden = false
                               
                               for subView in (fldView?.subviews)! {
                                   
                                   if subView.isHidden {
                                       subView.isHidden = false
                                   }
                               }
                           }
                        }else{
                            let fldView = self.view.viewWithTag((Int((fldDependentsYes[index] as! TableFieldDependency).fielddependencyfieldid)))
                            fldView?.isHidden = true
                        }
                    }
                }
                
                // show dependent fields for NO
                let fldDependentsNo = DataModel.share.getDependentFieldsFromTableFieldDependencyForFieldID(fieldID: (tag))
                
                if (fldDependentsNo.count > 0) {
                    
                    for (index,_) in fldDependentsNo.enumerated() {
                        
                        let fldView = self.view.viewWithTag((Int((fldDependentsNo[index] as! TableFieldDependency).fielddependencyfieldid)))
                        
                        if fldView != nil {
                            
                            fldView?.isHidden = false
                            
                            for subView in (fldView?.subviews)! {
                                
                                if subView.isHidden {
                                    subView.isHidden = false
                                }
                            }
                        }
                    } // for -each
                }
                
                //LOOP FROM NO TO YES TO LAST
                
                let preViewIndex = getIndexWithSubViews(subViews: scrollView.subviews,fieldId: ((mainScrollView?.viewWithTag(tag))!.superview?.superview?.tag)!)
                
                let preView = scrollView.subviews[preViewIndex]
                
                self.nextConditonIndexWithPrevView(preView: preView, scrollView: scrollView, prevIndex: preViewIndex)
            }
        }
    }
    
    func getIndexWithSubViews(subViews : [AnyObject],fieldId : Int)-> Int
    {
        for (i,item) in subViews.enumerated()
        {
            if item.tag == fieldId
            {
                return i
            }
        }
        return 0
    }
    
    func nextConditonIndexWithPrevView(preView : UIView,scrollView : UIScrollView,prevIndex : Int)
    {
        var scrollViewContentHeight : CGFloat = 0.0
        var lastFrame = preView.frame
        
        for nextIndex in (prevIndex + 1)..<scrollView.subviews.count
        {
            let innerView = scrollView.subviews[nextIndex]
            if !innerView.isHidden
            {
                var newFrame = innerView.frame
                newFrame.origin.y = (lastFrame.origin.y) + (lastFrame.size.height) + 10.0
                innerView.frame = newFrame
                lastFrame = newFrame
                scrollViewContentHeight = (lastFrame.origin.y) + (lastFrame.size.height) + 10.0
            }
        }
        
        if scrollViewContentHeight > 0.0 {
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height:scrollViewContentHeight)
        }
    }
}

extension DashboardViewController : DateProtocol, TextBoxProtocol,TextAreaProtocol,SpinnerProtocol,RadioButtonProtocol,CheckBoxProtocol,TimeProtocol,MediaControlProtocol
{
    func mediaControlWithSuperview(superView: UIView, name: String, mediaDetails: [String : AnyObject]) {
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[superView.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = mediaDetails["placeholder"]! as AnyObject
        
        sectionDict[superView.tag] = fieldDict as AnyObject
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
    }
    
    func textFieldWithSuperview(_ superView: UIView, value: String, placeholder: String) {
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[superView.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = value as AnyObject
        sectionDict[superView.tag] = fieldDict as AnyObject
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
    }
    
    
    func textFieldWithValue(_ value: String,_ placeholder: String, textField : UITextField) {
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(textField.superview?.superview?.superview?.superview?.tag)!] as! [AnyObject]
        var fieldDict = sectionDict[(textField.superview?.tag)!] as! [String : AnyObject]
        fieldDict["fieldValue"] = value as AnyObject
        sectionDict[(textField.superview?.tag)!] = fieldDict as AnyObject
        sectionSubSectionResponse[(textField.superview?.superview?.superview?.superview?.tag)!] = sectionDict as AnyObject
    }
    
    func textViewWithSuperview(_ superView: UIView, value: String, placeholder: String) {
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[superView.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = value as AnyObject
        sectionDict[superView.tag] = fieldDict as AnyObject
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
    }
    
    func spinnerWithSuperview(_ superView: UIView, _ value: FieldDataMaster) {
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[superView.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = String(describing: value.id) as AnyObject
        
        sectionDict[superView.tag] = fieldDict as AnyObject
        if fieldDict["fieldType"] as! String == DataType.kSpinner {
            var dependentFieldDict = sectionDict[superView.tag + 2] as! [String : AnyObject]
            dependentFieldDict["isMandatory"] =  false as AnyObject
            sectionDict[superView.tag + 2] = dependentFieldDict as AnyObject
        }
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
        // hide/show radio dependents
        self.hideUnhideSpinnerDependents(tag: (superView.subviews[0].superview?.superview!.tag)!,sectionID: ((superView.superview?.superview?.superview!.tag)!), fieldValue: Int(value.id))
    }
    
    func spinnerWithValue(_ superView: UIView, _ value: String) {
        
    }
    
    func checkBoxWithSuperview(_ superView:UIView, value:String) {
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[(superView.superview?.superview?.subviews[1].tag)!] as! [String : AnyObject]
        
        var selectedBoxValue = ""
        for label in superView.subviews {
            if label.isKind(of: UILabel.self) {
                selectedBoxValue = (label as! UILabel).text!
            }
        }
        
        if (fieldDict["fieldValue"] as! String) == "" {
            fieldDict["fieldValue"] = selectedBoxValue as AnyObject
        }else {
            fieldDict["fieldValue"] = (fieldDict["fieldValue"] as! String) + "," + selectedBoxValue as AnyObject
        }
        sectionDict[(superView.superview?.superview?.subviews[1].tag)!] = fieldDict as AnyObject
        
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
    }
    
    func datePickerWithSuperview(_ superView: UIView, date : Date){
        
        let dateString = Utility.sharedUtility.getDateStringFromDate(date)
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[superView.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = dateString as AnyObject
        sectionDict[superView.tag] = fieldDict as AnyObject
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
    }
    
    func timePickerWithSuperview(_ superView:UIView,timeString : String) {
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] as! [AnyObject]
        var fieldDict = sectionDict[superView.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = timeString as AnyObject
        sectionDict[superView.tag] = fieldDict as AnyObject
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.subviews[5].tag)!] = sectionDict as AnyObject
    }
    
    func radioButtonWithSuperview(_ superView:UIView) {
        
        let selectedRadioButton = superView.subviews[0].subviews[0]
        selectedRadioButton.isHidden = false
        
        let radioLabel = (superView.superview?.superview?.subviews[1] as! UILabel)
        _ = radioLabel.text
        let responseView =  superView.subviews[0]
        let value = String(describing: (responseView.tag)) as AnyObject
        
        let superRadioSubvViews = superView.superview?.superview?.subviews
        
        var radioGroups = [AnyObject]()
        
        for view in superRadioSubvViews! {
            
            if view.isKind(of: UIImageView.self){
                
            }else if view.isKind(of: UILabel.self) {
                
            }else if view.isKind(of: UIView.self) {
                radioGroups.append(view)
            }
        }
        
        for (_,item) in (radioGroups.enumerated())
        {
            let radioSubView = item.subviews
            
            for (_,radioView) in radioSubView!.enumerated() {
                
                let selectedRadioButton = radioView.subviews[0]
                
                if radioView.tag == superView.tag
                {
                    selectedRadioButton.isHidden = false
                }
                else
                {
                    selectedRadioButton.subviews[0].isHidden = true
                }
            }
        }
        
        var sectionDict :  [AnyObject] = sectionSubSectionResponse[(superView.superview?.superview?.superview?.superview?.tag)!] as! [AnyObject]
        var fieldDict = sectionDict[radioLabel.tag] as! [String : AnyObject]
        fieldDict["fieldValue"] = value as AnyObject
        sectionDict[radioLabel.tag] = fieldDict as AnyObject
        sectionSubSectionResponse[(superView.superview?.superview?.superview?.superview?.tag)!] = sectionDict as AnyObject
        
        // hide/show radio dependents
        self.hideUnhideRadioDependents(tag: superView.subviews[0].tag,sectionID: ((superView.superview?.superview?.superview?.superview!.tag)!))
    }
    
}

extension DashboardViewController: UtilityProtocol {
    
    func dismissAlert() {
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
    }
    
    func pushToViewController() {
        mainScrollView?.isHidden = true
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func pushToNextViewController() {
        
        let alertView = self.view.subviews.last
        alertView?.removeFromSuperview()
        
        // submit case
        self.submitCase()
    }
}

extension DashboardViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.view.endEditing(true)
        let pageNumber = Int((mainScrollView?.contentOffset.x)! / (mainScrollView?.bounds.size.width)!)

        updateSection(pageNo: pageNumber)
    }
    
    func updateSection(pageNo: Int)
    {
        let superViewSubViews = self.view.subviews
        
        //leftView
        let leftView = superViewSubViews[2]
        //RightView
        let rightView = superViewSubViews[3]
        
        if  pageNo  ==  0
        {
            leftView.isHidden = true
            rightView.isHidden = false
        }
        else
        {
            leftView.isHidden = false
            rightView.isHidden = false
        }
        if pageNo == (mainScrollView?.subviews.count)! - 1
        {
            rightView.isHidden = true
            leftView.isHidden = false
            sendInformationButton?.isHidden = false
        }
    }
        
}


