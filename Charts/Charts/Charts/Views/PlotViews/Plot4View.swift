//
//  Plot4View.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/7/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit.UIView

private let maxNumberIterations = 10

class Plot4View: UIView, PlotViewProtocol {

  private var oldBounds: (minY: Double, maxY: Double) = (-1, -1)
  private var newBounds: (minY: Double, maxY: Double) = (-1, -1)

  private var minY: Double {
    return isMainPlot ? chartRange.min : chartRange.allMin
  }
  private var maxY: Double {
    return isMainPlot ? chartRange.max : chartRange.allMax
  }

  private var chartRange: ChartRange!
  private let isMainPlot: Bool

  private var currentIteration = 0

  private var isDrawn = false
  private var isAnimating: Bool {
    return currentIteration > 0
  }

  private var displayLink: CADisplayLink?

  init(isMainPlot: Bool) {
    self.isMainPlot = isMainPlot

    super.init(frame: .zero)

    backgroundColor = .clear
  }

  func updateChart(_ chartRange: ChartRange) {
    self.chartRange = chartRange
    if newBounds != (minY, maxY) && isDrawn {
      newBounds = (minY, maxY)
      rangeUpdated()
      isDrawn = true
    } else if !isAnimating {
      setNeedsDisplay()
    }
  }

  func rangeUpdated() {
    guard newBounds.maxY != -1 else {
      oldBounds = (minY, maxY)
      return
    }
    displayLink = CADisplayLink(target: self, selector: #selector(redraw))
    displayLink?.add(to: .main, forMode: .common)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func redraw() {
    currentIteration += 1
    setNeedsDisplay()
    if currentIteration >= maxNumberIterations {
      displayLink?.invalidate()
      displayLink = nil

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

    compute(isChanging: isAnimating,
            yAxes: chartRange.activeYAxes,
            visibleDates: Array(chartRange.xCoordinates[minX...maxX]),
            visibleRange: (minX...maxX),
            minY: minY,
            maxY: maxY,
            size: bounds.size,
            currentIteration: currentIteration,
            maxNumberIterations: maxNumberIterations,
            startDate: startDate.timeIntervalSince1970,
            endDate: endDate.timeIntervalSince1970,
            oldBounds: oldBounds).forEach { axis in
              let columnWidth = axis.points[2].x - axis.points[1].x
              context.beginPath()
              context.move(to: CGPoint(x: 0, y: frame.maxY))
              axis.points.forEach {
                context.addLine(to: CGPoint(x: $0.x - columnWidth / 2, y: $0.y))
                context.addLine(to: CGPoint(x: $0.x + columnWidth / 2, y: $0.y))
              }
              context.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
              context.setFillColor(axis.color)
              context.fillPath()
    }
  }
}

extension CGContext {
  func drawColumn(_ rect: CGRect, color: CGColor) {
    beginPath()
    move(to: .init(x: rect.minX, y: rect.minY))
    addLine(to: .init(x: rect.minX, y: rect.maxY))
    addLine(to: .init(x: rect.maxX, y: rect.maxY))
    addLine(to: .init(x: rect.maxX, y: rect.minY))

  }
}
