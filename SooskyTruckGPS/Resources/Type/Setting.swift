//
//  Setting.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 7/5/25.
//

import UIKit

enum Setting: CaseIterable {
  case tutorial
  case rate
  case feedback
  case privacy
  case termOfUse
  case moreApp
  var title: String {
    switch self {
    case .tutorial:
      return "Tutorials"
    case .rate:
      return "Rate App"
    case .feedback:
      return "Feedback"
    case .privacy:
      return "Privacy Policy"
    case .termOfUse:
      return "Terms Of Use"
    case .moreApp:
      return "More Apps"
    }
  }
  
  var icon: UIImage {
    switch self {
    case .tutorial:
      return .icTutorial
    case .rate:
      return .icRateApp
    case .feedback:
      return .icFeedback
    case .privacy:
      return .icPrivacyPolicy
    case .termOfUse:
      return .icTerms
    case .moreApp:
      return .icMoreApps
    }
  }
}
