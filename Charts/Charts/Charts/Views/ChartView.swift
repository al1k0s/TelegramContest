//
//  ChartView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ChartView: UIView {

  private var isLight: Bool = true

  private var chartRange: ChartRange! {
    didSet {
      infoView.tapOccured = { point in
        let chartRange = self.chartRange!
        let up = chartRange.range.upperBound.timeIntervalSince1970
        let down = chartRange.range.lowerBound.timeIntervalSince1970
        let diff = up - down
        let time = down + diff * Double(point)
        let (index, _) = chartRange.xCoordinates.map { $0.timeIntervalSince1970 }
          .map { abs($0 - time) }
          .enumerated()
          .min(by: { $0.1 < $1.1 })!
        let dateX = (chartRange.xCoordinates[index].timeIntervalSince1970 - down) / diff
        let max = chartRange.max
        let charts = chartRange.activeYAxes.map { axe -> (UIColor, Int, CGPoint) in
          let value = Int(axe.coordinates[index])
          return (color: UIColor(hexString: axe.color), value, CGPoint(x: dateX, y: Double(value) / max))
        }
        return InfoViewModel(date: chartRange.xCoordinates[index],
                             xCount: chartRange.indicies.count,
                             charts: charts)
      }
    }
  }

  private let contentContainer = UIView()
  private let titleLabel = with(UILabel()) { titleLabel in
    titleLabel.font = UIFont.systemFont(ofSize: 17)
    titleLabel.textColor = UIColor(red: 137.0 / 255, green: 137.0 / 255, blue: 142.0 / 255, alpha: 1.0)
    titleLabel.text = "FOLLOWERS"
  }

  let verticalAxeView = VerticalAxeView()
  private let dateAxeView = DateAxeView(frame:
    CGRect(
      x: 0.0,
      y: 0.0,
      width: UIScreen.main.bounds.width - 2 * Constants.padding,
      height: 42.0
    )
  )
  private let controlPanelView: ControlPanelView
  private let filterButtonsView = FilterButtonsView()
  private let infoView: InfoViewProtocol

  private let plotView: PlotViewProtocol

  var chartChange: ((Int) -> ())?

  var rangeChanged: ((ClosedRange<Float>) -> ())? {
    get {
      return controlPanelView.rangeChanged
    } set {
      controlPanelView.rangeChanged = newValue
    }
  }

  var yAxesChanged: ((Int) -> ())? {
    get {
      return filterButtonsView.yAxesChanged
    } set {
      filterButtonsView.yAxesChanged = newValue
    }
  }

  init(plotView: PlotViewProtocol,
       infoView: InfoViewProtocol,
       bottomPlotView: PlotViewProtocol) {
    self.plotView = plotView
    self.controlPanelView = ControlPanelView(plotView: bottomPlotView)
    self.infoView = infoView
    super.init(frame: .zero)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = UIColor(red: 239.0 / 255, green: 239.0 / 255, blue: 244.0 / 255, alpha: 1.0)

    // configure title label
    addSubview(titleLabel, constraints: [
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
    ])

    contentContainer.backgroundColor = .white
    addSubview(contentContainer, constraints: [
      contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
    ])

    // configure vertical axes view
    verticalAxeView.clipsToBounds = true
    let topInset = 8 as CGFloat
    contentContainer.addSubview(verticalAxeView, constraints: [
      verticalAxeView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: topInset),
      verticalAxeView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Constants.padding),
      verticalAxeView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Constants.padding),
      verticalAxeView.heightAnchor.constraint(equalToConstant: VerticalAxeView.Constants.stripHeight * 5.5)
    ])

    plotView.translatesAutoresizingMaskIntoConstraints = false
    contentContainer.addSubview(plotView)

    NSLayoutConstraint.activate([
      plotView.topAnchor.constraint(equalTo: verticalAxeView.topAnchor),
      plotView.leadingAnchor.constraint(equalTo: verticalAxeView.leadingAnchor),
      plotView.trailingAnchor.constraint(equalTo: verticalAxeView.trailingAnchor),
      plotView.bottomAnchor.constraint(equalTo: verticalAxeView.bottomAnchor)
    ])

    addSubview(infoView, constraints: [
      infoView.topAnchor.constraint(equalTo: verticalAxeView.topAnchor),
      infoView.leadingAnchor.constraint(equalTo: verticalAxeView.leadingAnchor),
      infoView.trailingAnchor.constraint(equalTo: verticalAxeView.trailingAnchor),
      infoView.bottomAnchor.constraint(equalTo: verticalAxeView.bottomAnchor)
    ])
    infoView.onZoom = zoom

    // configure date axe view
    contentContainer.addSubview(dateAxeView, constraints: [
      dateAxeView.topAnchor.constraint(equalTo: verticalAxeView.bottomAnchor),
      dateAxeView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Constants.padding),
      dateAxeView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Constants.padding),
      dateAxeView.heightAnchor.constraint(equalToConstant: 30)
    ])

    // configure control panel plot view
    contentContainer.addSubview(controlPanelView, constraints: [
      controlPanelView.topAnchor.constraint(equalTo: dateAxeView.bottomAnchor),
      controlPanelView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Constants.padding),
      controlPanelView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Constants.padding),
      controlPanelView.heightAnchor.constraint(equalToConstant: 40)
    ])

    // configure filter buttons
    addSubview(filterButtonsView, constraints: [
      filterButtonsView.topAnchor.constraint(equalTo: controlPanelView.bottomAnchor, constant: 16),
        filterButtonsView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
        filterButtonsView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
        filterButtonsView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -16)
    ])
  }

  func zoom() {
    
  }

  func rangeUpdated(_ chartRange: ChartRange) {
    verticalAxeView.maxValue = chartRange.max
    plotView.updateChart(chartRange)
    dateAxeView.updateDateAxe(chartRange: chartRange)
    infoView.hide()
  }

  func yAxesUpdated(_ chartRange: ChartRange) {
    verticalAxeView.maxValue = chartRange.max
    plotView.updateChart(chartRange)
    controlPanelView.updateChartRange(chartRange)
    let cellProps = chartRange.allYAxes.map { axe in
      return FilterButtonCell.Props(
        color: UIColor(hexString: axe.color),
        text: axe.name,
        isChecked: chartRange.activeYAxes.contains(axe)
      )
    }
    filterButtonsView.render(cellProps: cellProps)
    infoView.hide()
    self.chartRange = chartRange
  }

  func toggleLightMode(on: Bool) {
    if on {
      backgroundColor = UIColor(red: 239.0 / 255, green: 239.0 / 255, blue: 244.0 / 255, alpha: 1.0)
      titleLabel.textColor = UIColor(red: 137.0 / 255, green: 137.0 / 255, blue: 142.0 / 255, alpha: 1.0)
      contentContainer.backgroundColor = .white
    } else {
      backgroundColor = UIColor(red: 24.0 / 255, green: 34.0 / 255, blue: 44.0 / 255, alpha: 1.0)
      titleLabel.textColor = UIColor(red: 91.0 / 255, green: 106.0 / 255, blue: 125.0 / 255, alpha: 1.0)
      contentContainer.backgroundColor = UIColor(red: 34.0 / 255, green: 47.0 / 255, blue: 62.0 / 255, alpha: 1.0)
    }
    verticalAxeView.toggleMode(isLight: on)
    controlPanelView.toggleLighMode(on: on)
    infoView.isLight = on
  }

  enum Constants {
    static let padding: CGFloat = 16
  }
}
