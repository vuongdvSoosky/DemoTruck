//
//  SubB0VC.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 7/8/25.
//

import UIKit

class SubB0VC: StoreManager {
  
  @IBOutlet weak var unlimitedLable: UILabel!
  @IBOutlet weak var premiumLabel: UILabel!
  @IBOutlet var contentLabel: [UILabel]!
  @IBOutlet weak var desLabel: UILabel!
  @IBOutlet weak var yearLable: UILabel!
  @IBOutlet weak var monthlyLabel: UILabel!
  @IBOutlet weak var priceYearlyLabel: UILabel!
  @IBOutlet weak var priceMonthyLabel: UILabel!
  @IBOutlet weak var termsLabel: UILabel!
  @IBOutlet weak var restoreLabel: UILabel!
  @IBOutlet weak var privacyLabel: UILabel!
  
  @IBOutlet weak var imageChooseYear: UIImageView!
  @IBOutlet weak var imageChooseMonth: UIImageView!
  
  @IBOutlet weak var yearlyView: UIView!
  @IBOutlet weak var mainScrollView: UIScrollView!
  @IBOutlet weak var monthlyView: UIView!
  
  private let viewModel = IAPViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setProperties()
//    viewModel.action.send(.chosePacket(registeredPurchase: .yearly))
    AppManager.shared.setStateShouldShowOpenAds(false)
//    setupYearlyView()
  }
  
  private func setProperties() {
    unlimitedLable.font = AppFont.font(.boldText, size: 32)
    premiumLabel.font = AppFont.font(.heavy, size: 20)
    contentLabel.forEach({$0.font = AppFont.font(.mediumText, size: 18)})
    desLabel.font = AppFont.font(.regularText, size: 14)
    termsLabel.font = AppFont.font(.lightText, size: 14)
    privacyLabel.font = AppFont.font(.lightText, size: 14)
    monthlyLabel.font = AppFont.font(.bold, size: 17)
    yearLable.font = AppFont.font(.bold, size: 17)
    priceYearlyLabel.font = AppFont.font(.bold, size: 17)
    priceMonthyLabel.font = AppFont.font(.bold, size: 17)
    restoreLabel.font = AppFont.font(.semiBoldText, size: 18)
    
    mainScrollView.contentInsetAdjustmentBehavior = .never
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
    setupYearlyView(with: 3.5, boderColor: UIColor(rgb: 0xC96C32), textColor: UIColor(rgb: 0xFAF7F3), priceColor: UIColor(rgb: 0xFAF7F3))
  
    setupMonthlyView(with: 3.5, boderColor: UIColor(rgb: 0xFFFEE9), textColor: UIColor(rgb: 0x1A1A1A), priceColor: UIColor(rgb: 0x1A1A1A))
    self.purchaseProduct(type: .yearly)
    
    imageChooseYear.image = .icChooseSub
    imageChooseMonth.image = .icUnChooseSub
  }
  

  
  @IBAction func onTapMonthly(_ sender: Any) {
    setupMonthlyView(with: 3.5, boderColor: UIColor(rgb: 0xC96C32), textColor: UIColor(rgb: 0xFAF7F3), priceColor: UIColor(rgb: 0xFAF7F3))
    
    setupYearlyView(with: 3.5, boderColor: UIColor(rgb: 0xFFFEE9), textColor: UIColor(rgb: 0x1A1A1A), priceColor: UIColor(rgb: 0x1A1A1A))
    
    self.purchaseProduct(type: .monthly)
    imageChooseMonth.image = .icChooseSub
    imageChooseYear.image = .icUnChooseSub
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

extension SubB0VC {
  private func setupYearlyView(with boderWidth: CGFloat = 2, boderColor: UIColor = UIColor(rgb: 0xC96C32),
                               textColor: UIColor = UIColor(rgb: 0x1A1A1A),
                               priceColor: UIColor = UIColor(rgb: 0x1A1A1A)) {
    yearlyView.layer.borderWidth = boderWidth
    yearlyView.backgroundColor = boderColor
    yearLable.textColor = textColor
    priceYearlyLabel.textColor = priceColor
  }
  
  private func setupMonthlyView(with boderWidth: CGFloat = 2, boderColor: UIColor = UIColor(rgb: 0xC96C32),
                                textColor: UIColor = UIColor(rgb: 0x1A1A1A),
                                priceColor: UIColor = UIColor(rgb: 0x1A1A1A)) {
    monthlyView.layer.borderWidth = boderWidth
    monthlyView.backgroundColor = boderColor
    
    monthlyLabel.textColor = textColor
    priceMonthyLabel.textColor = priceColor
  }
}

// MARK: - Navigate
extension SubB0VC {
  func setNavi(with navi: IAPNavigateType) {
    viewModel.action.send(.navi(navi: navi))
  }
}
