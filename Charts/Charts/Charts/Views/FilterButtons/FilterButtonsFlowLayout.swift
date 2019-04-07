//
//  FilterButtonsFlowLayout.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/7/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

class FilterButtonsCollectionViewFlowLayout: UICollectionViewFlowLayout {

  private var names = [String]()

  private var otherContentWidth: CGFloat = 41
  private var cache = [UICollectionViewLayoutAttributes]()
  private(set) var contentHeight: CGFloat = 0 {
    didSet {
      onHeightChange?(contentHeight)
    }
  }
  var onHeightChange: ((CGFloat) -> ())?

  fileprivate var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }

  override func prepare() {
    super.prepare()
    guard let collectionView = collectionView else { return }

    let numbersOfItems = collectionView.numberOfItems(inSection: 0)
    if numbersOfItems != cache.count || numbersOfItems == 0 {
      contentHeight = 0
      cache = []
    }

    let columnHeight: CGFloat = 30
    contentHeight = columnHeight
    var yOffset: CGFloat = 0
    var xOffset: CGFloat = 16
    let contentWidth = collectionView.bounds.width

    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

      let indexPath = IndexPath(item: item, section: 0)
      guard indexPath.row < names.count else { return }

      let textWidth = calculateLength(of: names[indexPath.row])
      let width = textWidth + otherContentWidth
      if xOffset + width > contentWidth - 16 {
        xOffset = 16
        yOffset += columnHeight + 8
        contentHeight += columnHeight + 8
      }
      let height = columnHeight
      let frame = CGRect(
        x: xOffset,
        y: yOffset,
        width: width,
        height: height
      )

      xOffset += width + 8
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = frame
      cache.append(attributes)
    }
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    // Loop through the cache and look for items in the rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }

  func calculateLength(of text: String) -> CGFloat {
    let size = (text as NSString).size(
      withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
    )
    return size.width
  }

  func updateNames(names: [String]) {
    self.names = names
  }
}
