//
//  ControlPanelPlotView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class PlotView: UIView {

  private let isMainPlot: Bool
  private var chartRange: ChartRange?
  private var boundForChange: (Double, Double) = (-1, -1)
  private var boundForCheck: (Double, Double) = (-1, -1)
  private var isChanging: Bool = false
  private var numberOfIterations: Int = 0
  private let maxNumber = 10
  private var displayLink: CADisplayLink?
  private var shapeLayers: [CAShapeLayer] = []

  init(isMainPlot: Bool) {
    self.isMainPlot = isMainPlot
    super.init(frame: .zero)
    backgroundColor = .clear
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateChart(_ chartRange: ChartRange) {
    self.chartRange = chartRange
    if minFromChart() != boundForCheck.0 || maxFromChart() != boundForCheck.1 {
      updateMinMax(chartRange)
      boundForCheck = (minFromChart(), maxFromChart())
    } else if !isChanging {
      setNeedsDisplay()
    }
  }

  private func minFromChart() -> Double {
    return isMainPlot ? chartRange!.min : chartRange!.allMin
  }

  private func maxFromChart() -> Double {
    return isMainPlot ? chartRange!.max : chartRange!.allMax
  }

  private func updateMinMax(_ chartRange: ChartRange) {
    guard boundForCheck.0 != -1 else {
      boundForChange = (minFromChart(), maxFromChart())
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
    let startDate = (isMainPlot ? chartRange.range.lowerBound : chartRange.xCoordinates.first!).timeIntervalSince1970
    let endDate = (isMainPlot ? chartRange.range.upperBound : chartRange.xCoordinates.last!).timeIntervalSince1970
    let timeFrame = endDate - startDate

    for axe in chartRange.activeYAxes {
      let (width, height) = (UIScreen.main.bounds.width - 32, bounds.height)
      // normalize values to view coordinates
      let min = isMainPlot ? Swift.max(0, chartRange.indicies.lowerBound - 1) : 0
      let max = isMainPlot ? Swift.min(chartRange.xCoordinates.count - 1, chartRange.indicies.upperBound + 1) : chartRange.xCoordinates.count - 1
      let newValues = zip(
        chartRange.xCoordinates[min...max],
        axe.coordinates[min...max]
        )
        .map { (arg) -> (CGPoint) in
          let (date, value) = arg
          // get x value from 2 to view.width - 2
          let x = ((date.timeIntervalSince1970 - startDate) / timeFrame * Double(width - 4)) + 2
          let difference = Double(maxFromChart() - minFromChart())
          // get y value from 0 to view.height
          let y: Double
          if isChanging { //numberOfIterations > 0 {
            let oldDiff = boundForChange.1 - boundForChange.0
            let oldY = (1 - Double(value - boundForChange.0) / oldDiff) * Double(height)
            let newY = (1 - Double(value - minFromChart()) / difference) * Double(height)
            y = oldY + (newY - oldY) * (Double(numberOfIterations) / Double(maxNumber))
          } else {
            y = (1 - Double(value - minFromChart()) / difference) * Double(height)
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


