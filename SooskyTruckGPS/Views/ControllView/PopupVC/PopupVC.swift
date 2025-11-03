//
//  PopupVC.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 8/8/25.
//

import UIKit
import SnapKit

class PopupVC: UIViewController {
  
  let contentView = PopupView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupUI()
  }
}

extension PopupVC {
  private func setupConstraint() {
    self.view.addSubview(contentView)
    
    contentView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
    }
  }
  
  private func setupUI() {
    self.view.backgroundColor = .black.withAlphaComponent(0.4)
    setupConstraint()
    
    contentView.layer.cornerRadius = 33
    contentView.clipsToBounds = true
  }
  
  func configData(status: Bool, description: String, handle: (() -> Void)?) {
    contentView.configData(status: status, description: description)
    contentView.dismissAction = { [weak self] in
      guard let self else { return }
      self.dismiss(animated: true) {
        handle?()
      }
    }
  }
}
