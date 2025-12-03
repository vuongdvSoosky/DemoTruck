//
//  ATTCV.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/12/25.
//

import UIKit
import Combine
import AppTrackingTransparency

class ATTCV: BaseViewController {
  
  
  override func setColor() {
    self.view.backgroundColor = .red
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //showAdsTracking()
  }
  
  override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      requestATT()
  }

  private func requestATT() {
      guard #available(iOS 14, *) else { return }

      // Delay dài hơn cho XR
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          ATTrackingManager.requestTrackingAuthorization { status in
              DispatchQueue.main.async {
                  print("ATT status: \(status.rawValue)")
              }
          }
      }
  }
}
