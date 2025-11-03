//
//  MediaGGNativeAdView.swift
//  DemoAds
//
//  Created by Việt Nguyễn on 10/11/24.
//

import UIKit
import GoogleMobileAds
import SkeletonView

class MediaGGNativeAdView: NativeAdView {
  static var height: CGFloat = 300
  
  private var adContainerView = UIView(),
              adMediaView = MediaView(),
              adHeadlineLabel = UILabel(),
              adBodyLabel = UILabel(),
              adIconImageView = UIImageView(),
              adRatingView = UIImageView(),
              adActionButton = UIButton(),
              adAttributionView = UIView()
  
  let adAttributionLabel = UILabel()
  let headlineStackView = UIStackView()
  let bodyStackView = UIStackView()
  
  var adUnitID: String?
  let (viewBackgroundColor, titleColor, vertiserColor, contenColor, actionColor, backgroundAction) = AdMobManager.shared.adsNativeColor.colors
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupConstraints()
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupConstraints()
    setupUI()
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    let gradient = SkeletonGradient(baseColor: UIColor.clouds)
    [adMediaView, adHeadlineLabel, adBodyLabel, adRatingView, adIconImageView, adActionButton].forEach { view in
      view.showAnimatedGradientSkeleton(
        usingGradient: gradient,
        animation: SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 0.7)
      )
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    adAttributionView.setShadow(
      radius: 4,
      opacity: 1,
      offset: CGSize(width: 0, height: 2),
      color: UIColor(hex: "000000").withAlphaComponent(0.45)
    )
    adAttributionView.layer.cornerRadius = 3
  }
  
  private func setupConstraints() {
    adRatingView.snp.makeConstraints { make in
      make.width.equalTo(90)
      make.height.equalTo(12)
    }
    
    let ratingStack = UIStackView()
    ratingStack.axis = .horizontal
    ratingStack.distribution = .fill
    ratingStack.addArrangedSubview(adRatingView)
    ratingStack.addArrangedSubview(UIView())
    
    headlineStackView.axis = .vertical
    headlineStackView.spacing = 0
    headlineStackView.distribution = .equalSpacing
    headlineStackView.addArrangedSubview(adHeadlineLabel)
    headlineStackView.addArrangedSubview(adBodyLabel)
    headlineStackView.addArrangedSubview(ratingStack)
    headlineStackView.addArrangedSubview(UIView())
    
    addSubview(adContainerView)
       
    adContainerView.addSubview(adIconImageView)
    adContainerView.addSubview(headlineStackView)
    adContainerView.addSubview(adActionButton)
    adContainerView.addSubview(adMediaView)
    adContainerView.addSubview(adAttributionView)

    adContainerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    let mediaHeighRatio: CGFloat = CGFloat(222)/CGFloat(330)
    
    adMediaView.snp.makeConstraints { make in
      make.top.left.right.equalToSuperview()
      make.height.equalTo(adContainerView).multipliedBy(mediaHeighRatio)
    }
    
    adIconImageView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(10)
      make.top.equalTo(adMediaView.snp.bottom).offset(15)
      make.bottom.equalToSuperview().offset(-15)
      make.width.equalTo(adIconImageView.snp.height)
    }
    
    let actionButtonRatio: CGFloat = CGFloat(90)/CGFloat(33)
    adActionButton.snp.makeConstraints { make in
      make.centerY.equalTo(adIconImageView)
      make.right.equalToSuperview().offset(-10)
      make.height.equalTo(33)
      make.width.equalTo(adActionButton.snp.height).multipliedBy(actionButtonRatio)
    }
    
    headlineStackView.snp.makeConstraints { make in
      make.top.equalTo(adIconImageView)
      make.left.equalTo(adIconImageView.snp.right).offset(5)
      make.right.equalTo(adActionButton.snp.left).offset(-5)
      make.bottom.equalTo(adIconImageView)
    }
  
    adAttributionView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.left.equalToSuperview().offset(10)
      make.height.equalTo(23)
      make.width.equalTo(31)
    }
    
    adAttributionView.addSubview(adAttributionLabel)
    adAttributionLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupUI() {
    
    adContainerView.backgroundColor = UIColor(hex: "FFFFFF")

    adAttributionView.backgroundColor = UIColor(hex: "FFFFFF")

    adAttributionLabel.text = "Ad"
    adAttributionLabel.font = .systemFont(ofSize: 12)
    adAttributionLabel.textAlignment = .center
    adAttributionLabel.textColor = UIColor(hex: "4E4E4E")
    
    [adMediaView, adHeadlineLabel, adBodyLabel, adIconImageView, adActionButton, adRatingView].forEach { view in
      view.isSkeletonable = true
    }
  }
}

extension MediaGGNativeAdView: NativeAdProtocol {
  func bindingData(nativeAd: NativeAd) {
    [adMediaView, adHeadlineLabel, adBodyLabel, adIconImageView, adActionButton, adRatingView].forEach { view in
      view.hideSkeleton()
    }
    
    self.mediaView = adMediaView
    self.iconView = adIconImageView
    self.headlineView = adHeadlineLabel
    self.bodyView = adBodyLabel
    self.starRatingView = adRatingView
    self.callToActionView = adActionButton
    
    if nativeAd.mediaContent.hasVideoContent {
      self.adMediaView.mediaContent = nativeAd.mediaContent
      self.adMediaView.contentMode = .scaleAspectFit
    }
  
    self.adContainerView.backgroundColor = UIColor(hex: "FFFFFF")
    
    self.adIconImageView.image = nativeAd.icon?.image
    self.adIconImageView.isHidden = nativeAd.icon == nil
    self.adIconImageView.layer.cornerRadius = 3
    self.adIconImageView.layer.masksToBounds = true
    
    self.adHeadlineLabel.text = nativeAd.headline
    self.adHeadlineLabel.textColor = titleColor
    self.adHeadlineLabel.font = .systemFont(ofSize: 14)
    
    self.adBodyLabel.text = nativeAd.body
    self.adBodyLabel.textColor = contenColor
    self.adBodyLabel.font = .systemFont(ofSize: 11)
    self.adBodyLabel.numberOfLines = 3
      
    self.adRatingView.image = imageOfStars(from: nativeAd.starRating)
    self.adRatingView.contentMode = .scaleAspectFit
    self.adRatingView.isHidden = nativeAd.starRating == nil || nativeAd.starRating == 0
    
    self.adActionButton.setTitle(nativeAd.callToAction, for: .normal)
    self.adActionButton.layer.backgroundColor = backgroundAction.first?.cgColor
    self.adActionButton.layer.cornerRadius = AdMobManager.shared.adsNativeCornerRadiusButton
    self.adActionButton.setTitleColor(actionColor, for: .normal)
    
    self.backgroundColor = viewBackgroundColor
    layer.borderWidth = AdMobManager.shared.adsNativeBorderWidth
    layer.borderColor = AdMobManager.shared.adsNativeBorderColor.cgColor
    clipsToBounds = true
    
    self.nativeAd = nativeAd
  }
  
  func getGADView() -> NativeAdView {
    return self
  }
}
