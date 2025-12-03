//
//  RewardView.swift
//  SooskyHorseTracking
//
//  Created by VuongDV on 20/10/25.
//

import SnapKit
import UIKit
import Foundation

class RewardView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.6)
    return view
  }()
  private lazy var rewardView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFEFEFE)
    view.cornerRadius = 12
    
    let title = UILabel()
    title.text = "Watch Ads"
    title.textColor = UIColor(rgb: 0xF26101)
    title.font = AppFont.font(.boldText, size: 24)
    
    let des1Label = UILabel()
    des1Label.text = "Watch a short ads to continue"
    des1Label.textColor = UIColor(rgb: 0x332644)
    des1Label.font = AppFont.font(.regularText, size: 17)
    
    let des2Label = UILabel()
    des2Label.text = "using this features."
    des2Label.textColor = UIColor(rgb: 0x332644)
    des2Label.font = AppFont.font(.regularText, size: 17)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    
    [watchNowView, getPremiumView].forEach({stackView.addArrangedSubview($0)})
    [icReward, title, des1Label, des2Label, stackView, icClosse].forEach({view.addSubviews($0)})
    
    icReward.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.centerX.equalToSuperview()
    }
    
    icClosse.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(18)
      make.width.height.equalTo(24)
    }
    
    title.snp.makeConstraints { make in
      make.top.equalTo(self.icReward.snp.bottom).inset(-16)
      make.centerX.equalToSuperview()
    }
    
    des1Label.snp.makeConstraints { make in
      make.top.equalTo(title.snp.bottom).inset(-16)
      make.centerX.equalToSuperview()
    }
    
    des2Label.snp.makeConstraints { make in
      make.top.equalTo(des1Label.snp.bottom).inset(-8)
      make.centerX.equalToSuperview()
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(des2Label.snp.bottom).inset(-16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.height.equalTo(48)
      make.bottom.equalToSuperview().inset(16)
    }
    
    return view
  }()
  private lazy var icReward: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .icReward
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private lazy var watchNowView: UIView = {
    let view = UIView()
    view.cornerRadius = 12
    view.layer.borderColor = UIColor(rgb: 0xF26101).cgColor
    view.layer.borderWidth = 2
    view.backgroundColor = UIColor(rgb: 0xFFEFD3)
    
    let label = UILabel()
    label.text = "Watch now"
    label.font = AppFont.font(.boldText, size: 16)
    label.textColor = UIColor(rgb: 0x332644)
    
    let icon = UIImageView()
    icon.image = .icWatchAds
    icon.contentMode = .scaleAspectFill
    
    icon.snp.makeConstraints { make in
      make.width.height.equalTo(24)
    }
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.distribution = .fill
    
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubviews(stackView)
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var getPremiumView: UIView = {
    let view = UIView()
    view.cornerRadius = 12
    view.backgroundColor = UIColor(rgb: 0xF26101)
    
    let label = UILabel()
    label.text = "Get Premium"
    label.font = AppFont.font(.bold, size: 16)
    label.textColor = UIColor(rgb: 0xFAF7F3)
    
    view.addSubviews(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var icClosse: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .icCloseReward
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  var handlerActionWatchAds: Handler?
  var handlerActionGetPremium: Handler?
  
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
    self.addSubviews(containerView)
    self.addSubviews(rewardView)
  }
  
  override func setConstraints() {
    containerView.frame = self.bounds
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    rewardView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(330)
    }
  }
  
  private func setupAction() {
    watchNowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapWatchNow)))
    getPremiumView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapGetPremium)))
    icClosse.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapClose)))
  }
  
  @objc private func onTapWatchNow() {
    handlerActionWatchAds?()
    self.removeFromSuperview()
  }
  
  @objc private func onTapGetPremium() {
    handlerActionGetPremium?()
    self.removeFromSuperview()
  }
  
  @objc private func onTapClose() {
    self.removeFromSuperview()
  }
}
