//
//  ContentView.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/10/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine

class ShowModel: ObservableObject {
  @Published var shows: [Show] = []
  @Published var searchTerm = ""
  private let tvMazeService: TVMazeProvider
  private var subscriptions = Set<AnyCancellable>()
  init(tvMazeService: TVMazeProvider = TVMazeService.shared) {
    self.tvMazeService = tvMazeService
    $searchTerm
      .debounce(for: .seconds(0.25), scheduler: RunLoop.main)
      .removeDuplicates()
      .flatMap { term -> AnyPublisher<[Show], Never> in
        guard !term.isEmpty else {
          return Just<[Show]>([]).eraseToAnyPublisher()
        }
        return tvMazeService
          .search(query: term)
          .replaceError(with: [])
          .eraseToAnyPublisher()
      }
      .receive(on: RunLoop.main)
      .assign(to: \.shows, on: self)
      .store(in: &subscriptions)
  }
}

struct ShowView: View {
  @ObservedObject var model: ShowModel
  private var searchTerm: Binding<String>
  init(model: ShowModel = .init()) {
    self.model = model
    searchTerm = .init(get: { model.searchTerm }, set: { model.searchTerm = $0})
  }
  var body: some View {
    NavigationView {
      VStack {
        SearchBar(text: searchTerm)
        List(self.model.shows) { show in
          NavigationLink(show.name, destination: SeasonsView(model: .init(show: show)))
        }
      }
      .navigationBarTitle("Show Search")
    }
  }
}

struct SearchBar : View {
  @Binding var text: String
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
      TextField("TV Show Search...", text: $text)
        .textFieldStyle(RoundedBorderTextFieldStyle())
      Button(action: { self.text = "" }) {
        Text("Clear")
      }
      .padding(8)
      .background(Color.accentColor)
      .foregroundColor(Color.white)
      .cornerRadius(4)
    }
    .padding()
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ShowView()
  }
}
#endif
