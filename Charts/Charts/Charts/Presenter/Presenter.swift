//
//  Presenter.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import Foundation

final class Presenter {

  private let chartsSource = ChartsSource()
  private let charts: [Chart]

  weak var viewController: ViewController?

  private var chartRanges: [ChartRange]

  init() {
    charts = chartsSource.getCharts()
    chartRanges = charts.map { ChartRange(chart: $0, chosenRange: 0.3...0.7) }
  }

  func rangeChanged(_ change: ClosedRange<Float>, index: Int) {
    chartRanges[index].chosenRange = change
    viewController?.updateRange(chartRanges[index], index: index)
  }

  /// - Parameter enabledAxes: Y axes names
  func yAxesChanged(chartIndex: Int, _ parameterIndex: Int) {
    chartRanges[chartIndex].updateYAxes(parameterIndex)
    viewController?.updateYAxes(chartRanges[chartIndex], index: chartIndex)
  }

  func viewWillAppear() {
    chartRanges.enumerated().forEach { (index, chartRange) in
      viewController?.updateRange(chartRange, index: index)
      viewController?.updateYAxes(chartRange, index: index)
    }
  }
}
