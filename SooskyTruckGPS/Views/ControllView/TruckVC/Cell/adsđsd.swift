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

struct LocationResult: Identifiable, Hashable {
  static func == (lhs: LocationResult, rhs: LocationResult) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  var id = UUID()
  var title: String
  var subTitle: String
  var coordinate: CLLocationCoordinate2D
  var completion: MKLocalSearchCompletion?
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
  var onSelectCurrentPosition = PassthroughSubject<LocationResult, Never>()
  
  var results: [LocationResult] = []
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
      guard let self else { return }
      guard let response = response else {
        print("Search error: \(error?.localizedDescription ?? "Unknown error")")
        return
      }
      
      
      
      self.results = response.mapItems.map { $0.placemark }.map({ placemark in
        
        return LocationResult(title: self.getPlaceName(placemark: placemark), subTitle: "", coordinate: placemark.coordinate)
      })
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
    guard let location = locations.last else { return }
    getPlaceName(from: location) { name in
      let result = LocationResult(title: name ?? "User Current Location", subTitle: "", coordinate: location.coordinate)
      self.onSelectCurrentPosition.send(result)
    }
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
