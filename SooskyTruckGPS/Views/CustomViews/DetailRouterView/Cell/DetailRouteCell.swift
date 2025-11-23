//
//  DetailRouteCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 14/11/25.
//

import UIKit
import SnapKit

class DetailRouteCell: BaseCollectionViewCell {
  
  // MARK: - UIView
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  private lazy var lineView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x332644)
    view.cornerRadius = 4
    return view
  }()
  private lazy var inforView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 12
    view.borderColor = UIColor(rgb: 0xC4C4C4, alpha: 0.25)
    view.borderWidth = 0.5
    
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.distribution = .fillEqually
        
    [addressTitle, addressContent].forEach({stackView.addArrangedSubview($0)})
    
    let stateStackView = UIStackView()
    stateStackView.addArrangedSubview(stateView)
    
    let mainStackView = UIStackView()
    mainStackView.axis = .vertical
    mainStackView.spacing = 4
    mainStackView.distribution = .fill
    mainStackView.alignment = .leading
    
    [stateStackView, stackView].forEach({mainStackView.addArrangedSubview($0)})
    
    view.addSubviews(mainStackView)
    
    mainStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12)
      make.left.equalToSuperview().inset(8)
      make.right.equalToSuperview().inset(8)
      make.bottom.lessThanOrEqualToSuperview().inset(12)
    }
    return view
  }()
  private lazy var stateView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 8
    view.backgroundColor = UIColor(rgb: 0xE1F1E5)
    view.isHidden = true
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 6
    
    [iconState, stateLabel].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(5)
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
  private lazy var iconState: UIImageView = {
    let icon = UIImageView()
    icon.image = .icSuccess
    icon.contentMode = .scaleAspectFit
    return icon
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
    label.textColor = UIColor(rgb: 0x332644)
    label.text = "762 Evergreen Terrace, Springfield, IL 62704, USA"
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  private lazy var totalTimeValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "1h59m"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 17)
    return label
  }()
  private lazy var totalTimeTitle: UILabel = {
    let label = UILabel()
    label.text = "Duration"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.regularText, size: 12)
    return label
  }()
  private lazy var totalDistanceValue: UILabel = {
    let label = UILabel()
    label.text = "5000"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 17)
    return label
  }()
  private lazy var totalDistanceTitle: UILabel = {
    let label = UILabel()
    label.text = "Distance(mi)"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.regularText, size: 12)
    return label
  }()
  private lazy var stateLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Success"
    label.font = AppFont.font(.regularText, size: 10)
    label.textColor = UIColor(rgb: 0x299F46)
    return label
  }()
  
  // MARK: - UIStackView

  private var deleteButtonWidth: CGFloat = 35
  private var isDeleteMode = false
  private var spacingBetweenDeleteAndContainer: CGFloat = 8
  
  var onDeleteTapped: (() -> Void)?
  var onDeleteModeChanged: ((Bool) -> Void)?
  var onChooseItemPlace: ((Place) -> Void)?
  var itemPlace: Place?
  
  override func addComponents() {
    self.contentView.addSubview(containerView)
    self.containerView.addSubviews(icon, lineView , inforView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(4)
      make.left.right.bottom.equalToSuperview()
    }
    
    icon.snp.makeConstraints { make in
      make.top.left.equalToSuperview()
      make.width.height.equalTo(32)
    }
    
    inforView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalTo(icon.snp.right).offset(8)
      make.right.equalToSuperview().offset(-8)
      make.bottom.equalTo(8)
    }
    
    lineView.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).inset(-2)
      make.centerX.equalTo(icon.snp.centerX)
      make.width.equalTo(3)
      make.bottom.equalToSuperview().inset(-10)
    }
  }
  
  override func setProperties() {
    containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapChooseItem)))
  }
  
  override func setColor() {
    inforView.addShadow()
  }
  
  @objc private func onTapChooseItem() {
    guard let Place = itemPlace else {
      return
    }
    onChooseItemPlace?(Place)
  }
}

extension DetailRouteCell {
  func configData(_ Place: Place) {
    self.itemPlace = Place
    self.addressTitle.text = Place.address
    self.addressContent.text = Place.fullAddres
    
    guard let state = Place.state else {
      return
    }
    stateLabel.text = state ? "Success" : "Failed"
    stateLabel.textColor = state ? UIColor(rgb: 0x299F46) : UIColor(rgb: 0xDC2E24)
    stateView.backgroundColor = state ? UIColor(rgb: 0xE1F1E5) :  UIColor(rgb: 0xDC2E24, alpha: 0.14)
    iconState.image = state ? .icSuccess : .icFailed
    addressTitle.textColor = UIColor(rgb: 0xBDBDBD)
    addressContent.textColor = UIColor(rgb: 0xBDBDBD)
  }
}

extension DetailRouteCell {
  func hideStackView() {
    lineView.isHidden = true
  }
  
  func showLineView() {
    lineView.isHidden = false
  }
}

extension DetailRouteCell {
  func hideStateView() {
    stateView.isHidden = true
  }
  
  func showStateView() {
    stateView.isHidden = false
  }
}
