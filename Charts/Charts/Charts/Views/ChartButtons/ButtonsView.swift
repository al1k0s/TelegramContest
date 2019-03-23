//
//  ButtonsView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/23/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ButtonsView: UIView {

  private let tableView = UITableView()
  private var props: [ButtonCell.Props] = []

  var yAxesChanged: ((Int) -> ())?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {
    tableView.register(ButtonCell.self, forCellReuseIdentifier: "ButtonCell")
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self
    tableView.isScrollEnabled = false
    tableView.backgroundColor = .clear
    addSubview(tableView, constraints: [
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func render(props: [ButtonCell.Props]) {
    self.props = props
    tableView.reloadData()
  }

  func reload() {
    tableView.reloadData()
  }
}

extension ButtonsView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    yAxesChanged?(indexPath.row)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40.0
  }
}

extension ButtonsView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return props.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
    cell.render(props: props[indexPath.row])
    return cell
  }
}
