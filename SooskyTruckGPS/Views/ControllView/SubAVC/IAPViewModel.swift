//
//  IAPViewModel.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 8/8/25.
//

import Foundation
import Combine
import UIKit

class IAPViewModel: BaseViewModel {
  
  // MARK: - Enums
  
  enum State {
    case initial
  }
  
  enum Action {
    case back
    case chosePacket(registeredPurchase: RegisteredPurchase)
    case purchase(vc: UIViewController)
    case restorePurchases(vc: UIViewController)
    case terms
    case privacy
    case navi(navi: IAPNavigateType)
  }
  
  // MARK: - Properties
  
  let action = PassthroughSubject<Action, Never>()
  var registeredPurchase: RegisteredPurchase = .yearly
  private var navigate: IAPNavigateType = .other
  private let router = IAPRouter()
  
  // MARK: - Init
  
  override init() {
    super.init()
    bindActions()
  }
  
  // MARK: - Private Methods
  
  private func bindActions() {
    action
      .sink { [weak self] action in
        self?.processAction(action)
      }
      .store(in: &subscriptions)
  }
  
  private func processAction(_ action: Action) {
    switch action {
    case .back:
      switch navigate {
      case .onboard:
        router.route(to: .tabbar)
      case .other:
        router.route(to: .back)
      }
    case .chosePacket(let registeredPurchase):
      self.registeredPurchase = registeredPurchase
    case .purchase(let vc):
      if let purchasableVC = vc as? Purchasable {
        purchasableVC.purchaseProduct(type: self.registeredPurchase)
      } else {
        LogManager.show("⚠️ ViewController does not conform to Purchasable")
      }
    case .restorePurchases(let vc):
      if let purchasableVC = vc as? Purchasable {
        purchasableVC.purchaseProduct(type: self.registeredPurchase)
      } else {
        LogManager.show("⚠️ ViewController does not conform to Purchasable")
      }
    case .terms:
      openURL(AppText.term)
    case .privacy:
      openURL(AppText.policy)
    case .navi(navi: let navi):
      self.navigate = navi
    }
  }
}

extension IAPViewModel {
  func openURL(_ urlLink: String) {
    if let url = URL(string: urlLink) {
      UIApplication.shared.open(url)
    }
  }
}
