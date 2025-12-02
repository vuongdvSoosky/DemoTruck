//
//  TutorialArriedView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 2/12/25.
//

import UIKit
import SnapKit

class TutorialArriedView: BaseView {
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }()
  
  private lazy var mainContentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xF3F3F3)
    view.cornerRadius = 28
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var imageView: UIImageView = {
    let img = UIImageView()
    img.translatesAutoresizingMaskIntoConstraints = false
    img.contentMode = .scaleAspectFill
    img.image = .icTutorialArried
    return img
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = AppFont.font(.boldText, size: 21)
    label.textColor = UIColor(rgb: 0xF26101)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.text = "Stop’s status"
    return label
  }()
  
  private lazy var desLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.setAttributedText(
        "You can change a stop’s status by tapping its pin on the map and also from the view list by selecting the stop there",
        boldParts: ["pin on the map", "view list"],
        normalFont: AppFont.font(.regularText, size: 17),
        boldFont: AppFont.font(.boldText, size: 17),
        textColor: UIColor(rgb: 0x222222)
    )
    return label
  }()
  
  private lazy var confirmView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 8
    view.backgroundColor = UIColor(rgb: 0xF26101)
    let label = UILabel()
    label.text = "Okay"
    label.font = AppFont.font(.boldText, size: 17)
    label.textColor = UIColor(rgb: 0xFFFFFF)
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  
  var handlerAction: Handler?
  
  override func addComponents() {
    addSubviews(containerView, mainContentView)
    mainContentView.addSubviews(imageView, titleLabel, desLabel, confirmView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    mainContentView.snp.makeConstraints { make in
      make.width.equalTo(330)
      make.height.equalTo(443)
      make.centerX.centerY.equalToSuperview()
    }
    
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.left.right.equalToSuperview().inset(18)
      make.height.equalTo(189)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).inset(-10)
      make.left.right.equalToSuperview().inset(16)
    }
    
    desLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).inset(-8)
      make.left.right.equalToSuperview().inset(16)
    }
    
    confirmView.snp.makeConstraints { make in
      make.top.equalTo(desLabel.snp.bottom).inset(-15)
      make.height.equalTo(48)
      make.left.right.bottom.equalToSuperview().inset(16)
    }
  }
  
  override func setProperties() {
    confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ontapConfirmView)))
  }

  override func setColor() {
    imageView.addShadow()
  }
  
  @objc private func ontapConfirmView() {
    handlerAction?()
    UserDefaultsManager.shared.set(true, key: .tutorialGoing)
    self.dismissSlideView()
    
  }
}
