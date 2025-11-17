//
//  GoingDetailView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import UIKit
import SnapKit

class GoingDetailView: BaseView {
  // MARK: -UIView
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
  
  private lazy var editView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 8
    view.clipsToBounds = true
    view.backgroundColor = UIColor(rgb: 0x909090)
    
    let label = UILabel()
    label.text = "Edit Route"
    label.textColor = UIColor(rgb: 0xF2F2F2)
    label.font = AppFont.font(.bold, size: 15)
    
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private lazy var titleRoute: UILabel = {
    let label = UILabel()
    label.text = "Highway Supply Chain Network"
    label.numberOfLines = 0
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 21)
    return label
  }()
  
  override func addComponents() {
    self.addSubview(containerView)
    containerView.addSubviews(lineView, titleRoute, editView)
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
    
    editView.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(12)
      make.top.equalTo(lineView.snp.bottom).inset(-28)
      make.width.equalTo(102)
      make.height.equalTo(30)
    }
    
    titleRoute.snp.makeConstraints { make in
      make.top.equalTo(lineView.snp.bottom).inset(-19)
      make.left.equalToSuperview().inset(12)
      make.right.equalTo(editView.snp.left).inset(-10)
    }
    
  }
}
