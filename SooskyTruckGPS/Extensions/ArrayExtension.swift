//
//  ArrayExtension.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 3/9/25.
//

extension Array {
  subscript(safe index: Int) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
