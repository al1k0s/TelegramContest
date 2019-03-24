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
    contentView.yAxesChanged = presenter.yAxesChanged
    
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    //let container = ScrollContainerView(contentView: contentView)
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Statistics"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.viewWillAppear()
    contentView.changeBackground = { [weak self] isLight in
      let light = UIColor(red: 239.0 / 255, green: 239.0 / 255, blue: 244.0 / 255, alpha: 1.0)
      let dark = UIColor(red: 34.0 / 255, green: 47.0 / 255, blue: 62.0 / 255, alpha: 1.0)
      self?.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: isLight ? .black : light]
      self?.navigationController?.navigationBar.barTintColor = isLight ? light : dark
    }
    contentView.chartChange = { [weak self] index in
      self?.presenter.changeChart(index: index)
    }
  }

  func updateRange(_ chartRange: ChartRange) {
    contentView.rangeUpdated(chartRange)
  }

  func updateYAxes(_ chartRange: ChartRange) {
    contentView.yAxesUpdated(chartRange)
  }
}
