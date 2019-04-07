//
//  FilterButtonsView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/7/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class FilterButtonsView: UIView {

  private let flowLayout = FilterButtonsCollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
  private var collectionViewHeight: NSLayoutConstraint!

  private var items: [FilterButtonCell.Props] = [
    FilterButtonCell.Props(color: .green, text: "Android", isChecked: true),
    FilterButtonCell.Props(color: .blue, text: "iPhone", isChecked: false),
    FilterButtonCell.Props(color: .blue, text: "OSX", isChecked: true),
    FilterButtonCell.Props(color: .red, text: "Web", isChecked: false),
    FilterButtonCell.Props(color: .orange, text: "TDescktop", isChecked: false),
    FilterButtonCell.Props(color: .blue, text: "Other", isChecked: true)
  ]

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    flowLayout.updateNames(names: items.map { $0.text })
    collectionView.reloadData()
  }

  private func setup() {
    backgroundColor = .clear
    collectionView.backgroundColor = .clear
    collectionView.register(FilterButtonCell.self, forCellWithReuseIdentifier: "FilterButton")
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0)
    flowLayout.onHeightChange = { [weak self] height in self?.collectionViewHeight.constant = height }
    addSubview(collectionView, withEdgeInsets: .zero)
    NSLayoutConstraint.activate([collectionViewHeight])
  }
}

extension FilterButtonsView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterButton", for: indexPath) as! FilterButtonCell
    cell.render(props: items[indexPath.row])
    return cell
  }
}

extension FilterButtonsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let props = items[indexPath.row]
    let newProps = FilterButtonCell.Props(color: props.color, text: props.text, isChecked: !props.isChecked)
    items[indexPath.row] = newProps
    collectionView.reloadData()
  }
}
