//
//  ViewController.swift
//  TinkoffPoints
//
//  Created by Дмитрий Белоусов on 24.02.2018.
//  Copyright © 2018 Дмитрий Белоусов. All rights reserved.
//

import UIKit
import MapKit



class MapViewController: UIViewController, MKMapViewDelegate
{
    static func newInstance() -> MapViewController? {
        return
            UIStoryboard(
                name: "Main",
                bundle: nil
            )
            .instantiateViewController(
                withIdentifier: "MapViewControllerID"
            )
            as? MapViewController
    }
    
    
    
    //MARK: - IBOutlet Views
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    //MARK: - Variables
    private let presenter = MapPresenter()
    
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        initCallbacks()
        
        presenter.viewDidLoad()
    }
    
    private func initCallbacks() {
        presenter.mapRegion = { [unowned self] () -> MKCoordinateRegion in
            return self.mapView.region
        }
        
        presenter.animateToRegion = { [unowned self] (region: MKCoordinateRegion) -> Void in
            self.mapView.setRegion(region, animated: true)
        }
        
        presenter.animateToCoordinate = { [unowned self] (coord: CLLocationCoordinate2D) -> Void in
            self.mapView.setCenter( coord, animated: true)
        }
        
        presenter.removeAllAnnotations = { [unowned self] in
            self.mapView.removeAnnotations( self.mapView.annotations )
        }
        
        presenter.addAnnotations = { [unowned self] (annotations: [MKAnnotation]) in
            self.mapView.addAnnotations(annotations)
        }
    }
    
    
    
    //MARK: - IBActions
    
    @IBAction func zoomInTapped(_ sender: UIButton) {
        presenter.zoomInTapped()
    }
    
    @IBAction func zoomOutTapped(_ sender: UIButton) {
        presenter.zoomOutTapped()
    }
    
    @IBAction func myLocationTapped(_ sender: UIButton) {
        presenter.myLocationTapped()
    }
    
    
    
    //MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        presenter.mapRegionChanged(mapView.region)
    }
}

