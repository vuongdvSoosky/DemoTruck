//
//  Oboard.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 20/5/25.
//

import UIKit

enum Onboard: CaseIterable {
  case onboard1
  case onboard2
  case onboard3
  
  var title: String {
    switch self {
    case .onboard1:
      return "Ride Smarter, Care Better"
    case .onboard2:
      return "Track Your Journey with GPS"
    case .onboard3:
      return "Enjoying the Ride?"
    }
  }
  
  var description: String {
    switch self {
    case .onboard1:
      return "Track your rides, care for your horse, and stay safe on every journey"
    case .onboard2:
      return "We use GPS to record your ride route, distance, and speed"
    case .onboard3:
      return "A quick review helps us improve and bring you even better riding experiences"
    }
  }
  
  var image: UIImage {
    switch self {
    case .onboard1:
      return .icOnboard1
    case .onboard2:
      return .icOnboard2
    case .onboard3:
      return .icOnboard3
    }
  }
}
