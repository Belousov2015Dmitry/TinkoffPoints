//
//  Utils.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 25.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import MapKit.MKGeometry



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
    
    func contains(region: MKCoordinateRegion) -> Bool {
        let first = MKMapRect(
            origin: MKMapPoint(
                x: self.center.latitude - self.span.latitudeDelta / 2,
                y: self.center.longitude - self.span.longitudeDelta / 2
            ),
            size: MKMapSize(
                width: self.span.latitudeDelta,
                height: self.span.longitudeDelta
            )
        )
        
        let second = MKMapRect(
            origin: MKMapPoint(
                x: region.center.latitude - region.span.latitudeDelta / 2,
                y: region.center.longitude - region.span.longitudeDelta / 2
            ),
            size: MKMapSize(
                width: region.span.latitudeDelta,
                height: region.span.longitudeDelta
            )
        )
        
        return MKMapRectContainsRect(first, second)
    }
}
