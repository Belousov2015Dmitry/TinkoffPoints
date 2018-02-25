//
//  Partner+CoreDataClass.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 24.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit.UIImage


public class Partner: NSManagedObject {

    static func entityDescription(inContext context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Partner", in: context)!
    }
    
    
    convenience init(
        id: String,
        name: String,
        picture: String,
        points: NSSet = [],
        context: NSManagedObjectContext
    ) {
        self.init(
            entity: Partner.entityDescription(inContext: context),
            insertInto: context
        )
        
        self.id = id
        self.name = name
        self.picture = picture
        self.points = points
    }
    
    static func parse(json: [String : Any], context: NSManagedObjectContext) -> Partner? {
        guard
            let id      = json["id"] as? String,
            let name    = json["name"] as? String,
            let picture = json["picture"] as? String
        else {
            return nil
        }
        
        return Partner(id: id, name: name, picture: picture, context: context)
    }
}
