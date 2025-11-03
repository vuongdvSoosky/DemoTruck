//
//  BaseNavigationController.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else { return }
        if navigationController.viewControllers.count > 1 {
            tabBar.isHidden = false  // Giữ TabBar luôn hiển thị khi push
        } else {
            tabBar.isHidden = false
        }
    }
}
