//
//  maplist.swift
//  Mymap
//
//  Created by 浅野未央 on 2017/07/15.
//  Copyright © 2017年 mio. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit


class maplist {
  var ref: DatabaseReference?
  var title: String?
  var latitude: CLLocationDegrees?
  var longitude:CLLocationDegrees?
  
  init(snapshot: DataSnapshot) {
    ref = snapshot.ref
  
    let date = snapshot.value as! Dictionary<String, Any>
    
    let data2 = date["data"] as! Dictionary<String, Any>
    
    title = data2["title"] as? String
    latitude = Double(data2["latitude"] as! NSNumber )
    longitude = Double(data2["longitude"] as! NSNumber)
  }
}
