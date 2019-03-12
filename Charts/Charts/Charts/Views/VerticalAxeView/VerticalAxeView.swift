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
  private let viewWidth: CGFloat

  private var maxValue = 100.0 {
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
    let diff = newValue - previousValue

    let animatableStripViews = self.stripViews.dropLast()

    if diff > 0 {
      UIView.animate(withDuration: 0.5, animations: {
        for (index, view) in animatableStripViews.enumerated() {
          let distanceToMove = Constants.stripHeight * CGFloat(Constants.numberOfStrips - index + 1)
          view.frame.origin.y -= distanceToMove
          view.alpha = 0
        }
      }, completion: { _ in
        animatableStripViews.forEach { $0.removeFromSuperview() }
        self.stripViews = Array(self.stripViews.prefix(1))
      })
    } else {
      UIView.animate(withDuration: 0.5, animations: {
        for (index, view) in animatableStripViews.enumerated() {
          let distanceToMove = Constants.stripHeight * CGFloat(Constants.numberOfStrips - index) / 2
          view.frame.origin.y += distanceToMove
          view.alpha = 0
        }
      }, completion: { _ in
        animatableStripViews.forEach { $0.removeFromSuperview() }
        self.stripViews = Array(self.stripViews.prefix(1))
      })


      var newStripViews: [HorizontalStripView] = []
      let stripHeight = Constants.stripHeight
      for index in 0..<Constants.numberOfStrips {
        let frame = CGRect(x: 0,
                           y: Constants.stripHeight * -CGFloat(Constants.numberOfStrips - index + 1),
                           width: self.viewWidth,
                           height: 18.5)
        let number = String(step * Double(Constants.numberOfStrips - index))
        let stripView = HorizontalStripView(frame: frame,
                                            number: number)
        stripView.alpha = 0.2
        self.stripViews.append(stripView)
        newStripViews.append(stripView)
        self.addSubview(stripView)
      }

      UIView.animate(withDuration: 0.5,
                     animations: {
                      for (index, view) in newStripViews.enumerated() {
                        view.frame.origin.y = CGFloat(index) * stripHeight
                        view.alpha = 1
                      }
      }) { _ in

      }
    }
  }

  private func setup() {
    let stripHeight = Constants.stripHeight
    for iter in 0..<Constants.numberOfStrips + 1 {
      let frame = CGRect(x: 0, y: CGFloat(iter) * stripHeight, width: viewWidth, height: 18.5)
      let stripView = HorizontalStripView(frame: frame, number: String(step * Double(Constants.numberOfStrips - iter)))
      stripViews.append(stripView)
      addSubview(stripView)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.maxValue = 50
    }
  }

  enum Constants {
    static let numberOfStrips = 5
    static let topPadding: CGFloat = 25
    static let stripHeight: CGFloat = 40
  }
}
