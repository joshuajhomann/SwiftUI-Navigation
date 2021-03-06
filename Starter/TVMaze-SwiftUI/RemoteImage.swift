//
//  RemoteImage.swift
//  TVMaze-SwiftUI
//
//  Created by Joshua Homann on 1/11/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

class ImageCache {
  enum Error: Swift.Error {
    case dataConversionFailed
    case sessionError(Swift.Error)
  }
  static let shared = ImageCache()
  private let cache = NSCache<NSURL, UIImage>()
  private init() { }
  static func image(for url: URL?) -> AnyPublisher<UIImage?, ImageCache.Error> {
    guard let url = url else {
      return Empty().eraseToAnyPublisher()
    }
    guard let image = shared.cache.object(forKey: url as NSURL) else {
      return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .tryMap { (tuple) -> UIImage in
          let (data, _) = tuple
          guard let image = UIImage(data: data) else {
            throw Error.dataConversionFailed
          }
          shared.cache.setObject(image, forKey: url as NSURL)
          return image
      }
      .mapError({ error in Error.sessionError(error) })
      .eraseToAnyPublisher()
    }
    return Just(image)
      .mapError({ _ in fatalError() })
      .eraseToAnyPublisher()
  }
}

class ImageModel: ObservableObject {
  @Published var image: UIImage? = nil
  var cacheSubscription: AnyCancellable?
  init(url: URL?) {
    cacheSubscription = ImageCache
      .image(for: url)
      .replaceError(with: nil)
      .receive(on: RunLoop.main, options: .none)
      .assign(to: \.image, on: self)
  }
}

struct RemoteImage : View {
  @ObservedObject var imageModel: ImageModel
  private let contentMode: ContentMode
  init(url: URL?, contentMode: ContentMode = .fit) {
    imageModel = ImageModel(url: url)
    self.contentMode = contentMode
  }
  var body: some View {
    imageModel
      .image
      .map { Image(uiImage:$0).resizable().aspectRatio(contentMode: contentMode) }
      ?? Image(systemName: "questionmark").resizable().aspectRatio(contentMode: contentMode)
  }
}

#if DEBUG
struct RemoteImage_Previews : PreviewProvider {
  static var previews: some View {
    RemoteImage(url: URL(string:"http://assets22.pokemon.com/assets/cms2/img/pokedex/full/001.png")!)
  }
}
#endif
