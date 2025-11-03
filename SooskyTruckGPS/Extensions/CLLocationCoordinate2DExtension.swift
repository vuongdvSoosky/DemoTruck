//
//  CLLocationCoordinate2DExtension.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 28/8/25.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
