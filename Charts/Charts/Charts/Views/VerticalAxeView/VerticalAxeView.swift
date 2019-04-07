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

  private var zeroLine: HorizontalStripView!
  private var stripViews: [HorizontalStripView] = []
  private var currentAnimated: [HorizontalStripView] = []
  private let viewWidth: CGFloat
  private var displayLink: CADisplayLink?

  private var pendingMax: Double?
  var maxValue = 200.0 {
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

  private var isAnimating: Bool {
    return !currentAnimated.isEmpty
  }

  init(width: CGFloat) {
    self.viewWidth = width
    super.init(frame: .zero)

    for index in 0..<Constants.numberOfStrips - 1 {
      let stripView = createStrips(index: index)
      self.stripViews.append(stripView)
    }
    zeroLine = createStrips(index: Constants.numberOfStrips)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func toggleMode(isLight: Bool) {
    zeroLine.toggleMode(isLight: isLight)
    stripViews.forEach { $0.toggleMode(isLight: isLight) }
    currentAnimated.forEach { $0.toggleMode(isLight: isLight) }
    self.isLight = isLight
  }

  private func update(from previousValue: Double, newValue: Double) {
    guard previousValue != newValue else { return }

    for view in currentAnimated {
      UIView.animate(withDuration: 0.07) {
        view.alpha = 0
      }
    }

    let diff = previousValue - newValue

    let distanceToMove: CGFloat = diff > 0 ? -20 : 20
    let newY: (Int) -> CGFloat = { index in
      CGFloat(index) * Constants.stripHeight - distanceToMove
    }
    let newViewsMove: (Int) -> CGFloat = { index in
        CGFloat(index) * Constants.stripHeight
    }

    var hiddenStripViews = (0..<(Constants.numberOfStrips))
      .map { _ -> HorizontalStripView in
        let stripView = HorizontalStripView(frame: .zero, number: "", isLight: isLight)
        stripView.alpha = 1.0
        return stripView
    }
    let animatableStripViews = stripViews
    self.stripViews = hiddenStripViews

    currentAnimated = stripViews + hiddenStripViews

    UIView.animate(withDuration: 0.2, animations: {
      for view in animatableStripViews {
        view.frame.origin.y += distanceToMove
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
                         height: Constants.stripViewHeight)
      addSubview(stripView)
      stripView.frame = frame
      stripView.alpha = 0.2
      stripView.number = lineNumber(index)
    }

    UIView.animate(
      withDuration: 0.2,
      animations: {
        for (index, view) in self.stripViews.enumerated() {
          view.frame.origin.y = newViewsMove(index)
          view.alpha = 1.0
        }
      },
      completion: { [weak self] wasInterrupted in
        self?.currentAnimated = []
        if let max = self?.pendingMax {
          self?.pendingMax = nil
          self?.update(from: newValue, newValue: max)
        }
      }
    )
  }

  private func lineNumber(_ index: Int) -> String {
    return String(Int(step * Double(Constants.numberOfStrips - index) * 0.96))
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
    static let stripViewHeight: CGFloat = 18.5
    static let topPadding: CGFloat = 25
    static let stripHeight: CGFloat = 44
  }
}
