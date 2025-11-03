//
//  AppExtension.swift
//  BaseSubscription
//
//  Created by HaiTu on 12/11/24.
//

import UIKit

extension UIView {
  @discardableResult   // 1
  func fromNib<T : UIView>() -> T? {   // 2
    guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
      // xib not loaded, or its top view is of the wrong type
      return nil
    }
    self.addSubview(contentView)     // 4
    contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
    contentView.layoutAttachAll()   // 6
    return contentView   // 7
  }
  
  /// attaches all sides of the receiver to its parent view
  func layoutAttachAll(margin : CGFloat = 0.0) {
    let view = superview
    layoutAttachTop(to: view, margin: margin)
    layoutAttachBottom(to: view, margin: margin)
    layoutAttachLeading(to: view, margin: margin)
    layoutAttachTrailing(to: view, margin: margin)
  }
  
  /// attaches the top of the current view to the given view's top if it's a superview of the current view, or to it's bottom if it's not (assuming this is then a sibling view).
  /// if view is not provided, the current view's super view is used
  @discardableResult
  func layoutAttachTop(to: UIView? = nil, margin : CGFloat = 0.0) -> NSLayoutConstraint {
    
    let view: UIView? = to ?? superview
    let isSuperview = view == superview
    let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: isSuperview ? .top : .bottom, multiplier: 1.0, constant: margin)
    superview?.addConstraint(constraint)
    
    return constraint
  }
  
  /// attaches the bottom of the current view to the given view
  @discardableResult
  func layoutAttachBottom(to: UIView? = nil, margin : CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
    
    let view: UIView? = to ?? superview
    let isSuperview = (view == superview) || false
    let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: isSuperview ? .bottom : .top, multiplier: 1.0, constant: -margin)
    if let priority = priority {
      constraint.priority = priority
    }
    superview?.addConstraint(constraint)
    
    return constraint
  }
  
  /// attaches the leading edge of the current view to the given view
  @discardableResult
  func layoutAttachLeading(to: UIView? = nil, margin : CGFloat = 0.0) -> NSLayoutConstraint {
    
    let view: UIView? = to ?? superview
    let isSuperview = (view == superview) || false
    let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: isSuperview ? .leading : .trailing, multiplier: 1.0, constant: margin)
    superview?.addConstraint(constraint)
    
    return constraint
  }
  
  /// attaches the trailing edge of the current view to the given view
  @discardableResult
  func layoutAttachTrailing(to: UIView? = nil, margin : CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
    
    let view: UIView? = to ?? superview
    let isSuperview = (view == superview) || false
    let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: isSuperview ? .trailing : .leading, multiplier: 1.0, constant: -margin)
    if let priority = priority {
      constraint.priority = priority
    }
    superview?.addConstraint(constraint)
    
    return constraint
  }
}

// them nhieu view con cho view cha
//extension UIView {
//    func addSubviews(_ views: UIView...) {
//        for view in views {
//            addSubview(view)
//        }
//    }
//}
//
//// xoa tat ca sub view
//extension UIView {
//    /// Remove all subview
//    func removeAllSubviews() {
//        subviews.forEach { $0.removeFromSuperview() }
//    }
//
//    /// Remove all subview with specific type
//    func removeAllSubviews<T: UIView>(type: T.Type) {
//        subviews
//            .filter { $0.isMember(of: type) }
//            .forEach { $0.removeFromSuperview() }
//    }
//}


// custom button
extension UIButton {
  func configBaseButton(title: String, radius: CGFloat = 10){
    DispatchQueue.main.async {
      self.setTitle(title, for: .normal)
      self.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
      self.backgroundColor = UIColor(hexString: "5C3218")
      self.setTitleColor(.white, for: .normal)
      self.layer.cornerRadius = radius
    }
  }
}

// color hex string
extension UIColor {
  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

