import SwiftUI
import WidgetKit

struct HeadacheDiaryEntry: TimelineEntry {
  let date: Date
}

struct HeadacheDiaryProvider: TimelineProvider {
  func placeholder(in context: Context) -> HeadacheDiaryEntry {
    HeadacheDiaryEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (HeadacheDiaryEntry) -> Void) {
    completion(HeadacheDiaryEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HeadacheDiaryEntry>) -> Void) {
    completion(Timeline(entries: [HeadacheDiaryEntry(date: Date())], policy: .never))
  }
}

struct HeadacheDiaryWidgetEntryView: View {
  let entry: HeadacheDiaryEntry

  var body: some View {
    Link(destination: URL(string: "headacheDiary://addSymptom?homeWidget")!) {
      Image("logo-widget")
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}

@main
struct HeadacheDiaryWidget: Widget {
  let kind = "HeadacheDiaryWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HeadacheDiaryProvider()) { entry in
      HeadacheDiaryWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Peavalu päevik")
    .description("Ava kiiresti sümptomi lisamine.")
    .supportedFamilies([.systemSmall])
  }
}
