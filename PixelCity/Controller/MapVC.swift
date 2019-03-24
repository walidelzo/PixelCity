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
    //MARK:- OutLets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pulledView: UIView!
    @IBOutlet weak var pulledViewHeightConstraint: NSLayoutConstraint!
    let screenSize = UIScreen.main.bounds
    var spinner : UIActivityIndicatorView?
    var progressLabel:UILabel?
    var collectionV:UICollectionView?
    var flowlayout = UICollectionViewFlowLayout()
    
    //MARK:- IBActions
    @IBAction func locationBtnPressed(_ sender:Any){
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
    //MARK:-  core location manager
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius :Double = 2000
    
    //MARK:- View method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        locationManager.delegate = self
        configureAuthServices()
        addPinTapGetsure()
        addSwipDownGesture()
        collectionV = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height), collectionViewLayout: flowlayout)
        collectionV?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionV?.delegate = self
        collectionV?.dataSource = self
        collectionV?.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        //pulledView.addSubview(collectionV!)
        
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
    
    
    
    //MARK:- add Pin to MapVC
    @objc func dropAPinToMap(sender:UITapGestureRecognizer){
        removePin()
        removeSpinner()
        removeProgessLabel()
        pullUPPhotoView()
        addSpinner()
        addProgressBarLabel()
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
    
    //MARK:- add UI to mapView by code
    
    //function to pullview
    func pullUPPhotoView(){
        pulledViewHeightConstraint.constant = (screenSize.height / 2.5)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()

        }
        
    }
    
    @objc func pullDownPhotoView(){
        pulledViewHeightConstraint.constant = 1
        self.view.layoutIfNeeded()
    }
    
    //add Spinner
    
    func addSpinner(){
       spinner = UIActivityIndicatorView(style: .whiteLarge)
        let y :CGFloat = (screenSize.height / 2.5) / 2
        let x : CGFloat = (screenSize.width / 2) - 25
        spinner?.center = CGPoint(x: x, y: y)
        spinner?.color = UIColor.darkGray
        spinner?.startAnimating()
        collectionV?.addSubview(spinner!)
        
        
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
            
        }
    }
    
    
    func addProgressBarLabel(){
        let x : CGFloat = (screenSize.width / 2) - 25
        let y :CGFloat = (screenSize.height / 2.5) / 2
        progressLabel = UILabel(frame: CGRect(x: x - 25 , y: y, width: x, height: y + 5 ))
        progressLabel?.center = CGPoint(x:x,y:y + 30)
        progressLabel?.textAlignment = .center
        progressLabel?.font = UIFont(name: "Avera Next", size: 22)
        progressLabel?.text = "12/24 photos loaded"
        collectionV?.addSubview(progressLabel!)
    }
    func removeProgessLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
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


extension MapVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
    
}
