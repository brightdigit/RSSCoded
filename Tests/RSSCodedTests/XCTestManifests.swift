#if !canImport(ObjectiveC)
  import XCTest

  extension BlogTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__BlogTests = [
      ("testBlogs", testBlogs)
    ]
  }

  extension RSSCodedTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__RSSCodedTests = [
      ("testDurations", testDurations),
      ("testJSONXMLEquality", testJSONXMLEquality),
      ("testPodcastEpisodes", testPodcastEpisodes),
      ("testSyndication", testSyndication),
      ("testYoutubeVideos", testYoutubeVideos)
    ]
  }

  public func __allTests() -> [XCTestCaseEntry] {
    return [
      testCase(BlogTests.__allTests__BlogTests),
      testCase(RSSCodedTests.__allTests__RSSCodedTests)
    ]
  }
#endif
