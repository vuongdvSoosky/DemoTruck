//
//  ImageManager.swift
//  SooskyHorseTracking
//
//  Created by VuongDV on 27/9/25.
//

import UIKit
import Foundation
import Photos


final class ImageManager {
  static let shared = ImageManager()
  
  private init() {}
  
  func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    switch status {
    case .authorized, .limited:
      completion(true)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
        DispatchQueue.main.async {
          completion(newStatus == .authorized || newStatus == .limited)
        }
      }
    default:
      completion(false)
    }
  }
  
  func openSettingsForPhotoAccess(with nameVC: String) {
    let alert = UIAlertController(
      title: "Allow “Horse Riding Tracker” to access your photos?",
      message: "To personalize your horse profiles, Horse Riding Tracker needs access to your photo library.This lets you upload, view, and update horse images to mange your horses",
      preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
      guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsURL) else { return }
      UIApplication.shared.open(settingsURL)
      UserDefaultsManager.shared.set(nameVC, key: .currentVC)
    })
    
    // Present alert (if self is a UIViewController)
    DispatchQueue.main.async {
      UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
  }
}
