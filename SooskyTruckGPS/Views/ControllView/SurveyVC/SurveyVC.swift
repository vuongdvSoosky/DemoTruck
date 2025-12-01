//
//  SurveyVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 1/12/25.
//

import UIKit
import SnapKit

class SurveyVC: BaseViewController {
  private var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFF8EC)
    return view
  }()
  
  private lazy var bigTruckView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 20
    view.clipsToBounds = true
    view.borderColor = UIColor(rgb: 0xF26101)
//    view.borderWidth = 5
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
    icon.image = .icUnChooseTruck
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
    icTruck.contentMode = .scaleAspectFit
    
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
    label.text = "What Kind Of Truck Are You Driving?"
    label.textColor = UIColor(rgb: 0x332644)
    label.numberOfLines = 0
    label.font = AppFont.font(.heavy, size: 28)
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
  
  private let viewModel = OnboardVM()
  
  override func addComponents() {
    self.view.addSubviews(containerView)
    containerView.addSubviews(titleLabel, stackView, saveView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(34)
      make.left.right.equalToSuperview().inset(10)
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).inset(-71)
      make.left.right.equalToSuperview().inset(20)
      make.bottom.lessThanOrEqualTo(saveView.snp.top).inset(-10)
    }
    
    saveView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(24)
      make.height.equalTo(60)
    }
    
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
  
  override func setColor() {
    bigTruckView.addShadow()
    smallTruckView.addShadow()
  }
}

extension SurveyVC {
  @objc private func onTapBigTruckView() {
    changeStateBigTruckView()
    enableSaveView()
    
    TruckTypeManager.shared.setType(.big)
  }
  
  @objc private func onTapSmallTruckView() {
    changeStateSmallTruckView()
    enableSaveView()
    
    TruckTypeManager.shared.setType(.small)
  }
  
  @objc private func onTapSave() {
    viewModel.action.send(.iap)
    UserDefaultsManager.shared.set(TruckTypeManager.shared.truckTypes?.rawValue, key: .truckType)
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
  
  private func changeStateBigTruckView() {
    bigTruckView.borderWidth = 5
    icChooseBigTruck.image = .icChooseTruck
    
    smallTruckView.borderWidth = 0
    icChooseSmallTruck.image = .icUnChooseTruck
  }
  
  private func changeStateSmallTruckView() {
    smallTruckView.borderWidth = 5
    icChooseSmallTruck.image = .icChooseTruck
    
    bigTruckView.borderWidth = 0
    icChooseBigTruck.image = .icUnChooseTruck
  }
}
