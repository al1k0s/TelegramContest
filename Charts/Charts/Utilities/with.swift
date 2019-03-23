//
//  with.swift
//  Charts
//
//  Created by Alik Vovkotrub on 3/23/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

@discardableResult
public func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
  var item = item
  try update(&item)
  return item
}
