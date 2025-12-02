//
//  AdsTrackingView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 2/12/25.
//

import UIKit
import SnapKit
import AppTrackingTransparency

class AdsTrackingView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFAFAFA)
    view.cornerRadius = 20
    
    view.addSubviews(iconAds, titleLabel, desLabel, continueView)
    
    iconAds.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(14)
      make.centerX.equalToSuperview()
      make.width.equalTo(96)
      make.height.equalTo(110)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(iconAds.snp.bottom).inset(-8)
      make.left.right.equalToSuperview().inset(36)
    }
    
    desLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).inset(-8)
      make.left.right.equalToSuperview().inset(20)
    }
    
    continueView.snp.makeConstraints { make in
      make.top.equalTo(desLabel.snp.bottom).inset(-16)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(60)
      make.bottom.equalToSuperview().inset(16)
    }
    
    return view
  }()
  
  private lazy var iconAds: UIImageView = {
    let icon = UIImageView()
    icon.image = .icAdsTracking
    icon.contentMode = .scaleAspectFill
    return icon
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Personalize Your New Experience"
    label.font = AppFont.font(.boldText, size: 24)
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var desLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.numberOfLines = 0
    
    let text = "Ads are crucial to keep our content free and accessible for everyone. Please consider allowing tracking for a more personalized experience"
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 6
    paragraphStyle.alignment = .center
    
    let attributedText = NSAttributedString(
      string: text,
      attributes: [
        .font: AppFont.font(.regularText, size: 17),
        .foregroundColor: UIColor(rgb: 0x292929),
        .paragraphStyle: paragraphStyle
      ]
    )
    
    label.attributedText = attributedText
    return label
  }()
  
  private lazy var continueView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Continue"
    titleLabel.font = AppFont.font(.boldText, size: 20)
    titleLabel.textColor = UIColor(rgb: 0xFFFFFF)
    
    view.addSubviews(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  var handlerAction: Handler?
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupAction()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupAction()
  }
  
  private func setupAction() {
    continueView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapContinue)))
  }
  
  override func setProperties() {
    self.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.4)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
      guard let self else {
        return
      }
      let colors: [UIColor] = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      continueView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
      continueView.cornerRadius = 12
      continueView.clipsToBounds = true
    }
  }
  
  override func addComponents() {
    addSubviews(containerView)
  }
  
  override func setConstraints() {
    containerView.frame = bounds
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(330)
      make.height.equalTo(400)
    }
  }
  
  @objc private func onTapContinue() {
    handlerAction?()
    self.removeFromSuperview()
  }
}
