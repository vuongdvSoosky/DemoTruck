//
//  ListLocationCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import UIKit
import SnapKit

class ListLocationCell: BaseCollectionViewCell {
  
  private let deleteButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .systemRed
    button.layer.cornerRadius = 12
    button.setImage(.icTrashButton, for: .normal)
    button.tintColor = .white
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var icon: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTruck
    icon.contentMode = .scaleAspectFit
    return icon
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
    view.backgroundColor = UIColor(rgb: 0xF2F2F2)
    view.cornerRadius = 12
    
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.distribution = .fillEqually
    
    [addressTitle, addressContent].forEach({stackView.addArrangedSubview($0)})
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().inset(8)
      make.right.equalToSuperview().inset(8)
      make.bottom.lessThanOrEqualToSuperview().inset(8)
    }
    return view
  }()
  
  private lazy var addressTitle: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.mediumText, size: 17)
    label.textColor = UIColor(rgb: 0x332644)
    label.text = "762 Evergreen Terrace"
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var addressContent: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.lightText, size: 12)
    label.textColor = UIColor(rgb: 0x332644)
    label.text = "762 Evergreen Terrace, Springfield, IL 62704, USA"
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private var deleteButtonWidth: CGFloat = 35
  private var isDeleteMode = false
  private var spacingBetweenDeleteAndContainer: CGFloat = 8
  
  var onDeleteTapped: (() -> Void)?
  var onDeleteModeChanged: ((Bool) -> Void)?
  var onChooseItemPlace: ((Place) -> Void)?
  var itemPlace: Place?
  
  override func addComponents() {
    self.contentView.addSubview(deleteButton)
    self.contentView.addSubview(containerView)
    self.containerView.addSubviews(icon, lineView , inforView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    deleteButton.snp.makeConstraints { make in
      make.top.equalTo(contentView)
      make.bottom.equalTo(contentView).inset(10)
      make.trailing.equalTo(contentView).offset(-3)
      make.width.equalTo(deleteButtonWidth)
    }
    
    icon.snp.makeConstraints { make in
      make.top.left.equalToSuperview()
      make.width.height.equalTo(32)
    }
    
    inforView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalTo(icon.snp.right).offset(8)
      make.right.equalToSuperview().offset(-3)
      make.bottom.equalToSuperview().inset(10)
    }
    
    lineView.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).inset(-2)
      make.centerX.equalTo(icon.snp.centerX)
      make.width.equalTo(3)
      make.bottom.equalToSuperview()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    hideDeleteMode()
  }
  
  override func setColor() {
    inforView.addShadow()
  }
  
  override func setProperties() {
    // Add left swipe gesture to show delete mode
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(_:)))
    leftSwipeGesture.direction = .left
    containerView.addGestureRecognizer(leftSwipeGesture)
    
    // Add right swipe gesture to hide delete mode
    let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(_:)))
    rightSwipeGesture.direction = .right
    containerView.addGestureRecognizer(rightSwipeGesture)
    
    // Add delete button action
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapChoosePlace)))
  }
  
  // MARK: - Gesture Handlers
  @objc private func handleLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
    if !isDeleteMode {
      showDeleteMode()
    }
  }
  
  @objc private func handleRightSwipe(_ gesture: UISwipeGestureRecognizer) {
    if isDeleteMode {
      hideDeleteMode()
    }
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    if isDeleteMode {
      hideDeleteMode()
    }
  }
  
  @objc private func deleteButtonTapped() {
    onDeleteTapped?()
  }
  
  @objc private func onTapChoosePlace() {
    guard let itemPlace = itemPlace else { return }
    onChooseItemPlace?(itemPlace)
  }
}

extension ListLocationCell {
  // MARK: - Private Methods
  private func showDeleteMode() {
    isDeleteMode = true
    onDeleteModeChanged?(true)
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
      let translationX = -(self.deleteButtonWidth + self.spacingBetweenDeleteAndContainer)
      self.containerView.transform = CGAffineTransform(translationX: translationX, y: 0)
    }
  }
  
  private func hideDeleteMode() {
    isDeleteMode = false
    onDeleteModeChanged?(false)
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
      self.containerView.transform = .identity
    }
  }
  
  // MARK: - Public Methods
  func hideDeleteModeCell() {
    if isDeleteMode {
      hideDeleteMode()
    }
  }
  
  func hideLineView() {
    lineView.isHidden = true
  }
  
  func showLineView () {
    lineView.isHidden = false
  }
}

extension ListLocationCell {
  func configData(_ place: Place) {
    self.itemPlace = place
    self.addressTitle.text = place.address
    self.addressContent.text = place.fullAddres
  }
  
  func configData(_ place: Place, itemRoute: RouteResponseRealm?) {
    self.itemPlace = place
    self.addressTitle.text = place.address
    self.addressContent.text = place.fullAddres
    
    guard let itemRoute = itemRoute, let state = place.state else {
      return
    }
    
    if itemRoute.history {
      icon.image = state ? .icFinish : .icFailedRoute
    }
  }
}
