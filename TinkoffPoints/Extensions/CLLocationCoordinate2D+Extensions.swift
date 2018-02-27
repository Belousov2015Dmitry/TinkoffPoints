//
//  CLLocationCoordinate2D+Extensions.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 27.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation


extension CLLocationCoordinate2D
{
    static func == (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool {
        return
            fabs(left.latitude - right.latitude) < 0.0000001 &&
                fabs(left.longitude - right.longitude) < 0.0000001
    }
}
