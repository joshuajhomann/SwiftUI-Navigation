//
//  StringInterpolation+Date.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/11/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Foundation

extension String.StringInterpolation {
  static let dateFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }()
  mutating func appendInterpolation(date: Date) {
    appendInterpolation(Self.dateFormatter.string(from: date))
  }
}
