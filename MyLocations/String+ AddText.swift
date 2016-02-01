//
//  String+ AddText.swift
//  MyLocations
//
//  Created by Vasyl Kotsiuba on 2/1/16.
//  Copyright © 2016 Vasiliy Kotsiuba. All rights reserved.
//

import Foundation

extension String {
  mutating func addText(text: String?, withSeparator separator: String = "") {
    if let text = text {
      if !isEmpty {
        self += separator
      }
      self += text
    }
  }
}
