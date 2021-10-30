//
//  View.swift
//  ClaimsInvestigation

//
//  Created by Vivek Saini on 24/07/18.
//  Copyright © 2018 iNubeSolutions. All rights reserved.
//

import UIKit

class View: UIView {
    
    func shadowAllEdges(shadowColor: UIColor = .black, shadowOpacity: Float = 1.0, shadowOffSet: CGSize,shadowRadius: CGFloat = 5.0,shadowSize: CGFloat = 5.0) {
        
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: bounds.size.width + shadowSize ,
                                                   height: bounds.size.height + shadowSize))
        layer.masksToBounds = false
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    func dropShadow(color: UIColor, opacity: Float = 0.6, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    func createRoundThemeColorImage() {
        
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.borderColor = ColorConstant.kThemeColor.cgColor
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 2.0
        
        let viewInner = UIView(frame: CGRect(x: self.frame.midX - self.frame.size.width/3, y: self.frame.size.height/6, width: self.frame.size.width/3*2, height: self.frame.size.height/3*2))
        viewInner.layer.cornerRadius = viewInner.frame.size.height/2
        viewInner.backgroundColor = ColorConstant.kThemeColor
        self.addSubview(viewInner)
    }
    
    func clearSubview() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.borderColor = ColorConstant.kThemeColor.cgColor
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 2.0
        
        for view in self.subviews {
            if (view.isKind(of: UIView.self)) {
                view.removeFromSuperview()
            }
        }
        
    }
    
    
}
