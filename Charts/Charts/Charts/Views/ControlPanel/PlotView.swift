//
//  ControlPanelPlotView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class PlotView: UIView {

  private var max: Double = 0
  private var min: Double = 0
  private var yAxes: [YAxis] = []
  private var shapeLayers: [CAShapeLayer] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateChart(_ chartRange: ChartRange) {
    let yAxes = chartRange.yAxes
    let maxValues = yAxes
      .map { $0.coordinates }
      .compactMap { $0.max() }
    guard let max = maxValues.max() else {
      return
    }
    let minValues = yAxes
      .map { $0.coordinates }
      .compactMap { $0.min() }
    guard let min = minValues.min() else {
      return
    }
    self.max = max
    self.min = min
    self.yAxes = Array(yAxes)
    layoutIfNeeded()
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    for axe in yAxes {
      guard axe.coordinates.count > 0 else { break }
      let (width, height) = (UIScreen.main.bounds.width - 32, 40.0)
      let count = axe.coordinates.count
      // normalize values to view coordinates
      let newValues = axe.coordinates.enumerated().map { (arg) -> (CGPoint) in
        let (index, value) = arg
        // get x value from 2 to view.width - 2
        let x = (Double(index) / Double(count - 1) * Double(width - 4)) + 2
        let difference = Double(max - min)
        // get y value from 0 to view.height
        let y = (1 - Double(value - min) / difference) * height
        return CGPoint(x: x, y: y)
      }

      // draw circle on first and last values
      context.drawCircle(
        at: newValues.first!,
        radius: 1,
        color: UIColor(hexString: axe.color).cgColor,
        lineWidth: 1
      )
      context.drawCircle(
        at: newValues.last!,
        radius: 1,
        color: UIColor(hexString: axe.color).cgColor,
        lineWidth: 1
      )
      for iter in 0..<(count - 1) {
        context.drawLine(from: newValues[iter], to: newValues[iter + 1], color: UIColor(hexString: axe.color).cgColor, lineWidth: 1)
      }
    }
    context.setFillColor(UIColor.clear.cgColor)
  }
}


