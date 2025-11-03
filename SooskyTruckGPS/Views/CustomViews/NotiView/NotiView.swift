//
//  NotiView.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 13/5/25.
//

import UIKit

class NotiView: BaseView {
  
  @IBOutlet var contentView: UIView!
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var desLabel: UILabel!
  
  
  override func addComponents() {
    loadNibNamed()
    addSubview(contentView)
  }
  
  override func setConstraints() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  override func setProperties() {
    desLabel.font = AppFont.font(.lightText, size: 12)
  }
  
  override func binding() {
//    AlarmManager.shared.$currentItemAlarm
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] itemAlarm in
//        guard let self else {
//          return
//        }
//        guard let time = itemAlarm?.alarmTime?.formattedTime() else {
//          return
//        }
//        timeLabel.attributedText = time.asAlarmAttributedText()
//        desLabel.text = itemAlarm?.note ?? "Reminder"
//        
//      }.store(in: &subscriptions)
  }
  
  @IBAction func onTapClose(_ sender: Any) {
//    AlarmManager.shared.stop()
//    if let topVC = UIApplication.topViewController() as? TabbarVC {
//      topVC.closeNotiView()
//    } else {
//      if let topVC = UIApplication.topViewController() as? BaseViewController {
//        topVC.closeNotiView()
//      }
//    }
  }
}
