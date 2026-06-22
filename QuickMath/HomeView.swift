import SwiftUI
import SwiftData

struct HomeView: View {
    var forceScreen: String? = nil

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store

    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var showInsights = false
    @State private var showWordDetail = false

    var body: some View {
        ZStack {
            QMBackground()
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header streak row
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lexicon")
                                    .font(.largeTitle.weight(.bold))
                                Text("One rich word a day")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            // Streak badge
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(Color.qmAccent)
                                Text("\(appModel.streak.currentStreak)")
                                    .font(.headline.weight(.bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.qmCard, in: Capsule())
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Today's word card
                        if let word = appModel.todayWord {
                            WordCardView(card: word)
                                .padding(.horizontal)
                                .onTapGesture {
                                    Haptics.tap()
                                    showWordDetail = true
                                }
                        } else {
                            Text("No word for today yet.")
                                .foregroundStyle(.secondary)
                                .padding()
                        }

                        // Action row
                        HStack(spacing: 12) {
                            MetricTile(value: "\(appModel.allWords.count)", label: "words")
                            MetricTile(value: "\(appModel.streak.longestStreak)", label: "best streak")
                            MetricTile(
                                value: "\(appModel.allWords.filter(\.isFavorite).count)",
                                label: "favorites"
                            )
                        }
                        .padding(.horizontal)

                        // Pro archive tile
                        Button {
                            Haptics.tap()
                            if store.isPro {
                                showInsights = true
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "books.vertical")
                                            .foregroundStyle(Color.qmAccent)
                                        Text(store.isPro ? "Word Archive" : "Unlock Archive")
                                            .font(.headline.weight(.semibold))
                                    }
                                    Text(store.isPro
                                         ? "Browse every word you've unlocked"
                                         : "Search past words, streaks & reminders")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: store.isPro ? "chevron.right" : "lock.fill")
                                    .foregroundStyle(store.isPro ? .secondary : Color.qmAccent)
                            }
                            .padding()
                            .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Haptics.tap()
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color.qmAccent)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
                .environmentObject(appModel)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showInsights) {
            InsightsView()
                .environmentObject(appModel)
                .environmentObject(store)
        }
        .sheet(isPresented: $showWordDetail) {
            if let word = appModel.todayWord {
                WordDetailView(card: word)
                    .environmentObject(appModel)
            }
        }
        .onAppear {
            handleForceScreen()
        }
    }

    private func handleForceScreen() {
        guard let screen = forceScreen else { return }
        switch screen {
        case "paywall": showPaywall = true
        case "insights": showInsights = true
        case "settings": showSettings = true
        default: break
        }
    }
}

// MARK: - WordCardView

struct WordCardView: View {
    let card: WordCard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.headword)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                    Text(card.partOfSpeech)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.qmAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.qmAccent.opacity(0.1), in: Capsule())
                }
                Spacer()
                if card.isFavorite {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Color.qmAccent)
                }
            }

            Divider()

            Text(card.definition)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                Label("Etymology", systemImage: "clock.arrow.circlepath")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(card.etymology)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Example", systemImage: "quote.opening")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\"" + card.exampleSentence + "\"")
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if card.wasReviewed {
                Label("Learned", systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.qmCorrect)
            }
        }
        .qmCard()
    }
}

// MARK: - WordDetailView

struct WordDetailView: View {
    let card: WordCard
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                ScrollView {
                    VStack(spacing: 0) {
                        WordCardView(card: card)
                            .padding()

                        if !card.wasReviewed {
                            Button {
                                Haptics.success()
                                appModel.markReviewed(card)
                                dismiss()
                            } label: {
                                Text("Mark as Learned")
                                    .frame(maxWidth: .infinity)
                            }
                            .prominentButton()
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }

                        Button {
                            Haptics.tap()
                            appModel.toggleFavorite(card)
                        } label: {
                            Label(card.isFavorite ? "Remove Bookmark" : "Bookmark Word",
                                  systemImage: card.isFavorite ? "bookmark.fill" : "bookmark")
                                .frame(maxWidth: .infinity)
                        }
                        .softButton()
                        .padding(.horizontal)
                        .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Today's Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
