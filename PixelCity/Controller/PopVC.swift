//
//  PopVC.swift
//  PixelCity
//
//  Created by Admin on 3/25/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import UIKit

class PopVC: UIViewController ,UIScrollViewDelegate {

    @IBOutlet weak var popImage: UIImageView!
    
    @IBOutlet weak var scr: UIScrollView!
    @IBOutlet weak var imageTile: UILabel!
    var passedImage:UIImage?
    var passImageTitle:String?
    func initData(image:UIImage,ImageTitle:String){
         passedImage = image
        passImageTitle = ImageTitle
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImage.image = passedImage
        imageTile.text = passImageTitle
        addDoubleClick()
        scr.delegate = self
        scr.minimumZoomScale = 0.5
        scr.maximumZoomScale = 5
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return popImage
    }
    
    func addDoubleClick(){
        let gest = UITapGestureRecognizer(target: self, action: #selector(dismissTheView))
        gest.numberOfTapsRequired = 2
        view.addGestureRecognizer(gest)
    }
    @objc func dismissTheView(){
        self.dismiss(animated: true, completion: nil)
    }
    

 

}
