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
  private var range: ClosedRange<Date> {
    didSet {
      viewController?.updateChart(chartRange)
    }
  }

  weak var viewController: ViewController?

  private var currentChart: Chart {
    return charts[0]
  }

  private var chartRange: ChartRange {
    return ChartRange(chart: currentChart,
                      range: range)
  }

  init() {
    charts = chartsSource.getCharts()
    let coordinates = charts[0].x.coordinates
    range = coordinates.first!...coordinates.last!
  }

  func rangeChanged(_ change: ClosedRange<Date>) {
    self.range = change
  }

  func viewWillAppear() {
    viewController?.updateChart(chartRange)
    viewController?.updateBottomPanel(yAxes: currentChart.yAxes)
  }
}
