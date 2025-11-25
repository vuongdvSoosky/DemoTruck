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
    
    // MARK: - State stack
    let stateStackView = UIStackView()
    stateStackView.axis = .horizontal
    stateStackView.spacing = 4
    stateStackView.distribution = .fill
    stateStackView.alignment = .center
    
    stateView.setContentHuggingPriority(.required, for: .horizontal)
    stateView.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    stateStackView.addArrangedSubview(stateView)
    stateStackView.addArrangedSubview(emtyView)
    
    // MARK: - Horizontal stack (label + spacer)
    let horizontalStackView = UIStackView()
    horizontalStackView.axis = .horizontal
    horizontalStackView.spacing = 4
    horizontalStackView.distribution = .fill
    horizontalStackView.alignment = .center
    
    labelView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    labelView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    
    let spacerView = UIView()
    spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    horizontalStackView.addArrangedSubview(labelView)
    
    // MARK: - Main vertical stack
    let mainStackView = UIStackView()
    mainStackView.axis = .vertical
    mainStackView.spacing = 4
    mainStackView.distribution = .fill
    mainStackView.alignment = .fill
    
    [stateStackView, horizontalStackView].forEach { mainStackView.addArrangedSubview($0) }
    
    view.addSubview(mainStackView)
    
    mainStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(4)
    }
    
    return view
  }()
  
  private lazy var emtyView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.backgroundColor = .black
    return view
  }()
  
  private lazy var stateView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 8
    view.backgroundColor = UIColor(rgb: 0xE1F1E5)
    view.isHidden = true
    
    // Ưu tiên trạng thái giữ kích thước theo content
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.distribution = .fill
    stackView.alignment = .center
    
    iconState.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    iconState.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    stateLabel.setContentHuggingPriority(.required, for: .horizontal)
    stateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    [iconState, stateLabel].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(5)
    }
    
    return view
  }()
  
  private lazy var labelView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    // Vertical stack for title and content
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.alignment = .fill
    stackView.distribution = .fill
    
    // Title: ưu tiên thấp hơn content
    addressTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
    addressTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    addressContent.numberOfLines = 0
    addressContent.setContentHuggingPriority(.required, for: .horizontal)
    addressContent.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    [addressTitle, addressContent].forEach { stackView.addArrangedSubview($0) }
    
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
    icon.snp.makeConstraints { make in
      make.width.equalTo(12)
    }
    return icon
  }()
  
  // MARK: - UILabel
  private lazy var addressTitle: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.mediumText, size: 17)
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .left
    return label
  }()
  private lazy var addressContent: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.lightText, size: 15)
    label.textColor = UIColor(rgb: 0x909090)
    label.textAlignment = .left
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
    self.containerView.addSubviews(icon, lineView, inforView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(4)
      make.left.right.bottom.equalToSuperview()
    }
    
    icon.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().inset(12)
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
  func configData(_ place: Place) {
    self.itemPlace = place
    self.addressTitle.text = place.address
    self.addressContent.text = place.fullAddres
    LogManager.show(place.address)
    LogManager.show(place.fullAddres)
    hideStateView()
    
    guard let state = place.state else {
      return
    }
    stateLabel.text = state ? "Success" : "Failed"
    stateLabel.textColor = state ? UIColor(rgb: 0x299F46) : UIColor(rgb: 0xDC2E24)
    stateView.backgroundColor = state ? UIColor(rgb: 0xE1F1E5) :  UIColor(rgb: 0xDC2E24, alpha: 0.14)
    iconState.image = state ? .icSuccess : .icFailed
    addressTitle.textColor = UIColor(rgb: 0xBDBDBD)
    addressContent.textColor = UIColor(rgb: 0xBDBDBD)
  }
  
  func configData(_ place: Place, itemRoute: RouteResponseRealm?) {
    self.itemPlace = place
    self.addressTitle.text = place.address
    self.addressContent.text = place.fullAddres
    
    guard let state = place.state else {
      hideStateView()
      return
    }
    
    stateLabel.text = state ? "Success" : "Failed"
    stateLabel.textColor = state ? UIColor(rgb: 0x299F46) : UIColor(rgb: 0xDC2E24)
    stateView.backgroundColor = state ? UIColor(rgb: 0xE1F1E5) :  UIColor(rgb: 0xDC2E24, alpha: 0.14)
    iconState.image = state ? .icSuccess : .icFailed
    addressTitle.textColor = UIColor(rgb: 0xBDBDBD)
    addressContent.textColor = UIColor(rgb: 0xBDBDBD)
    stateView.isHidden = false
    
    
    guard let itemRoute = itemRoute, let state = place.state else {
      return
    }
    
    if itemRoute.history {
      icon.image = state ? .icFinish : .icFailedRoute
    }
  }
}

extension DetailRouteCell {
  func hideLineView() {
    lineView.isHidden = true
  }
  
  func showLineView() {
    lineView.isHidden = false
  }
}

extension DetailRouteCell {
  func hideStateView() {
    stateView.isHidden = true
    emtyView.isHidden = true
  }
  
  func showStateView() {
    stateView.isHidden = false
    emtyView.isHidden = false
  }
}

