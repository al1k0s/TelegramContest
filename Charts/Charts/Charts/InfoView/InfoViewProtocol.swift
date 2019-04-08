//
//  InfoViewProtocol.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/9/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit.UIView

protocol InfoViewProtocol: UIView {
  var isLight: Bool { get set }
  func hide()
  var tapOccured: (CGFloat) -> InfoViewModel { get set }
  var onZoom: (() -> Void)? { get set }
}
