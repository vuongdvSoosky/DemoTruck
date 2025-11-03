//
//  SubB3VC.swift
//  SooskyHorseTracking
//
//  Created by VuongDv on 22/10/25.
//

import UIKit

class SubB3VC: StoreManager {
  
  @IBOutlet private weak var unlimitedLable: UILabel!
  @IBOutlet private weak var premiumLabel: UILabel!
  @IBOutlet var contentLabel: [UILabel]!
  @IBOutlet private weak var desLabel: UILabel!
  @IBOutlet private weak var yearLable: UILabel!
  @IBOutlet private weak var weeklyLabel: UILabel!
  @IBOutlet private weak var priceYearlyLabel: UILabel!
  @IBOutlet private weak var priceWeeklyLabel: UILabel!
  @IBOutlet private weak var subcribeLabel: UILabel!
  @IBOutlet private weak var termsLabel: UILabel!
  @IBOutlet private weak var restoreLabel: UILabel!
  @IBOutlet private weak var privacyLabel: UILabel!
  @IBOutlet weak var justLabel: UILabel!
  @IBOutlet private weak var yearlyView: UIView!
  @IBOutlet private weak var weeklyView: UIView!
  @IBOutlet private weak var subcribeView: UIView!
  @IBOutlet private weak var bestOffer: UILabel!
  @IBOutlet weak var mainScrollView: UIScrollView!
  @IBOutlet weak var priceOnYear: UILabel!
  @IBOutlet weak var offerView: UIView!
  
  @IBOutlet weak var perYearLabel: UILabel!
  
  @IBOutlet weak var perWeeklyLabel: UILabel!
  
  private let viewModel = IAPViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.action.send(.chosePacket(registeredPurchase: .yearly))
    AppManager.shared.setStateShouldShowOpenAds(false)
    setProperties()
  }
  
  private func setProperties() {
    unlimitedLable.font = AppFont.font(.boldText, size: 32)
    premiumLabel.font = AppFont.font(.heavy, size: 20)
    contentLabel.forEach({$0.font = AppFont.font(.mediumText, size: 18)})
    desLabel.font = AppFont.font(.regularText, size: 14)
    termsLabel.font = AppFont.font(.lightText, size: 14)
    privacyLabel.font = AppFont.font(.lightText, size: 14)
    subcribeLabel.font = AppFont.font(.bold, size: 20)
    weeklyLabel.font = AppFont.font(.bold, size: 17)
    yearLable.font = AppFont.font(.bold, size: 17)
    priceWeeklyLabel.font = AppFont.font(.bold, size: 17)
    priceYearlyLabel.font = AppFont.font(.bold, size: 17)
    restoreLabel.font = AppFont.font(.semiBoldText, size: 18)
    bestOffer.font = AppFont.font(.boldText, size: 13)
    priceOnYear.font = AppFont.font(.mediumText, size: 14)
    perYearLabel.font = AppFont.font(.mediumText, size: 16)
    perWeeklyLabel.font = AppFont.font(.mediumText, size: 16)
    mainScrollView.contentInsetAdjustmentBehavior = .never
    
    DispatchQueue.main.async {[weak self] in
      guard let self else {
        return
      }
      
      offerView.addShadow(color: UIColor(rgb: 0x000000))
      offerView.addCornerRadius(radius: 11)
    }
  }
  
  
  // MARK: - Action
  @IBAction func onTapTerms(_ sender: Any) {
    viewModel.action.send(.terms)
  }
  
  @IBAction func onTapRestore(_ sender: Any) {
    Task {
      await self.restorePurchases()
    }
  }
  
  @IBAction func onTapPrivacy(_ sender: Any) {
    viewModel.action.send(.privacy)
  }
  
  @IBAction func onTapYearView(_ sender: Any) {
    setupYearlyView(with: 0, boderColor: UIColor(rgb: 0xC96C32), textColor: UIColor(rgb: 0xFAF7F3), priceColor: UIColor(rgb: 0xFAF7F3), justColor: UIColor(rgb: 0xFAF7F3))
    
    setupWeaklyView(with: 2, boderColor: UIColor(rgb: 0xDFA683), backgroundColor: .clear, textColor: UIColor(rgb: 0x1A1A1A), priceColor: UIColor(rgb: 0x1A1A1A))
    viewModel.action.send(.chosePacket(registeredPurchase: .yearly))
  }
  
  @IBAction func onTapWeeklyView(_ sender: Any) {
    setupWeaklyView(with: 0, boderColor: UIColor(rgb: 0xC96C32), textColor: UIColor(rgb: 0xFAF7F3), priceColor: UIColor(rgb: 0xFAF7F3))
    
    setupYearlyView(with: 2, boderColor: UIColor(rgb: 0xDFA683), backgroundColor: .clear, textColor: UIColor(rgb: 0x1A1A1A), priceColor: UIColor(rgb: 0x1A1A1A), justColor: UIColor(rgb: 0x727272))
    viewModel.action.send(.chosePacket(registeredPurchase: .monthly))
  }
  
  @IBAction func onTapSubcribe(_ sender: Any) {
    self.purchaseProduct(type: viewModel.registeredPurchase)
  }
  
  @IBAction func onTapBack(_ sender: Any) {
    viewModel.action.send(.back)
  }
  
  override func offSub() {
    viewModel.action.send(.back)
  }
}

extension SubB3VC {
  private func setupYearlyView(with boderWidth: CGFloat = 4, boderColor: UIColor = UIColor(rgb: 0xDFA683), backgroundColor: UIColor = UIColor(rgb: 0xC96C32), textColor: UIColor = UIColor(rgb: 0x1A1A1A), priceColor: UIColor = UIColor(rgb: 0x1A1A1A), justColor: UIColor = UIColor(rgb: 0x727272)) {
    yearlyView.layer.borderWidth = boderWidth
    yearlyView.layer.borderColor = boderColor.cgColor
    yearlyView.backgroundColor = backgroundColor
    yearLable.textColor = textColor
    priceYearlyLabel.textColor = priceColor
    perYearLabel.textColor = textColor
    justLabel.textColor = justColor
  }
  
  private func setupWeaklyView(with boderWidth: CGFloat = 2, boderColor: UIColor = UIColor(rgb: 0xDFA683), backgroundColor: UIColor = UIColor(rgb: 0xC96C32), textColor: UIColor = UIColor(rgb: 0x1A1A1A), priceColor: UIColor = UIColor(rgb: 0x1A1A1A), justColor: UIColor = UIColor(rgb: 0x727272)) {
    weeklyView.layer.borderWidth = boderWidth
    weeklyView.layer.borderColor = boderColor.cgColor
    weeklyView.backgroundColor = backgroundColor
    weeklyLabel.textColor = textColor
    priceWeeklyLabel.textColor = priceColor
    perWeeklyLabel.textColor = textColor
  }
}


// MARK: - Navigate
extension SubB3VC {
  func setNavi(with navi: IAPNavigateType) {
    viewModel.action.send(.navi(navi: navi))
  }
}
