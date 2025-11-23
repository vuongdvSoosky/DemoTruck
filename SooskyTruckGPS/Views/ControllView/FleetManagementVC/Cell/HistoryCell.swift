//
//  HistoryCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import UIKit
import SnapKit

class HistoryCell: BaseCollectionViewCell {
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
    label.text = "Apr,2025"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.mediumText, size: 15)
    return label
  }()
  
  private lazy var iconDistance: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icTotalDistance
    return icon
  }()
  
  private lazy var iconTime: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icTimeEstimate
    return icon
  }()
  
  private lazy var distanceView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.alignment = .center
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
  
  override func addComponents() {
    self.contentView.addSubviews(containerView)
    containerView.addSubviews(routeName, dateLabel, distanceView, timeView)
  }
  
  override func setColor() {
    containerView.addShadow()
  }
  
  override func setProperties() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(2)
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
  
  func configData(item: RouteResponseRealm) {
    self.distanceLabel.text = "\(String(format: "%.2f", item.trackingRecords.first?.distanceRace ?? 0.0)) mi"
    self.routeName.text = item.nameRouter ?? ""
    self.timeLabel.text = item.trackingRecords.first?.duration?.toTimeStringFromSeconds()
  }
}
