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
  
  @IBOutlet weak var subscribeLabel: UILabel!
  @IBOutlet weak var proView: UIView!
  @IBOutlet weak var subcribeView: UIView!
  
  private let viewModel = IAPViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setProperties()
//    viewModel.action.send(.chosePacket(registeredPurchase: .yearly))
    AppManager.shared.setStateShouldShowOpenAds(false)
    setColor()
//    setupYearlyView()
  }
  
  private func setProperties() {
    unlimitedLable.font = AppFont.font(.boldText, size: 32)
    premiumLabel.font = AppFont.font(.heavy, size: 20)
    contentLabel.forEach({$0.font = AppFont.font(.mediumText, size: 20)})
    desLabel.font = AppFont.font(.regularText, size: 14)
    termsLabel.font = AppFont.font(.lightText, size: 14)
    privacyLabel.font = AppFont.font(.lightText, size: 14)
    monthlyLabel.font = AppFont.font(.bold, size: 17)
    yearLable.font = AppFont.font(.bold, size: 17)
    priceYearlyLabel.font = AppFont.font(.bold, size: 17)
    priceMonthyLabel.font = AppFont.font(.bold, size: 17)
    restoreLabel.font = AppFont.font(.semiBoldText, size: 18)
    subscribeLabel.font = AppFont.font(.boldText, size: 20)
    
    mainScrollView.contentInsetAdjustmentBehavior = .never
  }

  private func setColor() {
    DispatchQueue.main.async {
      let color: [UIColor] = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      self.subcribeView.addArrayColorGradient(arrayColor: color, startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
      self.subcribeView.cornerRadius = 20
      self.subcribeView.clipsToBounds = true
      
      let proviewColors: [UIColor] = [UIColor(rgb: 0xFFD138), UIColor(rgb: 0xF58300)]
      self.proView.addArrayColorGradient(arrayColor: proviewColors, startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
      self.proView.cornerRadius = 14
      self.proView.clipsToBounds = true
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
    setupYearlyView(with: 3.5, boderColor: UIColor(rgb: 0xF26101))
  
    setupMonthlyView(with: 2, boderColor: UIColor(rgb: 0xFFC096))
    self.purchaseProduct(type: .yearly)
    
    imageChooseYear.image = .icChooseSub
    imageChooseMonth.image = .icUnChooseSub
  }
  
  @IBAction func onTapMonthly(_ sender: Any) {
    setupMonthlyView(with: 3.5, boderColor: UIColor(rgb: 0xF26101))
    
    setupYearlyView(with: 2, boderColor: UIColor(rgb: 0xFFC096))
    
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
  
  @IBAction func onTapSubscribe(_ sender: Any) {
    
  }
  
  override func offSub() {
    viewModel.action.send(.back)
  }
}

extension SubB0VC {
  private func setupYearlyView(with boderWidth: CGFloat = 3.5, boderColor: UIColor = UIColor(rgb: 0xF26101),
                               textColor: UIColor = UIColor(rgb: 0x332644),
                               priceColor: UIColor = UIColor(rgb: 0x332644)) {
    yearlyView.layer.borderWidth = boderWidth
    yearlyView.layer.borderColor = boderColor.cgColor
    yearLable.textColor = textColor
    
    priceYearlyLabel.textColor = priceColor
  }
  
  private func setupMonthlyView(with boderWidth: CGFloat = 2, boderColor: UIColor = UIColor(rgb: 0xFFC096),
                                textColor: UIColor = UIColor(rgb: 0x332644),
                                priceColor: UIColor = UIColor(rgb: 0x332644)) {
    monthlyView.layer.borderWidth = boderWidth
    monthlyView.layer.borderColor = boderColor.cgColor
    
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
