//
//  SmallGGNativeAdVIew.swift
//  DemoAds
//
//  Created by Việt Nguyễn on 10/11/24.
//

import UIKit
import GoogleMobileAds
import SkeletonView

class SmallGGNativeAdView: NativeAdView {
  
  static var height: CGFloat = 137
  
  private var adContainerView = UIView(),
              adHeadlineLabel = UILabel(),
              adBodyLabel = UILabel(),
              adIconImageView = UIImageView(),
              adRatingView = UIImageView(),
              adActionButton = UIButton(),
              adAttributionView = UIView()
  
  let adAttributionLabel = UILabel()
  let titleStack = UIStackView()
  let contentStack = UIStackView()

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
    [adIconImageView, adActionButton, titleStack, adBodyLabel, adRatingView].forEach { view in
      view.showAnimatedGradientSkeleton(
        usingGradient: gradient,
        animation: SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 0.7)
      )
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    adAttributionView.setRoundCorners(corners: .allCorners, radius: 2)
  }
  
  
  private func setupConstraints() {
    addSubview(adContainerView)
    adContainerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    adContainerView.addSubview(adIconImageView)
    adContainerView.addSubview(adAttributionView)
    adContainerView.addSubview(titleStack)
    adContainerView.addSubview(adActionButton)
    adContainerView.addSubview(contentStack)
    
    adIconImageView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(5)
      make.top.equalToSuperview().offset(10)
      make.bottom.equalToSuperview().offset(-10)
      make.width.equalTo(adIconImageView.snp.height)
    }
    
    let actionButtonRatio: CGFloat = CGFloat(88)/CGFloat(33)
    adActionButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-5)
      make.height.equalTo(33)
      make.width.equalTo(adActionButton.snp.height).multipliedBy(actionButtonRatio)
    }
    
    adRatingView.snp.makeConstraints { make in
      make.height.equalTo(12)
      make.width.equalTo(90)
    }
    
    adAttributionView.snp.makeConstraints { make in
      make.top.equalTo(adIconImageView.snp.top)
      make.left.equalTo(adIconImageView.snp.right).offset(2.5)
      make.height.equalTo(15)
      make.width.equalTo(15)
    }
    
    titleStack.snp.makeConstraints { make in
      make.top.bottom.equalTo(adAttributionView)
      make.right.equalTo(adActionButton.snp.left).offset(-2.5)
      make.left.equalTo(adAttributionView.snp.right).offset(2.5)
    }
    
    titleStack.spacing = 3
    titleStack.axis = .horizontal
    titleStack.distribution = .fill
    titleStack.addArrangedSubview(adHeadlineLabel)
    titleStack.addArrangedSubview(UIView())
    
    let ratingStack = UIStackView()
    ratingStack.axis = .horizontal
    ratingStack.distribution = .fill
    ratingStack.addArrangedSubview(adRatingView)
    ratingStack.addArrangedSubview(UIView())
  
    contentStack.axis = .vertical
    contentStack.distribution = .equalSpacing
    contentStack.addArrangedSubview(adBodyLabel)
    contentStack.addArrangedSubview(ratingStack)
    contentStack.addArrangedSubview(UIView())
    
    contentStack.snp.makeConstraints { make in
      make.top.equalTo(adAttributionView.snp.bottom).offset(2.5)
      make.left.equalTo(adIconImageView.snp.right).offset(2.5)
      make.right.equalTo(adActionButton.snp.left).offset(-2.5)
      make.bottom.equalTo(adIconImageView)
    }
       
    adAttributionView.backgroundColor = UIColor(hex: "000000")
    
    adAttributionView.addSubview(adAttributionLabel)
    adAttributionLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupUI() {
    adContainerView.backgroundColor = UIColor(hex: "FFFFFF")
    
    adHeadlineLabel.skeletonTextNumberOfLines = 1
    adHeadlineLabel.numberOfLines = 2
    
    adBodyLabel.skeletonTextNumberOfLines = 1
    adBodyLabel.numberOfLines = 3
    
    adAttributionLabel.text = "Ad"
    adAttributionLabel.font = .systemFont(ofSize: 9)
    adAttributionLabel.textAlignment = .center
    adAttributionLabel.textColor = UIColor(hex: "FFFFFF")
    
    [adIconImageView, adActionButton, titleStack, adBodyLabel, adRatingView].forEach { view in
      view.isSkeletonable = true
    }
  }
}

extension SmallGGNativeAdView: NativeAdProtocol {
  func bindingData(nativeAd: NativeAd) {
    [adIconImageView, adActionButton, titleStack, adBodyLabel, adRatingView].forEach { view in
      view.hideSkeleton()
    }
    
    self.iconView = adIconImageView
    self.headlineView = adHeadlineLabel
    self.bodyView = adBodyLabel
    self.starRatingView = adRatingView
    self.callToActionView = adActionButton
    
    self.adIconImageView.image = nativeAd.icon?.image
    self.adIconImageView.isHidden = nativeAd.icon == nil
    self.adIconImageView.layer.cornerRadius = 6
    self.adIconImageView.layer.masksToBounds = true
    
    self.adHeadlineLabel.text = nativeAd.headline
    self.adHeadlineLabel.textColor = titleColor
    self.adHeadlineLabel.font = .systemFont(ofSize: 14)
    
    self.adBodyLabel.text = nativeAd.body
    self.adBodyLabel.textColor = contenColor
    self.adBodyLabel.font = .systemFont(ofSize: 11)
    
    self.adRatingView.image = imageOfStars(from: nativeAd.starRating)
    self.adRatingView.contentMode = .scaleAspectFit
    self.adRatingView.isHidden = nativeAd.starRating == nil || nativeAd.starRating == 0
    
    self.adActionButton.setTitle(nativeAd.callToAction, for: .normal)
    self.adActionButton.titleLabel?.font = .systemFont(ofSize: 14)
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
