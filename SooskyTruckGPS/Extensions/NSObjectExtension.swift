//
//  NSObjectExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation

extension NSObject {
  public class var className: String {
    return String(describing: self)
  }
  
  public var className: String {
    return String(describing: self)
  }
}
