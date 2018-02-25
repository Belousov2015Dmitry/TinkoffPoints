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
    public typealias PresentablePoint = (title: String, icon: UIImage, coordinate: CLLocationCoordinate2D)
    
    
    //MARK: - Variables
    private lazy var mainContext = APP_DELEGATE.persistentContainer.viewContext
    private lazy var readContext = self.createReadManagedObjectContext()
    private lazy var writeContext = self.createReadManagedObjectContext()
    
    private let partnersSerialQueue = DispatchQueue(label: "PartnersSerialQueue")
    
    private var partners = [String : Partner]()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
    
    public let locationManager = CLLocationManager()
    
    
    
    //MARK: - Callbacks
    public var locationChanged: ((_ coordinate: CLLocationCoordinate2D) -> Void)? = nil
    public var pointsFetched: ((_ center: CLLocationCoordinate2D, _ radius: Double) -> Void)? = nil
    
    
    //MARK: - Presenter Interface
    public func viewDidLoad() {
        locationManager.delegate = self
        
        requestPartners()
    }
    
    public func cachedPoints(
        center: CLLocationCoordinate2D,
        radius: Double,
        callback: @escaping (_ points: [PresentablePoint]) -> Void
    ) {
        readContext.perform { [unowned self] in
            do {
                let results: [Point] = try self.readContext.fetch( Point.fetchRequest() )
                
                callback(
                    results.map { (point) -> PresentablePoint in    //todo
                        (
                            title: "",
                            icon: UIImage(),
                            coordinate: point.coordinate
                        )
                    }
                )
            }
            catch {
                print(error)
                callback([])
            }
        }
    }
    
    public func requestPoints(center: CLLocationCoordinate2D, radius: Double) {
        //todo
    }
    
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationChanged?(location.coordinate)
        }
    }
    
    
    
    //MARK: - Inner
    private func createReadManagedObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType) //main
        context.parent = self.mainContext
        return context
    }
    
    private func createWriteManagedObjectContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType) //background
        context.parent = self.mainContext
        return context
    }
    
    private func requestPartners() {
        APIClient.GetPartners { [unowned self] (json, headers, error) in
            var needUpdate = false

            if
                let lastModified = headers["Last-Modified"] as? String,
                let date = self.dateFormatter.date(from: lastModified)
            {
                needUpdate = UserDefaults.standard.partnersLastModified().timeIntervalSince1970 < date.timeIntervalSince1970
            }
            
            if(needUpdate) {
                guard
                    json != nil,
                    let jpartners = json!["payload"] as? [ [String : Any] ]
                else {
                    return
                }
                
                self.writeContext.perform {
                    self.savePartners(jsonArray: jpartners)
                }
            }
            else if self.partners.isEmpty {
                self.writeContext.perform {
                    self.loadPartners()
                }
            }
        }
    }
    
    private func savePartners(jsonArray: [ [String : Any] ]) {
        var freshPartners = [String : Partner]()
        
        for jpartner in jsonArray {
            guard
                let partner = Partner.parse(json: jpartner, context: self.mainContext),
                let data = APIClient.GetImageData(name: partner.picture!)
            else {
                continue
            }
            
            partner.imageData = data
            
            do {
                try partner.managedObjectContext?.save()
                
                freshPartners[partner.id!] = partner
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
    
    private func loadPartners() {
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
}
