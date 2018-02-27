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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    
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
        
        presenter.displayAnnotations = { [unowned self] (freshAnnotations: [PointAnnotation]) -> Void in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(freshAnnotations)
        }
        
        presenter.loaderHidden = { [unowned self] (hidden: Bool) in
            if hidden {
                self.activityIndicatorView.stopAnimating()
                self.view.sendSubview(toBack: self.activityIndicatorView)
            }
            else {
                self.activityIndicatorView.startAnimating()
                self.view.bringSubview(toFront: self.activityIndicatorView)
            }
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pointAnnotation = annotation as? PointAnnotation else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PointAnnotationID")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PointAnnotationID")
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.canShowCallout = true
        annotationView!.image = pointAnnotation.image.ofSize(width: 30, height: 30)?.rounded
        
        annotationView!.clipsToBounds = false
        
        let annotationLayer = annotationView!.layer
        
        annotationLayer.shadowColor = UIColor.black.cgColor
        annotationLayer.shadowOpacity = 0.35
        annotationLayer.shadowOffset = .zero
        annotationLayer.shadowRadius = 6
        annotationLayer.shadowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: .zero,
                size: CGSize(width: 30, height: 30)
            ),
            cornerRadius: 15
        ).cgPath
        
        return annotationView
    }
}

