//
//  Button.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 20/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

class Button: UIButton {
    var selectedView : UIView? = nil
    var isPused : Bool = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commitInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitInit()
    }
    
    func commitInit()
    {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        self.isExclusiveTouch = false
        self.setDefaultStyles()
        let view = UIView(frame: .zero)
        view.alpha = 0.0
        view.backgroundColor = UIColor.green
        view.isUserInteractionEnabled = false
        self.selectedView = view
    }
    
    
    func setDefaultStyles()
    {
        self.titleLabel?.textColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.performLayout()
    }
    
    func performLayout()
    {
        self.selectedView?.backgroundColor = UIColor.lightText
        self.backgroundColor = UIColor.init(red: 0.0/255.0, green: 55.0/255.0, blue: 122.0/255.0, alpha: 1.0)
        self.selectedView?.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.addSubview(self.selectedView!)
//        self.layer.cornerRadius = self.frame.size.height / 2.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.15,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        self.isHighlighted = true
                        self.selectedView?.alpha = 1.0
                        self.backgroundColor = UIColor.orange
        }
            , completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.15,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        self.isHighlighted = false
                        self.selectedView?.alpha = 0.0
                        self.backgroundColor = UIColor.green
        }
            , completion: nil)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
