//
//  ControlPanelView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/12/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ControlPanelView: UIView {

  private let plotView = Plot1View(isMainPlot: false)
  private let leftShadowView = UIView()
  private let leftControlView = SideView(isLeft: true)
  private let centerView = CenterView()
  private let rightControlView = SideView(isLeft: false)
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
    layer.cornerRadius = 5
    clipsToBounds = true
    backgroundColor = .clear

    // configure plot view
    addSubview(plotView, constraints: [
      plotView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
      plotView.leadingAnchor.constraint(equalTo: leadingAnchor),
      plotView.trailingAnchor.constraint(equalTo: trailingAnchor),
      plotView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
    ])

    // configure left shadow view
    leftShadowView.backgroundColor = Constants.lightBackground.withAlphaComponent(0.2)
    addSubview(leftShadowView, constraints: [
      leftShadowView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
      leftShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
      leftShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
    ])

    // configure center view
    let centerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCenterPanGesture(_:)))
    centerView.addGestureRecognizer(centerPanGesture)
    centerView.backgroundColor = .clear
    addSubview(centerView, constraints: [
      centerView.topAnchor.constraint(equalTo: topAnchor),
      centerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure left control view
    let leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPanGesture(_:)))
    leftControlView.addGestureRecognizer(leftPanGesture)
    leftControlView.isUserInteractionEnabled = true
    leftControlView.setImage(#imageLiteral(resourceName: "leftArrow"))
    leftControlLeadingConstraint = leftControlView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100)
    addSubview(leftControlView, constraints: [
      leftControlView.topAnchor.constraint(equalTo: topAnchor),
      leftControlView.leadingAnchor.constraint(
        equalTo: leftShadowView.trailingAnchor,
        constant: -(Constants.unvisibleControlViewWidth + Constants.controlViewRadius)
      ),
      leftControlLeadingConstraint,
      leftControlView.trailingAnchor.constraint(equalTo: centerView.leadingAnchor),
      leftControlView.bottomAnchor.constraint(equalTo: bottomAnchor),
      leftControlView.widthAnchor.constraint(equalToConstant: Constants.unvisibleControlViewWidth * 2)
    ])

    // configure right shadow view
    rightShadowView.backgroundColor = Constants.lightBackground.withAlphaComponent(0.2)
    addSubview(rightShadowView, constraints: [
      rightShadowView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
      rightShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
      rightShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
    ])

    // configure right control view
    let rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRightPanGesture(_:)))
    rightControlView.addGestureRecognizer(rightPanGesture)
    rightControlView.isUserInteractionEnabled = true
    rightControlView.setImage(#imageLiteral(resourceName: "rightArrow"))
    rightControlLeadingConstraint = rightControlView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 200)
    addSubview(rightControlView, constraints: [
      rightControlView.topAnchor.constraint(equalTo: topAnchor),
      rightControlLeadingConstraint,
      rightControlView.trailingAnchor.constraint(
        equalTo: rightShadowView.leadingAnchor,
        constant: Constants.unvisibleControlViewWidth + Constants.controlViewRadius
      ),
      rightControlView.leadingAnchor.constraint(equalTo: centerView.trailingAnchor),
      rightControlView.bottomAnchor.constraint(equalTo: bottomAnchor),
      rightControlView.widthAnchor.constraint(equalToConstant: Constants.unvisibleControlViewWidth * 2)
    ])
  }

  func updateChartRange(_ chartRange: ChartRange) {
    plotView.updateChart(chartRange)
  }

  func toggleLighMode(on: Bool) {
    let light = Constants.lightBackground
    let dark = Constants.darkBackground
    let lightOverlay = Constants.lightOverlay
    let darkOverlay = Constants.darkOverlay
    leftShadowView.backgroundColor = on ? lightOverlay : darkOverlay
    leftControlView.setBackgroundColor(on ? light : dark)
    rightShadowView.backgroundColor = on ? lightOverlay : darkOverlay
    rightControlView.setBackgroundColor(on ? light : dark)
    centerView.setLinesColor(on ? light : dark)
  }

  private var leftControlerHandler: ConstraintHandler?
  private var rightControlerHandler: ConstraintHandler?
  private var centerHandler: ConstraintHandler?
}

// handle pan gestures
extension ControlPanelView {

  struct ConstraintHandler {
    let startXCoordinate: CGFloat
    let constraintConstant: CGFloat
  }

  @objc func handleLeftPanGesture(_ event: UIPanGestureRecognizer) {
    switch event.state {
    case .began:
      let xCoordinate = event.location(in: self).x
      leftControlerHandler = .init(
        startXCoordinate: xCoordinate,
        constraintConstant: leftControlLeadingConstraint.constant
      )

    case .changed:
      guard let handler = leftControlerHandler else { return }
      let xCoordinate = event.location(in: self).x
      let diff = xCoordinate - handler.startXCoordinate
      let newConstant = handler.constraintConstant + diff
      let minValue = max(newConstant, -Constants.unvisibleControlViewWidth)
      let boundedCoordinate = min(minValue, rightControlLeadingConstraint.constant - 2 * Constants.unvisibleControlViewWidth)
      leftControlLeadingConstraint.constant = boundedCoordinate

      updateRange()
    default:
      break
    }
  }

  @objc func handleRightPanGesture(_ event: UIPanGestureRecognizer) {
    switch event.state {
    case .began:
      let xCoordinate = event.location(in: self).x
      rightControlerHandler = .init(
        startXCoordinate: xCoordinate,
        constraintConstant: rightControlLeadingConstraint.constant
      )

    case .changed:
      guard let handler = rightControlerHandler else { return }
      let xCoordinate = event.location(in: self).x
      let width = self.bounds.width
      let diff = xCoordinate - handler.startXCoordinate
      let newConstant = handler.constraintConstant + diff
      let minValue = max(newConstant, leftControlLeadingConstraint.constant + 2 * Constants.unvisibleControlViewWidth)
      let boundedCoordinate = min(minValue, width - Constants.unvisibleControlViewWidth)
      rightControlLeadingConstraint.constant = boundedCoordinate

      updateRange()
    default:
      break
    }
  }

  @objc func handleCenterPanGesture(_ event: UIPanGestureRecognizer) {
    switch event.state {
    case .began:
      let xCoordinate = event.location(in: self).x
      centerHandler = .init(
        startXCoordinate: xCoordinate,
        constraintConstant: leftControlLeadingConstraint.constant
      )

    case .changed:
      guard let handler = centerHandler else { return }
      let xCoordinate = event.location(in: self).x
      let width = self.bounds.width
      let diff = xCoordinate - handler.startXCoordinate
      let newX = handler.constraintConstant + diff
      let minValue = max(newX, -Constants.unvisibleControlViewWidth)
      let boundedCoordinate = min(minValue, width - 3 * Constants.unvisibleControlViewWidth - centerView.bounds.width)
      leftControlLeadingConstraint.constant = boundedCoordinate
      rightControlLeadingConstraint.constant = boundedCoordinate + centerView.bounds.width + 2 * Constants.unvisibleControlViewWidth

      updateRange()
    default:
      break
    }
  }

  private func updateRange() {
    let width = self.frame.width
    let leftPoint = Float((leftControlView.frame.minX + Constants.unvisibleControlViewWidth) / width)
    let rightPoint = Float((rightControlView.frame.maxX - Constants.unvisibleControlViewWidth ) / width)
    rangeChanged?(leftPoint...rightPoint)
  }
}

private enum Constants {
  static let unvisibleControlViewWidth: CGFloat = 13
  static let controlViewRadius: CGFloat = 6
  static let lightOverlay = UIColor(red: 208.0 / 255, green: 230.0 / 255, blue: 249.0 / 255, alpha: 0.4)
  static let darkOverlay = UIColor(red: 16.0 / 255, green: 24.0 / 255, blue: 39.0 / 255, alpha: 0.4)
  static let lightBackground = UIColor(red: 190.0 / 255, green: 205.0 / 255, blue: 220.0 / 255, alpha: 1.0)
  static let darkBackground = UIColor(red: 86.0 / 255, green: 98.0 / 255, blue: 108.0 / 255, alpha: 1.0)
}

