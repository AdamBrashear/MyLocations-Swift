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
  var locations = [Location]()
  
  //MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    //Fetch Core Data
    
    //Create a fetch request that describes the search parameters of the object
    let fetchRequest = NSFetchRequest()
    
    //The NSEntityDescription tells the fetch request you’re looking for Location entities
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
    fetchRequest.entity = entity
    
    //The NSSortDescriptor tells the fetch request to sort on the date attribute, in ascending order. In order words, the Location objects that the user added first will be at the top of the list
    let sortDescriptior = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptior]
    
    do {
      let foundObject = try managedObjectContext.executeFetchRequest(fetchRequest)
      
      locations = foundObject as! [Location]
    } catch {
      fatalCoreDataError(error)
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

      return locations.count
  }

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell

    let location = locations[indexPath.row]
    cell.configureForLocation(location)
    
    return cell
  }
  

  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle == .Delete {
          // Delete the row from the data source
          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      } else if editingStyle == .Insert {
          // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
      }    
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      // Return false if you do not want the item to be re-orderable.
      return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
