import UIKit

class SettingsRouter: Router {
  typealias RouteType = Route
  enum Route: String {
    case end
    case iap
    case tutorial
  }
}

extension SettingsRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .end:
      break
    case .iap:
      switch AppManager.shared.displaySub {
      case 0:
        context.push(to: SubAVC(), animated: true)
      default:
        context.push(to: SubB0VC(), animated: true)
      }
    case .tutorial:
      let tutorialVC = TutorialVC()
      context.push(to: tutorialVC, animated: true)
    }
  }
}
