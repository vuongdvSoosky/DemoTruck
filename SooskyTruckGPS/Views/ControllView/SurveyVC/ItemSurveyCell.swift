//
//  ItemSurveyCell.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/12/25.
//

import UIKit
import SnapKit

class ItemSurveyCell: BaseCollectionViewCell {
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 12
    
    [icChoose, label].forEach({view.addSubviews($0)})
    icChoose.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(16)
      make.width.height.equalTo(24)
    }
    label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(self.icChoose.snp.trailing).inset(-8)
      make.trailing.equalToSuperview().inset(12)
    }
    return view
  }()
  private lazy var icChoose: UIImageView = {
    let image = UIImageView()
    image.image = .icUnChooseSize
    image.contentMode = .scaleAspectFill
    return image
  }()
  private lazy var label: UILabel = {
    let label = UILabel()
    label.text = "< 500K sq ft"
    label.numberOfLines = 0
    label.textColor = UIColor(rgb: 0x1A1A1A)
    label.font = AppFont.font(.lightText, size: 17)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  private func setupUI() {
    contentView.addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(2)
    }
  }
  
  override func setColor() {
    containerView.addShadow()
  }
  
  func chooseItem(isSelected: Bool) {
    icChoose.image = isSelected ? .icChooseSize : .icUnChooseSize
    containerView.layer.borderColor = UIColor(rgb: 0xF26101).cgColor
    containerView.layer.borderWidth = isSelected ? 3 : 0
    label.font = isSelected ? AppFont.font(.boldText, size: 17) : AppFont.font(.lightText, size: 17)
  }
  
  func binding(with farmSizeType: OwnerType) {
    label.text = farmSizeType.title
  }
  
  func bindingForWorkType(with workType: VehicleType) {
    label.text = workType.title
  }
}
