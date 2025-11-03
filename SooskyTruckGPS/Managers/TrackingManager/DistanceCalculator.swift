
//
//  DistanceCalculator.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 12/8/25.
//

import Foundation
import CoreLocation
import Combine

protocol DistanceCalculatorDelegate: AnyObject {
  /// Gửi ra vị trí hiện tại
  func distanceCalculator(_ calculator: DistanceCalculator, didUpdateLocation coordinate: CLLocationCoordinate2D)
  
  /// Gửi ra một đoạn path riêng biệt (segment mới nhất)
  func distanceCalculator(_ calculator: DistanceCalculator, didUpdatePathSegment segment: [CLLocationCoordinate2D])
}

/// Đơn vị đo lường
enum DistanceUnit {
  case kilometer
  case mile
}

/// Trạng thái tracking
enum TrackingLocationState {
  case idle
  case tracking
  case paused
}

final class DistanceCalculator: NSObject, ObservableObject {
  
  static let shared = DistanceCalculator()
  
  // MARK: - Published
  @Published private(set) var totalDistance: Double = 0
  @Published private(set) var currentSpeed: Double = 0
  @Published private(set) var averageSpeed: Double = 0
  @Published private(set) var currentPace: String = "--:--"
  @Published private(set) var averagePace: String = "--:--"
  
  @Published private(set) var totalDistanceMiles: Double = 0
  @Published private(set) var currentSpeedMph: Double = 0
  @Published private(set) var averageSpeedMph: Double = 0
  
  weak var delegate: DistanceCalculatorDelegate?
  var unit: DistanceUnit = .mile
  @Published private(set) var state: TrackingLocationState = .idle
  
  private let locationManager = CLLocationManager()
  private var lastLocation: CLLocation?
  private var startTime: Date?
  private var pauseStartTime: Date?
  private var pausedDuration: TimeInterval = 0
  private var speedSamples: [Double] = []
  
  // ✅ Mỗi segment là một mảng toạ độ riêng
  private var pathSegments: [[CLLocationCoordinate2D]] = [[]]
  
  private var simulationTimer: Timer?
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
}

// MARK: - Public Methods
extension DistanceCalculator {
  
  func startTracking() {
    guard state == .idle else { return }
    state = .tracking
    
    guard CLLocationManager.locationServicesEnabled() else {
      LogManager.show("Location services are disabled.")
      state = .idle
      return
    }
    
    let authStatus = locationManager.authorizationStatus
    switch authStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      DispatchQueue.main.async {
        self.resetTrackingData()
        self.startTime = Date()
        self.locationManager.startUpdatingLocation()
      }
    case .denied, .restricted:
      LogManager.show("Location access denied.")
      state = .idle
    @unknown default:
      break
    }
  }
  
  func pauseTracking() {
    guard state == .tracking else { return }
    state = .paused
    pauseStartTime = Date()
    locationManager.stopUpdatingLocation()
  }
  
  func resumeTracking() {
    guard state == .paused else { return }
    state = .tracking
    
    if let pauseTime = pauseStartTime {
      pausedDuration += Date().timeIntervalSince(pauseTime)
    }
    
    if let currentLocation = locationManager.location {
      lastLocation = currentLocation
    }
    
    // ✅ Tạo segment mới khi resume
    pathSegments.append([])
    
    locationManager.startUpdatingLocation()
  }
  
  func stopTracking() {
    guard state != .idle else { return }
    state = .idle
    locationManager.stopUpdatingLocation()
  }
  
  func resetTrackingData() {
    totalDistance = 0
    totalDistanceMiles = 0
    currentSpeed = 0
    averageSpeed = 0
    currentPace = "--:--"
    averagePace = "--:--"
    currentSpeedMph = 0
    averageSpeedMph = 0
    
    lastLocation = nil
    startTime = nil
    pauseStartTime = nil
    pausedDuration = 0
    speedSamples.removeAll()
    pathSegments = [[]]
    
    delegate?.distanceCalculator(self, didUpdatePathSegment: [])
  }
}

// MARK: - Helpers
private extension DistanceCalculator {
  func convertMetersToMiles(_ meters: Double) -> Double { meters / 1609.34 }
  func convertMetersToKilometers(_ meters: Double) -> Double { meters / 1000.0 }
  func mpsToKmph(_ speed: Double) -> Double { speed * 3.6 }
  func mpsToMph(_ speed: Double) -> Double { speed * 2.23694 }
  
  func formatPace(from secondsPerUnit: Double, unit: DistanceUnit) -> String {
    guard secondsPerUnit.isFinite && secondsPerUnit > 0 else { return "--:--" }
    let totalMinutes = Int(secondsPerUnit / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
  }
  
  func updateStats(newLocation: CLLocation) {
      guard state == .tracking else { return }
      if pathSegments.isEmpty {
          pathSegments.append([])
      }

      guard let last = lastLocation else {
          // Lần đầu tiên có location — thêm điểm đầu tiên
          lastLocation = newLocation
          pathSegments[pathSegments.count - 1].append(newLocation.coordinate)
          
          delegate?.distanceCalculator(self, didUpdateLocation: newLocation.coordinate)
          delegate?.distanceCalculator(self, didUpdatePathSegment: pathSegments.last ?? [])
          return
      }

      let distance = newLocation.distance(from: last)
      guard distance > 1, newLocation.horizontalAccuracy < 20 else { return }

      totalDistance += distance
      pathSegments[pathSegments.count - 1].append(newLocation.coordinate)

      let elapsed = Date().timeIntervalSince(startTime ?? Date()) - pausedDuration
      let timeDiff = newLocation.timestamp.timeIntervalSince(last.timestamp)

      currentSpeed = timeDiff > 0 ? distance / timeDiff : 0
      speedSamples.append(currentSpeed)
      if speedSamples.count > 10 { speedSamples.removeFirst() }
      let smoothedSpeed = speedSamples.reduce(0, +) / Double(speedSamples.count)

      totalDistanceMiles = convertMetersToMiles(totalDistance)
      currentSpeedMph = mpsToMph(smoothedSpeed)

      let avgSpeedMps = totalDistance / max(elapsed, 1)
      switch unit {
      case .kilometer:
          averageSpeed = mpsToKmph(avgSpeedMps)
      case .mile:
          averageSpeed = mpsToMph(avgSpeedMps)
      }
      averageSpeedMph = mpsToMph(avgSpeedMps)

      let distanceInUnit = (unit == .kilometer)
          ? convertMetersToKilometers(totalDistance)
          : convertMetersToMiles(totalDistance)
      let avgPaceSec = elapsed / max(distanceInUnit, 0.001)
      averagePace = formatPace(from: avgPaceSec, unit: unit)

      if smoothedSpeed > 0 {
          let pacePerUnit = (unit == .kilometer) ? 1000 / smoothedSpeed : 1609.34 / smoothedSpeed
          currentPace = formatPace(from: pacePerUnit, unit: unit)
      } else {
          currentPace = "--:--"
      }

      delegate?.distanceCalculator(self, didUpdateLocation: newLocation.coordinate)

      if let currentSegment = pathSegments.last, !currentSegment.isEmpty {
          delegate?.distanceCalculator(self, didUpdatePathSegment: currentSegment)
      }

      lastLocation = newLocation
  }
}

// MARK: - CLLocationManagerDelegate
extension DistanceCalculator: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let newLocation = locations.last else { return }
    updateStats(newLocation: newLocation)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    LogManager.show("Location error: \(error.localizedDescription)")
  }
}

// MARK: - Accessors
extension DistanceCalculator {
  var currentCoordinate: CLLocationCoordinate2D? { lastLocation?.coordinate }
  var path: [CLLocationCoordinate2D] {
    pathSegments.flatMap { $0 }
  }
  
  var segments: [[CLLocationCoordinate2D]] { pathSegments }
}
