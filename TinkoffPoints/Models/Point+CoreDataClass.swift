//
//  Point+CoreDataClass.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 24.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation.CLLocation
import UIKit.UIImage


public class Point: NSManagedObject {

    static func entityDescription(inContext context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Point", in: context)!
    }
    
    convenience init(
        externalId: String,
        partnerName: String,
        latitude: Double,
        longitude: Double,
        partner: Partner? = nil,
        context: NSManagedObjectContext
    ) {
        self.init(
            entity: Point.entityDescription(inContext: context),
            insertInto: context
        )
        
        self.externalId  = externalId
        self.partnerName = partnerName
        self.latitude    = latitude
        self.longitude   = longitude
        self.partner     = partner
    }
    
    static func parse(json: [String : Any], context: NSManagedObjectContext) -> Point? {
        guard
            let externalId  = json["externalId"] as? String,
            let partnerName = json["partnerName"] as? String,
            let location    = json["location"] as? [String : Double],
            let latitude    = location["latitude"],
            let longitude   = location["longitude"]
        else {
            return nil
        }
        
        return Point(
            externalId: externalId,
            partnerName: partnerName,
            latitude: latitude,
            longitude: longitude,
            context: context
        )
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var icon: UIImage {
        guard
            partner != nil,
            let picture = partner?.picture as NSString?
        else {
            return UIImage()
        }
        
        let cache = APP_DELEGATE.imageCache
        
        if let cached = cache.object(forKey: picture) {
            return cached
        }
        else {
            guard
                let data = partner?.imageData,
                let image = UIImage(data: data as Data)
            else {
                return UIImage()
            }
            
            cache.setObject(image, forKey: picture)
            return image
        }
    }
    
    public var name: String {
        return partner?.name ?? ""
    }
}
