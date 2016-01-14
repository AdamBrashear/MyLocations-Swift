//
//  MapViewController.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/14/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

  //MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!
  var managedObjectContext: NSManagedObjectContext!
  
  //MARK: - iVars
  var locations = [Location]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLocations()
      // Do any additional setup after loading the view.
    
    if !locations.isEmpty {
      showLocations()
    }
  }

  //MARK: - Actions
  @IBAction func showUser() {
    let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }
  
  @IBAction func showLocations() {
    let region = regionForAnnotations(locations)
    mapView.setRegion(region, animated: true)
  }
  
  // MARK: - Private functions
  private func updateLocations() {
    mapView.removeAnnotations(locations)
    
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = entity
    locations = try! managedObjectContext.executeFetchRequest( fetchRequest) as! [Location]
    
    mapView.addAnnotations(locations)
  }
  
  private func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
  
    var region: MKCoordinateRegion
    
    switch annotations.count {
    case 0:
      region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
      
    case 1:
      let annotation = annotations.first!
      region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
      
    default:
      var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRightCoord = CLLocationCoordinate2D(latitude: 90,
      longitude: -180)
      
      for annotation in annotations {
        topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
        topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
        bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
        bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
      }
      
      let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
      let extraSpace = 1.1
      let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
      
      region = MKCoordinateRegion(center: center, span: span)
    }
    
    return region
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}


extension MapViewController: MKMapViewDelegate {
  
}