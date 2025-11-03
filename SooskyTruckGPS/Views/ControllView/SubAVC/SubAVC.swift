//
//  SubAVC.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 6/8/25.
//

import UIKit

class SubAVC: StoreManager {
  
  @IBOutlet private weak var subcribeLabel: UILabel!
  @IBOutlet private weak var yearlyLabel: UILabel!
  @IBOutlet private weak var weeklyLabel: UILabel!
  @IBOutlet private weak var monthlyLabel: UILabel!
  
  @IBOutlet private weak var termsLabel: UILabel!
  @IBOutlet private weak var restoreLabel: UILabel!
  @IBOutlet private weak var privacyLabel: UILabel!
  @IBOutlet private weak var contentLabel: UILabel!
  @IBOutlet private weak var yearlyView: UIView!
  @IBOutlet private weak var weaklyView: UIView!
  @IBOutlet private weak var monthlyView: UIView!
  @IBOutlet var desLabel: [UILabel]!
  
  @IBOutlet weak var premiumLabel: UILabel!
  @IBOutlet weak var weeklyPrice: UILabel!
  @IBOutlet weak var yearPrice: UILabel!
  @IBOutlet weak var monthPrice: UILabel!
  
  
  @IBOutlet weak var topLayoutContraints: NSLayoutConstraint!
  
  @IBOutlet weak var mainScrollView: UIScrollView!
  private let viewModel = IAPViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setProperties()
//    viewModel.action.send(.chosePacket(registeredPurchase: .yearly))
    AppManager.shared.setStateShouldShowOpenAds(false)
  }
  
  private func setProperties() {
    termsLabel.font = AppFont.font(.light, size: 14)
    privacyLabel.font = AppFont.font(.light, size: 14)
    restoreLabel.font = AppFont.font(.semiBold, size: 18)
    subcribeLabel.font = AppFont.font(.bold, size: 20)
    contentLabel.font = AppFont.font(.regularText, size: 14)
    desLabel.forEach({$0.font = AppFont.font(.mediumText, size: 18)})
    yearlyLabel.font = AppFont.font(.boldText, size: 17)
    weeklyLabel.font = AppFont.font(.boldText, size: 17)
    weeklyPrice.font = AppFont.font(.boldText, size: 17)
    yearPrice.font = AppFont.font(.boldText, size: 17)
    monthlyLabel.font = AppFont.font(.boldText, size: 17)
    monthPrice.font = AppFont.font(.boldText, size: 17)
    premiumLabel.font = AppFont.font(.heavy, size: 16)
    
    mainScrollView.contentInsetAdjustmentBehavior = .never
  }
  
  @IBAction func onTapYearlyView(_ sender: Any) {
    setupYearlyView(with: 0, boderColor: UIColor(rgb: 0xDFA683), background: UIColor(rgb: 0xC96C32))
    
    setupWeaklyView(with: 2, boderColor: UIColor(rgb: 0xDFA683), background: .clear)
    
    setupMonthlyView(with: 2, boderColor: UIColor(rgb: 0xDFA683), background: .clear)
    
    viewModel.action.send(.chosePacket(registeredPurchase: .yearly))
  }
  
  @IBAction func onTapWeaklyView(_ sender: Any) {
    setupWeaklyView(with: 0, boderColor: UIColor(rgb: 0xDFA683), background: UIColor(rgb: 0xC96C32))
    
    setupYearlyView(with: 2, boderColor: UIColor(rgb: 0xDFA683), background: .clear)
    setupMonthlyView(with: 2, boderColor: UIColor(rgb: 0xDFA683), background: .clear)
    viewModel.action.send(.chosePacket(registeredPurchase: .weekly))
  }
  
  @IBAction func onTapMonthlyView(_ sender: Any) {
    setupMonthlyView(with: 0, boderColor: UIColor(rgb: 0xDFA683), background: UIColor(rgb: 0xC96C32))
    
    setupWeaklyView(with: 2, boderColor: UIColor(rgb: 0xDFA683),background: .clear)
    setupYearlyView(with: 2, boderColor: UIColor(rgb: 0xDFA683),background: .clear)
    viewModel.action.send(.chosePacket(registeredPurchase: .monthly))
  }
  
  @IBAction func onTapSubcribeView(_ sender: Any) {
    self.purchaseProduct(type: viewModel.registeredPurchase)
  }
  
  @IBAction func onTapTerms(_ sender: Any) {
    viewModel.action.send(.terms)
  }
  
  @IBAction func onTapPrivacy(_ sender: Any) {
    viewModel.action.send(.privacy)
  }
  
  @IBAction func onTapRestore(_ sender: Any) {
    Task {
       await self.restorePurchases()
    }
  }
  
  @IBAction func onTapBack(_ sender: Any) {
    viewModel.action.send(.back)
    LogManager.show("Back")
  }
  
  override func offSub() {
    viewModel.action.send(.back)
  }
}

extension SubAVC {
  private func setupYearlyView(with boderWidth: CGFloat = 0, boderColor: UIColor = UIColor(rgb: 0xDFA683), background: UIColor = .clear) {
    yearlyView.layer.borderWidth = boderWidth
    yearlyView.layer.borderColor = boderColor.cgColor
    yearlyView.backgroundColor = background
  }
  
  private func setupWeaklyView(with boderWidth: CGFloat = 0, boderColor: UIColor = UIColor(rgb: 0xDFA683), background: UIColor = .clear) {
    weaklyView.layer.borderWidth = boderWidth
    weaklyView.layer.borderColor = boderColor.cgColor
    weaklyView.backgroundColor = background
  }
  
  private func setupMonthlyView(with boderWidth: CGFloat = 0, boderColor: UIColor = UIColor(rgb: 0xDFA683), background: UIColor = .clear) {
    monthlyView.layer.borderWidth = boderWidth
    monthlyView.layer.borderColor = boderColor.cgColor
    monthlyView.backgroundColor = background
  }
}

// MARK: - Navigate
extension SubAVC {
  func setNavi(with navi: IAPNavigateType) {
    viewModel.action.send(.navi(navi: navi))
  }
}
