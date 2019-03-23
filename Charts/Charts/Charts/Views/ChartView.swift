//
//  ChartView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ChartView: UIView {

  private let titleLabel = with(UILabel()) { titleLabel in
    titleLabel.font = UIFont.systemFont(ofSize: 17)
    titleLabel.textColor = UIColor.white
    titleLabel.text = "FOLLOWERS"
  }

  let verticalAxeView = VerticalAxeView(
    width: UIScreen.main.bounds.width - 2 * Constants.padding
  )
  private let dateAxeView = DateAxeView(frame:
    CGRect(
      x: 0.0,
      y: 0.0,
      width: UIScreen.main.bounds.width - 2 * Constants.padding,
      height: 30.0
    )
  )
  private let controlPanelView = ControlPanelView()
  private let buttonsView = ButtonsView()
  private let infoView = InfoView()
  private let switchButton = UIButton()
  private let plotView = PlotView(isMainPlot: true)

  var rangeChanged: ((ClosedRange<Float>) -> ())? {
    get {
      return controlPanelView.rangeChanged
    } set {
      controlPanelView.rangeChanged = newValue
    }
  }

  var yAxesChanged: ((Int) -> ())? {
    get {
      return buttonsView.yAxesChanged
    } set {
      buttonsView.yAxesChanged = newValue
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {
    backgroundColor = .gray

    // configure title label
    addSubview(titleLabel, constraints: [
      titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
    ])

    let contentContainer = UIView()
    contentContainer.backgroundColor = .white
    addSubview(contentContainer, constraints: [
      contentContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])

    plotView.translatesAutoresizingMaskIntoConstraints = false
    contentContainer.addSubview(plotView)

    // configure vertical axes view
    contentContainer.addSubview(verticalAxeView, constraints: [
      verticalAxeView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
      verticalAxeView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Constants.padding),
      verticalAxeView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Constants.padding),
      verticalAxeView.heightAnchor.constraint(equalToConstant: 240)
    ])

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

    // configure buttons view
    contentContainer.addSubview(buttonsView, constraints: [
      buttonsView.topAnchor.constraint(equalTo: controlPanelView.bottomAnchor),
      buttonsView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: Constants.padding),
      buttonsView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -Constants.padding),
      buttonsView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
    ])

    // configure button
    let containerView = UIView()
    containerView.backgroundColor = .white
    switchButton.setTitle("Switch to Night Mode", for: .normal)
    addSubview(containerView, constraints: [
      containerView.topAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: 16),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -16)
    ])
    containerView.addSubview(switchButton, constraints: [
      switchButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      switchButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    ])
  }

  func rangeUpdated(_ chartRange: ChartRange) {
    verticalAxeView.maxValue = chartRange.max
    plotView.updateChart(chartRange)
    dateAxeView.updateDateAxe(chartRange: chartRange)
  }

  func yAxesUpdated(_ chartRange: ChartRange) {
    verticalAxeView.maxValue = chartRange.max
    plotView.updateChart(chartRange)
    controlPanelView.updateChartRange(chartRange)
    let props = chartRange.allYAxes.map { axe in
      return ButtonCell.Props.init(
        title: axe.name,
        color: UIColor(hexString: axe.color),
        isChecked: chartRange.activeYAxes.contains(axe)
      )
    }
    buttonsView.render(props: props)
  }

  enum Constants {
    static let padding: CGFloat = 16
  }
}
