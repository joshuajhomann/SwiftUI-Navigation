//
//  TVMazeService.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import Foundation
import Combine

protocol TVMazeProvider {
  func search(query: String) -> AnyPublisher<[Show], Error>
  func seasons(forShowId id: Int) -> AnyPublisher<[Season], Error>
}

final class TVMazeService: TVMazeProvider {
  private enum Constant {
    static let episodesUrl = "http://api.tvmaze.com/shows/:id/episodes"
    static let showUrl = "http://api.tvmaze.com/search/shows"
  }
  private init() {}
  static let shared = TVMazeService()
  func search(query: String) -> AnyPublisher<[Show], Error> {
    var components = URLComponents(url: URL(string: Constant.showUrl)!, resolvingAgainstBaseURL: false)
    components?.queryItems = [URLQueryItem(name: "q", value: query)]
    return URLSession
    .shared
    .dataTaskPublisher(for: components!.url!)
    .map(\.data)
    .decode(type: [ShowResults].self, decoder: JSONDecoder())
    .map { $0.map { $0.show } }
    .eraseToAnyPublisher()
  }
  func seasons(forShowId id: Int) -> AnyPublisher<[Season], Error> {
    let episodesUrl = URL(string: Constant.episodesUrl.replacingOccurrences(of: ":id", with: "\(id)"))!
    return URLSession
      .shared
      .dataTaskPublisher(for: episodesUrl)
      .map(\.data)
      .decode(type: [Episode].self, decoder: JSONDecoder())
      .map { episodes in
        let noHtmlEpisodes = episodes.map { episode -> Episode in
          var copy = episode
          copy.summary = copy.summary.map {
            $0
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "")
          }
          return copy
        }
        let grouped = Dictionary(grouping: noHtmlEpisodes, by: { $0.season })
        return grouped
          .keys
          .sorted()
          .compactMap { Season(id: $0, episodes: grouped[$0] ?? []) }
      }
      .eraseToAnyPublisher()
  }
}

