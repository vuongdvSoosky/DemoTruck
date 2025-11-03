//
//  MPVolumeViewExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import MediaPlayer

extension MPVolumeView {
  // Điều chỉnh âm lượng qua thanh trượt.
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      slider?.value = volume
    }
  }
}
