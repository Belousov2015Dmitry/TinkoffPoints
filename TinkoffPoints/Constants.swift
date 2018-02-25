//
//  Constants.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 24.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import UIKit.UIScreen


let HOST_API = "api.tinkoff.ru"
let HOST_STATIC = "static.tinkoff.ru"

let PATH_POINTS = "/v1/deposition_points"
let PATH_PARTNERS = "/v1/deposition_partners"
let PATH_ICONS = "/icons/deposition-partners-v3"


enum SizeClass : String {
    case x1 = "mdpi"
    case x2 = "xhdpi"
    case x3 = "xxhdpi"
    
    static var current: SizeClass {
        switch UIScreen.main.scale {
            case 1:  return .x1
            case 2:  return .x2
            default: return .x3
        }
    }
}
