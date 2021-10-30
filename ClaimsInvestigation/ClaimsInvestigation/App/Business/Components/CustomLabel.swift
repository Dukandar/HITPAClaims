//
//  CustomLabel.swift
//  ClaimsInvestigation
//
//  Created by Vivek Saini on 08/08/18.
//  Copyright © 2018 iNube Software Solutions. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 10.0
    @IBInspectable var rightInset: CGFloat = 10.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }


}
