//
//  UIImage+Extsensions.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 27.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import UIKit.UIImage



extension UIImage
{
    func ofSize(width: CGFloat, height: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        
        self.draw(in: CGRect(origin: .zero, size: size))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    var rounded: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        
        let rect = CGRect(origin: .zero, size: self.size)
        
        UIBezierPath(roundedRect: rect, cornerRadius: self.size.height).addClip()
        
        self.draw(in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
