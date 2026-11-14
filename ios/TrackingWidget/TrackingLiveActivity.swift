import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    public struct ContentState: Codable, Hashable { }
    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String { "\(id)_\(key)" }
}

let sharedDefault = UserDefaults(suiteName: "group.dev.raone.ahealth")!

struct Vals {
    let title: String, distance: String, elapsedText: String, startMs: Double, running: Bool
    init(_ c: ActivityViewContext<LiveActivitiesAppAttributes>) {
        let a = c.attributes
        title = sharedDefault.string(forKey: a.prefixedKey("title")) ?? ""
        distance = sharedDefault.string(forKey: a.prefixedKey("distance")) ?? ""
        elapsedText = sharedDefault.string(forKey: a.prefixedKey("elapsedText")) ?? ""
        startMs = sharedDefault.double(forKey: a.prefixedKey("startMs"))
        running = sharedDefault.bool(forKey: a.prefixedKey("running"))
    }
}

struct TimeView: View {
    let d: Vals
    var body: some View {
        if d.running {
            Text(Date(timeIntervalSince1970: d.startMs / 1000), style: .timer)
        } else {
            Text(d.elapsedText)
        }
    }
}

struct TrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let d = Vals(context)
            HStack {
                VStack(alignment: .leading) {
                    Text(d.title).font(.headline)
                    Text(d.distance).font(.title2).bold()
                }
                Spacer()
                TimeView(d: d).font(.title2).monospacedDigit()
            }
            .padding()
        } dynamicIsland: { context in
            let d = Vals(context)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { Text(d.distance).font(.title3).bold() }
                DynamicIslandExpandedRegion(.trailing) { TimeView(d: d).monospacedDigit() }
                DynamicIslandExpandedRegion(.bottom) { Text(d.title) }
            } compactLeading: {
                Image(systemName: "figure.run")
            } compactTrailing: {
                TimeView(d: d).monospacedDigit().frame(maxWidth: 50)
            } minimal: {
                Image(systemName: "figure.run")
            }
        }
    }
}