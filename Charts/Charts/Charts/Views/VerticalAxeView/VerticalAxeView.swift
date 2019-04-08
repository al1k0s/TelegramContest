//
//  VerticalAxeView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

struct Extremum: Equatable {
  let topLeft: Double
  let bottomLeft: Double
  let topRight: Double?
  let bottomRight: Double?
}

final class VerticalAxeView: UIView {

  private var isLight: Bool = true
  private var isAnimating: Bool = false
  private var stripViews: [HorizontalStripView] = []
  private var pendingExtremum: Extremum?
  private var completedAnimations = 0
  private var leftColor: UIColor?
  private var rightColor: UIColor?
  var extremum: Extremum = .init(topLeft: 100.0, bottomLeft: 100.0, topRight: nil, bottomRight: nil) {
    didSet {
      if isAnimating {
        pendingExtremum = extremum
      } else if !stripViews.isEmpty {
        update(from: oldValue, newValue: extremum)
      }
    }
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
    if isAnimating {
      pendingExtremum = extremum
    } else {
      update(from: .init(topLeft: -1.0, bottomLeft: -1.0, topRight: nil, bottomRight: nil), newValue: extremum)
    }
  }

  func toggleMode(isLight: Bool) {
    stripViews.forEach { $0.toggleMode(isLight: isLight) }
    self.isLight = isLight
  }

  func setColors(left: UIColor, right: UIColor) {
    leftColor = left
    rightColor = right
  }

  private func update(from previousValue: Extremum, newValue: Extremum) {
    guard previousValue != newValue else { return }
    isAnimating = true
    let count = stripViews.count + (newValue.topRight != nil ? stripViews.count : 0)
    for (index, strip) in stripViews.enumerated() {
      let isTopDirection = calculateIsTopDirection(
        index: index,
        prev: (bottom: previousValue.bottomLeft, top: previousValue.topLeft),
        new: (bottom: newValue.bottomLeft, top: newValue.topLeft)
      )
      strip.updateLabel(
        isLeft: true,
        isTopDirection: isTopDirection,
        newText: lineNumber(index, isLeft: true),
        color: leftColor ?? (isLight ? Constants.lightNumber : Constants.darkNumber),
        completion: { [weak self] () in
          guard let `self` = self else { return }
          self.completedAnimations += 1
          guard self.completedAnimations == count else { return }
          self.completedAnimations = 0
          if let newMax = self.pendingExtremum, newMax != newValue {
            self.pendingExtremum = nil
            self.update(from: newValue, newValue: newMax)
          } else {
            self.isAnimating = false
          }
        }
      )
      guard
        let newBottom = newValue.bottomRight,
        let newTop = newValue.topRight
      else { continue }
      let prevBottom = previousValue.bottomRight ?? 0.0
      let prevTop = previousValue.topRight ?? 0.0
      let isTop = calculateIsTopDirection(
        index: index,
        prev: (bottom: prevBottom, top: prevTop),
        new: (bottom: newBottom, top: newTop)
      )
      strip.updateLabel(
        isLeft: false,
        isTopDirection: isTop,
        newText: lineNumber(index, isLeft: false),
        color: rightColor ?? (isLight ? Constants.lightNumber : Constants.darkNumber),
        completion: { [weak self] () in
          guard let `self` = self else { return }
          self.completedAnimations += 1
          guard self.completedAnimations == count else { return }
          self.completedAnimations = 0
          if let newMax = self.pendingExtremum, newMax != newValue {
            self.pendingExtremum = nil
            self.update(from: newValue, newValue: newMax)
          } else {
            self.isAnimating = false
          }
        }
      )
    }
  }

  func calculateIsTopDirection(
    index: Int,
    prev: (bottom: Double, top: Double),
    new: (bottom: Double, top: Double)
  ) -> Bool {

    let normalize = 1.0 - Double(index) / 5.5
    let prevY = (prev.top - prev.bottom) * normalize
    let newY = (new.top - new.bottom) * normalize
    return newY < prevY
  }

  private func lineNumber(_ index: Int, isLeft: Bool) -> String {
    let step: Double
    let number: Int
    if isLeft {
      step = (extremum.topLeft - extremum.bottomLeft) / Double(Constants.numberOfStrips)
      number = Int(step * Double(Constants.numberOfStrips - index - 1)) + Int(extremum.bottomLeft)
    } else {
      step = ((extremum.topRight ?? 0.0) - (extremum.bottomRight ?? 0.0)) / Double(Constants.numberOfStrips)
      number = Int(step * Double(Constants.numberOfStrips - index - 1)) + Int(extremum.bottomRight ?? 0.0)
    }
    if number < 1000 {
      return "\(number)"
    } else if number < 1000000 {
      return "\(number / 1000).\((number % 1000) / 100)K"
    } else {
      return "\(number / 1000000).\((number % 1000000) / 100000)M"
    }
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
