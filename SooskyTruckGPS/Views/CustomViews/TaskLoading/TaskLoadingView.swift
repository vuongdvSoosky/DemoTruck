//
//  TaskLoadingView.swift
//  
//
//  Created by on 30/11/2023.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

class TaskLoadingView: BaseView {
  @IBOutlet var contentView: UIView!
  
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = .ballSpinFadeLoader
    loadingView.padding = 30.0
    loadingView.color = UIColor(rgb: 0xF08990)
    return loadingView
  }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    loadingView.startAnimating()
  }
  
  override func addComponents() {
    loadNibNamed()
    addSubview(contentView)
    addSubview(loadingView)
  }
  
  override func setConstraints() {
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    loadingView.snp.makeConstraints { make in
      make.width.height.equalTo(20.0)
      make.center.equalToSuperview()
    }
  }
}

extension TaskLoadingView {
  func setAlpha(alpha: Double) {
    self.alpha = alpha
  }
}

