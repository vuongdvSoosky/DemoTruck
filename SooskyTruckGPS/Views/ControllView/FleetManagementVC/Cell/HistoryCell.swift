//
//  HistoryCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import UIKit
import SnapKit

class HistoryCell: BaseCollectionViewCell {
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
    view.cornerRadius = 12
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var routeName: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Highway Supply Chain Network"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 17)
    return label
  }()
  
  private lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Apr 2,2025"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.mediumText, size: 15)
    return label
  }()
  
  private lazy var iconDistance: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icDistanceHistoryCell
    icon.contentMode = .scaleAspectFill
    icon.snp.makeConstraints { make in
      make.width.height.equalTo(24)
    }
    return icon
  }()
  
  private lazy var iconTime: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icTimeHistoryCell
    return icon
  }()
  
  private lazy var distanceView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.alignment = .fill
    [iconDistance,distanceLabel].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    return view
  }()
  
  private lazy var timeView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.alignment = .fill
    [iconTime,timeLabel].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    return view
  }()
  
  private lazy var distanceLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "1000 mi"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 15)
    return label
  }()
  
  private lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "1h59m"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 15)
    return label
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
    containerView.addSubviews(routeName, dateLabel, distanceView, timeView)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    hideDeleteMode()
  }
  
  override func setColor() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.containerView.addShadow()
    }
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(4)
    }
    
    deleteButton.snp.makeConstraints { make in
      make.top.equalTo(contentView).inset(4)
      make.bottom.equalTo(contentView).inset(10)
      make.trailing.equalTo(contentView).offset(-4)
      make.width.equalTo(deleteButtonWidth)
    }
    
    routeName.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(12)
      make.left.right.equalToSuperview().inset(12)
    }
    
    dateLabel.snp.makeConstraints { make in
      make.top.equalTo(routeName.snp.bottom).inset(-8)
      make.left.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(-12)
    }
    
    distanceView.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.bottom).inset(-12)
      make.left.equalToSuperview().inset(12)
      make.bottom.equalToSuperview().inset(12)
    }
    
    timeView.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.bottom).inset(-12)
      make.left.equalTo(distanceView.snp.right).inset(-12)
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

extension HistoryCell {
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

extension HistoryCell {
  func configData(item: RouteResponseRealm) {
    self.itemPlace = item
    self.distanceLabel.text = "\(String(format: "%.2f", item.trackingRecords.first?.distanceRace ?? 0.0)) mi"
    self.routeName.text = item.nameRouter ?? "My Route"
    self.timeLabel.text = item.trackingRecords.first?.duration?.toHHMMSSString()
  }
}
