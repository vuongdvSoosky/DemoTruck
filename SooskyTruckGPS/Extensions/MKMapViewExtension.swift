//
//  MKMapViewExtension.swift
//  SooskyTractorGPS
//
//  Created by VuongDV on 26/8/25.
//

import MapKit

extension MKMapView {
  func snapshotWithOverlays(for coordinates: [CLLocationCoordinate2D]) -> UIImage? {
    guard !coordinates.isEmpty else { return nil }
    
    // 1. Tính bounding box polygon
    var minLat = coordinates[0].latitude
    var maxLat = coordinates[0].latitude
    var minLon = coordinates[0].longitude
    var maxLon = coordinates[0].longitude
    
    for coord in coordinates {
      minLat = min(minLat, coord.latitude)
      maxLat = max(maxLat, coord.latitude)
      minLon = min(minLon, coord.longitude)
      maxLon = max(maxLon, coord.longitude)
    }
    
    let topLeft = CLLocationCoordinate2D(latitude: maxLat, longitude: minLon)
    let bottomRight = CLLocationCoordinate2D(latitude: minLat, longitude: maxLon)
    
    let topLeftPoint = convert(topLeft, toPointTo: self)
    let bottomRightPoint = convert(bottomRight, toPointTo: self)
    
    var rect = CGRect(
      x: min(topLeftPoint.x, bottomRightPoint.x),
      y: min(topLeftPoint.y, bottomRightPoint.y),
      width: abs(bottomRightPoint.x - topLeftPoint.x),
      height: abs(bottomRightPoint.y - topLeftPoint.y)
    )
    
    // Clamp rect vào trong bounds để tránh crash
    rect = rect.intersection(bounds)
    guard !rect.isEmpty else { return nil }
    
    // 2. Render toàn bộ mapView.layer thành UIImage
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    let fullImage = renderer.image { ctx in
      layer.render(in: ctx.cgContext)
    }
    
    // 3. Crop an toàn
    guard let cgImage = fullImage.cgImage,
          let cropped = cgImage.cropping(to: rect.integral) else {
      return fullImage
    }
    
    return UIImage(cgImage: cropped)
  }
}
