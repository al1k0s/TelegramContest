//
//  VerticalAxeView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class VerticalAxeView: UIView {

  private var stripViews: [HorizontalStripView] = []
  private var hiddenStripViews = (0...Constants.numberOfStrips)
    .map { _ in HorizontalStripView(frame: .zero, number: "") }
  private var newStripViews: [HorizontalStripView] = []
  private let viewWidth: CGFloat

  var maxValue = 200.0 {
    didSet {
      updateMaxValue(from: oldValue, newValue: maxValue)
    }
  }

  private var step: Double {
    return maxValue / Double(Constants.numberOfStrips)
  }

  init(width: CGFloat) {
    self.viewWidth = width
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateMaxValue(from previousValue: Double, newValue: Double) {
    guard previousValue != newValue else { return }
    newStripViews.forEach { $0.layer.removeAllAnimations() }
    hiddenStripViews.forEach { $0.layer.removeAllAnimations() }

    let diff = previousValue - newValue

    let animatableStripViews = Array(stripViews.dropLast())
    let distanceToMove: (Int) -> CGFloat
    let newY: (Int) -> CGFloat
    let newViewsMove: (Int) -> CGFloat

    if diff > 0 {
      distanceToMove = { index in
        Constants.stripHeight * CGFloat(Constants.numberOfStrips - index + 1)
      }
      newY = { _ in
        Constants.stripHeight * CGFloat(Constants.numberOfStrips)
      }
      newViewsMove = { index in
        CGFloat(index) * Constants.stripHeight
      }
    } else {
      distanceToMove = { index in
        return Constants.stripHeight * -CGFloat(Constants.numberOfStrips - index)
      }
      newY = { _ in
        -Constants.stripHeight
      }
      newViewsMove = { index in
        CGFloat(index) * Constants.stripHeight
      }
    }

    UIView.animate(withDuration: 0.5, animations: {
      for (index, view) in animatableStripViews.enumerated() {
        view.frame.origin.y -= distanceToMove(index)
        view.alpha = 0
      }
    }, completion: { _ in
      animatableStripViews.forEach { $0.removeFromSuperview() }
      self.hiddenStripViews = animatableStripViews
      self.stripViews = Array(self.stripViews.suffix(1)) + self.newStripViews
      self.newStripViews = []
    })

    for (index, stripView) in hiddenStripViews.enumerated() {
      let frame = CGRect(x: 0,
                         y: newY(index),
                         width: self.viewWidth,
                         height: 18.5)
      stripView.frame = frame
      stripView.alpha = 0.2
      stripView.number = lineNumber(index)
      stripViews.append(stripView)
      newStripViews.append(stripView)
      hiddenStripViews = []
      addSubview(stripView)
    }

    UIView.animate(withDuration: 0.5,
                   animations: {
                    for (index, view) in self.newStripViews.enumerated() {
                      view.frame.origin.y = newViewsMove(index)
                      view.alpha = 1
                    }
    })
  }

  private func lineNumber(_ index: Int) -> String {
    return String(Int(step * Double(Constants.numberOfStrips - index)))
  }

  private func setup() {
    let stripHeight = Constants.stripHeight
    for index in 0..<Constants.numberOfStrips + 1 {
      let frame = CGRect(x: 0, y: CGFloat(index) * stripHeight, width: viewWidth, height: 18.5)
      let stripView = HorizontalStripView(frame: frame,
                                          number: lineNumber(index))
      stripViews.append(stripView)
      addSubview(stripView)
    }
  }

  enum Constants {
    static let numberOfStrips = 5
    static let topPadding: CGFloat = 25
    static let stripHeight: CGFloat = 44
  }
}
