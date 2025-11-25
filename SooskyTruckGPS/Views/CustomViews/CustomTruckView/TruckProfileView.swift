//
//  CustomTruckView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 24/11/25.
//

import UIKit
import SnapKit

class TruckProfileView: BaseView {
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xF2F2F2)
    view.cornerRadius = 20
    return view
  }()
  
  private lazy var iconTutorialTruckProfile: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTruckProfileView
    icon.contentMode = .scaleAspectFit
    return icon
  }()
  
  private lazy var iconClose: UIImageView = {
    let icon = UIImageView()
    icon.image = .icClose
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapClose)))
    return icon
  }()
  
  private lazy var bigTruckView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 20
    view.clipsToBounds = true
    view.borderColor = UIColor(rgb: 0xF26101)
    view.borderWidth = 5
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBigTruckView)))
    
    let icTruck = UIImageView()
    icTruck.image = .icBigTruck
    
    let label = UILabel()
    label.text = "Big Truck"
    label.textAlignment = .center
    label.font = AppFont.font(.boldText, size: 19)
    label.textColor = UIColor(rgb: 0xF26101)
    
    view.addSubviews(icChooseBigTruck, icTruck, label)
    
    icChooseBigTruck.snp.makeConstraints { make in
      make.top.right.equalToSuperview().inset(15)
      make.width.height.equalTo(19)
    }
    
    icTruck.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(27)
      make.width.equalTo(184)
      make.height.equalTo(88)
      make.centerX.equalToSuperview()
    }
    
    label.snp.makeConstraints { make in
      make.top.equalTo(icTruck.snp.bottom).inset(-12)
      make.left.right.equalToSuperview().inset(12)
    }
    
    return view
  }()
  
  private lazy var icChooseBigTruck: UIImageView = {
    let icon = UIImageView()
    icon.image = .icChooseTruck
    return icon
  }()
  
  private lazy var icChooseSmallTruck: UIImageView = {
    let icon = UIImageView()
    icon.image = .icUnChooseTruck
    return icon
  }()
  
  private lazy var smallTruckView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.borderColor = UIColor(rgb: 0xF26101)
    view.cornerRadius = 20
    view.clipsToBounds = true
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSmallTruckView)))
    
    let icTruck = UIImageView()
    icTruck.image = .icSmallTruck
    
    let label = UILabel()
    label.text = "Small Truck"
    label.textAlignment = .center
    label.font = AppFont.font(.boldText, size: 19)
    label.textColor = UIColor(rgb: 0xF26101)
    
    view.addSubviews(icChooseSmallTruck, icTruck, label)
    
    icChooseSmallTruck.snp.makeConstraints { make in
      make.top.right.equalToSuperview().inset(15)
      make.width.height.equalTo(19)
    }
    
    icTruck.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(27)
      make.width.equalTo(184)
      make.height.equalTo(88)
      make.centerX.equalToSuperview()
    }
    
    label.snp.makeConstraints { make in
      make.top.equalTo(icTruck.snp.bottom).inset(-12)
      make.left.right.equalToSuperview().inset(12)
    }
    return view
  }()
  
  private lazy var stackView: UIStackView = {
    let st = UIStackView(arrangedSubviews: [bigTruckView, smallTruckView, saveView])
    st.axis = .vertical
    st.spacing = 24
    st.alignment = .fill
    st.distribution = .fill
    return st
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Customize Your Truck Route"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.bold, size: 20)
    label.textAlignment = .center
    
    return label
  }()
  
  private lazy var saveView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x909090)
    view.cornerRadius = 20
    view.isUserInteractionEnabled = false
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSave)))
    
    view.snp.makeConstraints { make in
      make.height.equalTo(60)
    }
    
    let label = UILabel()
    label.text = "Save"
    label.font = AppFont.font(.bold, size: 20)
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.textAlignment = .center
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  
  var handler: Handler?
  
  override func addComponents() {
    addSubviews(containerView,iconTutorialTruckProfile)
    containerView.addSubviews(titleLabel, iconClose, stackView)
  }
  
  override func setProperties() {
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) {
      iconTutorialTruckProfile.isHidden = true
    }
  }
  
  override func setConstraints() {
    iconTutorialTruckProfile.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
    }
    
    containerView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(iconTutorialTruckProfile.snp.bottom).offset(20)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32)
      make.left.right.equalToSuperview().inset(53)
      make.height.equalTo(24)
    }
    
    iconClose.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.right.equalToSuperview().inset(10)
      make.width.height.equalTo(18)
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).inset(-24)
      make.left.right.bottom.equalToSuperview().inset(20)
    }
    
    // Tỉ lệ width : height = 350 : 178
    let width: CGFloat = 350
    let height: CGFloat = 178
    let ratio = height / width
    
    bigTruckView.snp.makeConstraints { make in
      make.width.equalTo(width)
      make.height.equalTo(bigTruckView.snp.width).multipliedBy(ratio)
    }
    
    smallTruckView.snp.makeConstraints { make in
      make.width.equalTo(width)
      make.height.equalTo(smallTruckView.snp.width).multipliedBy(ratio)
    }
  }
  
  @objc private func onTapClose() {
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
      handler?()
    }
    self.dismissSlideView()
  }
  
  @objc private func onTapBigTruckView() {
    bigTruckView.borderWidth = 5
    icChooseBigTruck.image = .icChooseTruck
    enableSaveView()
    
    smallTruckView.borderWidth = 0
    icChooseSmallTruck.image = .icUnChooseTruck
  }
  
  @objc private func onTapSmallTruckView() {
    smallTruckView.borderWidth = 5
    icChooseSmallTruck.image = .icChooseTruck
    enableSaveView()
    
    bigTruckView.borderWidth = 0
    icChooseBigTruck.image = .icUnChooseTruck
  }
  
  @objc private func onTapSave() {
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
      handler?()
    }
    self.dismissSlideView()
  }
  
  private func enableSaveView() {
    DispatchQueue.main.async {
      let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      self.saveView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
      self.saveView.isUserInteractionEnabled = true
      self.saveView.cornerRadius = 12
      self.saveView.clipsToBounds = true
    }
  }
}
