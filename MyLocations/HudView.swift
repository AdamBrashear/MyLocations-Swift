//
//  HudView.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 1/11/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit

class HudView: UIView {

  var text = ""
  
  class func hudInView(view: UIView, animated: Bool) -> HudView {
    let hudView = HudView(frame: view.bounds)
    hudView.opaque = false
    
    view.addSubview(hudView)
    
    view.userInteractionEnabled = false
    
    return hudView
  }
  
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func drawRect(rect: CGRect) {
      // Drawing code
    let boxWidth: CGFloat = 96
    let boxHeight: CGFloat = 96
    
    let boxRect = CGRect(
      x:round((bounds.size.width - boxWidth) / 2),
      y: round((bounds.size.height - boxHeight) / 2),
      width: boxWidth,
      height: boxHeight)
    
    let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
    UIColor(white: 0.3, alpha: 0.8).setFill()
    roundedRect.fill()
    
    //draw checkmark image
    if let image = UIImage(named: "Checkmark") {
      let imagePoint = CGPoint(
      x: center.x - round(image.size.width / 2),
      y: center.y - round(image.size.height / 2) - boxHeight / 8)
      image.drawAtPoint(imagePoint)
    }
    
    //draw text
    let attribs = [ NSFontAttributeName : UIFont.systemFontOfSize(16),
                    NSForegroundColorAttributeName : UIColor.whiteColor()]
    let textSize = text.sizeWithAttributes(attribs)
    
    let textPoint = CGPoint(
                      x: center.x - round(textSize.width / 2),
                      y: center.y - round(textSize.height / 2) + boxHeight / 4)
    text.drawAtPoint(textPoint, withAttributes: attribs)
  }
  

}
