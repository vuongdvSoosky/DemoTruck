//
//  NoFindAddressView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 27/11/25.
//

import UIKit
import SnapKit

class NoFindAddressView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(hex: "FFFFFF")
    view.layer.cornerRadius = 12
    
    view.addSubviews(addressLabel)
    addressLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
      make.top.equalToSuperview().offset(8)
    }
    return view
  }()
  
  private lazy var addressLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(rgb: 0x332644)
    label.numberOfLines = 0
    label.font = AppFont.font(.mediumText, size: 15)
    label.textAlignment = .left
    return label
  }()
  
  override func addComponents() {
    addSubviews(containerView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func bindingAdress(_ adress: String) {
    addressLabel.text = adress.trimmingSpacesOnly()
  }
}
