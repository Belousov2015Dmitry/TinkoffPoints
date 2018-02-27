//
//  Point+CoreDataProperties.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 26.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//
//

import Foundation
import CoreData


extension Point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Point> {
        return NSFetchRequest<Point>(entityName: "Point")
    }

    @NSManaged public var externalId: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var partnerName: String?
    @NSManaged public var partner: Partner?

}
