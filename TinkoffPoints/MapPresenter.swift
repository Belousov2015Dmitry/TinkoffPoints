//
//  MapPresenter.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 24.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import Foundation
import MapKit.MKGeometry
import MapKit.MKAnnotation


class MapPresenter
{
    //MARK: - Variables
    private let interactor = MapInteractor()
    
    private var needTrackLocation = true
    
    
    
    //MARK: - Callbacks
    public var mapRegion: (() -> MKCoordinateRegion)? = nil
    public var animateToRegion: ((_ region: MKCoordinateRegion) -> Void)? = nil
    public var animateToCoordinate: ((_ region: CLLocationCoordinate2D) -> Void)? = nil
    public var removeAllAnnotations: (() -> Void)? = nil
    public var addAnnotations: ((_ annotations: [MKAnnotation]) -> Void)? = nil
    
    
    
    //MARK: - View Interface
    public func viewDidLoad() {
        initCallbacks()
        
        interactor.viewDidLoad()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            interactor.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func zoomInTapped() {
        if var region = self.mapRegion?() {
            region.span = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta / 2,
                longitudeDelta: region.span.longitudeDelta / 2
            )
            
            self.animateToRegion?(region)
        }
    }
    
    public func zoomOutTapped() {
        if var region = self.mapRegion?() {
            region.span = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta * 2,
                longitudeDelta: region.span.longitudeDelta * 2
            )
            
            self.animateToRegion?(region)
        }
    }
    
    public func myLocationTapped() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                if let coord = interactor.locationManager.location?.coordinate {
                    animateToRegion?( MKCoordinateRegionMakeWithDistance(coord, 1000, 1000) )
                }
                else {
                    needTrackLocation = true
                }
            
            case .notDetermined:
                interactor.locationManager.requestWhenInUseAuthorization()
            
            default:
                break
        }
    }
    
    public func mapRegionChanged(_ region: MKCoordinateRegion) {
        let radius = region.radius
        
        interactor.cachedPoints(
            center: region.center,
            radius: radius,
            callback: displayPoints(_:)
        )
        
        interactor.requestPoints(center: region.center, radius: radius)
    }
    
    
    
    //MARK: - Inner
    
    private func initCallbacks() {
        interactor.locationChanged = { [unowned self] (coordinate: CLLocationCoordinate2D) in
            if self.needTrackLocation {
                self.animateToRegion?( MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000) )
                self.needTrackLocation = false
            }
        }
        
        interactor.pointsFetched = { [unowned self] (center: CLLocationCoordinate2D, radius: Double) in
            guard let region = self.mapRegion?() else {
                return
            }
            
            if region.center == center {
                self.interactor.cachedPoints(
                    center: center,
                    radius: region.radius,
                    callback: self.displayPoints(_:)
                )
            }
        }
    }
    
    private func displayPoints(_ points: [MapInteractor.PresentablePoint]) {
        self.removeAllAnnotations?()
        
        self.addAnnotations?(
            points.map {
                PointAnnotation(title: $0.title, image: $0.icon, coordinate: $0.coordinate)
            }
        )
    }
}