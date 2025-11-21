//
//  ArrivedView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 18/11/25.
//

import UIKit
import SnapKit

class ArrivedView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xF3F3F3)
    view.cornerRadius = 24
    view.clipsToBounds = true
    return view
  }()
  private lazy var inforView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 12
    view.clipsToBounds = true
    
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.distribution = .fill
    
    [addressTitle, addressContent].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubviews(icon, stackView)
    
    icon.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(12)
      make.width.height.equalTo(32)
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(8)
      make.bottom.equalToSuperview().inset(8)
      make.left.equalTo(icon.snp.right).inset(-12)
      make.right.equalToSuperview()
    }
    
    return view
  }()
  private lazy var successView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 8
    view.clipsToBounds = true
    view.backgroundColor = UIColor(rgb: 0x299F46, alpha: 0.14)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSuccess)))
    
    let icon = UIImageView()
    icon.image = .icDoneArrived
    icon.contentMode = .scaleAspectFit
    
    let label = UILabel()
    label.text = "Success"
    label.textColor = UIColor(rgb: 0x299F46)
    label.font = AppFont.font(.semiBoldText, size: 15)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  private lazy var failedView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 8
    view.clipsToBounds = true
    view.backgroundColor = UIColor(rgb: 0xDC2E24, alpha: 0.14)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFailed)))
    
    let icon = UIImageView()
    icon.image = .icFailedArrived
    icon.contentMode = .scaleAspectFit
    
    let label = UILabel()
    label.text = "Failed"
    label.textColor = UIColor(rgb: 0xDC2E24)
    label.font = AppFont.font(.semiBoldText, size: 15)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  // MARK: - UIImageView
  private lazy var icon: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTruck
    icon.contentMode = .scaleAspectFit
    return icon
  }()
  
  // MARK: UIStackView
  private lazy var actionStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.distribution = .fillEqually
    
    [successView, failedView].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  // MARK: - UILabel
  private lazy var addressTitle: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.mediumText, size: 15)
    label.textColor = UIColor(rgb: 0x332644)
    label.text = "762 Evergreen Terrace"
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  private lazy var addressContent: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.lightText, size: 10)
    label.textColor = UIColor(rgb: 0x909090)
    label.text = "Springfield, IL 62704, USA"
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  private lazy var titleView: UILabel = {
    let label = UILabel()
    label.text = "Have you arrived?"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 21)
    return label
  }()
  
  private var Place: Place?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    self.dismissSlideView()
  }
  
  override func addComponents() {
    self.addSubview(containerView)
    containerView.addSubviews(titleView, inforView, actionStackView)
  }
  
  override func setProperties() {
    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(330)
      make.height.equalTo(199)
    }
    
    titleView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.left.right.equalToSuperview().inset(70)
    }
    
    inforView.snp.makeConstraints { make in
      make.top.equalTo(titleView.snp.bottom).inset(-20)
      make.left.equalToSuperview().inset(16)
      make.right.equalToSuperview().inset(16)
    }
    
    actionStackView.snp.makeConstraints { make in
      make.top.equalTo(inforView.snp.bottom).inset(-20)
      make.left.equalToSuperview().inset(16)
      make.right.equalToSuperview().inset(16)
      make.height.equalTo(48)
      make.bottom.equalToSuperview().inset(16)
    }
  }
  
  @objc private func onTapSuccess() {
    guard let Place = Place else {
      return
    }
    PlaceManager.shared.changStatePlace(with: Place, isSuccess: true)
  }
  
  @objc private func onTapFailed() {
    guard let Place = Place else {
      return
    }
    PlaceManager.shared.changStatePlace(with: Place, isSuccess: false)
  }
}

extension ArrivedView {
  func bindingData(Place: Place) {
    self.Place = Place
    addressTitle.text = Place.address
    addressContent.text = Place.fullAddres
  }
}
