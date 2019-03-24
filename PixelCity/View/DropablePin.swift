//
//  DropablePin.swift
//  PixelCity
//
//  Created by Admin on 3/23/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import UIKit
import MapKit
class DropablePin: NSObject,MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier:String
    init(coordinate:CLLocationCoordinate2D,identifier:String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
