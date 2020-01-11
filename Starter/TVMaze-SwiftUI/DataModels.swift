//
//  DataModels.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Foundation

// MARK: - ShowResults
struct ShowResults: Codable {
  var score: Double
  var show: Show
}

// MARK: - ShowClass
struct Show: Codable, Hashable, Identifiable {
  var id: Int
  var name: String

  enum CodingKeys: String, CodingKey {
    case id, name
  }
}

struct Season: Hashable, Identifiable {
  var id: Int
  var episodes: [Episode]
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  static func == (lhs: Season, rhs: Season) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Episode
struct Episode: Codable, Hashable, Identifiable {
  var id: Int
  var url: URL
  var name: String
  var season, number: Int
  var airdate: String
  var runtime: Int
  var image: Image?
  var summary: String?

  enum CodingKeys: String, CodingKey {
    case id, url, name, season, number, airdate, runtime, image, summary
  }

  struct Image: Codable {
    var medium, original: URL
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  static func == (lhs: Episode, rhs: Episode) -> Bool {
    lhs.id == rhs.id
  }
}


