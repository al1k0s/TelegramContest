//
//  BottomPlotView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/23/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class BottomPlotView: UIView {

  private var chartRange: ChartRange?
  private var boundForChange: (Double, Double) = (-1, -1)
  private var boundForCheck: (Double, Double) = (-1, -1)
  private var isChanging: Bool = false
  private var numberOfIterations: Int = 0
  private let maxNumber = 10
  private var displayLink: CADisplayLink?
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
    if chartRange.min != boundForCheck.0 || chartRange.max != boundForCheck.1 {
      updateMinMax(chartRange)
      boundForCheck = (chartRange.min, chartRange.max)
    } else if !isChanging {
      setNeedsDisplay()
    }
  }

  private func updateMinMax(_ chartRange: ChartRange) {
    guard boundForCheck.0 != -1 else {
      boundForChange = (chartRange.min, chartRange.max)
      return
    }
    isChanging = true
    if displayLink != nil {
      removeLink()
    }
    displayLink = CADisplayLink(target: self, selector: #selector(update))
    displayLink?.add(to: .main, forMode: .common)
  }

  @objc func update() {
    numberOfIterations += 1
    setNeedsDisplay()
    if numberOfIterations >= maxNumber {
      removeLink()
    }
  }

  private func removeLink() {
    isChanging = numberOfIterations != maxNumber
    displayLink?.invalidate()
    displayLink = nil
    let newMin = boundForChange.0 + (boundForCheck.0 - boundForChange.0) * (Double(numberOfIterations) / Double(maxNumber))
    let newMax = boundForChange.1 + (boundForCheck.1 - boundForChange.1) * (Double(numberOfIterations) / Double(maxNumber))
    numberOfIterations = 0
    boundForChange = (newMin, newMax)
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

    for axe in chartRange.activeYAxes {
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
          let difference = Double(chartRange.max - chartRange.min)
          // get y value from 0 to view.height
          let y: Double
          if isChanging { //numberOfIterations > 0 {
            let oldDiff = boundForChange.1 - boundForChange.0
            let oldY = (1 - Double(value - boundForChange.0) / oldDiff) * Double(height)
            let newY = (1 - Double(value - chartRange.min) / difference) * Double(height)
            y = oldY + (newY - oldY) * (Double(numberOfIterations) / Double(maxNumber))
          } else {
            y = (1 - Double(value - chartRange.min) / difference) * Double(height)
          }
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



