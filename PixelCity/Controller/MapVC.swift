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
import Alamofire
import AlamofireImage

class MapVC: UIViewController ,UIGestureRecognizerDelegate{
    //MARK:- OutLets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var pulledView: UIView!
    @IBOutlet weak var pulledViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTXT:UITextField!
    @IBOutlet weak var perPageTXT:UITextField!
    
    @IBAction func closePulUpView( _ sender:UIButton){
        pullDownPhotoView()

    }
    let screenSize = UIScreen.main.bounds
    var spinner : UIActivityIndicatorView?
    var progressLabel:UILabel?
    var collectionV:UICollectionView?
    var flowlayout = UICollectionViewFlowLayout()
    var urlImages = [String]()
    var imagesDownload = [UIImage]()
    var imagesTiles = [String]()
    
    //MARK:- IBActions
    @IBAction func locationBtnPressed(_ sender:Any){
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
            pullDownPhotoView()
        }
    }
    
    //MARK:-  core location manager
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius :Double = 3000
    
    //MARK:- View method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(perPage)
        map.delegate = self
        locationManager.delegate = self
        configureAuthServices()
        addPinTapGetsure()
        addSwipDownGesture()
        collectionV = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height), collectionViewLayout: flowlayout)
        self.registerForPreviewing(with: self, sourceView: collectionV!)
        collectionV?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionV?.delegate = self
        collectionV?.dataSource = self
        collectionV?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
       // collectionV?.scrollsToTop = true
        pulledView.addSubview(collectionV!)
        dismissKeyboard()
        
        
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
    
    func dismissKeyboard(){
        let gestt = UITapGestureRecognizer(target: self, action: #selector(EndEditing))
        map.addGestureRecognizer(gestt)
    }
    @objc func EndEditing(){
        self.view.endEditing(true)
    }
    
    
    //MARK:- add Pin to MapVC
    @objc func dropAPinToMap(sender:UITapGestureRecognizer){
       // print(api)
        Search_Text = searchTXT.text!
        removePin()
        removeSpinner()
        removeProgessLabel()
        CancellAllSession()
        imagesDownload = []
        urlImages = []
        collectionV?.reloadData()
        pullUPPhotoView()
        addSpinner()
        addProgressBarLabel()
        
        let touchPoint = sender.location(in: map)
        let touchCordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = DropablePin(coordinate: touchCordinate, identifier: "dropAnotation")
        map.addAnnotation(annotation)
        
        retriveURLS(forAnnotation: annotation) { (finshed) in
            if (finshed)
            {
                self.retriveImages(handler: { (finshed) in
                    if (finshed){
                        self.removeSpinner()
                        self.removeProgessLabel()
                        self.collectionV?.reloadData()
                    }
                })
            }
            
        }
        let coordinateRegion = MKCoordinateRegion(center: touchCordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
        //print()
    }
    
    func removePin(){
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }}
    
    //MARK:- Work with Alamofire
    
    func retriveURLS(forAnnotation annotation :DropablePin , handler:@escaping (_ status:Bool)->()){
        if  perPageTXT.text == "" { perPage = "40" }else {perPage = (perPageTXT.text)!}
        let apiUrl = getUrl(forApiKey: API_KEY, AndAnnotation: annotation, AndPageNumber:perPage)
        print(apiUrl)
        Alamofire.request(apiUrl).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else { self.progressLabel!.text = "NO RESULT " ;         self.view.layoutIfNeeded() ;return}
            print(json)
            let photos = json["photos"] as? Dictionary<String,AnyObject>
            let photoArray = photos!["photo"] as? [Dictionary<String,AnyObject>]
            for item in photoArray!{
                //http://farm8.staticflickr.com/7804/47459692401_274df06c59_z.jpg
                let oneUrl = "https://farm\(item["farm"]!).staticflickr.com/\(item["server"]!)/\(item["id"]!)_\(item["secret"]!)_z.jpg"
                self.imagesTiles.append(item["title"]! as! String)
                self.urlImages.append(oneUrl)
                handler(true)
                
                    
                
            }

        }
    }
    
    
    func retriveImages(handler:@escaping (_ status:Bool)->() ){
        for urlImage in urlImages{
            Alamofire.request(urlImage).responseImage { (response) in
                guard let image = response.result.value else {return }
                self.imagesDownload.append(image)
                self.progressLabel?.text = "\(self.imagesDownload.count)/\(perPage) images Downloaded"

                if self.imagesDownload.count == self.urlImages.count {
                    handler(true)
                }
            }
        }
        
    }
    
    func CancellAllSession()
    {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionData, uploadData, downloadData) in
            sessionData.forEach({$0.cancel()})
            uploadData.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    
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
       let cordinatee = CLLocationCoordinate2D(latitude: 37.7873589, longitude: -122.408227)
       // print(cordinate)
        //51.50998  ----  -0.1337
        let cordinatRegion = MKCoordinateRegion.init(center: cordinatee, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(cordinatRegion, animated: true)
        
    }
    
    //MARK:- add UI to mapView by code
    
    //function to pullview
    func pullUPPhotoView(){
        pulledViewHeightConstraint.constant = (screenSize.height / 1.5)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()

        }
        
    }
    
    @objc func pullDownPhotoView(){
        CancellAllSession()
        collectionV?.reloadData()
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
        progressLabel = UILabel(frame: CGRect(x: x - 25 , y: y, width: 200, height: y + 5 ))
        progressLabel?.center = CGPoint(x:x,y:y + 30)
        progressLabel?.textAlignment = .center
        progressLabel?.font = UIFont(name: "Avera Next", size: 15)
        progressLabel?.text = ""
        collectionV?.addSubview(progressLabel!)
    }
    func removeProgessLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
}








//MARK:- Map Location manager
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

//MARK:- CollectionView Methods
extension MapVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesDownload.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
            return PhotoCell()
        }
        if imagesDownload.count > 0{
            let imageToCell = UIImageView(image: imagesDownload[indexPath.row])
            cell.addSubview(imageToCell)
            // imageToCell.contentMode = .scaleAspectFit

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC  else {
            return
        }
        popVc.initData(image: imagesDownload[indexPath.row],ImageTitle: imagesTiles[indexPath.row])
        present(popVc, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
}

extension MapVC:UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let index = collectionV?.indexPathForItem(at: location) , let cell = collectionV?.cellForItem(at: index) else { return nil }
        let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVC")
        previewingContext.sourceRect = cell.contentView.frame
        return popVc
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit,sender: self)
    }
}
