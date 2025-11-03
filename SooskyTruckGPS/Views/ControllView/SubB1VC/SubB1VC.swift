//
//  SubB1VC.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 7/8/25.
//

import UIKit

class SubB1VC: StoreManager {
  
  @IBOutlet weak var unlimitedLable: UILabel!
  @IBOutlet weak var premiumLabel: UILabel!
  @IBOutlet weak var desLabel: UILabel!
  @IBOutlet weak var subcribeLabel: UILabel!
  @IBOutlet weak var termsLabel: UILabel!
  @IBOutlet weak var restoreLabel: UILabel!
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var subcribeView: UIView!
  @IBOutlet var priceLabel: [UILabel]!
  @IBOutlet weak var mainScrollView: UIScrollView!
  
  private var lastContentOffset: CGFloat = 0
  
  private let viewModel = IAPViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.action.send(.chosePacket(registeredPurchase: .weekly))
    AppManager.shared.setStateShouldShowOpenAds(false)
    setProperties()
  }
  
  private func setProperties() {
    unlimitedLable.font = AppFont.font(.boldText, size: 32)
    premiumLabel.font = AppFont.font(.heavy, size: 20)
    desLabel.font = AppFont.font(.regularText, size: 14)
    termsLabel.font = AppFont.font(.lightText, size: 14)
    privacyLabel.font = AppFont.font(.lightText, size: 14)
    subcribeLabel.font = AppFont.font(.bold, size: 20)
    restoreLabel.font = AppFont.font(.semiBoldText, size: 18)
    priceLabel.forEach({$0.font = AppFont.font(.pro, size: 16)})
  
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
    
  @IBAction func onTapSubcribe(_ sender: Any) {
    self.purchaseProduct(type: viewModel.registeredPurchase)
  }
  
  @IBAction func onTapClose(_ sender: Any) {
    viewModel.action.send(.back)
  }
  
  override func offSub() {
    viewModel.action.send(.back)
  }
}

// MARK: - Navigate
extension SubB1VC {
  func setNavi(with navi: IAPNavigateType) {
    viewModel.action.send(.navi(navi: navi))
  }
}
