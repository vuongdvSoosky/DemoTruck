//
//  ServerErrorView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 24/11/25.
//

import UIKit
import SnapKit

class ServerErrorView: BaseView {
  // MARK: - UIView
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0x292929, alpha: 0.7)
    return view
  }()
  private lazy var mainDiscardView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFEFEFE)
    view.cornerRadius = 12
    
    let icon = UIImageView()
    icon.image = .icServerError
    icon.contentMode = .scaleAspectFit
    icon.snp.makeConstraints { make in
      make.width.height.equalTo(100)
    }
    
    let titleLabel = UILabel()
    titleLabel.text = "Server is under maintenance"
    titleLabel.font = AppFont.font(.boldText, size: 21)
    titleLabel.textColor = UIColor(rgb: 0xF26101)
    titleLabel.textAlignment = .center
    titleLabel.setLineSpacing()
    titleLabel.numberOfLines = 0
    
    let descLabel = UILabel()
    descLabel.text = "We’re making a few updates to keep things running smoothly. Your route will be ready again shortly. Thanks for your patience"
    descLabel.font = AppFont.font(.regularText, size: 17)
    descLabel.textColor = UIColor(rgb: 0x332644)
    descLabel.textAlignment = .center
    descLabel.setLineSpacing()
    descLabel.numberOfLines = 0
    
    let stack = UIStackView(arrangedSubviews: [icon, titleLabel, descLabel, confirmView])
    stack.axis = .vertical
    stack.spacing = 16
    stack.alignment = .fill
    stack.distribution = .equalSpacing
    
    view.addSubview(stack)
    
    stack.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(20)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    confirmView.snp.makeConstraints { make in
      make.height.equalTo(48)
    }
    
    return view
  }()
  private lazy var confirmView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xF26101)
    view.cornerRadius = 12
    
    let label = UILabel()
    label.text = "Okay"
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.font = AppFont.font(.bold, size: 15)
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  var handlerActionOkay: Handler?
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupAction()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupAction()
  }
  
  override func addComponents() {
    addSubviews(containerView)
    containerView.addSubview(mainDiscardView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    mainDiscardView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(32)
    }
  }
  
  private func setupAction() {
    confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapConfirmView)))
  }
  
  // MARK: - Action
  
  @objc private func onTapConfirmView() {
    self.handlerActionOkay?()
  }
}
