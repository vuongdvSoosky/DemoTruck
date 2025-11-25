//
//  CustomAnnotationCalloutView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 25/11/25.
//

import UIKit
import SnapKit

final class CustomAnnotationCalloutView: BaseView {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.mediumText, size: 17)
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let desLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.lightText, size: 15)
    label.textColor = UIColor(rgb: 0x909090)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let iconButton: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .icPlus
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let titleButton: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.semiBoldText, size: 12)
    label.textColor = UIColor(rgb: 0xF2F2F2)
    label.text = "Add Stop"
    label.textAlignment = .center
    return label
  }()
  
  private lazy var buttonView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xF26101)
    view.cornerRadius = 12
    view.isUserInteractionEnabled = true
    
    let stackView = UIStackView(arrangedSubviews: [iconButton, titleButton])
    stackView.axis = .horizontal
    stackView.spacing = 6
    stackView.alignment = .center
    stackView.distribution = .fill
    
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleButtonTap)))
    return view
  }()
  
  // MARK: - Properties
  
  var onButtonTapped: (() -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  // MARK: - Setup
  
  private func setupView() {
    backgroundColor = .white
    layer.cornerRadius = 16
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.15
    layer.shadowOffset = CGSize(width: 0, height: 4)
    layer.shadowRadius = 8
    tag = 999
    
    addSubviews(titleLabel, desLabel, buttonView)
    
    // MARK: Constraints
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(12)
      make.centerX.equalToSuperview()
      make.width.lessThanOrEqualTo(buttonView.snp.width)
    }
    
    desLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(2)
      make.centerX.equalToSuperview()
      make.width.lessThanOrEqualTo(buttonView.snp.width)
    }
    
    buttonView.snp.makeConstraints { make in
      make.top.equalTo(desLabel.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
      make.width.equalTo(220)
      make.height.equalTo(40)
      make.bottom.equalToSuperview().inset(20)
    }
    
    // MARK: Set width của view chính theo buttonView
    self.snp.makeConstraints { make in
      make.width.equalTo(buttonView.snp.width).inset(-17)
    }
  }
  
  // MARK: - Config
  
  func configure(title: String, des: String) {
    titleLabel.text = title
    desLabel.text = des
  }
  
  func configureButton(title: String, icon: UIImage) {
    titleButton.text = title
    iconButton.image = icon
  }
  
  // MARK: - Actions
  
  @objc private func handleButtonTap() {
    onButtonTapped?()
  }
}
