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
  private weak var viewController: ViewController?

  init(viewController: ViewController) {
    charts = chartsSource.getCharts()
    self.viewController = viewController
  }

  func viewWillAppear() {
    viewController?.updateValues(charts[0].plots[0].values, max: charts[0].plots[0].values.max()!)
  }
}
