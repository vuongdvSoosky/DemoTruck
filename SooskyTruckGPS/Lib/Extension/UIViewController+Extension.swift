//
//  UIViewController+Extension.swift
//  BaseSubscription
//
//  Created by Việt Nguyễn on 13/1/25.
//

import UIKit
import NVActivityIndicatorView

extension UIViewController {
  func showLoadingDotAds(backgroundColor: UIColor = .clear, textLoading: String? = nil) {
    let keyWindow = self.keyWindowAds ?? self.view
    
    if self.view.subviews.first(where: {$0.tag == -111}) != nil {
      return
    }
    let overLayView = UIView()
    overLayView.backgroundColor = backgroundColor
    overLayView.tag = -112
    overLayView.frame = keyWindow!.frame
    
    let dotView = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: UIColor(hex: "FFFFFF"))
    
    dotView.tag = -111
    self.view.addSubview(overLayView)
    overLayView.snp.makeConstraints { make in
      make.height.width.equalTo(120)
      make.center.equalToSuperview()
    }
    
    overLayView.backgroundColor = UIColor(hex: "A7B3DB").withAlphaComponent(0.6)
    overLayView.layer.cornerRadius = 10
    
    overLayView.addSubview(dotView)
    
    dotView.snp.makeConstraints { make in
      if let textLoading {
        make.top.equalToSuperview().offset(25)
        make.centerX.equalToSuperview()
      } else {
        make.center.equalToSuperview()
      }
      make.height.width.equalTo(45)
    }
    
    dotView.startAnimating()
    
    if let textLoading = textLoading {
      let label = UILabel()
      label.textColor = UIColor(hex: "FFFFFF")
      label.font = .systemFont(ofSize: 14)
      overLayView.addSubview(label)
      label.text = textLoading
      label.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalTo(dotView.snp.bottom).offset(10)
      }
    }
  }
  
  func hideLoadingDotAds() {
    self.view.subviews.first(where: {$0.tag == -111})?.removeFromSuperview()
    self.view.subviews.first(where: {$0.tag == -112})?.removeFromSuperview()
  }
  
  var keyWindowAds: UIWindow? {
    get {
      return UIApplication.shared.windows.first(where: {$0.isKeyWindow})
    }
  }
}

@nonobjc extension UIViewController {
  func add(_ child: UIViewController, frame: CGRect? = nil) {
    print("Container Frame: ", frame)
    addChild(child)
    
    if let frame = frame {
      child.view.frame = frame
    }
    
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }
  
  func remove() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
  
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension UIViewController {
  
  func showAlertError(message: String,
                      firstHandler: (() -> Void)? = nil) {
    showAlert(title: "Error",
              message: message,
              firstButton: "OK",
              firstHandler: firstHandler)
  }
  
  func showAlert(style: UIAlertController.Style = .alert,
                 title: String?,
                 message: String?,
                 firstButton: String = "OK",
                 firstHandler: (() -> Void)? = nil,
                 secondButton: String? = nil,
                 secondHandler: (() -> Void)? = nil) {
    DispatchQueue.main.async {
      let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: style)
      
      let firstAction = UIAlertAction(title: firstButton, style: .cancel) { _ in
        firstHandler?()
      }
      alertController.addAction(firstAction)
      
      if let secondButton = secondButton {
        let secondAction = UIAlertAction(title: secondButton, style: .default) { _ in
          secondHandler?()
        }
        alertController.addAction(secondAction)
        alertController.preferredAction = secondAction
      }
      
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  
  func showAlertLocation() {
    self.showAlert(
      title: "You have to enable Location permission to access this feature! ",
      message: "Please enable location services in your device settings for a more personalized experience.",
      firstButton: "Cancel",
      secondButton: "Go to Setting"
    ) {
      guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
        return
      }
      
      if UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl)
      }
    }
  }
}

extension UIViewController {
  func activityStartAnimating() {
    let backgroundView = UIView()
    backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    backgroundView.backgroundColor = .black.withAlphaComponent(0.7)
    backgroundView.tag = 475647
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
    activityIndicator.center = self.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = .large
    activityIndicator.color = .white
    activityIndicator.startAnimating()
    self.view.isUserInteractionEnabled = false
    
    backgroundView.addSubview(activityIndicator)
    
    self.view.addSubview(backgroundView)
  }
  
  func activityStopAnimating() {
      if let background = view.viewWithTag(475647){
          background.removeFromSuperview()
      }
      self.view.isUserInteractionEnabled = true
  }
}
