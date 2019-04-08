//
//  Plot2View.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/8/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class Plot2View: UIView, PlotViewProtocol {

  private let isMainPlot: Bool
  private var chartRange: ChartRange?
  private var boundForChange: (minY: Double, maxY: Double) = (-1, -1)
  private var boundForChange2: (minY: Double, maxY: Double) = (-1, -1)
  private var boundForCheck: (minY: Double, maxY: Double) = (-1, -1)
  private var boundForCheck2: (minY: Double, maxY: Double) = (-1, -1)
  private var isChanging: Bool = false
  private var numberOfIterations: Int = 0
  private let maxNumberOfIterations = 10
  private var minValue = 0.0
  private var maxValue = 999.0
  private var minValue2 = 0.0
  private var maxValue2 = 999.0
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
    self.maxValue = isMainPlot
      ? chartRange.allYAxes[0].coordinates[chartRange.indicies].max()!
      : chartRange.allYAxes[0].coordinates.max()!
    self.minValue = isMainPlot
      ? chartRange.allYAxes[0].coordinates[chartRange.indicies].min()!
      : chartRange.allYAxes[0].coordinates.min()!
    self.maxValue2 = isMainPlot
      ? chartRange.allYAxes[1].coordinates[chartRange.indicies].max()!
      : chartRange.allYAxes[1].coordinates.max()!
    self.minValue2 = isMainPlot
      ? chartRange.allYAxes[1].coordinates[chartRange.indicies].min()!
      : chartRange.allYAxes[1].coordinates.min()!
    if minValue != boundForCheck.minY || maxValue != boundForCheck.maxY || minValue2 != boundForCheck2.minY || maxValue2 != boundForCheck2.maxY {
      updateMinMax(chartRange)
      boundForCheck = (minValue, maxValue)
      boundForCheck2 = (minValue2, maxValue2)
    } else if !isChanging {
      setNeedsDisplay()
    }
  }

  private func updateMinMax(_ chartRange: ChartRange) {
    guard boundForCheck.1 != -1 else {
      boundForChange = (minValue, maxValue)
      boundForChange2 = (minValue2, maxValue2)
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
    let newMin = boundForChange.0 + (boundForCheck.0 - boundForChange.0) * (Double(numberOfIterations) / Double(maxNumberOfIterations))
    let newMax = boundForChange.1 + (boundForCheck.1 - boundForChange.1) * (Double(numberOfIterations) / Double(maxNumberOfIterations))
    boundForChange = (newMin, newMax)
    let newMin2 = boundForChange2.0 + (boundForCheck2.0 - boundForChange2.0) * (Double(numberOfIterations) / Double(maxNumberOfIterations))
    let newMax2 = boundForChange2.1 + (boundForCheck2.1 - boundForChange2.1) * (Double(numberOfIterations) / Double(maxNumberOfIterations))
    numberOfIterations = 0
    boundForChange2 = (newMin2, newMax2)
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
            yAxes: [chartRange.allYAxes[0]],
            visibleDates: Array(chartRange.xCoordinates[minX...maxX]),
            visibleRange: (minX...maxX),
            minY: minValue,
            maxY: maxValue,
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

    compute(isChanging: isChanging,
            yAxes: [chartRange.allYAxes[1]],
            visibleDates: Array(chartRange.xCoordinates[minX...maxX]),
            visibleRange: (minX...maxX),
            minY: minValue2,
            maxY: maxValue2,
            size: bounds.size,
            currentIteration: numberOfIterations,
            maxNumberIterations: maxNumberOfIterations,
            startDate: startDate.timeIntervalSince1970,
            endDate: endDate.timeIntervalSince1970,
            oldBounds: boundForChange2).forEach { axis in
              drawPlot(max: maxX,
                       min: minX,
                       context: context,
                       newValues: axis.points,
                       color: axis.color)
    }
  }

//  private func calculateAxes(chartRange: ChartRange, visibleRange: ClosedRange<Int>) -> [YAxis] {
//    guard chartRange.allYAxes.count > 1 else { return chartRange.activeYAxes }
//    var secondAxis = chartRange.allYAxes[1]
//    let secondMax = secondAxis.coordinates[visibleRange].max()!
//    let secondMin = secondAxis.coordinates[visibleRange].min()!
//    secondAxis.coordinates = secondAxis.coordinates.map { ($0 - secondMin) / (secondMax - secondMin) * (maxValue - minY()) + minY() }
//    return [chartRange.allYAxes[0], secondAxis]
//  }
}
