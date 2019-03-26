//
//  roundButton.swift
//  PixelCity
//
//  Created by Admin on 3/26/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import UIKit
@IBDesignable
class roundButton: UIButton {

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    func setup(){
        layer.cornerRadius = 25
        layer.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)

    }

}
