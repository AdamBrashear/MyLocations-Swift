//
//  LocationCell.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/13/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

  //MARK: - Outlets
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var photoImageView: UIImageView!
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
  
  func configureForLocation(location: Location) {
    
    if location.locationDescription.isEmpty {
      descriptionLabel.text = "(No Descroption)"
    } else {
      descriptionLabel.text = location.locationDescription
    }
    
    //Read address
    if let placemark = location.placemark {
      var text = ""
      text.addText(placemark.subThoroughfare)
      text.addText(placemark.thoroughfare, withSeparator: " ")
      text.addText(placemark.locality, withSeparator: ", ")
      addressLabel.text = text
    } else {
      addressLabel.text = String(format:"Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
    }
    
    photoImageView.image = imageForLocation(location)
  }
  
  func imageForLocation(location: Location) -> UIImage {
    if location.hasPhoto, let image = location.photoImage {
      return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
    }
    
    return UIImage()
  }
  

}
