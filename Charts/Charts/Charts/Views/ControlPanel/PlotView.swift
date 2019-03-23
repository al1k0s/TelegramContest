//
//  ControlPanelPlotView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class PlotView: UIView {

  private var chartRange: ChartRange?
  private var shapeLayers: [CAShapeLayer] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateChart(_ chartRange: ChartRange) {
    self.chartRange = chartRange
    setNeedsDisplay()
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    guard let chartRange = chartRange else {
      return
    }
    let startDate = chartRange.range.lowerBound.timeIntervalSince1970
    let endDate = chartRange.range.upperBound.timeIntervalSince1970
    let timeFrame = endDate - startDate


    for axe in chartRange.yAxes {
      let (width, height) = (UIScreen.main.bounds.width - 32, bounds.height)
      // normalize values to view coordinates
      let min = Swift.max(0, chartRange.indicies.lowerBound - 1)
      let max = Swift.min(chartRange.xCoordinates.count - 1, chartRange.indicies.upperBound + 1)
      let newValues = zip(
          chartRange.xCoordinates[min...max],
          axe.coordinates[min...max]
        )
        .map { (arg) -> (CGPoint) in
          let (date, value) = arg
          // get x value from 2 to view.width - 2
          let x = ((date.timeIntervalSince1970 - startDate) / timeFrame * Double(width - 4)) + 2
          let difference = Double(chartRange.max - 0)//chartRange.min)
          // get y value from 0 to view.height
          let y = (1 - Double(value - 0/*chartRange.min*/) / difference) * Double(height)
          return CGPoint(x: x, y: y)
        }
      
      for iter in 0...(max - min - 1) {
        context.drawLine(
          from: newValues[iter],
          to: newValues[iter + 1],
          color: UIColor(hexString: axe.color).cgColor,
          lineWidth: 1
        )
      }
    }
    context.setFillColor(UIColor.clear.cgColor)
  }
}


