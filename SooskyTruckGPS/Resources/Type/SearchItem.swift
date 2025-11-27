//
//  SearchItem.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 27/11/25.
//

import MapKit

enum SearchItem: Identifiable {
  case userLocation(title: String, subtitle: String)
  case suggestion(MKLocalSearchCompletion)
  case manual(title: String)

  var id: String {
    switch self {
    case .userLocation(let title, _): return "user_\(title)"
    case .suggestion(let item): return item.title + item.subtitle
    case .manual(let title): return "manual_\(title)"
    }
  }
}
