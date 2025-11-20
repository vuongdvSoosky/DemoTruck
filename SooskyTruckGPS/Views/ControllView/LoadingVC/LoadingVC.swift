//
//  LoadingVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import UIKit
import Lottie
import SnapKit

class LoadingVC: BaseViewController {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFF8EC)
    return view
  }()
  private lazy var imageBg: UIImageView = {
    let image = UIImageView()
    //image.image = .imgBgLoadingPremium
    return image
  }()
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Finding the Shortest Path"
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.font = AppFont.font(.boldText, size: 25)
    return label
  }()
  
  private lazy var icon: [UIImageView] = {
    var images = [UIImageView]()
    for i in 0..<5 {
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
      "Analyzing all stops...",
      "Calculating best sequence...",
      "Checking truck restrictions...",
      "Building optimized route...",
      "Almost done"
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
  
  private lazy var confirmView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFEFD3)
    view.cornerRadius = 12
    view.borderColor = UIColor(rgb: 0xF26101)
    view.borderWidth = 2
    view.isHidden = false
    
    let label = UILabel()
    label.text = "Cancel"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 20)
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private lazy var lottieView: LottieAnimationView = {
    let animationView = LottieAnimationView(name: "Carloading")
    animationView.animationSpeed = 0.5
    animationView.loopMode = .loop
    animationView.contentMode = .scaleToFill
    animationView.clipsToBounds = true
    animationView.play()
    return animationView
  }()
  
  private var viewModel = LoadingVM()
  private var apiCompleted = false
  private var shouldStopLastAnimation = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    animateIcon(at: 0)
    viewModel.action.send(.getRequest)
  }
  
  override func addComponents() {
    self.view.addSubview(containerView)
    self.view.addSubview(imageBg)
    self.view.addSubview(titleLabel)
    self.view.addSubview(lottieView)
    self.view.addSubview(mainStackView)
    self.view.addSubview(confirmView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    imageBg.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    lottieView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(61)
      make.left.right.equalToSuperview().inset(-20)
      make.height.equalTo(243)
      make.centerX.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(lottieView.snp.bottom).inset(-48)
      make.left.right.equalToSuperview().inset(20)
      make.width.equalTo(302)
    }
    
    mainStackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).inset(-17)
      make.left.equalToSuperview().inset(62)
      make.height.equalTo(180)
    }
    
    confirmView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(32)
      make.height.equalTo(52)
    }
  }
  
  override func setProperties() {
    confirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapCancel)))
  }
  
  override func binding() {
    viewModel.showConfirmView
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self else {
          return
        }
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
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
      guard let self else {
        return
      }
      viewModel.action.send(.beforGoing)
    }
  }
  
  // MARK: - Action
  @objc private func onTapCancel() {
    viewModel.action.send(.cancelRequest)
  }
}
