//
//  DetailRouteCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 14/11/25.
//

import UIKit
import SnapKit

class DetailRouteCell: BaseCollectionViewCell {
  
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
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
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
  
  private lazy var totalDistanceView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    let icon = UIImageView()
    icon.image = .icTotalDistance
    icon.contentMode = .scaleAspectFit
    
    view.addSubviews(icon, totalDistanceValue, totalDistanceTitle)
    
    icon.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.width.height.equalTo(28)
      make.left.equalToSuperview()
    }
    
    totalDistanceValue.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    
    totalDistanceTitle.snp.makeConstraints { make in
      make.top.equalTo(totalDistanceValue.snp.bottom).inset(-2)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    return view
  }()
  
  private lazy var timeEstimateView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let icon = UIImageView()
    icon.image = .icTimeEstimate
    icon.contentMode = .scaleAspectFit
    
    
    view.addSubviews(icon, totalTimeValue, totalTimeTitle)
    
    icon.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.width.height.equalTo(28)
      make.left.equalToSuperview()
    }
    
    totalTimeValue.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    
    totalTimeTitle.snp.makeConstraints { make in
      make.top.equalTo(totalTimeValue.snp.bottom).inset(-2)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    
    return view
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
  
  // MARK: - UILabel
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
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .fill
    let emtyView = UIView()
    
    [totalDistanceView, emtyView,timeEstimateView].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  private var deleteButtonWidth: CGFloat = 35
  private var isDeleteMode = false
  private var spacingBetweenDeleteAndContainer: CGFloat = 8
  
  var onDeleteTapped: (() -> Void)?
  var onDeleteModeChanged: ((Bool) -> Void)?
  var onChooseItemPlace: ((Place) -> Void)?
  var itemPlace: Place?
  
  override func addComponents() {
    self.contentView.addSubview(containerView)
    self.containerView.addSubviews(icon, lineView , inforView, stackView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    icon.snp.makeConstraints { make in
      make.top.left.equalToSuperview()
      make.width.height.equalTo(32)
    }
    
    inforView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalTo(icon.snp.right).offset(8)
      make.right.equalToSuperview().offset(-3)
    }
    
    lineView.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).inset(-2)
      make.centerX.equalTo(icon.snp.centerX)
      make.width.equalTo(3)
      make.bottom.equalToSuperview()
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(inforView.snp.bottom).inset(-16)
      make.left.equalTo(icon.snp.right).inset(-30)
      make.right.equalToSuperview().inset(22)
      make.height.equalTo(32)
    }
  }
  
  override func setColor() {
    inforView.addShadow()
  }
}

extension DetailRouteCell {
  func configData(_ place: Place) {
    self.itemPlace = place
    self.addressTitle.text = place.address
    self.addressContent.text = place.fullAddres
  }
}

extension DetailRouteCell {
  func hideStackView() {
    lineView.isHidden = true
    timeEstimateView.isHidden = true
    totalDistanceView.isHidden = true
  }
  
  func showLineView() {
    lineView.isHidden = false
    timeEstimateView.isHidden = false
    totalDistanceView.isHidden = false
  }
}
