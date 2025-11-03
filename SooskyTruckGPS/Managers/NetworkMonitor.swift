//
//  NetworkMonitor.swift
//  Base_MVVM_Combine
//
//  Created by Trịnh Xuân Minh on 02/02/2024.
//

import Foundation
import Network
import Combine

final public class NetworkMonitor {
  public static let shared = NetworkMonitor()
  
  public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
  }
  
  @Published public private(set) var isConnected: Bool = false
  @Published public private(set) var connectionType: ConnectionType = .unknown
  private let queue = DispatchQueue.global()
  private let monitor: NWPathMonitor
  
  init() {
    monitor = NWPathMonitor()
    startMonitoring()
  }
  
  deinit {
    stopMonitoring()
  }
  
  private func startMonitoring() {
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else {
        return
      }
      self.isConnected = path.status == .satisfied
      self.setConnectionType(path)
    }
  }
  
  private func stopMonitoring() {
    monitor.cancel()
  }
  
  /// Force cleanup for memory management
  func forceCleanup() {
    stopMonitoring()
    LogManager.show("NetworkMonitor force cleanup completed")
  }
  
  private func setConnectionType(_ path: NWPath) {
    switch true {
    case path.usesInterfaceType(.wifi):
      connectionType = .wifi
    case path.usesInterfaceType(.cellular):
      connectionType = .cellular
    case path.usesInterfaceType(.wiredEthernet):
      connectionType = .ethernet
    default:
      connectionType = .unknown
    }
  }
}
