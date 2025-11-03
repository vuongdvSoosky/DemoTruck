//
//  UIImageExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
import SDWebImage

extension UIImage {
  class func gradientImage(bounds: CGRect,
                           colors: [UIColor],
                           startPoint: CGPoint,
                           endPoint: CGPoint,
                           type: CAGradientLayerType = .axial,
                           locations: [NSNumber]? = nil
  ) -> UIImage {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.colors = colors.map(\.cgColor)
    gradientLayer.type = type
    gradientLayer.startPoint = startPoint
    gradientLayer.endPoint = endPoint
    if let locations = locations {
      gradientLayer.locations = locations
    }
    
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    
    return renderer.image { ctx in
      gradientLayer.render(in: ctx.cgContext)
    }
  }
  
  func resize(maxSize: CGSize) -> UIImage {
    let size = self.size
    
    var ratio: CGFloat
    if size.width > size.height {
      ratio = maxSize.height / size.height
    } else {
      ratio = maxSize.width / size.width
    }
    
    if ratio >= 1.0 {
      return self
    }
    
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func resized() -> UIImage? {
    let canvas = CGSize(width: 500, height: (size.height / size.width) * 500)
    let format = imageRendererFormat
    format.opaque = true
    return UIGraphicsImageRenderer(size: canvas, format: format).image {
      _ in draw(in: CGRect(origin: .zero, size: canvas))
    }
  }
}

extension UIImage {
  func saveToFileManager(fileName: String) -> String? {
    guard let data = self.jpegData(compressionQuality: 1) else { return nil }
    
    do {
      let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      if !FileManager.default.fileExists(atPath: directory.path) {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
      }
      
      let finalFileName = fileName.hasSuffix(".jpg") ? fileName : fileName + ".jpg"
      let fileURL = directory.appendingPathComponent(finalFileName)
      
      try data.write(to: fileURL)
      return fileURL.path
    } catch {
      LogManager.show("Error saving image to FileManager: \(error)")
      return nil
    }
  }
  
  func resized(toWidth width: CGFloat) -> UIImage {
    let scale = width / size.width
    let newHeight = size.height * scale
    let newSize = CGSize(width: width, height: newHeight)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    self.draw(in: CGRect(origin: .zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage ?? self
  }
}
