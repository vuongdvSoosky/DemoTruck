//
//  GoingDetailView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import UIKit
import SnapKit

class GoingDetailView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.cornerRadius = 20
    return view
  }()
  
  private lazy var lineView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xDBDBDB)
    view.cornerRadius = 2
    view.clipsToBounds = true
    return view
  }()
  
  override func addComponents() {
    self.addSubview(containerView)
    containerView.addSubviews(lineView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    lineView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.centerX.equalToSuperview()
      make.width.equalTo(56)
      make.height.equalTo(4)
    }
  }
}
