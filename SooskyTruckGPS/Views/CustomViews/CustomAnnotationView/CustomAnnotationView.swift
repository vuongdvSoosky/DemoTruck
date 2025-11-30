//
//  CustomAnnotationView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 21/11/25.
//

import UIKit
import MapKit
import SnapKit
import NVActivityIndicatorView

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
  
  private lazy var loadingView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = .white
    return view
  }()
  
  private lazy var successView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 6
    view.clipsToBounds = true
    view.backgroundColor = UIColor(rgb: 0x299F46, alpha: 0.14)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSuccess)))
    view.borderColor = UIColor(rgb: 0x299F46)
    
    let icon = UIImageView()
    icon.image = .icDoneArrived
    icon.contentMode = .scaleAspectFit
    
    let label = UILabel()
    label.text = "Success"
    label.textColor = UIColor(rgb: 0x299F46)
    label.font = AppFont.font(.semiBoldText, size: 15)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  private lazy var failedView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 6
    view.clipsToBounds = true
    view.backgroundColor = UIColor(rgb: 0xDC2E24, alpha: 0.14)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFailed)))
    view.borderColor = UIColor(rgb: 0xDC2E24)
    
    let icon = UIImageView()
    icon.image = .icFailedArrived
    icon.contentMode = .scaleAspectFit
    
    let label = UILabel()
    label.text = "Failed"
    label.textColor = UIColor(rgb: 0xDC2E24)
    label.font = AppFont.font(.semiBoldText, size: 15)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private lazy var stateStateStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.distribution = .fillEqually
    [successView, failedView].forEach({stackView.addArrangedSubview($0)})
    stackView.isHidden = true
    return stackView
  }()
  
  private lazy var verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    [buttonView, stateStateStackView].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  weak var delegate: CustomAnnotationViewDelagate?
  private var currentPlace: Place?
  
  private var place: Place?
  private var isSuccessSelected = false
  private var isFailedSelected = false
  
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
    containerView.addSubview(verticalStackView)
    
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
      make.height.equalTo(30)
    }

    stateStateStackView.snp.makeConstraints { make in
      make.height.equalTo(30)
    }
    
    verticalStackView.snp.makeConstraints { make in
      make.top.equalTo(subtitleLabel.snp.bottom).inset(-8)
      make.left.equalToSuperview().offset(12)
      make.right.equalToSuperview().offset(-12)
      make.bottom.equalToSuperview().offset(-12)
    }
    
    let stack = UIStackView(arrangedSubviews: [removeIcon, removeLabel])
    stack.axis = .horizontal
    stack.spacing = 10
    stack.alignment = .center
    
    buttonView.addSubviews(loadingView, stack)
    loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(24)
    }
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
  
  private func configureView() {}
  
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
  }
  
  func showButton() {
    buttonView.isHidden = false
  }
  
  func showLoadingView() {
    removeIcon.isHidden = true
    removeLabel.isHidden = true
    
    loadingView.isHidden = false
    loadingView.startAnimating()
  }
  
  func hideLoadingView() {
    removeIcon.isHidden = false
    removeLabel.isHidden = false
    
    loadingView.isHidden = true
    loadingView.stopAnimating()
  }
  
  func showStateStackView() {
    stateStateStackView.isHidden = false
  }
  
  func getPlace(with place: Place) {
    self.place = place
    guard let state = place.state else {
      isSuccessSelected = false
      isFailedSelected = false
      successView.borderWidth = 0
      failedView.borderWidth = 0
      return
    }
    
    if state {
      isSuccessSelected = true
      isFailedSelected = false
      successView.borderWidth = 2
      failedView.borderWidth = 0
    } else {
      isSuccessSelected = false
      isFailedSelected = true
      successView.borderWidth = 0
      failedView.borderWidth = 2
    }
    
  }
}

extension CustomAnnotationView {
  @objc private func onTapSuccess() {
    guard let place = place else { return }
    
    if isSuccessSelected {
      // Bỏ chọn
      isSuccessSelected = false
      successView.borderWidth = 0
      PlaceManager.shared.changeState(for: place, isSuccess: true)
    } else {
      // Chọn
      isSuccessSelected = true
      isFailedSelected = false
      
      successView.borderWidth = 2
      failedView.borderWidth = 0
      PlaceManager.shared.changeState(for: place, isSuccess: true)
    }
  }
  
  @objc private func onTapFailed() {
    guard let place = place else { return }
    
    if isFailedSelected {
      // Bỏ chọn
      isFailedSelected = false
      failedView.borderWidth = 0
      PlaceManager.shared.changeState(for: place, isSuccess: false)
    } else {
      // Chọn
      isFailedSelected = true
      isSuccessSelected = false
      
      failedView.borderWidth = 2
      successView.borderWidth = 0
      PlaceManager.shared.changeState(for: place, isSuccess: false)
    }
  }
}
