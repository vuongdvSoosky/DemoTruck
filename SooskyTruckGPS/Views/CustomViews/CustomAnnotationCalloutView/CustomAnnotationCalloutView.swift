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
    label.font = UIFont.boldSystemFont(ofSize: 16)
    label.textColor = .black
    label.textAlignment = .center
    label.numberOfLines = 2
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
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xF26101)
    view.cornerRadius = 12
    
    let stackView = UIStackView(arrangedSubviews: [iconButton, titleButton])
    stackView.axis = .horizontal
    stackView.spacing = 6
    stackView.alignment = .center
    stackView.distribution = .equalCentering
    
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    view.isUserInteractionEnabled = true
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
    
    addSubviews(titleLabel, buttonView)
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(12)
      make.left.right.equalToSuperview().inset(16)
    }
    
    buttonView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
      make.left.right.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(23)
    }
  }
  
  // MARK: - Configuration
  
  func configure(title: String) {
    titleLabel.text = title
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
