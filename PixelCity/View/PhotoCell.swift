//
//  PhotoCell.swift
//  PixelCity
//
//  Created by Admin on 3/24/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup(){
        layer.cornerRadius = 10
        layer.borderColor = UIColor.yellow.cgColor
        layer.borderWidth = 4
        
    }
}
