//
//  CurrentLocationCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 27/11/25.
//

import UIKit
import SnapKit
import MapKit

class CurrentLocationCell: BaseTableViewCell {
  
  let titleSearchLbl = UILabel()
  
  private lazy var iconTruck: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icDirection
    return icon
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
    let padding: CGFloat = 20
    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding))
  }
  
  override func setColor() {
    contentView.backgroundColor = .clear    
    titleSearchLbl.textColor = UIColor(rgb: 0x332644)
    titleSearchLbl.font = AppFont.font(.boldText, size: 16)
    titleSearchLbl.text = "Use your location"
  }
  
  override func addComponents() {
    contentView.addSubviews(iconTruck, titleSearchLbl)
  }
  
  override func setConstraints() {
    iconTruck.snp.makeConstraints { make in
      make.width.height.equalTo(28)
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(0)
    }
    
    titleSearchLbl.snp.makeConstraints { make in
      make.left.equalTo(iconTruck.snp.right).offset(8)
      make.top.bottom.equalToSuperview()
      make.right.equalToSuperview().offset(-8)
    }
  }
}
