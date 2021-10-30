//
//  DatePickerViewController.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 29/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

protocol DatePickerProtocol {
    func selectedDate(_ date: Date, superview: UIView)
}

class DatePickerViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    var delegate: DatePickerProtocol?
    var superView: UIView?
    @IBOutlet weak var cancel: UIButton!
    
    convenience init(superview: UIView, delegate: DatePickerProtocol) {
        self.init()
        self.superView = superview
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cancel.layer.borderColor = UIColor.white.cgColor
        
       datePicker.maximumDate = Date()
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -60, to: Date())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func applyButtonTapped(_ sender: UIButton) {
        
        if self.delegate != nil {
            self.delegate?.selectedDate(datePicker.date, superview: self.superView!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }


}
