//
//  ControlPanelView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/12/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ControlPanelView: UIView {

  private let plotView = PlotView()
  private let leftShadowView = UIView()
  private let leftControlView = UIView()
  private let centerView = UIView()
  private let rightControlView = UIView()
  private let rightShadowView = UIView()
  private var leftControlLeadingConstraint: NSLayoutConstraint!
  private var rightControlLeadingConstraint: NSLayoutConstraint!

  var rangeChanged: ((ClosedRange<Float>) -> ())?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = .clear

    // configure plot view
    addSubview(plotView, constraints: [
      plotView.topAnchor.constraint(equalTo: topAnchor),
      plotView.leadingAnchor.constraint(equalTo: leadingAnchor),
      plotView.trailingAnchor.constraint(equalTo: trailingAnchor),
      plotView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure left shadow view
    leftShadowView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    addSubview(leftShadowView, constraints: [
      leftShadowView.topAnchor.constraint(equalTo: topAnchor),
      leftShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
      leftShadowView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure left control view
    let leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPanGesture(_:)))
    leftControlView.addGestureRecognizer(leftPanGesture)
    leftControlView.isUserInteractionEnabled = true
    leftControlView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
    leftControlLeadingConstraint = leftControlView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100)
    addSubview(leftControlView, constraints: [
      leftControlView.topAnchor.constraint(equalTo: topAnchor),
      leftControlView.leadingAnchor.constraint(equalTo: leftShadowView.trailingAnchor),
      leftControlLeadingConstraint,
      leftControlView.bottomAnchor.constraint(equalTo: bottomAnchor),
      leftControlView.widthAnchor.constraint(equalToConstant: 12)
    ])

    // configure center view
    centerView.backgroundColor = .clear
    addSubview(centerView, constraints: [
      centerView.topAnchor.constraint(equalTo: topAnchor),
      centerView.leadingAnchor.constraint(equalTo: leftControlView.trailingAnchor),
      centerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure right control view
    let rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRightPanGesture(_:)))
    rightControlView.addGestureRecognizer(rightPanGesture)
    rightControlView.isUserInteractionEnabled = true
    rightControlView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
    rightControlLeadingConstraint = rightControlView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 200)
    addSubview(rightControlView, constraints: [
      rightControlView.topAnchor.constraint(equalTo: topAnchor),
      rightControlView.leadingAnchor.constraint(equalTo: centerView.trailingAnchor),
      rightControlLeadingConstraint,
      rightControlView.bottomAnchor.constraint(equalTo: bottomAnchor),
      rightControlView.widthAnchor.constraint(equalToConstant: 12)
      ])

    // configure right shadow view
    rightShadowView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    addSubview(rightShadowView, constraints: [
      rightShadowView.topAnchor.constraint(equalTo: topAnchor),
      rightShadowView.leadingAnchor.constraint(equalTo: rightControlView.trailingAnchor),
      rightShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
      rightShadowView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func updateChartRange(_ chartRange: ChartRange) {
    plotView.updateChart(chartRange)
  }

  @objc func handleLeftPanGesture(_ event: UIPanGestureRecognizer) {
    switch event.state {
    case .changed:
      let xCoordinate = event.location(in: self).x
      let boundedCoordinate = min(max(xCoordinate, 0), rightControlLeadingConstraint.constant - 12)
      leftControlLeadingConstraint.constant = boundedCoordinate

      updateRange()
    default:
      break
    }
  }

  @objc func handleRightPanGesture(_ event: UIPanGestureRecognizer) {
    switch event.state {
    case .changed:
      let xCoordinate = event.location(in: self).x
      let width = self.bounds.width
      let boundedCoordinate = min(max(xCoordinate, leftControlLeadingConstraint.constant + 12), width - 12)
      rightControlLeadingConstraint.constant = boundedCoordinate

      updateRange()
    default:
      break
    }
  }

  private func updateRange() {
    let width = self.frame.width
    let leftPoint = Float(leftControlView.frame.minX / width)
    let rightPoint = Float(rightControlView.frame.maxX / width)
    rangeChanged?(leftPoint...rightPoint)
  }
}
