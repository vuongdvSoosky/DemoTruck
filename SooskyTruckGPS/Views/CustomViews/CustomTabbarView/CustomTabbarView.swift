//
//  CustomTabbarView.swift
//  Plant_IOS
//
//  Created by VuongDv on 20/01/2025.
//

import UIKit

protocol CustomTabbarViewDelagate: AnyObject {
  func didSelectedHorse(index: Int)
  func didSelectedTrack(index: Int)
  func didSelectedTraining(index: Int)
  func didSelectedSetting(index: Int)
}

class CustomTabbarView: BaseView {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet var stackView: [UIStackView]!
  
  @IBOutlet weak var icHorses: UIImageView!
  @IBOutlet weak var icTrack: UIImageView!
  @IBOutlet weak var icSettings: UIImageView!
  @IBOutlet weak var icTraining: UIImageView!
  
  @IBOutlet weak var horsesLabel: UILabel!
  @IBOutlet weak var trackLabel: UILabel!
  @IBOutlet weak var settingsLabel: UILabel!
  @IBOutlet weak var trainingLabel: UILabel!
  
  @IBOutlet var containerView: [UIView]!
  
  weak var delegate: CustomTabbarViewDelagate?
  
  private let viewModel = CustomTabbarViewModel()
  
  var actionSelectedHome: Handler?
  var actionSelectedSearch: Handler?
  var actionSelectedScan: Handler?
  var actionSelectedMyPlant: Handler?
  var actionSelectedBlog: Handler?
  
  override func addComponents() {
    loadNibNamed()
    addSubview(contentView)
  }
  
  override func setConstraints() {
    self.contentView.frame = bounds
    self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  override func setColor() {
    contentView.backgroundColor = UIColor(rgb: 0xFEFEFE)
  }
  
  override func setProperties() {
    containerView.forEach { stackView in
      stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTabbar(_:))))
    }
    
    [horsesLabel, trackLabel, trainingLabel, settingsLabel].forEach { label in
      label?.setContentHuggingPriority(.required, for: .horizontal)
      label?.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
  }
  
  override func binding() {
    viewModel.tabbarItem
      .receive(on: DispatchQueue.main)
      .sink { [weak self] tabbarItem in
        guard let self else {
          return
        }
        switch tabbarItem {
        case .horses:
          setupStateIconHorese(with: .icHorseTabbarSelected,  texColor: UIColor(rgb: 0x5C3218), font: AppFont.font(.boldText, size: 14))
          
          // UnSelected
          setupStateIconTrack(with: .icTrackTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconSettings(with: .icSettingTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconTraining(with: .icTrainingTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          
        case .track:
          setupStateIconTrack(with: .icTrackTabbarSelected,  texColor: UIColor(rgb: 0x5C3218), font: AppFont.font(.boldText, size: 14))
          // UnSelected
          setupStateIconSettings(with: .icSettingTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconTraining(with: .icTrainingTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconHorese(with: .icHorseTabbarUnSelected,  texColor: UIColor(rgb: 0xA2A2A2), font: AppFont.font(.boldText, size: 14))
          
        case .training:
          setupStateIconTraining(with: .icTrainingTabbarSelected,  texColor: UIColor(rgb: 0x5C3218), font: AppFont.font(.boldText, size: 14))
          
          // UnSelected
          setupStateIconSettings(with: .icSettingTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconTrack(with: .icTrackTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconHorese(with: .icHorseTabbarUnSelected,  texColor: UIColor(rgb: 0xA2A2A2), font: AppFont.font(.boldText, size: 14))
        case .settings:
          setupStateIconSettings(with: .icSettingTabbarSelected,  texColor: UIColor(rgb: 0x5C3218), font: AppFont.font(.boldText, size: 14))
          
          // UnSelected
          setupStateIconTraining(with: .icTrainingTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconTrack(with: .icTrackTabbarUnSelected, texColor: UIColor(rgb: 0xA2A2A2))
          setupStateIconHorese(with: .icHorseTabbarUnSelected,  texColor: UIColor(rgb: 0xA2A2A2))
        }
      }.store(in: &subscriptions)
  }
}

// MARK: - Action
extension CustomTabbarView {
  @objc private func onTapTabbar(_ sender: UITapGestureRecognizer) {
    switch sender.view?.tag {
    case 0:
      viewModel.action.send(.chooseItem(tabbarItem: .horses))
      self.delegate?.didSelectedHorse(index: sender.view?.tag ?? 0)
    case 1:
      viewModel.action.send(.chooseItem(tabbarItem: .track))
      self.delegate?.didSelectedTrack(index: sender.view?.tag ?? 0)
    case 2:
      viewModel.action.send(.chooseItem(tabbarItem: .training))
      self.delegate?.didSelectedTraining(index: sender.view?.tag ?? 0)
    default:
      viewModel.action.send(.chooseItem(tabbarItem: .settings))
      self.delegate?.didSelectedSetting(index: sender.view?.tag ?? 0)
    }
  }
  
  func changeBackgroundColor(index: Int) {
    containerView.forEach({ view in
      view.backgroundColor = view.tag == index ? UIColor(rgb: 0xFFDFEA) : .clear
    })
  }
}

extension CustomTabbarView {
  private func setupStateIconHorese(with icon: UIImage, texColor: UIColor,
                                    font: UIFont = AppFont.font(.mediumText, size: 15)) {
    icHorses.image = icon
    horsesLabel.textColor = texColor
    horsesLabel.font = font
  }
  
  private func setupStateIconTrack(with icon: UIImage, texColor: UIColor,
                                   font: UIFont = AppFont.font(.mediumText, size: 15)) {
    icTrack.image = icon
    trackLabel.textColor = texColor
    trackLabel.font = font
  }
  
  private func setupStateIconTraining(with icon: UIImage, texColor: UIColor,
                                      font: UIFont = AppFont.font(.mediumText, size: 15)) {
    icTraining.image = icon
    trainingLabel.textColor = texColor
    trainingLabel.font = font
  }
  
  private func setupStateIconSettings(with icon: UIImage, texColor: UIColor,
                                      font: UIFont = AppFont.font(.mediumText, size: 15)) {
    icSettings.image = icon
    settingsLabel.textColor = texColor
    settingsLabel.font = font
  }
}

extension CustomTabbarView {
  func getItemFromTabbar(_ item: TabbarItem) {
    viewModel.action.send(.chooseItem(tabbarItem: item))
  }
  
  func showIconLockIAP() {}
  
  func hideIconLockIAP() {}
}
