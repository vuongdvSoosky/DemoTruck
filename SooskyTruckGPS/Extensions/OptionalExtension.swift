//
//  OptionalExtension.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 21/8/25.
//

extension Optional where Wrapped == String {
  var isNilOrEmpty: Bool {
    return self?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
  }
}
