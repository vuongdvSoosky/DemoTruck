//
//  TabbarVC.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
import Combine
import SnapKit

class TabbarVC: UITabBarController, UITabBarControllerDelegate {
  
  private lazy var listVC = [TruckVC(), FleetManagementVC() ,SettingsVC()]
  private let defaultHeightForPlayView: CGFloat = 0
  private var previousIndex: Int = 0
  var countAdsToShow = 0
  var countShowIAP = 0
  
  private var subcription = Set<AnyCancellable>()
  private var lastSelectedIndex: Int?
  
  private lazy var bannerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var stackCreateNewSesssionView: UIStackView = {
    let stackView = UIStackView()
    return stackView
  }()
  
  private lazy var customItemTabbar: CustomTabbarView = {
    let tabbar = CustomTabbarView()
    tabbar.backgroundColor = UIColor(rgb: 0xFAF7F3)
    return tabbar
  }()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBar.isHidden = true
    self.tabBar.backgroundColor = .clear
    setupTabbarView()
    setConstraints()
  }
  
  private func setConstraints() {
    view.addSubview(customItemTabbar)
    view.addSubview(stackCreateNewSesssionView)
    
    customItemTabbar.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(95)
    }
  }
}
extension TabbarVC {
  func setSelectIndex(navigate: SenceNavigate) {
    selectedIndex = navigate.rawValue
    switch navigate {
    case .truck:
      customItemTabbar.getItemFromTabbar(.truck)
    case .diary:
      customItemTabbar.getItemFromTabbar(.diary)
    default:
      customItemTabbar.getItemFromTabbar(.settings)
    }
  }
}

extension TabbarVC: CustomTabbarViewDelagate {
  func didSelectedHorse(index: Int) {
    self.selectedIndex = index
  }
  
  func didSelectedTrack(index: Int) {
    self.selectedIndex = index
//    showInterAds(didDismiss: {[weak self] in
//      guard let self else {
//        return
//      }
//      if UserDefaultsManager.shared.get(of: Bool.self, key: .showTutorialTrack) == false {
//        showPopupTutorialView(0)
//        UserDefaultsManager.shared.set(true, key: .showTutorialTrack)
//      }
//      
//      self.selectedIndex = index
//    }, didFaild: {[weak self] in
//      guard let self else {
//        return
//      }
//      if UserDefaultsManager.shared.get(of: Bool.self, key: .showTutorialTrack) == false {
//        showPopupTutorialView(0)
//        UserDefaultsManager.shared.set(true, key: .showTutorialTrack)
//      }
//      self.selectedIndex = index
//    }
//    )
  }
  
  func didSelectedTraining(index: Int) {
    self.selectedIndex = index
  }
  
  func didSelectedSetting(index: Int) {
    self.selectedIndex = index
  }
  
  private func hideCustomTabbarView() {
    self.customItemTabbar.snp.updateConstraints { make in
      make.height.equalTo(0)
    }
  }
  
  func showCustomTabbarView() {
    self.customItemTabbar.snp.updateConstraints { make in
      make.height.equalTo(95)
    }
  }
  
  func reloadFleetManagementVC() {
      if let nav = viewControllers?[1] as? UINavigationController,
         let fleetVC = nav.viewControllers.first(where: { $0 is FleetManagementVC }) as? FleetManagementVC {
          fleetVC.reloadDataHistoryTab()
      }
  }
  
  private func showPopupTutorialView(_ index: Int) {
//    let view = PopupTutorialView()
//    view.setupData(TutorialType.allCases[index])
//    view.showSlideView(view: self.view)
  }
}

extension TabbarVC {
  private func setupTabbarView() {
    self.viewControllers = listVC
    customItemTabbar.delegate = self
  }
}

// MARK: Action ads
extension TabbarVC {
  private func showInterAds(didDismiss: @escaping() -> Void, didFaild: @escaping() -> Void) {
    AdMobManager.shared.countAdsToShowIntertitial(startAds: 1,
                                                  loopAds: 1, countFullAds: &countAdsToShow,
                                                  unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatInterstitialID1),
                                                  isSplash: false,
                                                  blockWillDismiss: nil,
                                                  blockDidDismiss: didDismiss)
    AdMobManager.shared.blockFullScreenAdFaild = { error in
      didFaild()
    }
  }
  
  private func showReward(with idAds: String , didReward: @escaping (Bool) -> Void) {
    AdMobManager.shared.showRewarded(unitId: AdUnitID(rawValue: idAds), completion: didReward)
  }
}
