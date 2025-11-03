//
//  UIView+Extension.swift
//  BaseSubscription
//
//  Created by Việt Nguyễn on 13/1/25.
//
import UIKit

// them nhieu view con cho view cha
extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

// xoa tat ca sub view
extension UIView {
    /// Remove all subview
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// Remove all subview with specific type
    func removeAllSubviews<T: UIView>(type: T.Type) {
        subviews
            .filter { $0.isMember(of: type) }
            .forEach { $0.removeFromSuperview() }
    }
}

extension UIView {
  func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
    guard let rating = starRating?.doubleValue else {
      return nil
    }
    if rating >= 5 {
      return UIImage(named: "stars_5.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
    } else if rating >= 4.5 {
      return UIImage(named: "stars_4_5.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
    } else if rating >= 4 {
      return UIImage(named: "stars_4.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
    } else if rating >= 3.5 {
      return UIImage(named: "stars_3_5.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
    } else {
      return nil
    }
  }
  
  enum GradientDirection {
    case left, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft
    
    var point: CGPoint {
      switch self {
      case .left:
        return .init(x: 0, y: 0.5)
      case .topLeft:
        return .init(x: 0, y: 0)
      case .top:
        return .init(x: 0.5, y: 0)
      case .topRight:
        return .init(x: 1, y: 0)
      case .right:
        return .init(x: 1, y: 0.5)
      case .bottomRight:
        return .init(x: 1, y: 1)
      case .bottom:
        return .init(x: 0.5, y: 1)
      case .bottomLeft:
        return .init(x: 0, y: 1)
      }
    }
  }
  
  func setGradient(
    startColor: UIColor = UIColor(hex: "E2465C"),
    endColor: UIColor = UIColor(hex: "FFC370"),
    cornerRadius: CGFloat = 0,
    startPoint: GradientDirection = .left,
    endPoint: GradientDirection = .right
  ) {
    let gradient = CAGradientLayer()
    gradient.colors = [startColor.cgColor, endColor.cgColor]
    gradient.startPoint = startPoint.point
    gradient.endPoint = endPoint.point
    gradient.frame = bounds
    gradient.cornerRadius = cornerRadius
    layer.insertSublayer(gradient, at: 0)
    layer.cornerRadius = cornerRadius
  }
  
  func setRoundCorners(
    corners: UIRectCorner,
    radius: CGFloat
  ) {
    if corners == .allCorners {
      layer.cornerRadius = radius
    } else {
      layer.cornerRadius = radius
      var cornerMask = CACornerMask()
      if corners.contains(.topLeft) {
        cornerMask.insert(.layerMinXMinYCorner)
      }
      if corners.contains(.topRight) {
        cornerMask.insert(.layerMaxXMinYCorner)
      }
      if corners.contains(.bottomLeft) {
        cornerMask.insert(.layerMinXMaxYCorner)
      }
      if corners.contains(.bottomRight) {
        cornerMask.insert(.layerMaxXMaxYCorner)
      }
      layer.maskedCorners = cornerMask
      clipsToBounds = true
    }
    
  }
  
  func setBorders(color: UIColor, width: CGFloat) {
    layer.borderColor = color.cgColor
    layer.borderWidth = width
  }
  
  func setShadow(radius: CGFloat,
                 opacity: Float,
                 offset: CGSize,
                 color: UIColor = .black) {
    layer.shadowRadius = radius
    layer.shadowOpacity = opacity
    layer.shadowOffset = offset
    layer.shadowColor = color.cgColor
  }
  
  func showLoading() {
    if self.subviews.first(where: {$0.tag  == -1111}) != nil {
      return
    }
    let overLayView = UIView()
    overLayView.backgroundColor = backgroundColor
    overLayView.tag = -1112
    overLayView.frame = self.frame
    
    let dotView = UIActivityIndicatorView()
    dotView.tag = -1111
    self.addSubview(overLayView)
    overLayView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    overLayView.addSubview(dotView)
    dotView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    dotView.startAnimating()
  }
  
  func hideLoading() {
    self.subviews.first(where: {$0.tag == -1111})?.removeFromSuperview()
    self.subviews.first(where: {$0.tag == -1112})?.removeFromSuperview()
  }
  
  
//  func addSubviews(_ views: UIView...) {
//    for view in views {
//      addSubview(view)
//    }
//  }
}
