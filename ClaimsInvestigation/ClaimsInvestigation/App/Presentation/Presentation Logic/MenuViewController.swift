//
//  MenuViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 01/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol SliderMenuDelegate {
    func updateInvestigatorProfile()
    func openInbox()
    func openDraft()
    func openCompleted()
    func openSubmitted()
    func openSettings()
    func openHealthCheck()
    func checkAppUpdate()
    func logOut()
}

class MenuViewController: UIViewController {
    
    var arrMenuList = ["Inbox","Draft","Completed","Submitted","","Others","Settings","Health Check","Update App","Logout"]
    var delegate : SliderMenuDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.loadMenu()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMenu() {
        
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 0.0
        var width: CGFloat = Configuration.sharedConfiguration.bounds().size.width - 100.0
        var height: CGFloat = Configuration.sharedConfiguration.bounds().size.height
        
        let menuView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        menuView.backgroundColor = UIColor.init(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        self.view.addSubview(menuView)
        
        xPos = Configuration.sharedConfiguration.bounds().size.width - 100
        width = 100
        
        let viewTap = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewTap.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        viewTap.isOpaque = false
        self.view.addSubview(viewTap)
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.onClose))
        panGesture.minimumNumberOfTouches = 1
        viewTap.addGestureRecognizer(panGesture)
        
        xPos = 0.0
        yPos = 0.0
        width = menuView.frame.size.width
        height = 100.0
        
        let logoView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        logoView.backgroundColor = UIColor.white
        menuView.addSubview(logoView)
        
        let logoImage = UIImageView(frame: CGRect(x: xPos, y: 10.0, width: width, height: 80.0))
        logoImage.image = #imageLiteral(resourceName: "hitpa_logo")
        logoImage.contentMode = UIViewContentMode.scaleAspectFit
        logoView.addSubview(logoImage)
        
        xPos = 0.0
        yPos = logoView.frame.size.height
        width = menuView.frame.size.width
        height = 60.0
        
        let profileView = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        profileView.backgroundColor = ColorConstant.kThemeColor
        menuView.addSubview(profileView)
        
        let profileGesture = UITapGestureRecognizer.init(target: self, action: #selector(profileGestureTapped(_:)))
        profileView.addGestureRecognizer(profileGesture)
        
        xPos = 15.0
        yPos = profileView.frame.size.height/2.0 - 15.0
        width = 30.0
        height = 30.0
        
        let profileImageInvestigator = UIImageView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        profileImageInvestigator.image = #imageLiteral(resourceName: "ic_account_circle_white")
        profileImageInvestigator.contentMode = UIViewContentMode.scaleAspectFit
        profileView.addSubview(profileImageInvestigator)
        
        xPos = profileImageInvestigator.frame.origin.x + profileImageInvestigator.frame.size.width + 10.0
        yPos = profileView.frame.size.height/2.0 - 15.0
        width = profileView.frame.size.width - profileImageInvestigator.frame.size.width - 5.0
        height = 30.0
        
        let profileNameInvestigator = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        profileNameInvestigator.textColor = UIColor.white
        profileNameInvestigator.font = FontsFamily.kRegular
        profileNameInvestigator.numberOfLines = 0
        profileNameInvestigator.textAlignment = NSTextAlignment.left
        profileNameInvestigator.text = UserManager.sharedManager.investigatorName != nil ? UserManager.sharedManager.investigatorName : "investigatorThree"
        profileView.addSubview(profileNameInvestigator)
        
        xPos = 0.0
        yPos = profileView.frame.size.height + profileView.frame.origin.y
        width = menuView.frame.size.width
        height = menuView.frame.size.height - profileView.frame.size.height - logoView.frame.size.height
        
        let tableViewMenu = UITableView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        tableViewMenu.backgroundColor = UIColor.clear
        tableViewMenu.tableFooterView = UIView()
        tableViewMenu.delegate = self
        tableViewMenu.dataSource = self
        tableViewMenu.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableViewMenu.isScrollEnabled = true
        tableViewMenu.separatorStyle = .none
        tableViewMenu.showsVerticalScrollIndicator = false
        tableViewMenu.reloadData()
        menuView.addSubview(tableViewMenu)
        
    }
    
    @objc func profileGestureTapped(_ sender: UITapGestureRecognizer)  {
        // update profile
        
        self.onCloseMenu()
        self.delegate?.updateInvestigatorProfile()
    }
    
    func cellImage(index: Int) -> UIImage {
        switch index {
        case 0:
            return #imageLiteral(resourceName: "ic_inbox_black")
        case 1:
            return #imageLiteral(resourceName: "ic_drafts_black")
        case 2:
            return #imageLiteral(resourceName: "ic_timepicker_black")
        case 3:
            return #imageLiteral(resourceName: "ic_done_black")
        case 6:
            return #imageLiteral(resourceName: "ic_settings_black")
        case 7:
            return #imageLiteral(resourceName: "ic_favorite_border_black")
        case 8:
            return #imageLiteral(resourceName: "ic_system_update_black")
        default:
            return #imageLiteral(resourceName: "ic_exit_to_app_black")
        }
    }
    
    func cellSelectedImage(index: Int) -> UIImage {
        switch index {
        case 0:
            return #imageLiteral(resourceName: "ic_inbox_blue")
        case 1:
            return #imageLiteral(resourceName: "ic_drafts_blue")
        case 2:
            return #imageLiteral(resourceName: "ic_timepicker_blue")
        case 3:
            return #imageLiteral(resourceName: "ic_done_blue")
        case 6:
            return #imageLiteral(resourceName: "ic_settings_blue")
        case 7:
            return #imageLiteral(resourceName: "ic_favorite_border_blue")
        case 8:
            return #imageLiteral(resourceName: "ic_system_update_blue")
        default:
            return #imageLiteral(resourceName: "ic_exit_to_app_blue")
        }
    }
    
    @objc func onCloseMenu()
    {
        UIView.animate(withDuration: 0.3, animations: { ()-> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.width, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    @objc func onClose()
    {
        UIView.animate(withDuration: 0.3, animations: { ()-> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.width, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            
        }, completion: { (finished) -> Void in
            self.removeFromParentViewController()
        })
    }
}

extension MenuViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for : indexPath)
        cell.selectionStyle = .gray
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.textLabel?.text = arrMenuList[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.isHidden = false
        
        if indexPath.row == 4 {
            
            let viewSeparator = UIView(frame: CGRect(x: 0.0, y: (cell.contentView.frame.size.height)/2, width: cell.contentView.frame.size.width, height: 1.0))
            viewSeparator.backgroundColor = UIColor.gray
            cell.contentView.addSubview(viewSeparator)
            cell.isUserInteractionEnabled = false
            
            cell.textLabel?.isHidden = true
        }
        
        if indexPath.row == 5 {
            cell.isUserInteractionEnabled = false
        }

        if indexPath.row != 4  && indexPath.row != 5 {
            cell.imageView?.frame = CGRect(x: 10.0, y: 10.0, width: 80.0, height: 80.0)
            cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            cell.imageView?.image = cellImage(index: indexPath.row)
        }
        
        if (HITPAUserDefaults.sharedUserDefaults.value(forKey: "RowSelected") == nil) && (indexPath.row == 0) {
            cell.textLabel?.textColor = ColorConstant.kThemeColor
            cell.contentView.backgroundColor = UIColor.lightGray
            cell.imageView?.image = cellSelectedImage(index: 0)
            
        }else if (HITPAUserDefaults.sharedUserDefaults.value(forKey: "RowSelected") != nil) && ((HITPAUserDefaults.sharedUserDefaults.value(forKey: "RowSelected") as! Int)  == indexPath.row) {
            
            cell.textLabel?.textColor = ColorConstant.kThemeColor
            cell.contentView.backgroundColor = UIColor.lightGray
            cell.imageView?.image = cellSelectedImage(index: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.textLabel?.textColor = ColorConstant.kThemeColor
        
        cell?.contentView.backgroundColor = UIColor.lightGray
        
        HITPAUserDefaults.sharedUserDefaults.set(indexPath.row, forKey: "RowSelected")
        HITPAUserDefaults.sharedUserDefaults.synchronize()
        
        switch indexPath.row {
        case 0:

            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.openInbox()
            break
        case 1:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.openDraft()
            break
        case 2:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.openCompleted()
            break
        case 3:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.openSubmitted()
            break
        case 6:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.openSettings()
            break
        case 7:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.openHealthCheck()
            break
        case 8:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)
            
            self.delegate?.checkAppUpdate()
            break
        case 9:
            cell?.imageView?.image = cellSelectedImage(index: indexPath.row)

            self.delegate?.logOut()
            break
        default:
            break
        }
                
        self.onCloseMenu()
    }
    
}
