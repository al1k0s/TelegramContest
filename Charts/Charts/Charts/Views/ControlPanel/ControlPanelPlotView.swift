//
//  ControlPanelPlotView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ControlPanelPlotView: UIView {

  private var max: Double = 0
  private var values: [Double] = []
  private var shapeLayer: CAShapeLayer?

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateValues(_ values: [Double], max: Double) {
    self.max = max
    self.values = values
    setupLayer()
  }

  private func setupLayer() {
    shapeLayer?.removeFromSuperlayer()

    let newShapeLayer = CAShapeLayer()
    newShapeLayer.path = createBezierPath().cgPath

    // apply other properties related to the path
    newShapeLayer.fillColor = UIColor.red.cgColor
    newShapeLayer.lineWidth = 1.0

    // add the new layer to our custom view
    self.layer.addSublayer(newShapeLayer)
    shapeLayer = newShapeLayer
    layoutIfNeeded()
  }

  private func createBezierPath() -> UIBezierPath {

    let path = UIBezierPath()

    let (width, height) = (UIScreen.main.bounds.width - CGFloat(32), CGFloat(40))

    let count = values.count
    let newValues = values.enumerated().map { (arg) -> (CGFloat, CGFloat) in
      let (index, value) = arg
      let x = (Double(index) / Double(count - 1) * Double(width - 4)) + 2
      let y = (1.0 - Double(value) / Double(max)) * Double(height)
      return (CGFloat(x), CGFloat(y))
    }

    path.move(to: CGPoint(x: newValues[0].0, y: newValues[0].1 + CGFloat(1)))

    for iter in 1..<count {
      path.addLine(to: CGPoint(x: newValues[iter].0, y: newValues[iter].1 + CGFloat(1)))
    }

    for iter in 0..<count {
      let backIter = count - iter - 1
      path.addLine(to: CGPoint(x: newValues[backIter].0, y: newValues[backIter].1 - CGFloat(1)))
    }

    path.close()

    return path
  }
}
