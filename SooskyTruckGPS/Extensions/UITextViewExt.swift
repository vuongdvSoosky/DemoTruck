//
//  UITextViewExt.swift
//  SooskyHorseTracking
//
//  Created by VuongDV on 25/9/25.
//

import UIKit
import SnapKit

private var placeholderKey: UInt8 = 0
private var maxHeightKey: UInt8 = 0

extension UITextView {
  private var placeholderLabel: UILabel? {
    get { objc_getAssociatedObject(self, &placeholderKey) as? UILabel }
    set { objc_setAssociatedObject(self, &placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  var maxHeight: CGFloat {
    get { (objc_getAssociatedObject(self, &maxHeightKey) as? CGFloat) ?? 120 }
    set { objc_setAssociatedObject(self, &maxHeightKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  func setPlaceholder(_ text: String,
                      color: UIColor = UIColor.lightGray,
                      font: UIFont? = nil,
                      inset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 0)) {
    if placeholderLabel == nil {
      let label = UILabel()
      label.textColor = color
      label.font = font ?? self.font
      label.numberOfLines = 0
      addSubview(label)
      
      // SnapKit layout
      label.snp.makeConstraints { make in
        make.top.equalToSuperview().offset(inset.top)
        make.leading.equalToSuperview().offset(inset.left)
        make.trailing.lessThanOrEqualToSuperview().inset(inset.right)
      }
      
      placeholderLabel = label
      
      // Theo dõi text change
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(textDidChange),
        name: UITextView.textDidChangeNotification,
        object: self
      )
    }
    placeholderLabel?.text = text
    placeholderLabel?.isHidden = !self.text.isEmpty
  }
  
  @objc private func textDidChange() {
    placeholderLabel?.isHidden = !self.text.isEmpty
    adjustHeight()
  }
  
  func adjustHeight() {
    let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
    let size = sizeThatFits(fittingSize)
    
    if size.height <= maxHeight {
      isScrollEnabled = false
      snp.updateConstraints { make in
        make.height.equalTo(120)
      }
    } else {
      isScrollEnabled = true
      snp.updateConstraints { make in
        make.height.equalTo(maxHeight)
      }
    }
  }
}
