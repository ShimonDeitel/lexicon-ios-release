import SwiftUI
import SwiftData

/// The primary entry/action screen — shows today's word with etymology deep-dive and learn action.
struct GridView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                if let word = appModel.todayWord {
                    WordStudyView(card: word)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Word of the Day")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 56))
                .foregroundStyle(Color.qmAccent)
            Text("Come back tomorrow")
                .font(.title3.weight(.semibold))
            Text("A fresh word unlocks every day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - WordStudyView

struct WordStudyView: View {
    let card: WordCard
    @EnvironmentObject var appModel: AppModel

    @State private var revealedSections: Set<String> = []
    @State private var learned = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Big headword
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.headword)
                        .font(.system(size: 42, weight: .bold, design: .serif))
                    HStack(spacing: 8) {
                        Text(card.partOfSpeech)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.qmAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.qmAccent.opacity(0.12), in: Capsule())
                        if card.wasReviewed || learned {
                            Label("Learned", systemImage: "checkmark.circle.fill")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.qmCorrect)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Definition card
                studySection(
                    id: "def",
                    icon: "doc.text",
                    title: "Definition",
                    content: card.definition,
                    autoReveal: true
                )

                // Etymology card
                studySection(
                    id: "ety",
                    icon: "clock.arrow.circlepath",
                    title: "Etymology",
                    content: card.etymology,
                    autoReveal: false
                )

                // Example sentence card
                studySection(
                    id: "ex",
                    icon: "quote.opening",
                    title: "Use it in a sentence",
                    content: "\"" + card.exampleSentence + "\"",
                    autoReveal: false
                )

                // Actions
                VStack(spacing: 12) {
                    if !card.wasReviewed && !learned {
                        Button {
                            Haptics.success()
                            learned = true
                            appModel.markReviewed(card)
                        } label: {
                            Text("I've got it — Mark Learned")
                                .frame(maxWidth: .infinity)
                        }
                        .prominentButton()
                    }

                    Button {
                        Haptics.tap()
                        appModel.toggleFavorite(card)
                    } label: {
                        Label(
                            card.isFavorite ? "Bookmarked" : "Bookmark",
                            systemImage: card.isFavorite ? "bookmark.fill" : "bookmark"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .softButton()
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            revealedSections.insert("def")
        }
    }

    @ViewBuilder
    private func studySection(id: String, icon: String, title: String, content: String, autoReveal: Bool) -> some View {
        let isRevealed = revealedSections.contains(id)
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Haptics.tap()
                if isRevealed {
                    revealedSections.remove(id)
                } else {
                    revealedSections.insert(id)
                }
            } label: {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isRevealed ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isRevealed {
                Text(content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .qmCard()
        .padding(.horizontal)
        .animation(.spring(duration: 0.3), value: isRevealed)
    }
}
