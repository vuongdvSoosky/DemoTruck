//import Foundation
//import CoreLocation
//import MapKit
//
//protocol UserLocationManagerDelegate: AnyObject {
//  func realLocationManager(_ manager: UserLocationManager, didUpdateLocation location: CLLocationCoordinate2D)
//  func realLocationManager(_ manager: UserLocationManager, didUpdatePath path: [CLLocationCoordinate2D])
//  func realLocationManager(_ manager: UserLocationManager, didFailWithError error: Error)
//}
//
///// Class để quản lý real location của user và tính khoảng cách đã đi
//class UserLocationManager: NSObject {
//  
//  static let shared = UserLocationManager()
//  
//  // MARK: - Properties
//  
//  weak var delegate: UserLocationManagerDelegate?
//  private let locationManager = CLLocationManager()
//  private let distanceCalculator = DistanceCalculator.shared
//  
//  /// Current real location của user
//  private(set) var currentLocation: CLLocationCoordinate2D?
//  
//  /// Path coordinates đã đi
//  private var traveledPath: [CLLocationCoordinate2D] = []
//  
//  /// Tracking state
//  private(set) var isTracking = false
//  
//  /// Flag để theo dõi xem có đang sử dụng path mới không
//  private var isUsingNewPath = false
//  
//  /// Minimum distance filter để tránh update quá thường xuyên (meters)
//  private let minimumDistanceFilter: Double = 2.0
//  
//  // Path update batching
//  private var pathUpdateCounter = 0
//  private let pathUpdateBatchSize = 3
//  
//  // Zoom properties
//  private var hasZoomedToLocation = false
//  private var pendingZoomRequest = false 
//  
//  // MARK: - Initialization
//  
//  override init() {
//    super.init()
//    setupLocationManager()
//  }
//  
//  // MARK: - Public Methods
//  
//  /// Bắt đầu tracking real location
//  func startTracking() {
//    guard !isTracking else {
//      return
//    }
//    
//    // Reset traveledPath để bắt đầu tracking mới
//    traveledPath.removeAll()
//    
//    // Check authorization
//    let authStatus = locationManager.authorizationStatus
//    
//    switch authStatus {
//    case .notDetermined:
//      locationManager.requestWhenInUseAuthorization()
//    case .denied, .restricted:
//      let error = NSError(domain: "RealLocationManager", code: 1, userInfo: [
//        NSLocalizedDescriptionKey: "Location access denied. Please enable location services in Settings."
//      ])
//      delegate?.realLocationManager(self, didFailWithError: error)
//    case .authorizedWhenInUse, .authorizedAlways:
//      startLocationUpdates()
//    @unknown default:
//      break
//    }
//  }
//  
//  /// Dừng tracking real location
//  func stopTracking() {
//    guard isTracking else { return }
//    isTracking = false
//    locationManager.stopUpdatingLocation()
//    
//    // Force final path update
//    if !traveledPath.isEmpty {
//      delegate?.realLocationManager(self, didUpdatePath: traveledPath)
//    }
//  }
//  
//  /// Tiếp tục tracking real location sau khi đã dừng
//  func continueTracking() {
//    guard !isTracking else { return }
//    
//    // Reset traveledPath để bắt đầu path mới
//    traveledPath.removeAll()
//    
//    // Bắt đầu path mới trong DistanceCalculator
//    distanceCalculator.startNewPath()
//    isUsingNewPath = true
//    
//    // Check authorization
//    let authStatus = locationManager.authorizationStatus
//    
//    switch authStatus {
//    case .notDetermined:
//      locationManager.requestWhenInUseAuthorization()
//    case .denied, .restricted:
//      let error = NSError(domain: "RealLocationManager", code: 1, userInfo: [
//        NSLocalizedDescriptionKey: "Location access denied. Please enable location services in Settings."
//      ])
//      delegate?.realLocationManager(self, didFailWithError: error)
//    case .authorizedWhenInUse, .authorizedAlways:
//      startLocationUpdates()
//    @unknown default:
//      break
//    }
//  }
//  
//  /// Reset tất cả data
//  func resetData() {
//    traveledPath.removeAll()
//    distanceCalculator.clearRealLocationData()
//    currentLocation = nil
//    
//    // Notify delegate about cleared path
//    delegate?.realLocationManager(self, didUpdatePath: traveledPath)
//  }
//  
//  /// Reset hoàn toàn trạng thái tracking về ban đầu
//  func resetTrackingState() {
//    // Stop tracking nếu đang tracking
//    if isTracking {
//      stopTracking()
//    }
//    
//    // Reset tất cả data
//    resetData()
//    
//    // Reset tracking state
//    isTracking = false
//    isUsingNewPath = false
//    
//    // Reset zoom state
//    hasZoomedToLocation = false
//    pendingZoomRequest = false
//    
//    // Reset path update counter
//    pathUpdateCounter = 0
//  }
//  
//  /// Reset cho session mới - cleanup hoàn toàn
//  func resetForNewSession() {
//    // Stop tracking nếu đang tracking
//    if isTracking {
//      stopTracking()
//    }
//    
//    // Reset tất cả data
//    resetData()
//    
//    // Reset tracking state
//    isTracking = false
//    isUsingNewPath = false
//    
//    // Reset zoom state
//    hasZoomedToLocation = false
//    pendingZoomRequest = false
//    
//    // Reset path update counter
//    pathUpdateCounter = 0
//    
//    // Clear delegate để tránh retain cycle
//    delegate = nil
//    
//    LogManager.show("UserLocationManager reset for new session")
//  }
//  
//  /// Clear path đã đi
//  func clearPath() {
//    traveledPath.removeAll()
//    distanceCalculator.clearRealLocationData()
//    delegate?.realLocationManager(self, didUpdatePath: traveledPath)
//  }
//  
//  /// Clear all data and reset state
//  func clearAll() {
//    // Stop tracking
//    if isTracking {
//      stopTracking()
//    }
//    
//    // Clear all data
//    traveledPath.removeAll()
//    distanceCalculator.clearAllData()
//    currentLocation = nil
//    
//    // Reset state
//    isTracking = false
//    isUsingNewPath = false
//    hasZoomedToLocation = false
//    pendingZoomRequest = false
//    pathUpdateCounter = 0
//    
//    // Clear delegate
//    delegate = nil
//    
//    LogManager.show("UserLocationManager cleared all data")
//  }
//  
//  /// Force cleanup memory - call when memory warning
//  func forceCleanup() {
//    clearAll()
//    LogManager.show("UserLocationManager force cleanup completed")
//  }
//  
//  // MARK: - Distance Methods
//  
//  /// Lấy tổng khoảng cách đã đi
//  /// - Returns: Khoảng cách tính bằng meters
//  func getTotalDistance() -> Double {
//    return distanceCalculator.getTotalRealDistance()
//  }
//  
//  /// Lấy khoảng cách formatted
//  /// - Returns: Formatted string (ví dụ: "1.25 mi")
//  func getFormattedDistance() -> String {
//    return distanceCalculator.getFormattedRealDistance()
//  }
//  
//  /// Lấy path coordinates đã đi (chỉ path hiện tại)
//  /// - Returns: Array of coordinates
//  var traveledPathCoordinates: [CLLocationCoordinate2D] {
//    return traveledPath
//  }
//  
//  /// Lấy tất cả các path đã đi (chỉ path đã hoàn thành)
//  /// - Returns: Array of path arrays
//  func getAllPaths() -> [[CLLocationCoordinate2D]] {
//    return distanceCalculator.getAllPaths()
//  }
//  
//  /// Lấy tất cả các path đã đi bao gồm cả path hiện tại
//  /// - Returns: Array of path arrays
//  func getAllPathsIncludingCurrent() -> [[CLLocationCoordinate2D]] {
//    return distanceCalculator.getAllPathsIncludingCurrent()
//  }
//  
//  /// Lấy tất cả các path đã đi dưới dạng một array duy nhất
//  /// - Returns: Array of coordinates từ tất cả các path
//  func getAllPathsCombined() -> [CLLocationCoordinate2D] {
//    return distanceCalculator.getAllPathsCombined()
//  }
//  
//  /// Lấy vị trí hiện tại
//  /// - Returns: Vị trí hiện tại hoặc nil nếu chưa có
//  func getCurrentLocation() -> CLLocationCoordinate2D? {
//    return currentLocation
//  }
//  
//  
//  /// Reset zoom state (cho phép zoom lại)
//  func resetZoomState() {
//    hasZoomedToLocation = false
//  }
//  
//  // MARK: - Session Restoration Methods
//  
//  /// Khôi phục vị trí hiện tại từ dữ liệu đã lưu
//  func restoreCurrentLocation(_ location: CLLocationCoordinate2D) {
//    currentLocation = location
//  }
//  
//  /// Khôi phục hoàn toàn từ đường đi đã lưu với thống kê đã có sẵn
//  func restoreFromPathWithStatistics(_ coordinates: [CLLocationCoordinate2D],
//                                     savedArea: Double,
//                                     savedPercent: Double) {
//    // Không load path cũ vào traveledPath để tránh nối liền
//    // traveledPath sẽ được reset khi bắt đầu tracking mới
//    traveledPath.removeAll()
//  
//    // Nếu có đường đi, thiết lập vị trí hiện tại là vị trí cuối cùng
//    if !coordinates.isEmpty {
//      let lastLocation = coordinates.last!
//      currentLocation = lastLocation
//    } else {
//      LogManager.show("No previous path found for real location")
//    }
//  }
//  
//  /// Tính hiệu suất từ đường đi đã đi
//  private func calculateEfficiencyFromPath() -> Double {
//    guard traveledPath.count >= 2 else { return 0.0 }
//    
//    let totalDistance = distanceCalculator.getTotalRealDistance()
//    let straightLineDistance = distanceCalculator.getRealPathStraightLineDistance()
//    
//    return straightLineDistance > 0 ? (straightLineDistance / totalDistance) * 100 : 0.0
//  }
//  
//  // MARK: - Private Methods
//  
//  private func setupLocationManager() {
//    locationManager.delegate = self
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    locationManager.distanceFilter = minimumDistanceFilter
//  }
//  
//  private func startLocationUpdates() {
//    LogManager.show("startLocationUpdates")
//    isTracking = true
//    
//    // Chỉ clear data khi bắt đầu tracking hoàn toàn mới (không phải khi continue)
//    if !isUsingNewPath {
//      traveledPath.removeAll()
//    }
//    isUsingNewPath = false
//    
//    // Reset zoom state for new tracking session
//    hasZoomedToLocation = false
//    locationManager.startUpdatingLocation()
//  }
//  
//  private func addToPath(_ coordinate: CLLocationCoordinate2D) {
//    // Chỉ thêm vào path nếu đang tracking
//    guard isTracking else { return }
//    
//    traveledPath.append(coordinate)
//    pathUpdateCounter += 1
//    
//    // Add to distance calculator
//    distanceCalculator.addRealLocationPoint(coordinate)
//    
//    // Batch updates for performance
//    if pathUpdateCounter >= pathUpdateBatchSize {
//      delegate?.realLocationManager(self, didUpdatePath: traveledPath)
//      pathUpdateCounter = 0
//    }
//  }
//  
//  /// Thêm điểm vào path mới (không tính khoảng cách từ điểm trước)
//  private func addToNewPath(_ coordinate: CLLocationCoordinate2D) {
//    // Chỉ thêm vào path nếu đang tracking
//    guard isTracking else { return }
//    
//    traveledPath.append(coordinate)
//    pathUpdateCounter += 1
//    
//    // Add to distance calculator với path mới
//    distanceCalculator.addRealLocationPointToNewPath(coordinate)
//    
//    // Batch updates for performance
//    if pathUpdateCounter >= pathUpdateBatchSize {
//      delegate?.realLocationManager(self, didUpdatePath: traveledPath)
//      pathUpdateCounter = 0
//    }
//  }
//}
//
//// MARK: - CLLocationManagerDelegate
//
//extension UserLocationManager: CLLocationManagerDelegate {
//  
//  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    guard isTracking, let location = locations.last else { return }
//    
//    let coordinate = location.coordinate
//    
//    // Update current location
//    currentLocation = coordinate
//    
//    // Add to path and distance calculation
//    if isUsingNewPath {
//      addToNewPath(coordinate)
//      // Sau điểm đầu tiên, chuyển về path bình thường
//      isUsingNewPath = false
//    } else {
//      addToPath(coordinate)
//    }
//    
//    // Notify delegate
//    delegate?.realLocationManager(self, didUpdateLocation: coordinate)
//  }
//  
//  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//    delegate?.realLocationManager(self, didFailWithError: error)
//  }
//  
//  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//    switch status {
//    case .authorizedWhenInUse, .authorizedAlways:
//      if isTracking {
//        startLocationUpdates()
//      }
//      
//    case .denied, .restricted:
//      stopTracking()
//      let error = NSError(domain: "RealLocationManager", code: 2, userInfo: [
//        NSLocalizedDescriptionKey: "Location access denied or restricted."
//      ])
//      delegate?.realLocationManager(self, didFailWithError: error)
//    case .notDetermined:
//      break
//    @unknown default:
//      break
//    }
//  }
//}
