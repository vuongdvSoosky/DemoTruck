//
//  EmptyView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 27/11/25.
//

import UIKit
import SnapKit

final class EmptyView: UIView {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = AppFont.font(.boldText, size: 17)
    label.textColor = UIColor(rgb: 0x909090)
    return label
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = AppFont.font(.regularText, size: 17)
    label.textColor = UIColor(rgb: 0x909090)
    return label
  }()
  
  private let stackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 6
    return stack
  }()
  
  init(title: String, description: String) {
    super.init(frame: .zero)
    setupUI()
    configure(title: title, description: description)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    isHidden = true
    
    addSubview(stackView)
    [titleLabel, descriptionLabel].forEach { stackView.addArrangedSubview($0) }
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.right.equalToSuperview().inset(16)
    }
  }
  
  func configure(title: String, description: String) {
    titleLabel.text = title
    descriptionLabel.text = description
  }
  
  func show() {
    isHidden = false
  }
  
  func hide() {
    isHidden = true
  }
}
