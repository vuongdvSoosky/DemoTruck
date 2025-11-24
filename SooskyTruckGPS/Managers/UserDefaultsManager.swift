//
//  UserDefaultsManager.swift
//  Base_MVVM_Combine
//
//  Created by Trịnh Xuân Minh on 03/10/2024.
//

import Foundation

final class UserDefaultsManager {
  static let shared = UserDefaultsManager()
  
  enum KeyUserDefaults: String {
    case showATT
    case showRating
    case currentVC
    case didShowOnboard
    case showIAPForReportView
    case requestLocation
    case tutorial
  }
  
  func set<T>(_ value: T?, key: KeyUserDefaults) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
  }
  
  func get<T>(of type: T.Type, key: KeyUserDefaults) -> T {
    let value = UserDefaults.standard.object(forKey: key.rawValue) as? T
    
    switch type.self {
    case is Bool.Type:
      return value ?? false as! T
    case is Int.Type:
      return value ?? 0 as! T
    case is Double.Type:
      return value ?? 0.0 as! T
    case is Float.Type:
      return value ?? 0.0 as! T
    case is String.Type:
      return value ?? "" as! T
    default:
      return value!
    }
  }
  
  func remove(key: KeyUserDefaults) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }
}
