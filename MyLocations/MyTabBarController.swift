//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 2/1/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  override func childViewControllerForStatusBarStyle() -> UIViewController? {
  return nil
  }
}
