//
//  ChartView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ChartView: UIView {

  private let titleLabel = UILabel()
  let verticalAxeView = VerticalAxeView(
    width: UIScreen.main.bounds.width - 2 * Constants.padding
  )
  private let controlPanelView = ControlPanelView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = .white

    // configure title label
    titleLabel.font = UIFont.systemFont(ofSize: 17)
    titleLabel.textColor = UIColor.gray
    titleLabel.text = "FOLLOWERS"
    addSubview(titleLabel, constraints: [
      titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
    ])

    // configure vertical axes view
    addSubview(verticalAxeView, constraints: [
      verticalAxeView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      verticalAxeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
      verticalAxeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
      verticalAxeView.heightAnchor.constraint(equalToConstant: 240)
    ])

    // configure control panel plot view
    addSubview(controlPanelView, constraints: [
      controlPanelView.topAnchor.constraint(equalTo: verticalAxeView.bottomAnchor),
      controlPanelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
      controlPanelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
      controlPanelView.heightAnchor.constraint(equalToConstant: 40)
    ])

    let emptyView = UIView()
    emptyView.backgroundColor = .red
    addSubview(emptyView, constraints: [
      emptyView.topAnchor.constraint(equalTo: controlPanelView.bottomAnchor, constant: 8),
      emptyView.leadingAnchor.constraint(equalTo: leadingAnchor),
      emptyView.trailingAnchor.constraint(equalTo: trailingAnchor),
      emptyView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func updateBottomPanel(yAxes: [YAxis]) {
    controlPanelView.updateValues(yAxes: yAxes)
  }

  enum Constants {
    static let padding: CGFloat = 16
  }
}
