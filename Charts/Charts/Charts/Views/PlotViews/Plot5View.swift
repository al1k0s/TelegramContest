//
//  Plot5View.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/8/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit.UIView

private let maxNumberIterations = 10

class Plot5View: UIView, PlotViewProtocol {

  private var oldBounds: (minY: Double, maxY: Double) = (-1, -1)
  private var newBounds: (minY: Double, maxY: Double) = (-1, -1)

  private var minY: Double {
    return 0.0//isMainPlot ? chartRange.min : chartRange.allMin
  }
  private var maxY: Double {
    return 100.0//isMainPlot ? chartRange.max : chartRange.allMax
  }

  private var chartRange: ChartRange!
  private let isMainPlot: Bool

  private var currentIteration = 0

  private var isAnimating: Bool {
    return currentIteration > 0
  }

  private let displayLink = CADisplayLink(target: self, selector: #selector(redraw))

  init(isMainPlot: Bool) {
    self.isMainPlot = isMainPlot

    super.init(frame: .zero)

    backgroundColor = .clear
  }

  func updateChart(_ chartRange: ChartRange) {
    self.chartRange = chartRange
    if minY != newBounds.minY || maxY != newBounds.maxY {
      newBounds = (minY, maxY)
    } else if !isAnimating {
      setNeedsDisplay()
    }
  }

  func rangeUpdated() {
    guard newBounds.maxY != -1 else {
      oldBounds = (minY, maxY)
      return
    }
    displayLink.add(to: .main, forMode: .common)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func redraw() {
    currentIteration += 1
    setNeedsDisplay()
    if currentIteration >= maxNumberIterations {
      displayLink.invalidate()

      let animationDone = (Double(currentIteration) / Double(maxNumberIterations))
      let newMin = oldBounds.minY + (newBounds.minY - oldBounds.minY) * animationDone
      let newMax = oldBounds.maxY + (newBounds.maxY - oldBounds.maxY) * animationDone
      currentIteration = 0
      oldBounds = (newMin, newMax)
    }
  }

  fileprivate func calculateX() -> (minX: Int, maxX: Int) {
    return isMainPlot ?
      (max(0, chartRange.indicies.lowerBound - 1),
       min(chartRange.xCoordinates.count - 1, chartRange.indicies.upperBound + 1)) :
      (0, chartRange.xCoordinates.count - 1)
  }

  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()!
    let (startDate, endDate) = isMainPlot ?
      (chartRange.range.lowerBound, chartRange.range.upperBound) :
      (chartRange.xCoordinates.first!, chartRange.xCoordinates.last!)

    let (minX, maxX) = calculateX()

    let resultAxis = compute(
      isChanging: isAnimating,
      yAxes: calculateAxes(chartRange: chartRange, visibleRange: (minX...maxX)),
      visibleDates: Array(chartRange.xCoordinates[minX...maxX]),
      visibleRange: (0...(maxX - minX)),
      minY: minY,
      maxY: maxY,
      size: bounds.size,
      currentIteration: currentIteration,
      maxNumberIterations: maxNumberIterations,
      startDate: startDate.timeIntervalSince1970,
      endDate: endDate.timeIntervalSince1970,
      oldBounds: oldBounds
    )
    resultAxis.enumerated().forEach { (index, axis) in
      context.beginPath()
      axis.points.enumerated().forEach {
        if $0.offset == 0 {
          context.move(to: CGPoint(x: $0.element.x, y: $0.element.y))
        } else {
          context.addLine(to: CGPoint(x: $0.element.x, y: $0.element.y))
        }
      }
      if index == 0 {
        context.addLine(to: CGPoint(x: axis.points.last!.x, y: bounds.height))
        context.addLine(to: CGPoint(x: axis.points.first!.x, y: bounds.height))
      } else {
        resultAxis[index - 1].points.reversed().forEach {
          context.addLine(to: CGPoint(x: $0.x, y: $0.y))
        }
      }
      //context.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
      context.setFillColor(axis.color)
      context.fillPath()
    }
  }

  private func calculateAxes(chartRange: ChartRange, visibleRange: ClosedRange<Int>) -> [YAxis] {
    let count = visibleRange.count
    let max = chartRange.activeYAxes.reduce([Double](repeating: 0, count: count), { result, axe in
      return zip(result, axe.coordinates[visibleRange]).map(+)
    })
    var lastX = [Double](repeatElement(0, count: count))
    return chartRange.activeYAxes.map { axe in
      var axe = axe
      let coords = zip(axe.coordinates[visibleRange], lastX).map(+)
      axe.coordinates = zip(coords, max).map(/).map { $0 * 100.0 }
      lastX = coords
      return axe
    }
  }
}
