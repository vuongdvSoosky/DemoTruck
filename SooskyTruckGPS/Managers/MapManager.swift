//
//  MapManager.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/11/25.
//

import Foundation
import MapKit
import CoreLocation

final class MapManager: NSObject {
  
  static let shared = MapManager()
  private let locationManager = CLLocationManager()
  var mapView: MKMapView?
  
  private var currentLocationCompletion: ((CLLocation?) -> Void)?
  
  private override init() {
    super.init()
    setupLocationManager()
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  // MARK: - Setup Map
  
  func attachMap(to mapView: MKMapView) {
    self.mapView = mapView
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .follow
  }
  
  // MARK: - Request Location
  
  func requestUserLocation(completion: @escaping (CLLocation?) -> Void) {
    currentLocationCompletion = completion
    
    switch locationManager.authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      locationManager.startUpdatingLocation()
    default:
      completion(nil)
    }
  }
  
  // MARK: - Show Pin for Address
  func showPin(for address: String, type: String = "default", title: String? = nil, completion: ((MKPlacemark?) -> Void)? = nil) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
      guard let self = self, let mapView = self.mapView else { return }
      guard let placemark = placemarks?.first,
            let location = placemark.location else {
        LogManager.show("Không tìm thấy địa chỉ: \(error?.localizedDescription ?? "Unknown error")")
        completion?(nil)
        return
      }
      
      let annotation = CustomAnnotation(
        coordinate: location.coordinate,
        type: type, titlePlace: address
      )
      
      DispatchQueue.main.async {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setRegion(
          MKCoordinateRegion(
            center: annotation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
          ),
          animated: true
        )
      }
      
      let mkPlacemark = MKPlacemark(
        coordinate: location.coordinate,
        addressDictionary: placemark.addressDictionary as? [String: Any]
      )
      completion?(mkPlacemark)
    }
  }
  
  // MARK: - Center Map
  
  func centerMap(on location: CLLocation, zoom: Double = 0.01) {
    guard let mapView = mapView else { return }
    let region = MKCoordinateRegion(center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom))
    mapView.setRegion(region, animated: true)
  }
}

extension MapManager: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
      locationManager.startUpdatingLocation()
    } else {
      currentLocationCompletion?(nil)
      currentLocationCompletion = nil
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    currentLocationCompletion?(location)
    currentLocationCompletion = nil
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    LogManager.show("Lỗi định vị: \(error.localizedDescription)")
    currentLocationCompletion?(nil)
    currentLocationCompletion = nil
  }
}

extension MapManager {
  /// Tìm kiếm dịch vụ quanh vị trí hiện tại của người dùng (VD: "gas station", "restaurant", "ATM")
  func searchNearbyService(_ query: String,
                           radius: CLLocationDistance = 5000,
                           completion: @escaping ([MKMapItem]) -> Void) {
    
    requestUserLocation { [weak self] location in
      guard let self = self, let location = location else {
        LogManager.show("Không xác định được vị trí hiện tại")
        completion([])
        return
      }
      
      // Xác định vùng tìm kiếm quanh vị trí hiện tại
      let region = MKCoordinateRegion(center: location.coordinate,
                                      latitudinalMeters: radius,
                                      longitudinalMeters: radius)
      
      let request = MKLocalSearch.Request()
      request.naturalLanguageQuery = query
      request.region = region
      
      let search = MKLocalSearch(request: request)
      search.start { [weak self] response, error in
        guard let self = self, let response = response else {
          LogManager.show("Không tìm thấy kết quả: \(error?.localizedDescription ?? "Unknown")")
          completion([])
          return
        }
        
        guard let mapView = self.mapView else {
          completion(response.mapItems)
          return
        }
        
        // Xóa các pin cũ
        DispatchQueue.main.async {
          mapView.removeAnnotations(mapView.annotations)
        }
        
        // Hiển thị kết quả tìm kiếm
        for item in response.mapItems {
          let annotation = MKPointAnnotation()
          annotation.title = item.name
          annotation.subtitle = item.placemark.title
          annotation.coordinate = item.placemark.coordinate
          
          DispatchQueue.main.async {
            mapView.addAnnotation(annotation)
          }
        }
        
        // Zoom tới vùng tìm kiếm
        DispatchQueue.main.async {
          mapView.setRegion(region, animated: true)
        }
        completion(response.mapItems)
      }
    }
  }
}

extension MapManager {
  /// Tìm dịch vụ quanh vùng hiển thị trên bản đồ
  func searchServiceAroundVisibleRegion(_ query: String,
                                        completion: @escaping ([MKMapItem]) -> Void) {
    guard let mapView = mapView else {
      completion([])
      return
    }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = mapView.region
    
    let search = MKLocalSearch(request: request)
    search.start { [weak self] response, error in
      guard let self = self, let response = response else {
        LogManager.show("Không tìm thấy kết quả: \(error?.localizedDescription ?? "Unknown")")
        completion([])
        return
      }
      
      DispatchQueue.main.async {
        mapView.removeAnnotations(mapView.annotations)
        
        for item in response.mapItems {
          let annotation = MKPointAnnotation()
          annotation.title = item.name
          annotation.subtitle = item.placemark.title
          annotation.coordinate = item.placemark.coordinate
          mapView.addAnnotation(annotation)
        }
      }
      
      completion(response.mapItems)
    }
  }
}

class CustomAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var type: String
  var titlePlace: String
  
  init(coordinate: CLLocationCoordinate2D, type: String, titlePlace: String) {
    self.coordinate = coordinate
    self.type = type
    self.titlePlace = titlePlace
  }
}
