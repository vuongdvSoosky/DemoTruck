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
  private var overlayView: UIView?
  
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
    tabbar.backgroundColor = UIColor(rgb: 0xF6F6F6)
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let overlay = overlayView {
      view.bringSubviewToFront(overlay)
    }
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
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      guard let self else {
        return
      }
      reloadFleetManagementTabSaveVC()
    }
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
    if let nav = listVC[1] as? FleetManagementVC {
      DispatchQueue.main.asyncAfter(deadline: .now()) {
        nav.reloadDataHistoryTab()
      }
    }
  }
  
  func reloadFleetManagementTabSaveVC() {
    if let nav = listVC[1] as? FleetManagementVC {
      nav.reloadDataForSavedTab()
    }
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

extension TabbarVC {
  func showTabbarOverlay() {
    guard overlayView == nil else { return }
    
    let overlay = UIView()
    overlay.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.7)
    overlay.isUserInteractionEnabled = true
    overlay.alpha = 0
    
    self.view.addSubview(overlay)
    overlay.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(95)
    }
    
    UIView.animate(withDuration: 0.25) {
      overlay.alpha = 1
    }
    
    self.overlayView = overlay
  }
  
  func hideOverlay() {
    guard let overlay = overlayView else { return }
    
    overlay.removeFromSuperview()
    self.overlayView = nil
  }
}
