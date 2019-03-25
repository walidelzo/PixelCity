//
//  PopVC.swift
//  PixelCity
//
//  Created by Admin on 3/25/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import UIKit

class PopVC: UIViewController {

    @IBOutlet weak var popImage: UIImageView!
    var passedImage:UIImage?
    func initData(image:UIImage){
         passedImage = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImage.image = passedImage
        addDoubleClick()
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
