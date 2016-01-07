//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/5/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

  //MARK: - Outlets
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  
  //MARK: - Ivars
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: NSError?
  
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError: NSError?
  
  //MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    updateLabels()
    configureGetButton()
  }

  //MARK: - Actions
  @IBAction func getLocation() {
    let authStatus = CLLocationManager.authorizationStatus()
    if authStatus == .NotDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if authStatus == .Denied || authStatus == .Restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      startLocationManager()
    }
    
    updateLabels()
    configureGetButton()
  }
  
  //MARK: - UI staff
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.hidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      tagButton.hidden = true
      
      let statusMessage: String
      if let error = lastLocationError {
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Location Services Disabled"
      } else if updatingLocation {
        statusMessage = "Searching..."
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      
      messageLabel.text = statusMessage
    }
    
  }
  
  func configureGetButton() {
    if updatingLocation {
      getButton.setTitle("Stop", forState: .Normal)
    } else {
      getButton.setTitle("Get My Location", forState: .Normal) }
  }
  
  //MARK: - Location manager
  func stopLocationManager() {
    if updatingLocation {
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true
    }
  }
  
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(okAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Location error: \(error.localizedDescription)")
    
    if error.code == CLError.LocationUnknown.rawValue {
      return
    }
    
    lastLocationError = error
    stopLocationManager()
    updateLabels()
    configureGetButton()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("Did update location \(newLocation)")
    
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      location = newLocation
      updateLabels()
      
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print("*** We're done")
        stopLocationManager()
        configureGetButton()
      }
    }
    
  }
  
  
}

