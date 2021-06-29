import Foundation
public protocol PodcastEpisodeProtocol {
  var title: String? { get }
  var episode: Int? { get }
  var author: String? { get }
  var subtitle: String? { get }
  var summary: String? { get }
  var explicit: String? { get }
  var duration: TimeInterval? { get }
  var image: iTunesImage? { get }
  var enclosure: Enclosure { get }
}
