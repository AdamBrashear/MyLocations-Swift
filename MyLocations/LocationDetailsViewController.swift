//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/10/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

//Create private global constant
private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .MediumStyle
  formatter.timeStyle = .ShortStyle
  return formatter
}()

enum sectionName: Int {
  case DescriptionSection = 0
  case AddPhotoSection
  case ReadOnlyInfoSection
}

class LocationDetailsViewController: UITableViewController {

  // MARK: - Outlets
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var addPhotoLabel: UILabel!
  
  // MARK: - Ivars
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  var managedObjectContext: NSManagedObjectContext!
  var date = NSDate()
  var locationToEdit: Location? {
    didSet {
      if let location = locationToEdit {
        descriptionText = location.locationDescription
        categoryName = location.category
        date = location.date
        coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        placemark = location.placemark
      }
    }
  }
  var descriptionText = ""
  var image: UIImage?
  var observer: AnyObject!
  
  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    listenForBackgroundNotification()
    
    if let location = locationToEdit {
      title = "Edit Location"
      if location.hasPhoto {
        if let image = location.photoImage {
          showImage(image)
        }
      }
    }
    
    descriptionTextView.text = descriptionText
    categoryLabel.text = categoryName
    
    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    
    if let placemark = placemark {
      addressLabel.text = stringFromPlacemark(placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    
    dateLabel.text = formatDate(date)
    
    //Add tap gesture recognizer to hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
    
    
    tableView.backgroundColor = UIColor.blackColor()
    tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
    tableView.indicatorStyle = .White
    descriptionTextView.textColor = UIColor.whiteColor()
    descriptionTextView.backgroundColor = UIColor.blackColor()
    addPhotoLabel.textColor = UIColor.whiteColor()
    addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
    addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
    addressLabel.highlightedTextColor = addressLabel.textColor
  }
  
  deinit {
    print("*** deinit \(self)")
    NSNotificationCenter.defaultCenter().removeObserver(observer)
  }
  
  // MARK: - Actions
  @IBAction func done() {
    
    var hudText = ""
    
    let location: Location
    if let temp = locationToEdit {
      hudText = "Updated"
      location = temp
    } else {
      hudText = "Tagged"
      location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
      location.photoID = nil
    }
    
    location.locationDescription = descriptionTextView.text
    location.category = categoryName
    location.latitude = coordinate.latitude
    location.longitude = coordinate.longitude
    location.date = date
    location.placemark = placemark
    
    //Save image to users document directory
    if let image = image {
      if !location.hasPhoto {
        location.photoID = Location.nextPhotoID()
      }
      
      if let data = UIImageJPEGRepresentation(image, 0.5) {
        do {
          try data.writeToFile(location.photoPath, options: .DataWritingAtomic)
        } catch {
          print("Error writing file: \(error)")
        }
      }
    }
    
    do {
      try managedObjectContext.save()
      
      let hudView = HudView.hudInView(navigationController!.view, animated: true)
      hudView.text = hudText
      
      afterDelay(0.6) {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      
    } catch {
      fatalCoreDataError(error)
    }
    
    
  }
  
  @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Helper
  func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.locationInView(tableView)
    let indexPath = tableView.indexPathForRowAtPoint(point)
    
    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
      return
    }
    
    descriptionTextView.resignFirstResponder()
  }
  
  
  // MARK: - Private methods
  private func stringFromPlacemark(placemark: CLPlacemark) -> String {
    var line = ""
    line.addText(placemark.subThoroughfare)
    line.addText(placemark.thoroughfare, withSeparator: " ")
    line.addText(placemark.locality, withSeparator: ", ")
    line.addText(placemark.administrativeArea, withSeparator: ", ")
    line.addText(placemark.postalCode, withSeparator: " ")
    line.addText(placemark.country, withSeparator: ", ")
    return line
  }
  
  private func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
  }
  
  private func listenForBackgroundNotification() {
    observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in // capture list for the closure
      if let strongSelf = self {
        if strongSelf.presentedViewController != nil {
          strongSelf.dismissViewControllerAnimated(false, completion: nil)
        }
        
        strongSelf.descriptionTextView.resignFirstResponder()
      }
      
      
    }
  }
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destinationViewController as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
  }
  
  @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
    let controller = segue.sourceViewController as! CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }
  
  // MARK: - UITableViewDelegate
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    //better to use switch satement
    //Using switch is very common in Swift because it makes large blocks of if – else if statements much easier to read
    switch (indexPath.section, indexPath.row) {
      case (sectionName.DescriptionSection.rawValue, 0):
        return 88
    case (sectionName.AddPhotoSection.rawValue, _):
        return imageView.hidden ? 44 : 280
    case (sectionName.ReadOnlyInfoSection.rawValue, 2):
        addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115 , height: 10000)
        addressLabel.sizeToFit()
        addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
        return addressLabel.frame.size.height + 20
    default:
      return 44
    }
    
    //VER 2
    /*
    if indexPath.section == sectionName.DescriptionSection.rawValue && indexPath.row == 0 {
      return 88
    } else if indexPath.section == sectionName.AddPhotoSection.rawValue {
      if imageView.hidden {
        return 44
      } else {
        return 280
      }
    } else if indexPath.section == sectionName.ReadOnlyInfoSection.rawValue && indexPath.row == 2 {
      addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115 , height: 10000)
      addressLabel.sizeToFit()
      addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
      return addressLabel.frame.size.height + 20
    } else {
      return 44
    }
*/
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if indexPath.section == sectionName.DescriptionSection.rawValue || indexPath.section == sectionName.AddPhotoSection.rawValue {
      return indexPath
    } else {
      return nil
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == sectionName.DescriptionSection.rawValue && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    } else if indexPath.section == sectionName.AddPhotoSection.rawValue && indexPath.row == 0 {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      pickPhoto()
    }
  }
  
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      cell.backgroundColor = UIColor.blackColor()
     
        if let textLabel = cell.textLabel {
        textLabel.textColor = UIColor.whiteColor()
        textLabel.highlightedTextColor = textLabel.textColor
      }
        
      if let detailLabel = cell.detailTextLabel {
        detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        detailLabel.highlightedTextColor = detailLabel.textColor
      }
        
      let selectionView = UIView(frame: CGRect.zero)
      selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
      cell.selectedBackgroundView = selectionView
  
      if indexPath.row == 2 {
        let addressLabel = cell.viewWithTag(100) as! UILabel
          addressLabel.textColor = UIColor.whiteColor()
          addressLabel.highlightedTextColor = addressLabel.textColor
      }
  }
}

 // MARK: - UIImagePickerControllerDelegate
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    image = info[UIImagePickerControllerEditedImage] as? UIImage
    if let image = image {
      showImage(image)
    }
    
    tableView.reloadData()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: - Image picker menu
  func showPhotoMenu() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {_ in self.takePhotoWithCamera()})
    alertController.addAction(takePhotoAction)
    
    let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()})
    alertController.addAction(chooseFromLibraryAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  //MARK: - Image management
  func showImage(image: UIImage) {
    imageView.image = image
    imageView.hidden = false
    imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
    addPhotoLabel.hidden = true
  }
  
  func takePhotoWithCamera() {
    let imagePicker = MyImagePickerController()
    imagePicker.view.tintColor = view.tintColor
    imagePicker.sourceType = .Camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func choosePhotoFromLibrary() {
    let imagePicker = MyImagePickerController()
    imagePicker.view.tintColor = view.tintColor
    imagePicker.sourceType = .PhotoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func pickPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      showPhotoMenu()
    } else {
      choosePhotoFromLibrary()
    }
  }
  
}
