//
//  ControlPanelPlotView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class Plot1View: UIView, PlotViewProtocol {
  
  private let isMainPlot: Bool
  private var chartRange: ChartRange?
  private var boundForChange: (minY: Double, maxY: Double) = (-1, -1)
  private var boundForCheck: (minY: Double, maxY: Double) = (-1, -1)
  private var isChanging: Bool = false
  private var numberOfIterations: Int = 0
  private let maxNumberOfIterations = 10
  private var maxValue = 999.0
  private var displayLink: CADisplayLink?
  
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
    self.maxValue = isMainPlot ? chartRange.max : chartRange.allMax
    if /*minFromChart() != boundForCheck.0 ||*/ maxY() != boundForCheck.maxY {
      updateMinMax(chartRange)
      boundForCheck = (minY(), maxY())
    } else if !isChanging {
      setNeedsDisplay()
    }
  }
  
  private func minY() -> Double {
    return 0.0//isMainPlot ? chartRange!.min : chartRange!.allMin
  }
  
  private func maxY() -> Double {
    return maxValue
  }
  
  private func updateMinMax(_ chartRange: ChartRange) {
    guard boundForCheck.1 != -1 else {
      boundForChange = (minY(), maxY())
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
    if numberOfIterations >= maxNumberOfIterations {
      removeLink()
    }
  }
  
  private func removeLink() {
    isChanging = numberOfIterations != maxNumberOfIterations
    displayLink?.invalidate()
    displayLink = nil
    let newMin = 0.0//boundForChange.0 + (boundForCheck.0 - boundForChange.0) * (Double(numberOfIterations) / Double(maxNumber))
    let newMax = boundForChange.1 + (boundForCheck.1 - boundForChange.1) * (Double(numberOfIterations) / Double(maxNumberOfIterations))
    numberOfIterations = 0
    boundForChange = (newMin, newMax)
  }
  
  fileprivate func drawPlot(max: Int,
                            min: Int,
                            context: CGContext,
                            newValues: [CGPoint],
                            color: CGColor) {
    for iter in .zero...(max - min - 1) {
      context.drawLine(
        from: newValues[iter],
        to: newValues[iter + 1],
        color: color,
        lineWidth: 1
      )
    }
    context.setFillColor(UIColor.clear.cgColor)
  }
  
  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()!
    let chartRange = self.chartRange!

    let (startDate, endDate) = isMainPlot ?
      (chartRange.range.lowerBound, chartRange.range.upperBound) :
      (chartRange.xCoordinates.first!, chartRange.xCoordinates.last!)

    let (minX, maxX) = isMainPlot ?
      (max(0, chartRange.indicies.lowerBound - 1),
       min(chartRange.xCoordinates.count - 1, chartRange.indicies.upperBound + 1)) :
      (0, chartRange.xCoordinates.count - 1)

    compute(isChanging: isChanging,
            chartRange: chartRange,
            minX: minX,
            maxX: maxX,
            minY: minY(),
            maxY: maxY(),
            size: bounds.size,
            currentIteration: numberOfIterations,
            maxNumberIterations: maxNumberOfIterations,
            startDate: startDate.timeIntervalSince1970,
            endDate: endDate.timeIntervalSince1970,
            oldBounds: boundForChange).forEach { axis in
              drawPlot(max: maxX,
                       min: minX,
                       context: context,
                       newValues: axis.points,
                       color: axis.color)
    }
  }
}

func compute(isChanging: Bool,
             chartRange: ChartRange,
             minX: Int,
             maxX: Int,
             minY: Double,
             maxY: Double,
             size: CGSize,
             currentIteration: Int,
             maxNumberIterations: Int,
             startDate: TimeInterval,
             endDate: TimeInterval,
             oldBounds: (minY: Double, maxY: Double)) -> [(color: CGColor,
                                                          points: [CGPoint])] {
    let timeFrame = endDate - startDate
    return chartRange.activeYAxes.map { axis in
      let color = UIColor(hexString: axis.color).cgColor
      let (width, height) = (size.width, size.height)
      // normalize values to view coordinates
      let newValues = zip(chartRange.xCoordinates[minX...maxX], axis.coordinates[minX...maxX])
        .map { (arg) -> (CGPoint) in
          let (date, value) = arg
          // get x value from 2 to view.width - 2
          let x = ((date.timeIntervalSince1970 - startDate) / timeFrame * Double(width - 4)) + 2
          let difference = Double(maxY - minY)
          // get y value from 0 to view.height
          let y: Double
          if isChanging { //numberOfIterations > 0 {
            let oldDiff = oldBounds.maxY - oldBounds.minY
            let oldY = (1 - Double(value - oldBounds.minY) / oldDiff) * Double(height)
            let newY = (1 - Double(value - minY) / difference) * Double(height)
            y = oldY + (newY - oldY) * (Double(currentIteration) / Double(maxNumberIterations))
            if value == 1130400 {
              print(y)
            }
          } else {
            y = (1 - Double(value - minY) / difference) * Double(height)
          }
          return CGPoint(x: x, y: y)
      }
      return (color, newValues)
    }
}
