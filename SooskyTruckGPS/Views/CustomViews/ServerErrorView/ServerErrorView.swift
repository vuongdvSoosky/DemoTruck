//
//  ServerErrorView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 24/11/25.
//

import UIKit

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
    icon.contentMode = .scaleAspectFill
    
    view.addSubview(icon)
    
    icon.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.width.height.equalTo(100)
      make.centerX.equalToSuperview()
    }
    
    let discardLabel = UILabel()
    let discardText = "Server is under maintenance"
//    discardLabel.setLineSpacing()
    discardLabel.text = discardText
    discardLabel.font = AppFont.font(.boldText, size: 21)
    discardLabel.textColor = UIColor(rgb: 0xF26101)
    discardLabel.numberOfLines = 0
    discardLabel.textAlignment = .center
    
    let desLabel = UILabel()
    let desLabelText = "We’re making a few updates to keep things running smoothly. Your route will be ready again shortly. Thanks for your patience"
    desLabel.font = AppFont.font(.regularText, size: 17)
    desLabel.textColor = UIColor(rgb: 0x332644)
    desLabel.textAlignment = .center
    desLabel.numberOfLines = 0
    desLabel.text = discardText
  
    let stackView = UIView()
    
    [discardLabel, desLabel].forEach({stackView.addSubview($0)})
    
    discardLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    
    desLabel.snp.makeConstraints { make in
      make.top.equalTo(discardLabel.snp.bottom).inset(-16)
      make.left.right.equalToSuperview()
    }
    
    view.addSubviews(stackView)
   
    stackView.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).inset(-20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(60)
    }
    
    let horizontalStackView = UIStackView()
    horizontalStackView.axis = .horizontal
    horizontalStackView.distribution = .fillEqually
    horizontalStackView.spacing = 10
    
    [confirmView].forEach({horizontalStackView.addArrangedSubview($0)})
    view.addSubviews(horizontalStackView)
    
    horizontalStackView.snp.makeConstraints { make in
      make.top.equalTo(stackView.snp.bottom).inset(-16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(48)
      make.bottom.equalToSuperview().inset(16)
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
    label.font = AppFont.font(.mediumText, size: 15)
    
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
    containerView.frame = bounds
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    mainDiscardView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(330)
      make.height.equalTo(262)
    }
    layoutIfNeeded()
  }
  
  private func setupAction() {
    confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapConfirmView)))
  }
  
  // MARK: - Action
  
  @objc private func onTapConfirmView() {
    self.handlerActionOkay?()
  }
}
