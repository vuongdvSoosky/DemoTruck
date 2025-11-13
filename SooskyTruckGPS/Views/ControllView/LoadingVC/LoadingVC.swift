//
//  LoadingVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import SnapKit
import UIKit

class LoadingVC: BaseViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFF8EC)
    return view
  }()
  

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Good Ride! \n Preparing Results..."
    label.textColor = UIColor(rgb: 0x5C3218)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = AppFont.font(.boldText, size: 25)
    return label
  }()
  
  private lazy var icon: [UIImageView] = {
    var images = [UIImageView]()
    for i in 0..<6 {
      let img = UIImageView()
      img.image = .icLoadingLoading
      img.contentMode = .scaleAspectFit
      img.tag = i
      img.isUserInteractionEnabled = true
      images.append(img)
    }
    return images
  }()
  
  private lazy var desLabel: [UILabel] = {
    let value: [String] = [
      "Analyzing ride data",
      "Checking horse’s condition",
      "Reviewing pace & distance",
      "Processing effort level (RPE)",
      "Preparing session summary",
      "Building recommendations"
    ]
    
    var labels = [UILabel]()
    for (i, text) in value.enumerated() {
      let label = UILabel()
      label.text = text
      label.textColor = UIColor(rgb: 0x111111)
      label.font = AppFont.font(.regularText, size: 17)
      labels.append(label)
    }
    return labels
  }()
  
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .leading
    stackView.spacing = 20
    stackView.addArrangedSubview(self.stackView)
    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    return stackView
  }()
  
  private lazy var stackView: UIStackView = {
    var rows: [UIStackView] = []
    for (i, img) in self.icon.enumerated() {
      let row = UIStackView(arrangedSubviews: [img, self.desLabel[i]])
      row.axis = .horizontal
      row.spacing = 10
      row.distribution = .fill
      rows.append(row)
      
      img.snp.makeConstraints { make in
        make.width.height.equalTo(18)
      }
    }
    
    let vertical = UIStackView(arrangedSubviews: rows)
    vertical.axis = .vertical
    vertical.spacing = 20
    vertical.distribution = .fillEqually
    
    return vertical
  }()
  
  private lazy var mainPremiumView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    let label = UILabel()
    label.text = "Go Premium For Faster & Deeper Insights"
    label.font = AppFont.font(.regularTextItalic, size: 17)
    label.textColor = UIColor(rgb: 0x000000)
    view.addSubviews(label, premiumView)
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    
    premiumView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(16)
      make.width.equalTo(265)
      make.height.equalTo(56)
      make.centerX.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var premiumView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFF3636)
    view.cornerRadius = 27
    
    let icon = UIImageView()
//    icon.image = .icPremiumLoadingIAP
    icon.contentMode = .scaleAspectFit
    
    let label = UILabel()
    label.text = "Get Priority Access"
    label.font = AppFont.font(.boldText, size: 20)
    label.textColor = UIColor(rgb: 0xFFFFFF)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private lazy var confirmView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x5C3218)
    view.cornerRadius = 12
    view.isHidden = true
    
    let label = UILabel()
    label.text = "Confirm"
    label.textColor = UIColor(rgb: 0xFEFEFE)
    label.font = AppFont.font(.semiBoldText, size: 20)
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private var viewModel: LoadingVM!
  
  private var apiCompleted = false
  private var shouldStopLastAnimation = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    animateIcon(at: 0)
    viewModel.action.send(.getRequest)
  }
  
  override func addComponents() {
    self.view.addSubview(containerView)
    self.view.addSubview(titleLabel)
    self.view.addSubview(mainStackView)
    self.view.addSubview(mainPremiumView)
    self.view.addSubview(confirmView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(90)
      make.centerX.equalToSuperview()
      make.width.equalTo(302)
    }
    
    mainStackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).inset(-24)
      make.left.equalToSuperview().inset(62)
    }
    mainPremiumView.snp.makeConstraints { make in
      make.top.equalTo(mainStackView.snp.bottom).inset(-20)
      make.centerX.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(92)
    }
    
    confirmView.snp.makeConstraints { make in
      make.top.equalTo(mainPremiumView.snp.bottom).offset(86)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(52)
    }
  }
  
  override func setProperties() {
    confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapConfirmView)))
    premiumView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPremium)))
  }
  
  override func binding() {
    viewModel.showConfirmView
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self else {
          return
        }
        apiCompleted = true
        shouldStopLastAnimation = true
      }.store(in: &subscriptions)
  }
  
  private func animateIcon(at index: Int) {
    guard index < icon.count else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.confirmView.isHidden = false
      }
      return
    }
    
    let img = icon[index]
    
    if index == icon.count - 1 {
      animateLastIcon(img)
      return
    }
    
    // Các icon 1–5 quay bình thường
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
      img.transform = CGAffineTransform(rotationAngle: .pi)
    }) { _ in
      UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
        img.transform = CGAffineTransform(rotationAngle: .pi * 2)
      }) { _ in
        img.image = .icLoadingLoadingDone
        img.transform = .identity
        self.animateIcon(at: index + 1)
      }
    }
  }
  
  private func animateLastIcon(_ img: UIImageView) {
    // Nếu API đã xong thì kết thúc ngay
    if shouldStopLastAnimation {
      finishLastIcon(img)
      return
    }
    
    // Quay vòng lặp đến khi API xong
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
      img.transform = CGAffineTransform(rotationAngle: .pi)
    }) { _ in
      UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
        img.transform = CGAffineTransform(rotationAngle: .pi * 2)
      }) { _ in
        img.transform = .identity
        
        // Nếu API vẫn chưa xong thì quay tiếp
        if !self.shouldStopLastAnimation {
          self.animateLastIcon(img)
        } else {
          self.finishLastIcon(img)
        }
      }
    }
  }
  
  private func finishLastIcon(_ img: UIImageView) {
    img.image = .icLoadingLoadingDone
    img.transform = .identity
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.confirmView.isHidden = false
    }
  }
  
  // MARK: - Action
  @objc private func onTapConfirmView() {
    viewModel.action.send(.confirm)
  }
  
  @objc private func onTapPremium() {
    viewModel.action.send(.iap)
  }
}

extension LoadingVC {
  func setViewModel(_ viewModel: LoadingVM) {
    self.viewModel = viewModel
  }
}
