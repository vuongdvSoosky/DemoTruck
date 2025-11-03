//
//  CustomTabbarViewModel.swift
//  Plant_IOS
//
//  Created by VuongDv on 24/02/2025.
//

import Foundation
import Combine

class CustomTabbarViewModel: BaseViewModel {
  enum Action {
    case chooseItem(tabbarItem: TabbarItem)
  }
  
  let action = PassthroughSubject<Action, Never>()
  let tabbarItem = CurrentValueSubject<TabbarItem, Never>(.truck)
  
  override init() {
    super.init()
    
    // Subscriptions
    action.sink(receiveValue: { [weak self] action in
      guard let self else {
        return
      }
      processAction(action)
    }).store(in: &subscriptions)
  }
}

extension CustomTabbarViewModel {
  private func processAction(_ action: Action) {
    switch action {
    case .chooseItem(let tabbarItem):
      self.tabbarItem.value = tabbarItem
    }
  }
}

