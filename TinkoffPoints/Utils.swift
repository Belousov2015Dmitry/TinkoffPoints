//
//  Utils.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 25.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import MapKit.MKGeometry


extension CLLocationCoordinate2D
{
    
    
    static func == (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool {
        return
            fabs(left.latitude - right.latitude) < 0.0000001 &&
            fabs(left.longitude - right.longitude) < 0.0000001
    }
}



extension MKCoordinateRegion
{
    var radius: Double {
        let center = CLLocation(
            latitude: self.center.latitude,
            longitude: self.center.longitude
        )
        
        let northEast = CLLocation(
            latitude: self.center.latitude + self.span.latitudeDelta * 0.5,
            longitude: self.center.longitude + self.span.longitudeDelta * 0.5
        )
        
        return northEast.distance(from: center)
    }
}
