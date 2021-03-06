//
//  UIView+Extensions.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 25.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import Foundation
import UIKit


@IBDesignable class UIViewDesignable : UIView {}
@IBDesignable class UIButtonDesignable : UIButton {}
@IBDesignable class UIImageViewDesignable : UIImageView {}
@IBDesignable class UILabelDesignable : UILabel {}



extension UIView
{
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    
    @IBInspectable var borderColor: UIColor {
        get {
            guard let cgColor = self.layer.borderColor else {
                return UIColor.clear
            }
            
            return UIColor(cgColor: cgColor)
        }
        
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
        layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: .zero,
                size: CGSize(width: self.frame.width, height: self.frame.height)
            ),
            cornerRadius: self.frame.height / 2
        ).cgPath
    }
}
