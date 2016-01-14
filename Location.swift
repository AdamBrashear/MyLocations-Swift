//
//  Location.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/11/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject, MKAnnotation {

// Insert code here to add functionality to your managed object subclass
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  
  var title: String? {
    if locationDescription.isEmpty {
    return "(No Description)"
  } else {
    return locationDescription
    }
  }
  
  var subtitle: String? { return category
  }

}
