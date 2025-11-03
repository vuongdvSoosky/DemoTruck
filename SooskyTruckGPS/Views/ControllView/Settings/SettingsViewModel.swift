import Foundation
import Combine

class SettingsViewModel: BaseViewModel {
  
  enum Action {
    case other
    case iap
    case tutorial
  }
  
  
  let action = PassthroughSubject<Action, Never>()
  let listItem = CurrentValueSubject<[Setting], Never>(Setting.allCases)
  
  private let router = SettingsRouter()
  
  override init() {
    super.init()
    
    // Subcription
    action.sink(receiveValue: {[weak self] action in
      guard let self else {
        return
      }
      progressAction(action)
    }).store(in: &subscriptions)
  }
}

extension SettingsViewModel {
  private func progressAction(_ action: Action) {
    switch action {
    case .other:
      print("To do")
    case .iap:
      router.route(to: .iap)
    case .tutorial:
      router.route(to: .tutorial)
    }
  }
}
