//
//  Untitled.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 8/8/25.
//

import UIKit
import SnapKit

class PopupView: UIView {
  
  let statusIcon = UIImageView()
  let statusDescriptionLbl = UILabel()
  let doneBtn = UIButton()
  
  var iconImg = UIImage()
  var textValue = ""
  var dismissAction: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  func commonInit() {
    //        fromNib()
  }
}

extension PopupView {
  private func setupConstraint() {
    self.addSubviews(statusIcon, statusDescriptionLbl, doneBtn)
    
    statusIcon.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(31)
      make.centerX.equalToSuperview()
      make.width.equalTo(statusIcon.snp.height)
    }
    
    doneBtn.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-41)
      make.left.equalToSuperview().offset(26)
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
    }
    
    statusDescriptionLbl.snp.makeConstraints { make in
      make.top.equalTo(statusIcon.snp.bottom).offset(23)
      make.left.equalToSuperview().offset(38)
      make.right.equalToSuperview().offset(-38)
      make.bottom.equalTo(doneBtn.snp.top).offset(-16)
    }
  }
  
  private func setupUI() {
    self.backgroundColor = .white
    setupConstraint()
    
    statusIcon.image = self.iconImg
    statusIcon.contentMode = .scaleAspectFit
    
    statusDescriptionLbl.text = self.textValue
    statusDescriptionLbl.textColor = .black
    statusDescriptionLbl.font = UIFont.systemFont(ofSize: 18)
    statusDescriptionLbl.textAlignment = .center
    statusDescriptionLbl.numberOfLines = 0
    
    doneBtn.configBaseButton(title: "Done", radius: 15)
    doneBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
  }
  
  func configData(status: Bool, description: String) {
    iconImg = (status ? .icSubSuccess : .icSubFailed) ?? UIImage()
    textValue = description
    setupUI()
  }
}

//MARK: -Target
extension PopupView {
  @objc private func backAction() {
    self.dismissAction?()
  }
}
