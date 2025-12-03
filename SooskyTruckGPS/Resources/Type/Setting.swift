//
//  Setting.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 7/5/25.
//

import UIKit

enum Setting: CaseIterable {
  case rate
  case feedback
  case privacy
  case termOfUse

  
  var title: String {
    switch self {
    case .rate:
      return "Rate App"
    case .feedback:
      return "Feedback"
    case .privacy:
      return "Privacy Policy"
    case .termOfUse:
      return "Terms Of Use"
    }
  }
  
  var icon: UIImage {
    switch self {
    case .rate:
      return .icRateApp
    case .feedback:
      return .icFeedback
    case .privacy:
      return .icPrivacyPolicy
    case .termOfUse:
      return .icTerms
    }
  }
}
