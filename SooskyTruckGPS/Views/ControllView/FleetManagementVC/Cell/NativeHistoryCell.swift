//
//  NativeHistoryCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 2/12/25.
//

import UIKit
import SnapKit

class NativeHorseCell: BaseCollectionViewCell {
  private lazy var nativeView: UIView = {
    let view = UIView()
    view.cornerRadius = 12
    view.clipsToBounds = true
    return view
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 12
    view.clipsToBounds = true
    return view
  }()
  
  override func addComponents() {
    self.addSubview(containerView)
    containerView.addSubview(nativeView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    nativeView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(2)
      make.trailing.leading.equalToSuperview().inset(2)
      make.bottom.equalToSuperview().inset(2)
      make.height.equalTo(110)
    }
  }
  
  func setupNativeView() {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    AdMobManager.shared.addAdNative(
      unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatNativeAdvanced1),
      rootVC: topVC,
      views: [nativeView],
      type: .custom,
      ratio: .portrait
    )
  }
  
  override func setColor() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.containerView.addShadow()
    }
  }
}
