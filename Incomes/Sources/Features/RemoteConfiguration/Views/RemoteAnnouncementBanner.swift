import MHDesign
import MHPlatform
import SwiftUI

struct RemoteAnnouncementBanner: View {
    private static let titleLineLimit = 2

    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @State private var isPresented = false

    let store: RemoteAnnouncementStore

    var body: some View {
        Group {
            if store.hasFeed {
                TimelineView(.everyMinute) { _ in
                    let announcements = visibleAnnouncements(at: .now)
                    if let first = announcements.first {
                        Button {
                            isPresented = true
                        } label: {
                            HStack {
                                Label {
                                    Text(verbatim: first.title)
                                        .lineLimit(Self.titleLineLimit)
                                } icon: {
                                    Image(systemName: "megaphone")
                                }
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .accessibilityHidden(true)
                            }
                            .padding(.horizontal)
                            .frame(minHeight: designMetrics.layout.control.minimumTouchTarget)
                            .contentShape(Rectangle())
                        }
                        .background(.regularMaterial)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                TimelineView(.everyMinute) { _ in
                    let announcements = visibleAnnouncements(at: .now)
                    List(announcements) { announcement in
                        VStack(alignment: .leading) {
                            Text(verbatim: announcement.title)
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                            Text(verbatim: announcement.body)
                                .textSelection(.enabled)
                        }
                    }
                    .onChange(of: announcements.isEmpty, initial: true) {
                        if announcements.isEmpty {
                            isPresented = false
                        }
                    }
                }
                .navigationTitle("Announcements")
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
            }
        }
    }

    private func visibleAnnouncements(at date: Date) -> [MHAnnouncement] {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return store.visibleAnnouncements(
            installedVersion: version.flatMap(MHAppVersion.init),
            at: date,
            appLanguage: Bundle.main.preferredLocalizations.first,
            preferredLanguages: Locale.preferredLanguages
        )
    }
}
