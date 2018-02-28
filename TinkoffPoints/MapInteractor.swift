//
//  MapInteractor.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 24.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit.UIImage


class MapInteractor : NSObject, CLLocationManagerDelegate
{
    public typealias PresentablePoint = (id: String, title: String, icon: UIImage, coordinate: CLLocationCoordinate2D)
    
    
    
    //MARK: - Callbacks
    public var locationChanged: ((_ coordinate: CLLocationCoordinate2D) -> Void)? = nil
    public var pointsFetched: ((_ center: CLLocationCoordinate2D, _ radius: Int) -> Void)? = nil
    public var loading: ((_ active: Bool) -> Void)? = nil
    
    
    
    //MARK: - Variables
    private let mainContext = APP_DELEGATE.persistentContainer.viewContext
    private lazy var readContext = self.createReadManagedObjectContext()
    private lazy var writeContext = self.createWriteManagedObjectContext()
    
    private let partnersSerialQueue = DispatchQueue(label: "PartnersSerialQueue")
    
    private var partners = [String : Partner]()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
    
    public let locationManager = CLLocationManager()
    
    
    
    //MARK: - Presenter Interface
    public func viewDidLoad() {
        locationManager.delegate = self
        
        self.loading?(true)
        
        requestPartners()
    }
    
    public func cachedPoints(
        center: CLLocationCoordinate2D,
        span: CLLocationCoordinate2D,
        callback: @escaping (_ points: [PresentablePoint]) -> Void
    ) {
        readContext.perform { [unowned self] in
            print("ReadContext: \(Thread.current)")
            
            do {
                let fetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(
                    format: "latitude >= %f and latitude <= %f and longitude >= %f and longitude <= %f",
                    center.latitude - span.latitude / 2,
                    center.latitude + span.latitude / 2,
                    center.longitude - span.longitude / 2,
                    center.longitude + span.longitude / 2
                )
                
                let results: [Point] = try self.readContext.fetch(fetchRequest)
                
                DispatchQueue.main.async {
                    callback(
                        results.map { (point) -> PresentablePoint in
                            (
                                id: point.externalId!,
                                title: point.name,
                                icon: point.icon,
                                coordinate: point.coordinate
                            )
                        }
                    )
                }
            }
            catch {
                print(error)
                DispatchQueue.main.async { callback([]) }
            }
        }
    }
    
    public func requestPoints(center: CLLocationCoordinate2D, radius: Int) {
        APIClient.GetPoints(center: center, radius: radius) { [unowned self] (json, headers, error) in
            guard
                json != nil,
                let jpoints = json!["payload"] as? [ [String : Any] ]
            else {
                if let errorMessage = json!["errorMessage"] as? String {
                    print("GetPoints error: \(errorMessage)")
                }
                return
            }
            
            self.writeContext.perform {
                self.savePoint(jsonArray: jpoints)
                DispatchQueue.main.async { self.pointsFetched?(center, radius) }
            }
        }
    }
    
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationChanged?(location.coordinate)
        }
    }
    
    
    
    //MARK: - Inner
    
    //MARK: Managed Object Context
    private func createReadManagedObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainContext
        return context
    }
    
    private func createWriteManagedObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainContext
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }
    
    
    
    //MARK: Partners
    private func requestPartners() {
        APIClient.GetPartners { [unowned self] (json, headers, error) in
            var needUpdate = false
            var lastModifiedLocally = UserDefaults.standard.partnersLastModified()
            
            if
                let lastModified = headers["Last-Modified"] as? String,
                let date = self.dateFormatter.date(from: lastModified)
            {
                if lastModifiedLocally.timeIntervalSince1970 < date.timeIntervalSince1970 {
                    lastModifiedLocally = date
                    needUpdate = true
                }
            }
            
            if(needUpdate) {
                guard
                    json != nil,
                    let jpartners = json!["payload"] as? [ [String : Any] ]
                else {
                    DispatchQueue.main.async { self.loading?(false) }
                    return
                }
                
                self.writeContext.perform {
                    print("WriteContext: \(Thread.current)")
                    
                    self.savePartners(jsonArray: jpartners)
                    UserDefaults.standard.setPartnersModifyDate(lastModifiedLocally)
                    DispatchQueue.main.async { self.loading?(false) }
                }
            }
            else if self.partners.isEmpty {
                self.readContext.perform {
                    self.loadCachedPartners()
                    DispatchQueue.main.async { self.loading?(false) }
                }
            }
            else {
                DispatchQueue.main.async { self.loading?(false) }
            }
        }
    }
    
    private func savePartners(jsonArray: [ [String : Any] ]) {
        var freshPartners = [String : Partner]()
        
        for jpartner in jsonArray {
            guard
                let partner = Partner.parse(json: jpartner, context: self.writeContext),
                let data = APIClient.GetImageData(name: partner.picture!)
            else {
                continue
            }
            
            partner.imageData = data
            
            self.writeContext.insert(partner)
            
            freshPartners[partner.id!] = partner
        }
    
        do {
            try self.writeContext.save()
            
            self.mainContext.performAndWait {
                do {
                    self.mainContext.mergePolicy = NSOverwriteMergePolicy
                    try self.mainContext.save()
                }
                catch {
                    print(error)
                }
            }
            
            self.partnersSerialQueue.sync { [unowned self] in
                self.partners.removeAll()
                self.partners.merge(freshPartners) { $1 }
            }
        }
        catch {
            print(error)
        }
    }
    
    private func loadCachedPartners() {
        var freshPartners = [String : Partner]()
        
        do {
            let results: [Partner] = try self.readContext.fetch( Partner.fetchRequest() )
            
            results.forEach { (partner) in
                freshPartners[partner.id!] = partner
            }
        }
        catch {
            print(error)
        }
        
        self.partnersSerialQueue.sync { [unowned self] in
            self.partners.removeAll()
            self.partners.merge(freshPartners) { $1 }
        }
    }
    
    
    //MARK: Points
    private func savePoint(jsonArray: [ [String : Any] ]) {
        for jpoint in jsonArray {
            guard
                let point = Point.parse(json: jpoint, context: self.writeContext)
            else {
                continue
            }
            
            self.partnersSerialQueue.sync {
                point.partner = self.partners[point.partnerName!]
            }
            
            self.writeContext.insert(point)
        }
        
        do {
            try self.writeContext.save()
            
            self.mainContext.performAndWait {
                do {
                    self.mainContext.mergePolicy = NSOverwriteMergePolicy
                    try self.mainContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
        catch {
            print(error)
        }
    }
}
