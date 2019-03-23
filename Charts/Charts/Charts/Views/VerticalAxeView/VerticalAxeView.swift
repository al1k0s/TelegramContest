//
//  VerticalAxeView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class VerticalAxeView: UIView {

  private var isLight: Bool = false
  private var stripViews: [HorizontalStripView] = []
  private var currentAnimated: [HorizontalStripView] = []
  private let viewWidth: CGFloat

  var maxValue = 200.0 {
    didSet {
      update(from: oldValue, newValue: maxValue)
    }
  }

  private var step: Double {
    return maxValue / Double(Constants.numberOfStrips)
  }

  private var isAnimating: Bool {
    return !currentAnimated.isEmpty
  }

  init(width: CGFloat) {
    self.viewWidth = width
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func toggleMode(isLight: Bool) {
    stripViews.forEach { $0.toggleMode(isLight: isLight) }
    //currentAnimated.forEach { $0.toggleMode(isLight: isLight) }
    self.isLight = isLight
  }

  func update(from previousValue: Double, newValue: Double) {
    guard previousValue != newValue else { return }

    for view in currentAnimated {
      UIView.animate(withDuration: 0.07) {
        view.alpha = 0
      }
    }

    let diff = previousValue - newValue

    let distanceToMove: (Int) -> CGFloat
    let newY: (Int) -> CGFloat
    let newViewsMove: (Int) -> CGFloat

    var hiddenStripViews = (0...(Constants.numberOfStrips))
      .map { _ -> HorizontalStripView in
        let stripView = HorizontalStripView(frame: .zero, number: "", isLight: isLight)
        stripView.alpha = 1.0
        return stripView
    }
    let animatableStripViews = stripViews
    self.stripViews = hiddenStripViews

    currentAnimated = stripViews + hiddenStripViews

    if diff > 0 {
      distanceToMove = { index in
        Constants.stripHeight * CGFloat(Constants.numberOfStrips - index + 1)
      }
      newY = { index in
        Constants.stripHeight * CGFloat(index + 1)
      }
      newViewsMove = { index in
        CGFloat(index) * Constants.stripHeight
      }
    } else {
      distanceToMove = { index in
        return Constants.stripHeight * -CGFloat(Constants.numberOfStrips - index)
      }
      newY = { index in
        CGFloat(index - 2) * Constants.stripHeight
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
      hiddenStripViews = animatableStripViews
    })

    for (index, stripView) in stripViews.enumerated() {
      let frame = CGRect(x: 0,
                         y: newY(index),
                         width: self.viewWidth,
                         height: 18.5)
      addSubview(stripView)
      stripView.frame = frame
      stripView.alpha = 1.0
      stripView.number = lineNumber(index)
    }

    UIView.animate(withDuration: 0.5,
                   animations: {
                    for (index, view) in self.stripViews.enumerated() {
                      view.frame.origin.y = newViewsMove(index)
                      view.alpha = 1.0
                    }
    })
  }

  private func lineNumber(_ index: Int) -> String {
    return String(Int(step * Double(Constants.numberOfStrips - index)))
  }

  private func setup() {
    for index in 0..<Constants.numberOfStrips - 1 {
      let stripView = createStrips(index: index)
      self.stripViews.append(stripView)
    }
    _ = createStrips(index: Constants.numberOfStrips)
  }

  private func createStrips(index: Int) -> HorizontalStripView {
    let stripHeight = Constants.stripHeight
    let frame = CGRect(x: 0, y: CGFloat(index) * stripHeight, width: viewWidth, height: 18.5)
    let stripView = HorizontalStripView(frame: frame,
                                        number: lineNumber(index),
                                        isLight: isLight)
    stripView.alpha = 1.0
    addSubview(stripView)
    return stripView
  }

  enum Constants {
    static let numberOfStrips = 5
    static let topPadding: CGFloat = 25
    static let stripHeight: CGFloat = 44
  }
}
