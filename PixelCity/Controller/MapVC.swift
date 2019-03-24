//
//  MapVC.swift
//  PixelCity
//
//  Created by Admin on 3/22/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController ,UIGestureRecognizerDelegate{
    //OutLets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pulledView: UIView!
    @IBOutlet weak var pulledViewHeightConstraint: NSLayoutConstraint!
    let screenSize = UIScreen.main.bounds
    
    //IBActions
    @IBAction func locationBtnPressed(_ sender:Any){
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    //core location manager
    
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius :Double = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        locationManager.delegate = self
        configureAuthServices()
        addPinTapGetsure()
        addSwipDownGesture()
        
    }
    
    func addPinTapGetsure(){
        let gest = UITapGestureRecognizer(target: self, action: #selector(dropAPinToMap(sender:)))
        gest.numberOfTapsRequired = 2
        gest.delegate = self
        map.addGestureRecognizer(gest)
        
        
    }
    func addSwipDownGesture(){
        let swipDwonGes = UISwipeGestureRecognizer(target: self, action: #selector(pullDownPhotoView))
        swipDwonGes.direction = .down
        pulledView.addGestureRecognizer(swipDwonGes)
    }
    
    
    
    
    @objc func dropAPinToMap(sender:UITapGestureRecognizer){
        removePin()
        pullUPPhotoView()
        addSpinner()
        let touchPoint = sender.location(in: map)
        let touchCordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = DropablePin(coordinate: touchCordinate, identifier: "dropAnotation")
        map.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion(center: touchCordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin(){
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }}
}



//MRARK:Extension for mapVC
extension MapVC:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "dropAnotation")
        pinAnnotation.pinTintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    
    //this method to center the main view user
    func centerMapOnUserLocation(){
        guard let cordinate = locationManager.location?.coordinate else { return  }
        let cordinatRegion = MKCoordinateRegion.init(center: cordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(cordinatRegion, animated: true)
        
    }
    
    //function to pullview
    func pullUPPhotoView(){
        pulledViewHeightConstraint.constant = (screenSize.height / 2.5)
        self.view.layoutIfNeeded()
        
    }
    
    @objc func pullDownPhotoView(){
        pulledViewHeightConstraint.constant = 1
        self.view.layoutIfNeeded()
    }
    
    //add Spinner
    
    func addSpinner(){
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        let height :CGFloat = (screenSize.height / 2.5) / 2
        let width : CGFloat = (screenSize.width / 2) - 25
        spinner.center = CGPoint(x: width, y: height)
        spinner.color = UIColor.darkGray
        print(screenSize.height)
        print(UIScreen.main.bounds)
        spinner.startAnimating()
        pulledView.addSubview(spinner)
    }
    
}









extension MapVC:CLLocationManagerDelegate{
    func configureAuthServices(){
        if authStatus == .notDetermined
        {
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
