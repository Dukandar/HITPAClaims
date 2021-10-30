//
//  TimePickerViewController.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 29/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

protocol TimePickerProtocol {
    func selectedTime(_ time: Date, superview: UIView)
}

class TimePickerViewController: UIViewController {
    
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet var timePicker: UIDatePicker!
    var delegate: TimePickerProtocol?
    var superView: UIView?
    
    convenience init(superview: UIView, delegate: TimePickerProtocol) {
        self.init()
        self.superView = superview
        self.delegate = delegate
    }
    
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        cancel.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        if self.delegate != nil {
            self.delegate?.selectedTime(timePicker.date, superview: self.superView!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
