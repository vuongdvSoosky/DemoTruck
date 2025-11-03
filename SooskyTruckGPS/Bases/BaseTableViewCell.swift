//
//  BaseCollectionViewCell.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
import Combine

class BaseTableViewCell: UITableViewCell, ViewProtocol {
  var subscriptions = Set<AnyCancellable>()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    addComponents()
    setConstraints()
    setProperties()
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      setColor()
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.selectionStyle = .none
    addComponents()
    setConstraints()
    setProperties()
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      setColor()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    removeSubs()
  }
  
  deinit {
    removeSubs()
  }
  
  func addComponents() {}
  
  func setConstraints() {}
  
  func setProperties() {}
  
  func setColor() {}
  
  func binding() {}
  
  func removeSubs() {
    subscriptions.forEach { $0.cancel() }
    subscriptions.removeAll()
  }
}
