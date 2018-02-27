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
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    
    
    
    //MARK: - Variables
    private let presenter = MapPresenter()
    
    private let annotationsDisplayingQueue = DispatchQueue(label: "AnnotationsDisplayingQueue")
    
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.zoomInButton.addShadow()
        self.zoomOutButton.addShadow()
        self.myLocationButton.addShadow()
        
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
            DispatchQueue.main.async {
                self.annotationsDisplayingQueue.sync {
                    let currentAnnotations = self.mapView.annotations.filter { !($0 is MKUserLocation) } as! [PointAnnotation]
                    
                    let removingAnnotations = currentAnnotations.filter { (annotation) -> Bool in
                        !freshAnnotations.contains { $0.id == annotation.id }
                    }
                    
                    let appendingAnnotations = freshAnnotations.filter { (annotation) -> Bool in
                        !currentAnnotations.contains { $0.id == annotation.id }
                    }
                    
                    self.mapView.removeAnnotations(removingAnnotations)
                    self.mapView.addAnnotations(appendingAnnotations)
                }
            }
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
        annotationView!.addShadow()
        
        return annotationView
    }
}

