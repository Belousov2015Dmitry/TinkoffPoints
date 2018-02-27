//
//  PointAnnotation.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 25.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import MapKit.MKAnnotation



class PointAnnotation : NSObject, MKAnnotation
{
    var id: String
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage
    
    
    init(id: String, title: String, image: UIImage, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = nil
        self.image = image
    }
}
