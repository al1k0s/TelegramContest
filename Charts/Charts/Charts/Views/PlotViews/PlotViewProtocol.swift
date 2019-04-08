//
//  PlotViewProtocol.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/7/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import class UIKit.UIView

protocol PlotViewProtocol: UIView {
  func updateChart(_ chartRange: ChartRange)
}
