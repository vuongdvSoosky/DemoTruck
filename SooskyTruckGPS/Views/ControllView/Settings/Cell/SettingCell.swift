//
//  ItemSettingCell.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 3/9/25.
//

import UIKit
import SnapKit

class SettingCell: BaseCollectionViewCell {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    
    [icItem, titleItem, icRightRow].forEach({view.addSubviews($0)})
    
    icItem.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.width.height.equalTo(28)
      make.centerY.equalToSuperview()
    }
    
    titleItem.snp.makeConstraints { make in
      make.leading.equalTo(self.icItem.snp.trailing).inset(-12)
      make.centerY.equalToSuperview()
    }
    
    icRightRow.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.width.equalTo(9)
      make.height.equalTo(17)
      make.centerY.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var icRightRow: UIImageView = {
    let image = UIImageView()
    image.image = .icRightRow
    image.contentMode = .scaleAspectFit
    return image
  }()
  
  private lazy var icItem: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleToFill
    return image
  }()
  
  private lazy var titleItem: UILabel = {
     let title = UILabel()
    title.font = AppFont.font(.regularText, size: 20)
    return title
  }()
  
  override func addComponents() {
    self.contentView.addSubviews(containerView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

extension SettingCell {
  func biding(_ item: Setting) {
    icItem.image = item.icon
    titleItem.text = item.title
  }
}
