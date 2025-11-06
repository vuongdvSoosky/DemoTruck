//
//  UIViewExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
private var dimViewKey: UInt8 = 0

extension UIView {
  func nearestAncestor<T>(ofType type: T.Type) -> T? {
    if let view = self as? T {
      return view
    }
    return superview?.nearestAncestor(ofType: type)
  }
  
  class func loadNib() -> Self {
    return Bundle.main.loadNibNamed(String(describing: Self.className), owner: nil)?.first as! Self
  }
  
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
  
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.cancelsTouchesInView = false
    addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    endEditing(true)
  }
}

@IBDesignable extension UIView {
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    } set {
      layer.cornerRadius = newValue
    }
  }
  
  @IBInspectable var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    } set {
      layer.shadowRadius = newValue
    }
  }
  
  @IBInspectable var shadowOpacity: CGFloat {
    get {
      return CGFloat(layer.shadowOpacity)
    } set {
      layer.shadowOpacity = Float(newValue / 100)
    }
  }
  
  @IBInspectable var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    } set {
      layer.shadowOffset = newValue
    }
  }
  
  @IBInspectable var shadowColor: UIColor? {
    get {
      guard let cgColor = layer.shadowColor else {
        return nil
      }
      return UIColor(cgColor: cgColor)
    } set {
      layer.shadowColor = newValue?.cgColor
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      guard let cgColor = layer.borderColor else {
        return nil
      }
      return UIColor(cgColor: cgColor)
    } set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    } set {
      layer.borderWidth = newValue
    }
  }
}

extension UIView {
  func loadNibNamed() {
    Bundle.main.loadNibNamed(String(describing: Self.className), owner: self)
  }
  
  func addDashedBorder(lineDashPattern: [NSNumber], color: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat) {
    let shapeLayer = CAShapeLayer()
    let frameSize = frame.size
    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
    
    shapeLayer.bounds = shapeRect
    shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = borderWidth
    shapeLayer.lineJoin = CAShapeLayerLineJoin.round
    shapeLayer.lineDashPattern = lineDashPattern
    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
    
    layer.addSublayer(shapeLayer)
  }
}

extension UIView {
  private func standardizeRect(_ rect: CGRect) -> CGRect {
    return CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
  }
  
  var left: CGFloat {
    get {
      return frame.minX
    }
    set(left) {
      var frame = standardizeRect(self.frame)
      
      frame.origin.x = left
      self.frame = frame
    }
  }
  
  var top: CGFloat {
    get {
      return frame.minY
    }
    set(top) {
      var frame = standardizeRect(self.frame)
      
      frame.origin.y = top
      self.frame = frame
    }
  }
  
  var right: CGFloat {
    get {
      return frame.maxX
    }
    set(right) {
      var frame = standardizeRect(self.frame)
      
      frame.origin.x = right - frame.size.width
      self.frame = frame
    }
  }
  
  var bottom: CGFloat {
    get {
      return frame.maxY
    }
    set(bottom) {
      var frame = standardizeRect(self.frame)
      
      frame.origin.y = bottom - frame.size.height
      self.frame = frame
    }
  }
  
  var width: CGFloat {
    get {
      return frame.width
    }
    set(width) {
      var frame = standardizeRect(self.frame)
      
      frame.size.width = width
      self.frame = frame
    }
  }
  
  var height: CGFloat {
    get {
      return frame.height
    }
    set(height) {
      var frame = standardizeRect(self.frame)
      
      frame.size.height = height
      self.frame = frame
    }
  }
  
  var centerX: CGFloat {
    get {
      return frame.midX
    }
    set(centerX) {
      center = CGPoint(x: centerX, y: center.y)
    }
  }
  
  var centerY: CGFloat {
    get {
      return center.y
    }
    set(centerY) {
      center = CGPoint(x: center.x, y: centerY)
    }
  }
  
  var size: CGSize {
    get {
      return standardizeRect(frame).size
    }
    set(size) {
      var frame = standardizeRect(self.frame)
      
      frame.size = size
      self.frame = frame
    }
  }
}

extension UIView {
  func showView(view: UIView) {
    self.frame = view.bounds
    view.addSubview(self)
  }
}

extension UIView {
  func findViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let nextResponder = responder?.next {
      if let viewController = nextResponder as? UIViewController {
        return viewController
      }
      responder = nextResponder
    }
    return nil
  }
}

extension UIView {
  func showToast(message: String, duration: Double = 2.0, completion: (() -> Void)? = nil) {
    // Tạo label để hiển thị thông báo
    let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width / 2, height: 50))
    toastLabel.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 100)
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font = UIFont.systemFont(ofSize: 14)
    toastLabel.text = message
    toastLabel.alpha = 0.0
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    
    self.addSubview(toastLabel)
    
    // Hiển thị với hiệu ứng fade-in và fade-out
    UIView.animate(withDuration: 0.5, animations: {
      toastLabel.alpha = 1.0
    }) { _ in
      UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
      }) { _ in
        toastLabel.removeFromSuperview()
        completion?()
      }
    }
  }
}

extension UIView {
  func addShadow(
    color: UIColor = UIColor(rgb: 0x7A7A7A),
    opacity: Float = 0.2,
    offset: CGSize = CGSize(width: 0, height: 2),
    radius: CGFloat = 6,
    cornerRadius: CGFloat = 0
  ) {
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offset
    layer.shadowRadius = radius
    layer.masksToBounds = false
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
  }
  
  func addCornerRadius(radius: CGFloat) {
    layer.cornerRadius = radius
  }
  
  func applyCardShadow(radius: CGFloat = 16) {
    self.layer.cornerRadius = radius
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.1
    self.layer.shadowOffset = CGSize(width: 0, height: 4)
    self.layer.shadowRadius = 8
    self.layer.masksToBounds = false
    self.backgroundColor = .white
  }
  
  func addShadowMiniPlayer(corner: CGFloat = 14,
                           color: UIColor = .black,
                           opacity: Float = 0.25,
                           offset: CGSize = CGSize(width: 0, height: 2),
                           radius: CGFloat = 12) {
    self.clipsToBounds = false
    layer.cornerRadius = corner
    
    layer.masksToBounds = false
    layer.shadowOffset = offset
    layer.shadowColor = color.cgColor
    layer.shadowRadius = radius
    layer.shadowOpacity = opacity
  }
  
  func addArrayColorGradient(arrayColor: [UIColor], startPoint: CGPoint, endPoint: CGPoint, cornerRadius: CGFloat = 0, locations: [NSNumber]? = nil) {
    //self.backgroundColor = .clear
    let gradient: CAGradientLayer = CAGradientLayer()
    let covertArrayCGColor = arrayColor.map( { $0.cgColor } )
    gradient.colors = covertArrayCGColor
    gradient.startPoint = startPoint
    gradient.endPoint = endPoint
    gradient.frame = self.bounds
    gradient.cornerRadius = cornerRadius
    self.layer.insertSublayer(gradient, at: 0)
  }
}

extension UIView {
  
  // MARK: - Associated dimView property
  private var dimView: UIView? {
    get {
      return objc_getAssociatedObject(self, &dimViewKey) as? UIView
    }
    set {
      objc_setAssociatedObject(self, &dimViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  // MARK: - Show slide view with dim background
  func showSlideView(view: UIView) {
    self.frame = view.bounds
    
    // Dim background nằm ngoài self
    let dim = UIView(frame: view.bounds)
    dim.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.6)
    dim.alpha = 0.1
    
    // Lưu dimView bằng associated object
    self.dimView = dim
    
    view.addSubview(dim)
    view.addSubview(self)
    
    // Khởi đầu ở dưới màn hình
    self.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
    self.alpha = 0
    
    UIView.animate(withDuration: 0.6,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0.5,
                   options: [.curveEaseOut],
                   animations: {
      self.transform = .identity
      self.alpha = 1
      dim.alpha = 1
    })
  }
  
  // MARK: - Dismiss slide view and remove dim background
  func dismissSlideView() {
    UIView.animate(withDuration: 0.3, animations: {
      self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
      self.alpha = 0
      self.dimView?.alpha = 0
    }) { _ in
      self.dimView?.removeFromSuperview()
      self.removeFromSuperview()
      self.dimView = nil
    }
  }
}
extension UIView {
  func currentFirstResponder() -> UIView? {
    if self.isFirstResponder {
      return self
    }
    for subview in self.subviews {
      if let responder = subview.currentFirstResponder() {
        return responder
      }
    }
    return nil
  }
}
