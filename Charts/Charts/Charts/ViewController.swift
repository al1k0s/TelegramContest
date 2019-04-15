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
  private let stackView: UIStackView
  private var isLightMode = true

  init(presenter: Presenter) {
    self.presenter = presenter

    let chartViews = (1...5).map { index -> ChartView in
      let chartView =  ChartView(
        plotView: createPlotView(index: index, isMainPlot: true),
        infoView: createInfoView(index: index),
        bottomPlotView: createPlotView(index: index, isMainPlot: false)
      )
      chartView.rangeChanged = { presenter.rangeChanged($0, index: index - 1) }
      chartView.yAxesChanged = { presenter.yAxesChanged(chartIndex: index - 1, $0) }
      return chartView
    }
    stackView = UIStackView(arrangedSubviews: chartViews)
    stackView.axis = .vertical
    
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let container = ScrollContainerView(contentView: stackView)
    view = container
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Statistics"
    navigationController?.navigationBar.isTranslucent = false
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Night mode",
      style: .plain,
      target: self,
      action: #selector(changeMode)
    )
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.viewWillAppear()
  }

  func updateRange(_ chartRange: ChartRange, index: Int) {
    (stackView.arrangedSubviews[index] as? ChartView)?.rangeUpdated(chartRange)
  }

  func updateYAxes(_ chartRange: ChartRange, index: Int) {
    (stackView.arrangedSubviews[index] as? ChartView)?.yAxesUpdated(chartRange)
  }

  @objc private func changeMode() {
    isLightMode.toggle()
    navigationItem.rightBarButtonItem?.title = isLightMode ? "Night mode" : "Day mode"
    let light = Constants.light
    let dark = Constants.dark
    navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: isLightMode ? .black : light]
    navigationController?.navigationBar.barTintColor = isLightMode ? light : dark
    stackView.arrangedSubviews.forEach { ($0 as? ChartView)?.toggleLightMode(on: isLightMode) }
  }
}

private enum Constants {
  static let light = UIColor(red: 239.0 / 255, green: 239.0 / 255, blue: 244.0 / 255, alpha: 1.0)
  static let dark = UIColor(red: 34.0 / 255, green: 47.0 / 255, blue: 62.0 / 255, alpha: 1.0)
}

private func createInfoView(index: Int) -> InfoViewProtocol {
  switch index {
  case 1:
    return Chart1InfoView()
  case 2:
    return Chart1InfoView()
  case 3:
    return Chart4InfoView()
  case 4:
    return Chart4InfoView()
  case 5:
    return Chart5InfoView()
  default:
    print("Error")
    return Chart1InfoView()
  }
}

private func createPlotView(index: Int, isMainPlot: Bool) -> PlotViewProtocol {
  switch index {
  case 1:
    return Plot1View(isMainPlot: isMainPlot)
  case 2:
    return Plot2View(isMainPlot: isMainPlot)
  case 3:
    return Plot3View(isMainPlot: isMainPlot)
  case 4:
    return Plot4View(isMainPlot: isMainPlot)
  case 5:
    return Plot5View(isMainPlot: isMainPlot)
  default:
    print("Error")
    return Plot5View(isMainPlot: isMainPlot)
  }
}
