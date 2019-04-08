//
//  ChartsSource.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import Foundation

final class ChartsSource {
  func getCharts() -> [Chart] {
    return (1...5).map { index in
      let url = Bundle.main.url(forResource: "\(index)", withExtension: "json")!
      let data = try! Data(contentsOf: url)
      let chart = try! JSONDecoder().decode(Chart.self, from: data)
      return chart
    }
  }
}
