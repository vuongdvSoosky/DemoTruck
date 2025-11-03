//
//  BaseObject.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 16/4/25.
//

import Foundation
import RealmSwift

class BaseObject: Object, Codable {
  @Persisted var id: String = UUID().uuidString
  @Persisted var dataURL: String?
  @Persisted var filename: String?
  
  func isDownloaded() -> Bool {
    return filename != nil
  }
}
