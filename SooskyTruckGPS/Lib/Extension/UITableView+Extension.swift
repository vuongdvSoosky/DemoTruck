//
//  UITableView+Extension.swift
//  BaseSubscription
//
//  Created by Việt Nguyễn on 13/1/25.
//

import UIKit

extension UITableView {
  func registerCell<T: UITableViewCell>(_ cell: T.Type) {
    register(cell.self, forCellReuseIdentifier: "\(cell.self)")
  }
  
  func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: "\(cell.self)", for: indexPath) as? T
    else {
      fatalError("Could not dequeue cell with identifier: \(cell.self)")
    }
    return cell
  }
  
  func setEmptyHistory() {
    let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
    let emptyImageView = UIImageView(image: UIImage(named: "ic_empty"))
    emptyView.addSubview(emptyImageView)
    emptyImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
//      make.height.equalTo(120)
//      make.width.equalTo(80)
    }
    
    let emptyLabel = UILabel()
    emptyLabel.text = "No history found"
    emptyLabel.font = .systemFont(ofSize: 14, weight: .medium)
    emptyLabel.textColor = UIColor(hex: "5358FD")
    emptyLabel.textAlignment = .center
    
    emptyView.addSubview(emptyLabel)
    emptyLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(emptyImageView.snp.bottom).offset(20)
    }
    
    self.backgroundView = emptyView
    self.separatorStyle = .none
  }
  
  func restore() {
    self.backgroundView = nil
  }
  
  
}
