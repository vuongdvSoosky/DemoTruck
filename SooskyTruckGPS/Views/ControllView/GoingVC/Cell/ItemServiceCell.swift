//
//  ItemServiceCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import UIKit
import SnapKit

class ItemServiceCell: BaseCollectionViewCell {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 12
    view.layer.masksToBounds = true
    return view
  }()
  
  private lazy var iconService: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.contentMode = .scaleAspectFit
    icon.image = .icGas
    return icon
  }()
  
  private lazy var titleService: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(rgb: 0x332644)
    label.text = "Gas Station"
    label.font = AppFont.font(.regularText, size: 12)
    return label
  }()
  
  override func addComponents() {
    self.contentView.addSubview(containerView)
    containerView.addSubviews(iconService, titleService)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(2)
    }
    
    iconService.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(4)
      make.left.equalToSuperview().inset(4)
    }
    
    titleService.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalTo(iconService.snp.right).inset(-8)
      make.right.equalToSuperview().inset(8)
    }
  }
  
  override func setColor() {
    self.containerView.backgroundColor = .white
    self.containerView.addShadow()
  }
}

extension ItemServiceCell {
  func binding(item: ServiceType) {
    self.titleService.text = item.title
    self.iconService.image = item.icon
  }
  
  func didSelectedItem(item: ServiceType) {
    self.containerView.backgroundColor = UIColor(rgb: 0xF26101)
    self.titleService.textColor = UIColor(rgb: 0xFFFFFF)
    self.titleService.font = AppFont.font(.mediumText, size: 12)
    self.iconService.image = item.iconSelected
  }
  
  func unSelectedItem(item: ServiceType) {
    self.containerView.backgroundColor = .white
    self.titleService.textColor = UIColor(rgb: 0x332644)
    self.titleService.font = AppFont.font(.mediumText, size: 12)
    self.iconService.image = item.icon
  }
}
