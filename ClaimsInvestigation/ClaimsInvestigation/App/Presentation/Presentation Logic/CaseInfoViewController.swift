//
//  CaseInfoViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 17/09/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class CaseInfoViewController: UIViewController {
    
    var caseID: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        createCaseView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createCaseView() {
        
        let frame = Configuration.sharedConfiguration.bounds()
        
        let fieldMasterDetails = DataModel.share.getFieldMasterWithSectionHeader()
        
        if (fieldMasterDetails.count > 0) {
            
            var xPos:CGFloat = 0.0
            var yPos:CGFloat = 100.0
            var width:CGFloat = frame.size.width
            var height:CGFloat = frame.size.height - yPos - 50.0
            
            let leading: CGFloat = 20.0
            
            xPos = leading
            
            let caseDetailMaster = DataModel.share.getAssignedCaseDetailForHeader(caseID: caseID)
            
            let mainView = UIView(frame: CGRect(x: 10.0, y: yPos, width: (width - 20), height: height))
            mainView.layer.cornerRadius = 4.0
            mainView.layer.masksToBounds = true
            mainView.layer.shadowRadius = 4.0
            mainView.backgroundColor = UIColor.white
            view.addSubview(mainView)
            
            let headerView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: mainView.frame.size.width, height: 50.0))
            headerView.backgroundColor = ColorConstant.kThemeColor
            mainView.addSubview(headerView)
            
            // Header label
            xPos = 20.0
            height = 40.0
            yPos = (headerView.frame.size.height - height)/2
            width = headerView.frame.size.width - 2 * xPos
            let headerLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
            headerLabel.text = "Case Information"
            headerLabel.textColor = UIColor.white
            headerLabel.numberOfLines = 1
            headerLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
            headerLabel.textAlignment = .left
            headerView.addSubview(headerLabel)
            
            // close button image
            xPos = headerView.frame.size.width - 50.0
            
            let closeImage = UIImageView(frame: CGRect(x: xPos, y: yPos, width: 40.0, height: 40.0))
            closeImage.image = #imageLiteral(resourceName: "ic_close")
            closeImage.contentMode = UIViewContentMode.scaleAspectFit
            headerView.addSubview(closeImage)
            
            xPos = closeImage.frame.origin.x - 10.0
            height = headerView.frame.size.height
            yPos = 0.0
            width = closeImage.frame.size.width + 20.0
            
            // close button
            let btnClose = UIButton(type: UIButtonType.custom)
            btnClose.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
            btnClose.backgroundColor = UIColor.clear
            btnClose.addTarget(self, action: #selector(dismissInfoView(_:)), for: UIControlEvents.touchUpInside)
            headerView.addSubview(btnClose)
            
            height = mainView.frame.size.height
            
            let fldScrollview = UIScrollView(frame: CGRect(x: 0.0, y: headerView.frame.size.height, width: headerView.frame.size.width, height: height))
            fldScrollview.showsVerticalScrollIndicator = false
            fldScrollview.alwaysBounceVertical = true
            mainView.addSubview(fldScrollview)
            
            var yPosField: CGFloat = 10.0
            
            var labelValue: UILabel? = nil
            
            for (index,fldItem) in fieldMasterDetails.enumerated()
            {
                _ = index
                
                var tempString: String = ""
                
                let fldItemWidth = (fldScrollview.frame.size.width - (leading * 2))/2 - 10.0
                
                let fldMasterData = fldItem as! FieldMaster
                
//                if (fldMasterData.master_fldId == 175213) || (fldMasterData.master_fldId == 175214) || (fldMasterData.master_fldId == 175762) {
//
//                }else {
                
                    if ((fldMasterData.fldType == DataType.kLabel) || (fldMasterData.fldType == DataType.kName)) {
                        
                        var heightDynamicKey: CGFloat = 0.0
                        var heightDynamicValue: CGFloat = 0.0
                        var heightNew: CGFloat = 40.0
                        
                        heightDynamicKey = Utility.sharedUtility.getHeightFromTextWithFrame(text: fldMasterData.fldLabel!, font: UIFont.systemFont(ofSize: 16.0), frame: CGRect(x: leading, y: yPosField, width: fldItemWidth, height: heightNew))
                        
                        for caseDetailItem in caseDetailMaster {
                            let caseMasterData = caseDetailItem as! CaseDetail
                            
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
                        fldScrollview.addSubview(label)
                        
                        xPos = label.frame.origin.x + label.frame.size.width + 20.0
                        
                        labelValue = UILabel(frame: CGRect(x: xPos, y: yPosField, width: fldItemWidth, height: heightNew))
                        labelValue?.font = UIFont.systemFont(ofSize: 16.0)
                        labelValue?.numberOfLines = 0
                        labelValue?.text = tempString
                        fldScrollview.addSubview(labelValue!)
                        
                        yPosField = yPosField + heightNew + 5.0
                    }
                    
                    fldScrollview.contentSize = CGSize(width: (fldScrollview.frame.size.width), height: yPosField + 60.0)

//                }
                
            }
        }
    }
    
    @IBAction func dismissInfoView(_ sender : UIButton) {
        
        // dismiss info view here
        
        self.dismiss(animated: true, completion: nil)
    }

}
