//
//  AppManger.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 15/5/25.
//

import Foundation
import Combine

class AppManager {
  static let shared = AppManager()
  
  private(set) var showAds: Bool = true
  @Published private(set) var hasSub: Bool = false
  
  private(set) var shouldShowOpenAds: Bool = true
  private(set) var spacingBottomCollectionView: CGFloat = 0
  
  // Dùng để hiển thị ads trong quá trình reviews app. Chỉ gán giá trị cho biến này qua firebase
  // display subscription
  var displaySub = 1 // 0: subA, 1: subB0, 2: subB1 , 3: subB3
  var isShowSubWithIntro = false
  
  // tracking
  var isCheckTracking : Bool = false
  
  // test
  let appSharedSecret = "f318fe192ce94653970070b2f1264920"
  
  // Dùng để check có đang mở màn sub ko
  var isOpenSub = false
  var isOpenOnboard = false
  var willShowOpenAds = false
  var didBecomeActive = false
}

extension AppManager {
  func setStateShouldShowOpenAds(_ state: Bool) {
    shouldShowOpenAds = state
  }
  
  func getspacingBottomCollectionView(_ spacing: CGFloat) {
    spacingBottomCollectionView = spacing
  }
  
  func getStateAds(showAds: Bool) {
    self.showAds = showAds
  }
  
  func getStateSub(hasSub: Bool) {
     self.hasSub = hasSub
  }
}
