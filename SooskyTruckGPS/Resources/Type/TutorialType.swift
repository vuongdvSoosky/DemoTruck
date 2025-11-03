//
//  TutorialType.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 10/9/25.
//

import UIKit

enum TutorialType: CaseIterable {
  case readyToRide
  case progress
  case trainWithAi
  case createYourHorse
  
  var title: String {
    switch self {
    case .readyToRide:
      return "Ready to Ride"
    case .progress:
      return "Review Your Progress"
    case .trainWithAi:
      return "Train Smarter with AI"
    case .createYourHorse:
      return "Create Your Horse"
    }
  }
  
  var desTitle: NSAttributedString {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = 6
    paragraph.paragraphSpacing = 4
    paragraph.alignment = .left
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 16),
      .foregroundColor: UIColor(rgb: 0x333333),
      .paragraphStyle: paragraph
    ]
    
    switch self {
    case .readyToRide:
      let text = """
      • Start GPS to track distance & route
      • Pick your horse → Tap Go
      • Ride normally – GPS runs auto
      • Tap Finish to complete your session
      """
      return NSAttributedString(string: text, attributes: attributes)
      
    case .progress:
      let text = """
      • Track Your Progress
      • Go to Ride History
      • Check ride stats & horse condition
      """
      return NSAttributedString(string: text, attributes: attributes)
      
    case .trainWithAi:
      let text = """
      • Start your ride
      • AI tracks speed, rhythm & endurance
      • Get instant tips to improve
      """
      return NSAttributedString(string: text, attributes: attributes)
      
    case .createYourHorse:
      let text = """
      • Build a horse profile to track health & progress
      • Go to My Horse
      • Add name, age, breed
      • Update status: Healthy / Moderate / Fatigue
      """
      return NSAttributedString(string: text, attributes: attributes)
    }
  }
  
  var image: UIImage {
    switch self {
    case .readyToRide:
      return .icTutorial1
    case .progress:
      return .icTutorial2
    case .trainWithAi:
      return .icTutorial3
    case .createYourHorse:
      return .icTutorial4
    }
  }
}
