//
//  DetailRouterView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import UIKit
import SnapKit

class DetailRouterView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    
    return view
  }()
  
  private lazy var titleRoute: UILabel = {
    let label = UILabel()
    label.text = "Highway Supply Chain Network"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 21)
    
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
  
  private lazy var timeEstimate: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
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
    label.text = "Total Distance(mi)"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.regularText, size: 12)
    return label
  }()
  
  override func addComponents() {
    self.addSubviews(containerView)
    containerView.addSubviews(titleRoute, totalDistanceView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleRoute.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(30)
    }
    
    totalDistanceView.snp.makeConstraints { make in
      make.top.equalTo(titleRoute.snp.bottom).inset(-20)
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(36)
    }
  }
}
