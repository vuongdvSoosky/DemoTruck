//
//  FullScreenGGNativeAdView.swift
//  DemoAds
//
//  Created by Việt Nguyễn on 8/11/24.
//

import UIKit
import GoogleMobileAds
import SkeletonView

class FullScreenGGNativeAdView: NativeAdView {
  private var adContainerView = UIView(),
              adHeadlineLabel = UILabel(),
              adBodyLabel = UILabel(),
              adIconImageView = UIImageView(),
              adRatingView = UIImageView(),
              adActionButton = UIButton(),
              adMediaView = MediaView(),
              
              adAttributionView = UIView()
  
  let contentStack = UIStackView()
  var adUnitID: String?
  let (viewBackgroundColor, titleColor, vertiserColor, contenColor, actionColor, backgroundAction) = AdMobManager.shared.adsNativeColor.colors
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupConstraints()
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
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    
    let gradient = SkeletonGradient(baseColor: UIColor.clouds)
    [adMediaView, adIconImageView, adHeadlineLabel, adBodyLabel, adRatingView, adActionButton].forEach { view in
      view.showAnimatedGradientSkeleton(
        usingGradient: gradient,
        animation: SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 0.7)
      )
    }
  }
  
  private func setupConstraints() {
    addSubview(adMediaView)
    addSubview(adContainerView)
    
    adContainerView.addSubview(adIconImageView)
    adContainerView.addSubview(adActionButton)
    adContainerView.addSubview(contentStack)
    
    adMediaView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
   
    adContainerView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(10)
      make.right.equalToSuperview().offset(-10)
      make.bottom.equalToSuperview().offset(-22)
      make.height.equalTo(100)
    }
    
    adIconImageView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(5)
      make.top.equalToSuperview().offset(15)
      make.bottom.equalToSuperview().offset(-15)
      make.width.equalTo(adIconImageView.snp.height)
    }
    
    let actionButtonRatio: CGFloat = CGFloat(90)/CGFloat(33)
    adActionButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-5)
      make.height.equalTo(33)
      make.width.equalTo(adActionButton.snp.height).multipliedBy(actionButtonRatio)
    }
    
    adRatingView.snp.makeConstraints { make in
      make.width.equalTo(90)
      make.height.equalTo(12)
    }
    
    let ratingStack = UIStackView()
    ratingStack.axis = .horizontal
    ratingStack.distribution = .fill
    ratingStack.addArrangedSubview(adRatingView)
    ratingStack.addArrangedSubview(UIView())

    contentStack.axis = .vertical
    contentStack.distribution = .equalSpacing
    contentStack.addArrangedSubview(adHeadlineLabel)
    contentStack.addArrangedSubview(adBodyLabel)
    contentStack.addArrangedSubview(ratingStack)
    
    contentStack.snp.makeConstraints { make in
      make.top.bottom.equalTo(adIconImageView)
      make.left.equalTo(adIconImageView.snp.right).offset(5)
      make.right.equalTo(adActionButton.snp.left).offset(-5)
    }
    
    addSubview(adAttributionView)
    adAttributionView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.left.equalToSuperview().offset(10)
      make.height.equalTo(23)
      make.width.equalTo(31)
    }
    adAttributionView.backgroundColor = UIColor(hex: "FFFFFF")

    let adAttributionLabel = UILabel()
    adAttributionView.addSubview(adAttributionLabel)
    adAttributionLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    adAttributionLabel.text = "Ad"
    adAttributionLabel.font = .systemFont(ofSize: 12)
    adAttributionLabel.textAlignment = .center
    adAttributionLabel.textColor = UIColor(hex: "4E4E4E")
    
    [adMediaView, adIconImageView, adHeadlineLabel, adBodyLabel, adRatingView, adActionButton].forEach { view in
      view.isSkeletonable = true
    }
  }
  
}
 
extension FullScreenGGNativeAdView: NativeAdProtocol {
  func bindingData(nativeAd: NativeAd) {
    
    print("==== Native Ad ====")
    print("Headline:", nativeAd.headline ?? "No Content")
    print("Prive:", nativeAd.price ?? "No Content")
    print("Body:", nativeAd.body ?? "No Content")
    print("Advertiser:", nativeAd.advertiser ?? "No Content")
    print("Call to Action:", nativeAd.callToAction ?? "No Content")
    
//    self.hideSkeleton()
    [adMediaView, adIconImageView, adHeadlineLabel, adBodyLabel, adRatingView, adActionButton].forEach { view in
      view.hideSkeleton()
    }
    
    self.mediaView = adMediaView
    self.iconView = adIconImageView
    self.headlineView = adHeadlineLabel
    self.bodyView = adBodyLabel
    self.starRatingView = adRatingView
    self.callToActionView = adActionButton
    
    self.adMediaView.mediaContent = nativeAd.mediaContent
    
    self.adContainerView.backgroundColor = UIColor(hex: "FFFFFF")
    self.adContainerView.setRoundCorners(corners: .allCorners, radius: 7)
    
    self.adIconImageView.image = nativeAd.icon?.image
    self.adIconImageView.isHidden = nativeAd.icon == nil
    self.adIconImageView.layer.cornerRadius = 17
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
    layer.cornerRadius = AdMobManager.shared.adsNativeCornerRadius
    clipsToBounds = true
    
    self.nativeAd = nativeAd
  }
  
  func getGADView() -> NativeAdView {
    return self
  }
}
