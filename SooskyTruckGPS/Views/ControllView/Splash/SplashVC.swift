//
//  SplashVC.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 10/9/25.
//

import UIKit
import SnapKit

class SplashVC: BaseViewController {
  
  private lazy var contanierView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .icSplash
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppManager.shared.setStateShouldShowOpenAds(false)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      if UserDefaultsManager.shared.get(of: Bool.self, key: .showOnboard) {
        self.setRoot(TabbarVC())
      } else {
        self.setRoot(Onboard1VC())
      }
    }
  }
  
  override func addComponents() {
    self.view.addSubview(contanierView)
    self.view.addSubview(iconImageView)
  }
  
  override func setConstraints() {
    contanierView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    iconImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(160)
    }
  }
  
  override func setColor() {
    let color: [UIColor] = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
    self.contanierView.addArrayColorGradient(arrayColor: color, startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1))
  }
  
  private func setRoot(_ vc: UIViewController) {
    guard let window = UIApplication.shared.windows.first else { return }
    let nav = UINavigationController(rootViewController: vc)
    nav.isNavigationBarHidden = true
    window.rootViewController = nav
    window.makeKeyAndVisible()
  }
}
