//
//  SeasonsView.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine

final class SeasonsModel: ObservableObject {
  let show: Show
  @Published var seasons: [Season] = []
  private let tvMazeService: TVMazeProvider
  private var subscriptions = Set<AnyCancellable>()
  init(show: Show, tvMazeService: TVMazeProvider = TVMazeService.shared) {
    self.show = show
    self.tvMazeService = tvMazeService
  }
  func load() {
    tvMazeService
      .seasons(forShowId: show.id)
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .assign(to: \.seasons, on: self)
      .store(in: &subscriptions)
  }
}

struct SeasonsView: View {
  @ObservedObject var model: SeasonsModel
  var body: some View {
    List {
      ForEach(self.model.seasons) { season in
        Section(header: Text("Season \(season.id)").font(.largeTitle), content: {
          ForEach(season.episodes) { episode in
            NavigationLink(destination: EpisodeView(model: .init(episode: episode))) {
              HStack(alignment: .top, spacing: 12) {
                RemoteImage(url: episode.image?.medium, contentMode: .fill)
                  .frame(width: 64, height: 64)
                  .cornerRadius(12)
                VStack(alignment: .leading, spacing: 4) {
                  Text(episode.name).font(.title)
                  Text("Episode \(episode.number)").font(.subheadline)
                  Text(episode.summary ?? "").font(.caption)
                }
              }
            }
          }
        })
      }
    }
    .navigationBarTitle(self.model.show.name)
    .onAppear { self.model.load() }
  }
}

#if DEBUG
struct SeasonsView_Previews: PreviewProvider {
  static var previews: some View {
    SeasonsView(model: .init(show: Show(id: 2, name: "Test")))
  }
}
#endif

