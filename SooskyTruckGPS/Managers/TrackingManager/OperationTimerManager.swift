import Foundation
import UIKit

protocol OperationTimerManagerDelegate: AnyObject {
  func setCurrentTimeDouble(_ time: Double)
  func updateTimeDisplay(_ time: String)
}

class OperationTimerManager {
  
  // MARK: - Properties
  private var operationTimer: Timer?
  private var operationStartTime: Date?
  private(set) var totalOperationTime: TimeInterval = 0.0
  private var isTimerRunning: Bool = false
  
  // MARK: - Callback
  var onTimeUpdate: ((String) -> Void)?
  
  // MARK: - Singleton
  static let shared = OperationTimerManager()
  
  weak var delegate: OperationTimerManagerDelegate?
  
  private init() {}
  
  // MARK: - Public Methods
  func startOperationTimer() {
    guard !isTimerRunning else { return }
    
    operationStartTime = Date()
    isTimerRunning = true
    
    // Start timer that updates every second
    operationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.updateTimerDouble()
      self?.updateTimeDisplay()
    }
  }
  
  func stopOperationTimer() {
    if let startTime = operationStartTime {
      totalOperationTime += Date().timeIntervalSince(startTime)
      operationStartTime = nil
    }
    
    operationTimer?.invalidate()
    operationTimer = nil
    isTimerRunning = false
  }
  
  func pauseOperationTimer() {
    guard isTimerRunning else { return }
    
    if let startTime = operationStartTime {
      // Cộng dồn thời gian từ lần start gần nhất
      totalOperationTime += Date().timeIntervalSince(startTime)
      operationStartTime = nil
    }
    
    operationTimer?.invalidate()
    operationTimer = nil
    isTimerRunning = false
  }
  
  func continueOperationTimer() {
    guard !isTimerRunning else { return }
    
    // Tiếp tục từ thời gian trước đó
    operationStartTime = Date()
    isTimerRunning = true
    
    operationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.updateTimerDouble()
      self?.updateTimeDisplay()
    }
  }
  
  func resetOperationTimer() {
    stopOperationTimer()
    totalOperationTime = 0.0
    onTimeUpdate?("")
  }
  
  func resetTotalOperationTime() {
    totalOperationTime = 0.0
  }
  
  func getCurrentOperationTime() -> TimeInterval {
    var currentTime = totalOperationTime
    
    if let startTime = operationStartTime {
      currentTime += Date().timeIntervalSince(startTime)
    }
    
    return currentTime
  }
  
  func getFormattedOperationTime() -> String {
    let totalSeconds = Int(getCurrentOperationTime())
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  func isRunning() -> Bool {
    return isTimerRunning
  }
  
  func getTotalOperationTime() -> TimeInterval {
    return totalOperationTime
  }
  
  // MARK: - Private Methods
  private func updateTimerDouble() {
    let currentTimeString = getCurrentOperationTime()
    self.delegate?.setCurrentTimeDouble(currentTimeString)
  }
  
  private func updateTimeDisplay() {
    let currentTimeString = getFormattedOperationTime()
    self.delegate?.updateTimeDisplay(currentTimeString)
  }
}

// MARK: - Extension for Time Formatting
extension OperationTimerManager {
  
  /// Format time interval to "Xh Ym" format (without seconds)
  func getFormattedTimeEstimate() -> String {
    let totalSeconds = Int(getCurrentOperationTime())
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    } else {
      return "\(minutes)m"
    }
  }
  
  /// Format time interval to "Xh Ym Zs" format
  func getFormattedTimeWithSeconds() -> String {
    let totalSeconds = Int(getCurrentOperationTime())
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    if hours > 0 {
      return "\(hours)h \(minutes)m \(seconds)s"
    } else if minutes > 0 {
      return "\(minutes)m \(seconds)s"
    } else {
      return "\(seconds)s"
    }
  }
  
  /// Get time components separately
  func getTimeComponents() -> (hours: Int, minutes: Int, seconds: Int) {
    let totalSeconds = Int(getCurrentOperationTime())
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    return (hours, minutes, seconds)
  }
}

extension OperationTimerManager {
  /// Khôi phục thời gian hoạt động từ dữ liệu đã lưu và tiếp tục đếm
  func restoreOperationTime(_ savedTime: TimeInterval) {
    // Gán lại tổng thời gian đã lưu
    totalOperationTime = savedTime
    
    // Nếu timer đang chạy thì dừng để reset lại
    operationTimer?.invalidate()
    operationTimer = nil
    isTimerRunning = false
    
    // Bắt đầu lại từ thời gian đã khôi phục
    operationStartTime = Date()
    isTimerRunning = true
    
    // Khởi động timer để đếm tiếp
    operationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.updateTimerDouble()
      self?.updateTimeDisplay()
    }
    
    // Cập nhật ngay lập tức sau khi restore
    updateTimerDouble()
    updateTimeDisplay()
  }
}
