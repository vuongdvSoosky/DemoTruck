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
    mapView.setUserTrackingMode(.followWithHeading, animated: true)
    mapView.showsCompass = false
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
  func searchServiceAroundVisibleRegion(_ query: String,
                                        type: String) {
    guard let mapView = mapView else {
      return
    }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = mapView.region
    
    let search = MKLocalSearch(request: request)
    search.start { [weak self] response, error in
      guard let self = self, let response = response else {
        LogManager.show("Không tìm thấy kết quả: \(error?.localizedDescription ?? "Unknown")")
        return
      }
      
      DispatchQueue.main.async {
        // Chỉ xóa các service annotations cũ, giữ lại Location annotations
        let serviceAnnotations = mapView.annotations.filter { $0 is CustomServiceAnimation }
        mapView.removeAnnotations(serviceAnnotations)
        
        // Tạo CustomServiceAnimation với đầy đủ thông tin
        for item in response.mapItems {
          // Format địa chỉ đầy đủ từ placemark
          var addressParts: [String] = []
          if let city = item.placemark.locality {
            addressParts.append(city)
          }
          if let state = item.placemark.administrativeArea {
            addressParts.append(state)
          }
          if let country = item.placemark.country {
            addressParts.append(country)
          }
          let fullAddress = addressParts.isEmpty ? (item.placemark.title ?? "") : addressParts.joined(separator: ", ")
          
          let annotation = CustomServiceAnimation(
            coordinate: item.placemark.coordinate,
            type: type,
            titlePlace: item.name ?? "",
            id: UUID().uuidString
          )
          annotation.title = item.name
          annotation.subtitle = fullAddress
          mapView.addAnnotation(annotation)
        }
      }
    }
  }
  
  func removeAllServiceAnnotations() {
     guard let mapView = mapView else { return }
     
     let serviceAnnotations = mapView.annotations.filter { $0 is CustomServiceAnimation }
     mapView.removeAnnotations(serviceAnnotations)
   }
}

// MARK: - CheckLocation
extension MapManager {
  func checkRouteAvailable(from start: CLLocationCoordinate2D,
                           to end: CLLocationCoordinate2D,
                           completion: @escaping (Bool) -> Void) {
    
    let startPlacemark = MKPlacemark(coordinate: start)
    let endPlacemark = MKPlacemark(coordinate: end)
    
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: startPlacemark)
    request.destination = MKMapItem(placemark: endPlacemark)
    request.transportType = .automobile
    
    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      if let routes = response?.routes, !routes.isEmpty {
        LogManager.show("Có đường đi, distance: \(routes.first?.distance ?? 0)")
        completion(true)
      } else {
        LogManager.show("Không có route khả dụng: \(error?.localizedDescription ?? "")")
        completion(false)
      }
    }
  }
}

class CustomAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var title: String?
  var subtitle: String?
  var identifier: String = "CustomAnnotationView"
  var type: String?
  var id: String?
  
  init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, type: String?, id: String?) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    self.type = type
    self.id = id
  }
}

class CustomServiceAnimation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var type: String
  var titlePlace: String
  var id: String
  var title: String?
  var subtitle: String?
  var identifier: String = "CustomAnnotationView"
  
  init(coordinate: CLLocationCoordinate2D, type: String, titlePlace: String, id: String) {
    self.coordinate = coordinate
    self.type = type
    self.titlePlace = titlePlace
    self.id = id
    self.title = titlePlace
  }
}
