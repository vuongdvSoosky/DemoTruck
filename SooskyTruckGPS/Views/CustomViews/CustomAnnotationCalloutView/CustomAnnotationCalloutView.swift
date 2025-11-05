//
//  CustomAnnotationCalloutView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/11/25.
//

import UIKit

class CustomAnnotationCalloutView: UIView {
  private let titleLabel = UILabel()
  private let button = UIButton(type: .system)
  
  var onButtonTapped: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = .white
    layer.cornerRadius = 16
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.15
    layer.shadowOffset = CGSize(width: 0, height: 4)
    layer.shadowRadius = 8
    self.tag = 999
    
    titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
    titleLabel.textColor = UIColor.black
    titleLabel.textAlignment = .center
    
    button.setTitle("＋ Add Stop", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor.orange
    button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    button.layer.cornerRadius = 18
    button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
    
    addSubview(titleLabel)
    addSubview(button)
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    button.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      
      button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
      button.centerXAnchor.constraint(equalTo: centerXAnchor),
      button.widthAnchor.constraint(equalToConstant: 160),
      button.heightAnchor.constraint(equalToConstant: 36),
      button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
  }
  
  func configure(title: String) {
    titleLabel.text = title
  }
  
  @objc private func handleButtonTap() {
    onButtonTapped?()
  }
}
