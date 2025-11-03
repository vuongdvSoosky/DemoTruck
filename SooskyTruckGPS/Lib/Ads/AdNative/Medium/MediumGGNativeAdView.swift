//
//  MediumGGNativeAdView.swift
//  DemoAds
//
//  Created by Việt Nguyễn on 10/11/24.
//

import UIKit
import GoogleMobileAds
import SkeletonView

class MediumGGNativeAdView: NativeAdView {
  static var height: CGFloat = 231
  
  private var adContainerView = UIView(),
              adHeadlineLabel = UILabel(),
              adBodyLabel = UILabel(),
              adIconImageView = UIImageView(),
              adRatingLabel = UILabel(),
              adRatingView = UIImageView(),
              adPriceLabel = UILabel(),
              adActionButton = UIButton(),
              adAttributionView = UIView()
  
  let adAttributionLabel = UILabel()
  let contentStack = UIStackView()
  let ratingStack = UIStackView()

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
    [adIconImageView, adHeadlineLabel, adBodyLabel, ratingStack, adActionButton].forEach { view in
      view.showAnimatedGradientSkeleton(
        usingGradient: gradient,
        animation: SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 0.7)
      )
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    adAttributionView.setRoundCorners(corners: .bottomRight, radius: 4)
  }
  
  
  private func setupConstraints() {
    addSubview(adContainerView)
    
    ratingStack.axis = .horizontal
    ratingStack.spacing = 10
    ratingStack.distribution = .fill
    ratingStack.addArrangedSubview(adRatingLabel)
    ratingStack.addArrangedSubview(adRatingView)
    ratingStack.addArrangedSubview(adPriceLabel)
    ratingStack.addArrangedSubview(UIView())
    
    adRatingView.snp.makeConstraints { make in
      make.width.equalTo(90)
    }
    
    adContainerView.addSubview(adAttributionView)
    adContainerView.addSubview(adIconImageView)
    adContainerView.addSubview(contentStack)
    adContainerView.addSubview(adActionButton)

    adContainerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    adIconImageView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(10)
      make.top.equalToSuperview().offset(33)
      make.width.height.equalTo(66)
    }
    
    ratingStack.snp.makeConstraints { make in
      make.height.equalTo(15)
    }
    
    contentStack.axis = .vertical
    contentStack.distribution = .equalSpacing
    contentStack.addArrangedSubview(adHeadlineLabel)
    contentStack.addArrangedSubview(adBodyLabel)
    contentStack.addArrangedSubview(ratingStack)
    
    contentStack.snp.makeConstraints { make in
      make.top.equalTo(adIconImageView)
      make.left.equalTo(adIconImageView.snp.right).offset(10)
      make.right.equalToSuperview().offset(-10)
      make.bottom.equalTo(adIconImageView)
    }
    
    let actionButtonRatio: CGFloat = CGFloat(350)/CGFloat(45)
    adActionButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(10)
      make.right.equalToSuperview().offset(-10)
      make.height.equalTo(adActionButton.snp.width).dividedBy(actionButtonRatio)
      make.bottom.equalToSuperview().offset(-25)
    }
    
    adAttributionView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
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
    
    adAttributionView.backgroundColor = UIColor(hex: "000000")
    
    adAttributionLabel.text = "Ad"
    adAttributionLabel.font = .systemFont(ofSize: 12)
    adAttributionLabel.textAlignment = .center
    adAttributionLabel.textColor = UIColor(hex: "FFFFFF")
    
    adPriceLabel.font = .systemFont(ofSize: 12)
    adRatingLabel.font = .systemFont(ofSize: 12)
    
    [adIconImageView, adHeadlineLabel, adBodyLabel, ratingStack, adActionButton].forEach { view in
      view.isSkeletonable = true
    }
  }
}

extension MediumGGNativeAdView: NativeAdProtocol {
  func bindingData(nativeAd: NativeAd) {
    [adIconImageView, adHeadlineLabel, adBodyLabel, ratingStack, adActionButton].forEach { view in
      view.hideSkeleton()
    }
    
    self.iconView = adIconImageView
    self.headlineView = adHeadlineLabel
    self.bodyView = adBodyLabel
    self.starRatingView = adRatingView
    self.callToActionView = adActionButton
    self.priceView = adPriceLabel
    
    self.adContainerView.backgroundColor = UIColor(hex: "FFFFFF")
    
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
      
    self.adRatingLabel.isHidden = nativeAd.starRating == nil || nativeAd.starRating == 0
    self.adRatingLabel.text = "\(nativeAd.starRating ?? 0)"
    
    self.adRatingView.image = imageOfStars(from: nativeAd.starRating)
    self.adRatingView.contentMode = .scaleAspectFit
    self.adRatingView.isHidden = nativeAd.starRating == nil || nativeAd.starRating == 0
    
    self.adPriceLabel.text = nativeAd.price
    self.adPriceLabel.isHidden = nativeAd.price == nil
    
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
