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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let padding: CGFloat = 20
    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding))
  }
  
  override func setColor() {
    contentView.backgroundColor = .clear
    
    titleSearchLbl.textColor = UIColor(rgb: 0x3337A5)
    titleSearchLbl.font = AppFont.font(.boldText, size: 16)
    
    descriptionSearchLbl.textColor = UIColor(rgb: 0x555555)
    descriptionSearchLbl.font = AppFont.font(.lightText, size: 14)
  }
  
  override func addComponents() {
    contentView.addSubviews(titleSearchLbl, descriptionSearchLbl)
  }
  
  override func setConstraints() {
    titleSearchLbl.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalToSuperview().offset(8)
      make.right.equalToSuperview().offset(-8)
    }
    
    descriptionSearchLbl.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalTo(titleSearchLbl.snp.bottom).offset(8)
      make.right.equalToSuperview().offset(-8)
    }
  }
}

extension HomeSearchCell {
  func configData(data: MKLocalSearchCompletion) {
    titleSearchLbl.text = data.title
    descriptionSearchLbl.text = data.subtitle
  }
}
