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
  
  
  //MARK: - Photo's managment
  var hasPhoto: Bool {
    return photoID != nil
  }
  
  var photoPath: String {
    assert(photoID != nil, "No photo ID set")
    let filename = "Photo-\(photoID!.integerValue).jpg"
    return (applicationDocumentsDirectory as NSString).stringByAppendingPathComponent(filename)
  }
  
  var photoImage: UIImage? {
    return UIImage(contentsOfFile: photoPath)
  }
  
  class func nextPhotoID() -> Int {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let photoIDKey = "PhotoID"
    let currentID = userDefaults.integerForKey(photoIDKey)
    userDefaults.setInteger(currentID + 1, forKey: photoIDKey)
    userDefaults.synchronize()
    return currentID
  }
  
  func remocePhotoFile() {
    if hasPhoto {
      let path = photoPath
      let fileManager = NSFileManager.defaultManager()
      if fileManager.fileExistsAtPath(path) {
        do {
          try fileManager.removeItemAtPath(path)
        } catch {
          print("Error removing file: \(error)")
        }
      }
    }
  }

}
