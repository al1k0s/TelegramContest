//
//  VerticalAxeView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class VerticalAxeView: UIView {

  private var isLight: Bool = true
  private var isAnimating: Bool = false
  private var stripViews: [HorizontalStripView] = []
  private var pendingMax: Double?
  var maxValue = -1.0 {
    didSet {
      if isAnimating {
        pendingMax = maxValue
      } else {
        update(from: oldValue, newValue: maxValue)
      }
    }
  }


  private var step: Double {
    return maxValue / Double(Constants.numberOfStrips)
  }

  override init(frame: CGRect) {
    super.init(frame: .zero)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    stripViews = []
    for index in 0..<Constants.numberOfStrips {
      let stripView = createStrips(index: index)
      self.stripViews.append(stripView)
    }
    update(from: -1, newValue: maxValue)
  }

  func toggleMode(isLight: Bool) {
    stripViews.forEach { $0.toggleMode(isLight: isLight) }
    self.isLight = isLight
  }

  private func update(from previousValue: Double, newValue: Double) {
    guard previousValue != newValue else { return }
    isAnimating = true
    let count = stripViews.count
    var completedAnimations = 0
    for (index, strip) in stripViews.enumerated() {
      let isTopDirection = newValue < previousValue
      strip.updateLabel(
        isLeft: true,
        isTopDirection: isTopDirection,
        newText: lineNumber(index),
        color: isLight ? Constants.lightNumber : Constants.darkNumber,
        completion: { [weak self] () in
          completedAnimations += 1
          guard completedAnimations == count else { return }
          if let newMax = self?.pendingMax, newMax != newValue {
            self?.pendingMax = nil
            self?.update(from: newValue, newValue: newMax)
          } else {
            self?.isAnimating = false
          }
        }
      )
    }
  }

  private func lineNumber(_ index: Int) -> String {
    let step = maxValue / 5.5
    let number = Int(step * Double(Constants.numberOfStrips - index - 1))
    return formatNumber(number)
  }

  private func createStrips(index: Int) -> HorizontalStripView {
    let stripHeight = Constants.stripHeight
    let frame = CGRect(
      x: 0,
      y: CGFloat(index) * stripHeight - 0.5 * stripHeight,
      width: bounds.width,
      height: stripHeight
    )
    let stripView = HorizontalStripView(
      frame: frame,
      isLight: isLight
    )
    stripView.alpha = 1.0
    addSubview(stripView)
    return stripView
  }

  enum Constants {
    static let numberOfStrips = 6
    static let stripHeight: CGFloat = 50
    static let lightNumber = UIColor(red: 173.0 / 255, green: 178.0 / 255, blue: 182.0 / 255, alpha: 1.0)
    static let darkNumber = UIColor(red: 80.0 / 255, green: 95.0 / 255, blue: 111.0 / 255, alpha: 1.0)
  }
}

func formatNumber(_ number: Int) -> String {
  if number < 1000 {
    return "\(number)"
  } else if number < 1000000 {
    return "\(number / 1000).\((number % 1000) / 100)K"
  } else {
    return "\(number / 1000000).\((number % 1000000) / 100000)M"
  }
}
