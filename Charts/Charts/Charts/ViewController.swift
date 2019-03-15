//
//  ViewController.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  private let presenter: Presenter
  private let contentView = ChartView()

  init(presenter: Presenter) {
    self.presenter = presenter

    contentView.rangeChanged = presenter.rangeChanged
    
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Statistics"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.viewWillAppear()
  }

  func updateChart(_ chartRange: ChartRange) {
    contentView.updateupdateChartRange(chartRange)
  }
}
