//
//  Onboard1VC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 1/12/25.
//

import UIKit
import SnapKit

class Onboard1VC: BaseViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }()
  
  private lazy var icBackground: UIImageView = {
    let img = UIImageView()
    img.translatesAutoresizingMaskIntoConstraints = false
    img.image = .icBgOnboard1
    return img
  }()
  
  private lazy var titleVC: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Plan Smarter Routes For Your Truck"
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = UIColor(rgb: 0xFCFCFC)
    label.font = AppFont.font(.heavy, size: 28)
    return label
  }()
  
  private lazy var titleDesVC: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    let text = "Enter your stops and let AI find the fastest, safest route — designed for truck drivers"
    label.textColor = UIColor(rgb: 0x111111)
    label.font = AppFont.font(.regularText, size: 17)
    label.numberOfLines = 0
    label.text = text
    label.setLineSpacing()
    return label
  }()
  
  private lazy var continueView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let label = UILabel()
    label.text = "Continue"
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.font = AppFont.font(.boldText, size: 20)
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
    
  }()
  
  private let viewModel = OnboardVM()
  
  
  override func addComponents() {
    self.view.addSubviews(containerView)
    containerView.addSubviews(icBackground, titleVC, titleDesVC, continueView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    icBackground.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleVC.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(28)
      make.width.equalTo(344)
      make.centerX.equalToSuperview()
    }
    
    titleDesVC.snp.makeConstraints { make in
      make.top.equalTo(titleVC.snp.bottom).inset(-12)
      make.width.equalTo(330)
      make.centerX.equalToSuperview()
    }
    
    continueView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(63)
      make.height.equalTo(60)
    }
  }
  
  override func setProperties() {
    continueView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapContinue)))
  }
  
  override func setColor() {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      let color: [UIColor] = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      continueView.addArrayColorGradient(arrayColor: color, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
      continueView.cornerRadius = 20
      continueView.clipsToBounds = true
    }
  }
  
  @objc private func onTapContinue() {
    viewModel.action.send(.next)
  }
}
