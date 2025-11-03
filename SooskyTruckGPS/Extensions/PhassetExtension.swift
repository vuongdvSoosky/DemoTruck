//
//  PhassetExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation
import Photos
import UIKit

extension PHAsset {
  func getFullResolutionImage(completion: @escaping (UIImage?) -> Void) {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true
    
    manager.requestImageDataAndOrientation(for: self, options: options) { data, _, _, _ in
      if let data = data, let image = UIImage(data: data) {
        DispatchQueue.main.async {
          completion(image)
        }
      } else {
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }
  }
  
  func getAssetThumbnail() -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: self, targetSize: CGSize(width: 250.0, height: 250.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
      thumbnail = result!
    })
    return thumbnail
  }
}

