//
//  adsđsd.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 27/11/25.
//

import Foundation
import MapKit
import Combine

enum SearchStatus: Equatable {
  case idle
  case searching
  case error(String)
  case result
}

// MARK: - Enum SearchItem
enum SearchItem: Identifiable {
  case userLocation(title: String, subtitle: String, coordinate: CLLocationCoordinate2D?)
  case suggestion(MKLocalSearchCompletion)
  case manual(title: String)
  
  var id: String {
    switch self {
    case .userLocation(let title, _, _): return "user-\(title)"
    case .suggestion(let completion): return completion.title + completion.subtitle
    case .manual(let title): return "manual-\(title)"
    }
  }
  
  var title: String {
    switch self {
    case .userLocation(let title, _, _): return title
    case .suggestion(let completion): return completion.title
    case .manual(let title): return title
    }
  }
  
  var subtitle: String {
    switch self {
    case .userLocation(_, let subtitle, _): return subtitle
    case .suggestion(let completion): return completion.subtitle
    case .manual: return ""
    }
  }
  
  var coordinate: CLLocationCoordinate2D? {
    switch self {
    case .userLocation(_, _, let coordinate): return coordinate
    case .suggestion: return nil
    case .manual: return nil
    }
  }
}

class LocationSearchManager: NSObject {
  var query: String = "" {
    didSet {
      completer.cancel()
      search?.cancel()
      handleSearchFragment(query)
    }
  }
  @Published var status: SearchStatus = .idle
  var onSelectCurrentPosition = PassthroughSubject<SearchItem, Never>()
  
  @Published var results: [SearchItem] = []
  var completer: MKLocalSearchCompleter
  
  var search: MKLocalSearch?
  private let locationManager: CLLocationManager = CLLocationManager()
  
  init(
    filter: MKPointOfInterestFilter = .excludingAll,
    region: MKCoordinateRegion = MKCoordinateRegion(.world),
    types: MKLocalSearchCompleter.ResultType = [.pointOfInterest, .address]
  ) {
    completer = MKLocalSearchCompleter()
    super.init()
    completer.delegate = self
    completer.pointOfInterestFilter = filter
    completer.region = region
    completer.resultTypes = types
    configureLocationManager()
  }
  
  func configureLocationManager() {
    locationManager.delegate = self
    locationManager.distanceFilter = 10
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.activityType = .automotiveNavigation
  }
  
  func getCurrentLocation() {
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func handleSearchFragment(_ fragment: String) {
    self.status = .searching
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = fragment
    search?.cancel()
    search = MKLocalSearch(request: request)
    search?.start { [weak self] response, error in
      guard let self = self else { return }
      guard let response = response else {
        print("Search error: \(error?.localizedDescription ?? "Unknown error")")
        return
      }
      
      var tempItems: [SearchItem] = []
      
      // 1. Luôn thêm User Location ở đầu
      tempItems.append(.userLocation(title: "My Location", subtitle: "Current Position", coordinate: nil))
      
      // 2. Chuyển kết quả MKLocalSearch thành SearchItem.suggestion
      let suggestions = response.mapItems.map { $0.placemark }.map { placemark in
        let title = self.getPlaceName(placemark: placemark)
        // Sử dụng .manual nếu muốn giữ giống comment trước, hoặc .suggestion với MKLocalSearchCompletion giả
        return SearchItem.manual(title: title)
      }
      
      if suggestions.isEmpty {
        // Nếu không có suggestion nào, thêm manual entry của fragment
        tempItems.append(.manual(title: fragment))
      } else {
        tempItems.append(contentsOf: suggestions)
      }
      
      // 3. Cập nhật kết quả
      self.results = tempItems
      self.status = .result
    }
  }
  
  private func getPlaceName(placemark: MKPlacemark) -> String {
    let name = placemark.name
    let address = [placemark.name,
                   placemark.thoroughfare,
                   placemark.subThoroughfare,
                   placemark.administrativeArea,
    ]
      .compactMap { $0 }
      .reduce(into: [String]()) { result, element in
        if !result.contains(element) {
          result.append(element)
        }
      }
      .joined(separator: ", ")
    return address
  }
}

extension LocationSearchManager: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
    self.status = .error(error.localizedDescription)
  }
}

extension LocationSearchManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,   status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      locationManager.startUpdatingLocation()
    } else {
      print("Permission is denied")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func getPlaceName(from location: CLLocation, completion: @escaping (String?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        print("Reverse geocoding failed: \(error.localizedDescription)")
        completion(nil)
        return
      }
      
      if let placemark = placemarks?.first {
        
        let name = placemark.name
        let address = [placemark.name,
                       placemark.thoroughfare,
                       placemark.subThoroughfare,
                       placemark.administrativeArea,
        ]
          .compactMap { $0 }
          .reduce(into: [String]()) { result, element in
            if !result.contains(element) {
              result.append(element)
            }
          }
          .joined(separator: ", ")
        completion(address)
        
      } else {
        completion(nil)
      }
    }
  }
}
