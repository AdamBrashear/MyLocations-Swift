//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/12/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {

  //MARK: - Ivars
  var managedObjectContext: NSManagedObjectContext!
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    let sortDescriptior1 = NSSortDescriptor(key: "category", ascending: true)
    let sortDescriptior2 = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptior1, sortDescriptior2]
    fetchRequest.fetchBatchSize = 20
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  
  //MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    performFetch()
    
    navigationItem.rightBarButtonItem = editButtonItem()
  }
  
  deinit {
    fetchedResultsController.delegate = nil
  }
  
  //MARK: - Core Data fetch
  func performFetch() {
    do {
    try fetchedResultsController.performFetch()
  } catch {
      fatalCoreDataError(error)
    }
  }

  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections!.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections![section]
    
    return sectionInfo.name
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell

    let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
    cell.configureForLocation(location)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
      managedObjectContext.deleteObject(location)
      
      do {
        try managedObjectContext.save()
      } catch {
        fatalCoreDataError(error)
      }
    }
  }
  
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "EditLocation" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! LocationDetailsViewController
    
      controller.managedObjectContext = managedObjectContext
      
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        controller.locationToEdit = location
      }
    }
  }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
  print("*** controllerWillChangeContent")
  tableView.beginUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    
    switch type {
    
      case .Insert:
        print("*** NSFetchedResultsChangeInsert (object)")
        tableView.insertRowsAtIndexPaths([newIndexPath!],
              withRowAnimation: .Fade)
        
      case .Delete:
        print("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        
      case .Update:
        print("*** NSFetchedResultsChangeUpdate (object)")
        if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell {
          let location = controller.objectAtIndexPath(indexPath!) as! Location
          cell.configureForLocation(location)
        }
      case .Move:
        print("*** NSFetchedResultsChangeMove (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      print("*** NSFetchedResultsChangeInsert (section)")
      tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
        print("*** NSFetchedResultsChangeDelete (section)")
      tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Update:
      print("*** NSFetchedResultsChangeUpdate (section)")
    case .Move:
        print("*** NSFetchedResultsChangeMove (section)")
  
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    print("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
}
