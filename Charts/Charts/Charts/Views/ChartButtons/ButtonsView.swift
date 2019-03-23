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
    tableView.delegate = self
    tableView.dataSource = self
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
}

extension ButtonsView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    yAxesChanged?(indexPath.row)
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
