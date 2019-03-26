//
//  Constants.swift
//  PixelCity
//
//  Created by Admin on 3/25/19.
//  Copyright © 2019 NanoSoft. All rights reserved.
//

import Foundation

let API_KEY = "2dd8f8426e3150ccd1203ed8956c56ee"
var Search_Text = ""
var perPage : String = "40"
func getUrl(forApiKey key:String , AndAnnotation annotation:DropablePin , AndPageNumber number:String)->String
{
let API_URL="https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&text=\(Search_Text)&radius_units=mi&per_page=\(perPage)&format=json&nojsoncallback=1"
    return API_URL
}
