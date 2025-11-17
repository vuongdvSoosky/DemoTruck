//
//  RouteInfoItemView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 17/11/25.
//

import UIKit
import SnapKit

class RouteInfoItemView: UIView {
  
  private let iconImageView = UIImageView()
  private let valueLabel = UILabel()
  private let titleLabel = UILabel()
  
  init(icon: UIImage?, value: String, title: String) {
    super.init(frame: .zero)
    setupUI(icon: icon, value: value, title: title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI(icon: UIImage?, value: String, title: String) {
    translatesAutoresizingMaskIntoConstraints = false
    
    iconImageView.image = icon
    iconImageView.contentMode = .scaleAspectFit
    
    valueLabel.text = value
    valueLabel.textColor = UIColor(rgb: 0xF26101)
    valueLabel.font = AppFont.font(.boldText, size: 17)
    
    titleLabel.text = title
    titleLabel.textColor = UIColor(rgb: 0x909090)
    titleLabel.font = AppFont.font(.regularText, size: 12)
    
    addSubviews(iconImageView, valueLabel, titleLabel)
    
    iconImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.width.height.equalTo(28)
      make.left.equalToSuperview()
    }
    
    valueLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.left.equalTo(iconImageView.snp.right).offset(8)
      make.right.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(valueLabel.snp.bottom).offset(2)
      make.left.equalTo(iconImageView.snp.right).offset(8)
      make.right.equalToSuperview()
    }
  }
  
  func update(value: String) {
    valueLabel.text = value
  }
}
