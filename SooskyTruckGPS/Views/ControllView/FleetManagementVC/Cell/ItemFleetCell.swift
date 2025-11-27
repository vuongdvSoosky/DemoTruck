//
//  ItemFleetCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 14/11/25.
//

import UIKit
import SnapKit

class ItemFleetCell: BaseCollectionViewCell {
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
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 16
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var titleRouteName: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "My Route"
    label.font = AppFont.font(.boldText, size: 17)
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .left
    return label
  }()
  
  private lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.text = "Apr 2,2025"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.mediumText, size: 15)
    label.textAlignment = .left
    return label
  }()
  
  private lazy var numberOfStop: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "3 intermediate stops"
    label.textColor = UIColor(rgb: 0xAFAEAE)
    label.font = AppFont.font(.regularText, size: 12)
    label.isHidden = true
    return label
  }()
  
  private lazy var departurePointTitle: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Departure Point"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.semiBoldText, size: 12)
    return label
  }()
  private lazy var departurePointValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 15)
    label.text = "742 Evergreen Terrace"
    return label
  }()
  private lazy var destinationTitle: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Destination"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.semiBoldText, size: 12)
    return label
  }()
  private lazy var destinationValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 15)
    label.text = "779 Evergreen Terrace"
    return label
  }()
  
  private lazy var iconTruck1: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTruck
    icon.contentMode = .scaleAspectFit
    return icon
  }()
  
  private lazy var iconTruck2: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTruck
    icon.contentMode = .scaleAspectFit
    return icon
  }()
  
  private lazy var departureStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 4
    [departurePointTitle, departurePointValue].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  private lazy var destinationStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 4
    [destinationTitle, destinationValue].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    
    [departureStackView, numberOfStop, destinationStackView].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  private lazy var lineView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x332644)
    return view
  }()
  
  private var deleteButtonWidth: CGFloat = 35
  private var isDeleteMode = false
  private var spacingBetweenDeleteAndContainer: CGFloat = 8
  var onDeleteTapped: (() -> Void)?
  var onDeleteModeChanged: ((Bool) -> Void)?
  var onChooseItemPlace: ((RouteResponseRealm) -> Void)?
  var itemPlace: RouteResponseRealm?
  
  override func addComponents() {
    self.contentView.addSubview(deleteButton)
    self.contentView.addSubviews(containerView)
    containerView.addSubviews(titleRouteName, dateLabel, lineView, iconTruck1, iconTruck2, numberOfStop, departureStackView, destinationStackView)
  }
  
  override func setColor() {
    containerView.addShadow()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    hideDeleteMode()
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(4)
    }
    
    deleteButton.snp.makeConstraints { make in
      make.top.equalTo(contentView).inset(5)
      make.bottom.equalTo(contentView).inset(10)
      make.trailing.equalTo(contentView).offset(-6)
      make.width.equalTo(deleteButtonWidth)
    }
    
    titleRouteName.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12)
      make.left.right.equalToSuperview().inset(12)
    }
    
    dateLabel.snp.makeConstraints { make in
      make.top.equalTo(titleRouteName.snp.bottom).inset(-4)
      make.left.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(12)
    }
    
    iconTruck1.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.bottom).inset(-12)
      make.left.equalToSuperview().inset(12)
      make.width.height.equalTo(36)
    }
    
    iconTruck2.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(12)
      make.left.equalToSuperview().inset(12)
      make.width.height.equalTo(36)
    }
    
    lineView.snp.makeConstraints { make in
      make.top.equalTo(iconTruck1.snp.bottom).inset(0)
      make.width.equalTo(2)
      make.centerX.equalTo(iconTruck1.snp.centerX)
      make.bottom.equalTo(iconTruck2.snp.top).inset(0)
    }
    
    departureStackView.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.bottom).inset(-12)
      make.left.equalTo(iconTruck1.snp.right).inset(-8)
      make.height.equalTo(36)
    }
    
    numberOfStop.snp.makeConstraints { make in
      make.top.equalTo(departureStackView.snp.bottom).inset(-12)
      make.left.equalTo(iconTruck1.snp.right).inset(-8)
      make.right.equalToSuperview().inset(8)
    }
    
    destinationStackView.snp.makeConstraints { make in
      make.top.equalTo(numberOfStop.snp.bottom).inset(-12)
      make.left.equalTo(iconTruck1.snp.right).inset(-8)
      make.height.equalTo(36)
      make.bottom.equalToSuperview().inset(12)
    }
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
  
  func hideDeleteModeCell() {
    if isDeleteMode {
      hideDeleteMode()
    }
  }
}

extension ItemFleetCell {
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
}

extension ItemFleetCell {
  func configData(with item: RouteResponseRealm) {
    self.itemPlace = item
    departurePointValue.text = item.places.first?.address
    titleRouteName.text = item.nameRouter ?? "My Route"
    destinationValue.text = item.places.last?.address
    dateLabel.text = item.createDate.asString(format: "MMM d, yyyy")
    
    if item.places.count < 3 {
      numberOfStop.isHidden = true
    } else {
      numberOfStop.isHidden = false
      numberOfStop.text = "\(item.places.count - 2) intermediate stops"
    }
  }
}
