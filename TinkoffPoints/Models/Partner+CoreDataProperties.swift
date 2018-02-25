//
//  Partner+CoreDataProperties.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 26.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//
//

import Foundation
import CoreData


extension Partner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Partner> {
        return NSFetchRequest<Partner>(entityName: "Partner")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var picture: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var points: NSSet?

}

// MARK: Generated accessors for points
extension Partner {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: Point)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: Point)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}
