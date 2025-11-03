//
//  LocationService.swift
//  SooskyHorseTracking
//
//  Created by VuongDv on 2/10/25.
//

import CoreLocation
import UIKit
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate {
  static let shared = LocationService() // Singleton instance
  let locationManager = CLLocationManager()
  private var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
  private(set) var onLocationUpdate: ((CLLocation) -> Void)?
  private(set) var stateAuthen: Bool = false
  private var didCallCompletion = false
  
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
  
  func requestCurrentLocation(onUpdate: @escaping (CLLocation) -> Void) {
    self.onLocationUpdate = onUpdate
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    onLocationUpdate?(location)
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    LogManager.show("Lỗi location: \(error.localizedDescription)")
  }
  
  // MARK: - Alert
  
  func showSettingsAlert(from viewController: UIViewController) {
    let alert = UIAlertController(
      title: "Location Access Required",
      message: "To record your rides tracks and show your current position, the app needs access to your location. You can grant access in your Settings",
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
