//
//  UIImageViewExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
import SDWebImage

extension UIImageView {
  func loadImage(_ imageURL: String) {
    guard let url = URL(string: imageURL) else {
      self.image = .icHorsePlaceHodler
      return
    }
    
    self.sd_setImage(with: url)
  }
  
  func setTrainingImage(from path: String?) {
    guard let fileName = path, !fileName.isEmpty else {
      self.image = .icHorsePlaceHodler
      return
    }
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsURL.appendingPathComponent(fileName)
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      DispatchQueue.main.async {
        self.image = .icHorsePlaceHodler
      }
      return
    }
    if let data = try? Data(contentsOf: fileURL),
       let image = UIImage(data: data) {
      DispatchQueue.main.async {
        self.image = image
      }
    } else {
      DispatchQueue.main.async {
        self.image = .icHorsePlaceHodler
      }
    }
  }
}
