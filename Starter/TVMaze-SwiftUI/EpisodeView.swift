//
//  EpisodeView.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/11/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine

final class EpisodeModel: ObservableObject {
  let episode: Episode
  private var subscriptions = Set<AnyCancellable>()
  init(episode: Episode) {
    self.episode = episode
  }
}

struct EpisodeView: View {
  @ObservedObject var model: EpisodeModel
  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 4) {
        RemoteImage(url: self.model.episode.image?.original)
        Text(self.model.episode.name).font(.largeTitle)
        Text("Episode \(self.model.episode.number)").font(.title)
        Text(self.model.episode.summary ?? "").font(.body)
      }
      .padding()
    }
  }
}

#if DEBUG
struct EpisodeView_Previews: PreviewProvider {
  static var previews: some View {
    EpisodeView(model: .init(episode: Episode(id: 1, url: URL(string: "cnn.com")!, name: "Test", season: 1, number: 1, airdate: "", runtime: 1, image: nil, summary: "summary")))
  }
}
#endif
