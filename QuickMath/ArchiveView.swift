import SwiftUI

/// Pro feature — searchable archive of past words, streak milestones, and favorites.
struct InsightsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var filterFavorites = false

    private var filteredWords: [WordCard] {
        var words = appModel.allWords
        if filterFavorites { words = words.filter(\.isFavorite) }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            words = words.filter {
                $0.headword.lowercased().contains(q) ||
                $0.definition.lowercased().contains(q) ||
                $0.partOfSpeech.lowercased().contains(q)
            }
        }
        return words
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                VStack(spacing: 0) {
                    // Streak summary
                    HStack(spacing: 12) {
                        MetricTile(value: "\(appModel.streak.currentStreak)", label: "streak")
                        MetricTile(value: "\(appModel.streak.longestStreak)", label: "best")
                        MetricTile(value: "\(appModel.allWords.filter(\.wasReviewed).count)", label: "learned")
                        MetricTile(value: "\(appModel.allWords.filter(\.isFavorite).count)", label: "saved")
                    }
                    .padding()

                    // Milestone badges
                    if appModel.streak.longestStreak >= 7 || appModel.allWords.filter(\.wasReviewed).count >= 10 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                if appModel.allWords.filter(\.wasReviewed).count >= 10 {
                                    BadgeTile(icon: "star.fill", label: "10 Words Learned")
                                }
                                if appModel.streak.longestStreak >= 7 {
                                    BadgeTile(icon: "flame.fill", label: "7-Day Streak")
                                }
                                if appModel.streak.longestStreak >= 30 {
                                    BadgeTile(icon: "trophy.fill", label: "30-Day Streak")
                                }
                                if appModel.allWords.filter(\.wasReviewed).count >= 30 {
                                    BadgeTile(icon: "book.fill", label: "30 Words Learned")
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }

                    // Filter bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search words…", text: $searchText)
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.qmField, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                    Toggle(isOn: $filterFavorites) {
                        Label("Bookmarks only", systemImage: "bookmark.fill")
                            .font(.subheadline)
                    }
                    .toggleStyle(.button)
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .tint(Color.qmAccent)

                    Divider()

                    // Word list
                    if filteredWords.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text(searchText.isEmpty ? "No words yet." : "No results for \"\(searchText)\"")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        List {
                            ForEach(filteredWords) { card in
                                ArchiveRowView(card: card)
                                    .listRowBackground(Color.qmCard)
                                    .listRowSeparatorTint(Color.qmHair)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Word Archive")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - ArchiveRowView

struct ArchiveRowView: View {
    let card: WordCard
    @State private var expanded = false
    @EnvironmentObject var appModel: AppModel

    private var dateLabel: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: card.dateUnlocked)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.headword)
                        .font(.headline.weight(.semibold))
                    Text(card.partOfSpeech + " · " + dateLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 8) {
                    if card.wasReviewed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.qmCorrect)
                            .font(.caption)
                    }
                    if card.isFavorite {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(Color.qmAccent)
                            .font(.caption)
                    }
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.tap()
                withAnimation(.spring(duration: 0.25)) { expanded.toggle() }
            }

            if expanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(card.definition)
                        .font(.subheadline)

                    Text(card.etymology)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()

                    Text("\"" + card.exampleSentence + "\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Button {
                            Haptics.tap()
                            appModel.toggleFavorite(card)
                        } label: {
                            Label(
                                card.isFavorite ? "Saved" : "Bookmark",
                                systemImage: card.isFavorite ? "bookmark.fill" : "bookmark"
                            )
                            .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(Color.qmAccent)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - BadgeTile

struct BadgeTile: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Color.qmAccent)
            Text(label)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.qmCard, in: Capsule())
    }
}
