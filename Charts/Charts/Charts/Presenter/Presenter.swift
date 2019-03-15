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

  private var range: ClosedRange<Float> {
    get {
      return chartRange.chosenRange
    } set {
      chartRange.chosenRange = newValue
      print("new range: \(range)")
      print("new dates: \(chartRange.range)")
    }
  }

  weak var viewController: ViewController?

  private var currentChartIndex: Int

  private var chartRange: ChartRange

  init(chartIndex: Int = 0) {
    currentChartIndex = chartIndex
    charts = chartsSource.getCharts()
    chartRange = ChartRange(chart: charts[0],
                            chosenRange: 0.3...0.7)
  }

  func rangeChanged(_ change: ClosedRange<Float>) {
    self.range = change
  }

  func viewWillAppear() {
    viewController?.updateChart(chartRange)
  }
}
