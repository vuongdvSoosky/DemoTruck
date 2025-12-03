//
//  LocationService.swift
//  SooskyHorseTracking
//
//  Created by VuongDv on 2/10/25.
//

import CoreLocation
import UIKit
import MapKit
import Combine

class LocationService: NSObject, CLLocationManagerDelegate {
  static let shared = LocationService()
  let locationManager = CLLocationManager()
  private var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
  private(set) var onLocationUpdate: ((CLLocation) -> Void)?
  private(set) var stateAuthen: Bool = false
  private var didCallCompletion = false
  let handlerPermissionDeneid = PassthroughSubject<Void, Never>()
  
  
  private override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  // MARK: - Authorization
  
  /// Kiểm tra và yêu cầu quyền truy cập vị trí
  func checkAndRequestAuthorization(onChange: @escaping (CLAuthorizationStatus) -> Void) {
    self.onAuthorizationChange = onChange
    didCallCompletion = false
    let currentStatus = CLLocationManager.authorizationStatus()
    if currentStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    } else {
      handleAuthorizationChange(currentStatus)
    }
  }
  
  func startTrackingUser() {
//    locationManager.requestWhenInUseAuthorization()
//    locationManager.startUpdatingLocation()
  }
  
  func stopTrackingUser() {
//    locationManager.stopUpdatingLocation()
  }
  
  /// Delegate khi trạng thái quyền thay đổi
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    onAuthorizationChange?(status)
  }
  
  private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
    guard status != .notDetermined else { return }
    guard !didCallCompletion else { return }
    didCallCompletion = true
    onAuthorizationChange?(status)
  }
  
  // MARK: - Location
  
  func requestCurrentLocation(from viewController: UIViewController? = nil,
                              onUpdate: @escaping (CLLocation) -> Void) {
    
    guard NetworkMonitor.shared.isConnected else {
      LogManager.show("[Network Error] No internet connection")
      if let topVC = UIApplication.topViewController() {
        let alert = UIAlertController(
          title: "No internet connection",
          message: "Please check your network and try again",
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        topVC.present(alert, animated: true)
      }
      
      return
    }
    self.onLocationUpdate = onUpdate
    let status = locationManager.authorizationStatus
    
    switch status {
    case .notDetermined:
      DispatchQueue.main.async {
        self.locationManager.requestWhenInUseAuthorization()
      }
    case .authorizedWhenInUse, .authorizedAlways:
      locationManager.startUpdatingLocation()
    case .restricted, .denied:
      if let vc = viewController {
        showSettingsAlert(from: vc)
      }
    @unknown default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    onLocationUpdate?(location)
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    LogManager.show("Lỗi location: \(error.localizedDescription)")
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      let status = manager.authorizationStatus
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        locationManager.startUpdatingLocation()
      case .denied, .restricted:
        LogManager.show("Từ chối cấp quyền")
        handlerPermissionDeneid.send(())
      default:
          break
      }
  }
  
  // MARK: - Alert
  
  func showSettingsAlert(from viewController: UIViewController) {
    let alert = UIAlertController(
      title: "Location Access Required",
      message: "To use this feature, please enable location access in your device settings.This helps us provide accurate routes for you and show your current position, the app needs access to your location.",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Open Setting", style: .default, handler: { _ in
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
      }
    }))
    
    
    DispatchQueue.main.async {
      viewController.present(alert, animated: true)
    }
  }
}
