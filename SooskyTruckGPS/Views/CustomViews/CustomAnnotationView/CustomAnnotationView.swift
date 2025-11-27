//
//  CustomAnnotationView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 21/11/25.
//

import UIKit
import MapKit
import SnapKit

protocol CustomAnnotationViewDelagate: AnyObject {
  func customAnnotationView(_ annotationView: CustomAnnotationView, place: Place?)
}

class CustomAnnotationView: MKAnnotationView {
  var annotationID: String?
  
  // MARK: - UI Components
  let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.15
    view.layer.shadowRadius = 6
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.mediumText, size: 17)
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.lightText, size: 15)
    label.textColor = UIColor(rgb: 0x909090)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let buttonView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xE46A24)
    view.layer.cornerRadius = 12
    return view
  }()
  
  private let removeIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .icPlus
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let removeLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.boldText, size: 12)
    label.textColor = UIColor(rgb: 0xF2F2F2)
    label.text = "Add Stop"
    label.textAlignment = .center
    return label
  }()
  
  weak var delegate: CustomAnnotationViewDelagate?
  private var currentPlace: Place?
  
  // MARK: - Override Annotation
  override var annotation: MKAnnotation? {
    didSet { configureView() }
  }
  
  // MARK: - Init
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  // MARK: - Setup UI
  private func setupUI() {
    canShowCallout = false
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-70)
      make.width.equalTo(220)
    }
    
    containerView.addSubview(titleLabel)
    containerView.addSubview(subtitleLabel)
    containerView.addSubview(buttonView)
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(18)
      make.left.equalToSuperview().offset(18)
      make.right.equalToSuperview().offset(-18)
    }
    
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
      make.left.equalTo(titleLabel)
      make.right.equalTo(titleLabel)
    }
    
    buttonView.snp.makeConstraints { make in
      make.top.equalTo(subtitleLabel.snp.bottom).inset(-8)
      make.left.equalToSuperview().offset(18)
      make.right.equalToSuperview().offset(-18)
      make.bottom.equalToSuperview().offset(-12)
      make.height.equalTo(36)
    }
    
    let stack = UIStackView(arrangedSubviews: [removeIcon, removeLabel])
    stack.axis = .horizontal
    stack.spacing = 10
    stack.alignment = .center
    
    buttonView.addSubview(stack)
    stack.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRemove)))
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if let view = super.hitTest(point, with: event) { return view }
    for subview in subviews {
      let subPoint = subview.convert(point, from: self)
      if let hitView = subview.hitTest(subPoint, with: event) {
        return hitView
      }
    }
    return nil
  }
  
  private func configureView() {
    guard let ann = annotation as? CustomAnnotation else { return }
    //    titleLabel.text = ann.title
    //    subtitleLabel.text = ann.subtitle
  }
  
  func configureButton(title: String, icon: UIImage) {
    removeLabel.text = title
    removeIcon.image = icon
  }
  
  func configure(title: String, des: String) {
    titleLabel.text = title
    subtitleLabel.text = des
    guard let coordinate = annotation?.coordinate else {
      return
    }
    
    // Lấy type từ annotation nếu là CustomServiceAnimation
    var placeType: String? = nil
    if let serviceAnnotation = annotation as? CustomServiceAnimation {
      placeType = serviceAnnotation.type
    } else if let customAnnotation = annotation as? CustomAnnotation {
      placeType = customAnnotation.type
    }
    
    self.currentPlace = Place(id: title, address: title, fullAddres: des, coordinate: coordinate, state: nil, type: placeType)
  }
  
  // MARK: - Action
  @objc private func didTapRemove() {
    delegate?.customAnnotationView(self, place: currentPlace)
  }
}

extension CustomAnnotationView {
  func hideTooltip() {
    containerView.isHidden = true
  }
  
  func showTooltip() {
    containerView.isHidden = false
  }
  
  func hideButton() {
    buttonView.isHidden = true
    // Cập nhật constraint để subtitleLabel là bottom
    subtitleLabel.snp.remakeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
      make.left.equalTo(titleLabel)
      make.right.equalTo(titleLabel)
      make.bottom.equalToSuperview().offset(-12)
    }
  }
  
  func showButton() {
    buttonView.isHidden = false
    // Khôi phục constraint ban đầu
    subtitleLabel.snp.remakeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
      make.left.equalTo(titleLabel)
      make.right.equalTo(titleLabel)
    }
    buttonView.snp.remakeConstraints { make in
      make.top.equalTo(subtitleLabel.snp.bottom).inset(-8)
      make.left.equalToSuperview().offset(18)
      make.right.equalToSuperview().offset(-18)
      make.bottom.equalToSuperview().offset(-12)
      make.height.equalTo(36)
    }
  }
}
