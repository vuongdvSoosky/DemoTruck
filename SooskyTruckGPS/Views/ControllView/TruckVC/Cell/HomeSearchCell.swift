//
//  HomeSearchCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 20/11/25.
//

import UIKit
import SnapKit
import MapKit

class HomeSearchCell: BaseTableViewCell {
  
  let titleSearchLbl = UILabel(),
      descriptionSearchLbl = UILabel()
  
  private lazy var iconTruck: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icTruck
    return icon
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding: CGFloat = 20
    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding))
  }
  
  override func setColor() {
    contentView.backgroundColor = .clear
    
    titleSearchLbl.textColor = UIColor(rgb: 0x332644)
    titleSearchLbl.font = AppFont.font(.boldText, size: 16)
    
    descriptionSearchLbl.textColor = UIColor(rgb: 0x909090)
    descriptionSearchLbl.font = AppFont.font(.lightText, size: 14)
  }
  
  override func addComponents() {
    contentView.addSubviews(iconTruck, titleSearchLbl, descriptionSearchLbl)
  }
  
  override func setConstraints() {
    iconTruck.snp.makeConstraints { make in
      make.width.height.equalTo(28)
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(0)
    }
    
    titleSearchLbl.snp.makeConstraints { make in
      make.left.equalTo(iconTruck.snp.right).offset(8)
      make.top.equalToSuperview().offset(12)
      make.right.equalToSuperview().offset(-8)
    }
    
    descriptionSearchLbl.snp.makeConstraints { make in
      make.left.equalTo(iconTruck.snp.right).offset(8)
      make.top.equalTo(titleSearchLbl.snp.bottom).offset(4)
      make.right.equalToSuperview().offset(-8)
    }
  }
}

extension HomeSearchCell {
  func configData(data: MKLocalSearchCompletion) {
    titleSearchLbl.text = data.title
    descriptionSearchLbl.text = data.subtitle
  }
  
  func configDataManual(data: String) {
    descriptionSearchLbl.isHidden = true
    
    titleSearchLbl.snp.remakeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalTo(iconTruck.snp.right).offset(8)
      make.right.equalToSuperview().offset(-8)
    }
    
    titleSearchLbl.text = data
  }
}
