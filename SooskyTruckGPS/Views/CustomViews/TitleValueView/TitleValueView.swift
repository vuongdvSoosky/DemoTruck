//
//  TitleValueView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import UIKit
import SnapKit

final class TitleValueView: UIView {
  
  private let titleLabel = UILabel()
  private let valueLabel = UILabel()
  
  init(title: String,
       value: String,
       titleColor: UIColor = UIColor(rgb: 0x909090),
       valueColor: UIColor = UIColor(rgb: 0xF26101),
       titleFont: UIFont = AppFont.font(.mediumText, size: 15),
       valueFont: UIFont = AppFont.font(.boldText, size: 17)) {
    super.init(frame: .zero)
    
    titleLabel.text = title
    titleLabel.textColor = titleColor
    titleLabel.font = titleFont
    titleLabel.textAlignment = .center
    
    valueLabel.text = value
    valueLabel.textColor = valueColor
    valueLabel.font = valueFont
    valueLabel.textAlignment = .center
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
    stackView.axis = .vertical
    stackView.spacing = 3
    stackView.distribution = .fill
    
    addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Update value dynamically
  func updateValue(_ text: String) {
    valueLabel.text = text
  }
}
