//
//  SplashVC.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 10/9/25.
//

import UIKit
import SnapKit

class SplashVC: StoreManager {
  
  private lazy var contanierView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFF8EC)
    return view
  }()
  private lazy var imageBackGround: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .imgBackgroundsplash
    imageView.contentMode = .scaleAspectFill
    imageView.isHidden = true
    return imageView
  }()
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .icSplash
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let viewModel = SplashViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppManager.shared.setStateShouldShowOpenAds(false)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.viewModel.action.send(.end)
    }
    
    addComponents()
    setConstraints()
  }
  
  func addComponents() {
    self.view.addSubview(imageBackGround)
    self.view.addSubview(contanierView)
    self.view.addSubview(iconImageView)
  }
  
  func setConstraints() {
    contanierView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    imageBackGround.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    iconImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(160)
    }
  }

}
