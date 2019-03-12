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
    guard let url = Bundle.main.url(forResource: "charts", withExtension: "json") else {
      print("Can't create an url for file charts.json")
      return []
    }
    do {
      let data = try Data(contentsOf: url)
      let charts = try JSONDecoder().decode([Chart].self, from: data)
      return charts
    } catch let error {
      print(error.localizedDescription)
      return []
    }
  }
}
