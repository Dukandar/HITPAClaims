//
//  DropdownSearchViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 09/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

struct DropdownDetail {
    static let HEADER_HEIGHT: CGFloat = DeviceType.IPAD ? 80.0 : 60.0
    static let DROPDOWN_CELL_HEIGHT: CGFloat = DeviceType.IPAD ? 64.0 : 44.0
}

protocol DropDownSearch {
    func setDropDownSearchValue(_ value: FieldDataMaster, superview: UIView)
    func setDropDownStringValue(_ value: String, superview: UIView)
}

class DropdownSearchViewController: UIViewController {
    
    var delegate: DropDownSearch?
    var listValues: [AnyObject]?
    var selectedStringValue : FieldDataMaster?
    var selectedYear: String?
    var superView: UIView?
    var dropDownTitle: String?
    var tableViewMenu:UITableView?
    var filteredValues: [AnyObject]?
    
    convenience init(_ list: [AnyObject],_ title: String,_ superview: UIView, delegate: DropDownSearch) {
        self.init()
        self.delegate = delegate
        self.superView = superview
        listValues = list[0] as?  [AnyObject]
        filteredValues = listValues
        self.dropDownTitle = title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createDropDownView()
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDropDownView() {
        
        let frame = Configuration.sharedConfiguration.bounds()
        
        var xPos: CGFloat = 0.0
        var yPos: CGFloat = 0.0
        var width: CGFloat = frame.size.width
        var height: CGFloat = frame.size.height
        
        let viewBG = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        viewBG.backgroundColor = UIColor.clear
        self.view.addSubview(viewBG)
        
        xPos = DeviceType.IPAD ? 30.0 : 10.0
        height = DeviceType.IPAD ? 340.0 : 320.0
        yPos = (viewBG.frame.size.height - height)/2
        width = viewBG.frame.size.width - 2 * xPos
        
        let dropdownView = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        dropdownView.backgroundColor = UIColor.white
        viewBG.addSubview(dropdownView)
        
        xPos = 0.0
        yPos = 0.0
        height = DropdownDetail.HEADER_HEIGHT
        width = dropdownView.frame.size.width
        
        let headerView = UIView(frame:CGRect(x: xPos, y: yPos, width: width, height: height))
        headerView.backgroundColor = ColorConstant.kThemeColor
        dropdownView.addSubview(headerView)
        
        // Header label
        xPos = 15.0
        yPos = 0.0
        width = headerView.frame.size.width - 70.0
        height = headerView.frame.size.height
        let headerLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        headerLabel.text = dropDownTitle
        headerLabel.textColor = UIColor.white
        headerLabel.numberOfLines = 0
        headerLabel.font = DeviceType.IPAD ? UIFont.systemFont(ofSize: 22.0) : UIFont.systemFont(ofSize: 18.0)
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.textAlignment = .left
        
        headerView.addSubview(headerLabel)
    
        
        // cancel button
        xPos = headerView.frame.size.width - 50.0
        yPos = 10.0
        width = 40.0
        height = 40.0
        
        let buttonImageSave = UIImage.init(named: "ic_close")
        let btnCancel = UIButton(type: UIButtonType.custom)
        
        btnCancel.setImage(buttonImageSave, for: UIControlState.normal)

        btnCancel.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        btnCancel.addTarget(self, action: #selector(btnCancelTapped(_:)), for: UIControlEvents.touchUpInside)

        headerView.addSubview(btnCancel)
        
        // search Bar
        xPos = 0.0
        yPos = headerView.frame.origin.y + headerView.frame.size.height + 10.0
        width = dropdownView.frame.size.width - 2 * xPos
        height = 40.0
        let searchBar = UISearchBar(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.placeholder = "search"
        
        searchBar.backgroundImage = UIImage()
        dropdownView.addSubview(searchBar)
        
        // gray separator line
        xPos = 0.0
        yPos = searchBar.frame.origin.y + searchBar.frame.size.height
        width = dropdownView.frame.size.width
        height = 1.0
        let viewSeparatorLine = UIView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        viewSeparatorLine.backgroundColor = ColorConstant.KGrayBGColor
        dropdownView.addSubview(viewSeparatorLine)
        
        // list view
        xPos = 0.0
        yPos = viewSeparatorLine.frame.origin.y + viewSeparatorLine.frame.size.height
        width = dropdownView.frame.size.width
        height = dropdownView.frame.size.height - yPos
        
        tableViewMenu = UITableView(frame: CGRect(x: xPos, y: yPos, width: width, height: height))
        tableViewMenu!.delegate = self
        tableViewMenu!.dataSource = self
        tableViewMenu!.tableFooterView = UIView()
        tableViewMenu!.separatorStyle = .singleLineEtched
        dropdownView.addSubview(tableViewMenu!)
        
    }
    
    @IBAction func btnCancelTapped(_ sender : UIButton) {
        // dismiss the view here
        self.dismiss(animated: true, completion: nil)
    }
}

extension DropdownSearchViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (filteredValues?.count)! > 0 {
            return filteredValues!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell!.textLabel?.textAlignment = NSTextAlignment.left
        let fldMaster = filteredValues?[indexPath.row] as? FieldDataMaster
        cell!.textLabel?.text = (fldMaster != nil) ? fldMaster?.fieldata_optionvalues : String(describing: (filteredValues?[indexPath.row])!)
        cell!.textLabel?.font = FontsFamily.kRegular
        cell!.backgroundColor = UIColor.clear
        cell!.textLabel?.numberOfLines = 0

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedStringValue = filteredValues?[indexPath.row] as? FieldDataMaster
        if self.selectedStringValue == nil {
            self.selectedYear = String(describing: (filteredValues?[indexPath.row])!)
        }
        if self.delegate != nil && self.selectedStringValue != nil {
            self.delegate?.setDropDownSearchValue(self.selectedStringValue!, superview: self.superView!)
        }else if self.delegate != nil && self.selectedYear != nil {
            self.delegate?.setDropDownStringValue(self.selectedYear!, superview: self.superView!)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension DropdownSearchViewController : UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.view.endEditing(true)
        searchBar.showsCancelButton = false
        filteredValues?.removeAll()
        filteredValues = listValues
        tableViewMenu?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        let searchText = searchBar.text
        
        if listValues is [FieldDataMaster] {
            let filteredListTemp = (listValues as! [FieldDataMaster]).filter({ (item : FieldDataMaster) -> Bool in
                
                let filteredString = (item.fieldata_optionvalues?.lowercased())?.range(of: (searchText!.lowercased()))
                return filteredString != nil ? true : false
            })
            
            filteredValues?.removeAll()
            filteredValues = filteredListTemp
        }else {
            let filteredTableData = (listValues as! [String]).filter{ (item:String) -> Bool in
                let filterString = item.range(of: (searchBar.text)!)
                return filterString != nil ? true : false
            }
            filteredValues?.removeAll()
            filteredValues = filteredTableData as [AnyObject]
        }
        
        tableViewMenu?.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (searchBar.text?.count)! > 0 {
            
            let searchText = searchBar.text

            if listValues is [FieldDataMaster] {
                let filteredListTemp = (listValues as! [FieldDataMaster]).filter({ (item : FieldDataMaster) -> Bool in
                    
                    let filteredString = (item.fieldata_optionvalues?.lowercased())?.range(of: (searchText!.lowercased()))
                    return filteredString != nil ? true : false
                })
                
                filteredValues?.removeAll()
                filteredValues = filteredListTemp
            }else {
                let filteredTableData = (listValues as! [String]).filter{ (item:String) -> Bool in
                    let filterString = item.range(of: searchText!)
                    return filterString != nil ? true : false
                }
                filteredValues?.removeAll()
                filteredValues = filteredTableData as [AnyObject]
            }
            
            tableViewMenu?.reloadData()
            
        }
        return true
        
    }

}

extension DropDownSearch {
    func setDropDownStringValue(_ value: String, superview: UIView) {
        
    }
}
