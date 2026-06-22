import SwiftUI
import SwiftData

// MARK: - SwiftData models

@Model
final class WordCard {
    @Attribute(.unique) var id: UUID
    var headword: String
    var definition: String
    var partOfSpeech: String
    var etymology: String
    var exampleSentence: String
    var dateUnlocked: Date
    var isFavorite: Bool
    var wasReviewed: Bool

    init(
        id: UUID = UUID(),
        headword: String,
        definition: String,
        partOfSpeech: String,
        etymology: String,
        exampleSentence: String,
        dateUnlocked: Date = Date(),
        isFavorite: Bool = false,
        wasReviewed: Bool = false
    ) {
        self.id = id
        self.headword = headword
        self.definition = definition
        self.partOfSpeech = partOfSpeech
        self.etymology = etymology
        self.exampleSentence = exampleSentence
        self.dateUnlocked = dateUnlocked
        self.isFavorite = isFavorite
        self.wasReviewed = wasReviewed
    }
}

@Model
final class StreakState {
    var currentStreak: Int
    var longestStreak: Int
    var lastOpenedDate: Date?

    init(currentStreak: Int = 0, longestStreak: Int = 0, lastOpenedDate: Date? = nil) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastOpenedDate = lastOpenedDate
    }
}

// MARK: - Built-in word list

struct WordEntry {
    let headword: String
    let definition: String
    let partOfSpeech: String
    let etymology: String
    let exampleSentence: String
}

let builtInWords: [WordEntry] = [
    WordEntry(headword: "Sonder", definition: "The realization that each passerby has a life as vivid and complex as your own.", partOfSpeech: "noun", etymology: "Coined by John Koenig in The Dictionary of Obscure Sorrows (2012); inspired by French 'sonder' (to probe).", exampleSentence: "A wave of sonder washed over her as she watched the crowd pour out of the subway."),
    WordEntry(headword: "Hiraeth", definition: "A homesickness for a home you can't return to, or perhaps never had.", partOfSpeech: "noun", etymology: "Welsh; combines 'hir' (long) and 'aeth' (going), evoking a longing that stretches through time.", exampleSentence: "Late autumn always filled him with hiraeth for a childhood summer he couldn't quite place."),
    WordEntry(headword: "Petrichor", definition: "The pleasant smell that accompanies the first rain after a long period of dry weather.", partOfSpeech: "noun", etymology: "Greek 'petra' (stone) + 'ichor' (the fluid said to flow through the veins of the gods); coined 1964.", exampleSentence: "She opened the window and breathed in the petrichor that rose from the warm pavement."),
    WordEntry(headword: "Vellichor", definition: "The strange wistfulness of used bookstores, filled with thousands of lives never fully lived.", partOfSpeech: "noun", etymology: "Coined by John Koenig; 'vellum' (parchment) + '-ichor' (ethereal fluid), 2013.", exampleSentence: "He lingered for an hour in vellichor, pulling novels from shelves he would never buy."),
    WordEntry(headword: "Limerence", definition: "An involuntary, intense romantic infatuation accompanied by longing for reciprocation.", partOfSpeech: "noun", etymology: "Coined by psychologist Dorothy Tennov in 1977 from a coined root; no prior etymology.", exampleSentence: "What he'd mistaken for love turned out to be pure limerence, dissolving once she finally texted back."),
    WordEntry(headword: "Sempiternal", definition: "Eternal and unchanging; everlasting.", partOfSpeech: "adjective", etymology: "Latin 'sempiternus': 'semper' (always) + 'aeternus' (eternal).", exampleSentence: "The mountains felt sempiternal against the brief drama of human lives below."),
    WordEntry(headword: "Apricity", definition: "The warmth of the sun in winter.", partOfSpeech: "noun", etymology: "Latin 'apricus' (warmed by the sun); appeared in Henry Cockeram's dictionary, 1623.", exampleSentence: "She sat on the bench in January, letting the apricity soak into her coat."),
    WordEntry(headword: "Psithurism", definition: "The sound of wind through trees or rustling leaves.", partOfSpeech: "noun", etymology: "Greek 'psithurismos' (whispering), from 'psithyrizein' (to whisper).", exampleSentence: "Only the psithurism of the pines broke the silence of the forest trail."),
    WordEntry(headword: "Meraki", definition: "To do something with soul, creativity, and love — leaving a piece of yourself in the work.", partOfSpeech: "noun", etymology: "Modern Greek; possibly from Turkish 'merak' (curiosity, passion).", exampleSentence: "Every dish she cooked had meraki — you could taste the care in each bite."),
    WordEntry(headword: "Kairos", definition: "The right, critical, or opportune moment; the perfect time for action.", partOfSpeech: "noun", etymology: "Ancient Greek 'kairos' (the appointed time), contrasted with 'chronos' (linear time).", exampleSentence: "He waited for his kairos, and when it came, he didn't hesitate."),
    WordEntry(headword: "Iridescent", definition: "Showing luminous colors that seem to change when seen from different angles.", partOfSpeech: "adjective", etymology: "Latin 'iris' (rainbow, from Greek 'Iris', goddess of the rainbow) + '-escent' (becoming).", exampleSentence: "The oil slick on the puddle spread into an iridescent bloom of violet and gold."),
    WordEntry(headword: "Ephemeral", definition: "Lasting for a very short time; transitory.", partOfSpeech: "adjective", etymology: "Greek 'ephemeros': 'epi' (on) + 'hemera' (day) — lasting but a day.", exampleSentence: "Cherry blossoms are ephemeral; that fleeting quality is exactly why we chase them."),
    WordEntry(headword: "Halcyon", definition: "Denoting a period of time in the past that was idyllically happy and peaceful.", partOfSpeech: "adjective", etymology: "Greek 'alkyon' (kingfisher), a bird fabled to calm the sea during the winter solstice.", exampleSentence: "She kept a photograph from those halcyon summers before everything changed."),
    WordEntry(headword: "Lambent", definition: "Softly bright or radiant; lightly brilliant; flickering gently.", partOfSpeech: "adjective", etymology: "Latin 'lambere' (to lick), suggesting flame that licks without burning.", exampleSentence: "Lambent candlelight played across the walls of the old dining room."),
    WordEntry(headword: "Effluvium", definition: "An unpleasant or harmful odor, secretion, or discharge.", partOfSpeech: "noun", etymology: "Latin 'effluvium': 'ex' (out) + 'fluere' (to flow).", exampleSentence: "The cellar greeted them with an effluvium of damp wood and decades of storage."),
    WordEntry(headword: "Palimpsest", definition: "Something altered but still bearing visible traces of an earlier form.", partOfSpeech: "noun", etymology: "Greek 'palimpsestos': 'palin' (again) + 'psestos' (scraped) — a reused writing surface.", exampleSentence: "The city was a palimpsest, each era's architecture layered beneath the next."),
    WordEntry(headword: "Scintilla", definition: "A tiny trace or spark of a specified quality or feeling.", partOfSpeech: "noun", etymology: "Latin 'scintilla' (spark); the same root gives us 'scintillate'.", exampleSentence: "There was not a scintilla of evidence to support the claim."),
    WordEntry(headword: "Liminal", definition: "Relating to a transitional or initial stage; occupying a threshold position.", partOfSpeech: "adjective", etymology: "Latin 'limen' (threshold, lintel); first used in psychology by Arnold van Gennep, 1909.", exampleSentence: "An airport is the most liminal of spaces — no one is quite themselves there."),
    WordEntry(headword: "Numinous", definition: "Having a strong religious or spiritual quality; indicating or suggesting the presence of a divinity.", partOfSpeech: "adjective", etymology: "Latin 'numen' (divine power, nod of assent); popularized by Rudolf Otto in 1917.", exampleSentence: "The clearing in the old forest had a numinous quality that made them speak in whispers."),
    WordEntry(headword: "Solipsism", definition: "The theory that only one's own mind is sure to exist; extreme self-centeredness.", partOfSpeech: "noun", etymology: "Latin 'solus' (alone) + 'ipse' (self); coined in philosophy in the 19th century.", exampleSentence: "His refusal to consider anyone else's perspective had curdled into full solipsism."),
    WordEntry(headword: "Sanguine", definition: "Optimistic, especially in a difficult situation; blood-red in color.", partOfSpeech: "adjective", etymology: "Latin 'sanguis' (blood); the humoral theory held that a blood-dominant temperament was cheerful.", exampleSentence: "She remained sanguine about the outcome despite the odds stacked against her."),
    WordEntry(headword: "Mellifluous", definition: "Sweet or musical; pleasant to hear.", partOfSpeech: "adjective", etymology: "Latin 'mel' (honey) + 'fluere' (to flow) — literally 'flowing with honey'.", exampleSentence: "His mellifluous voice could make a grocery list sound like a lullaby."),
    WordEntry(headword: "Obfuscate", definition: "To render obscure, unclear, or unintelligible; to confuse.", partOfSpeech: "verb", etymology: "Latin 'obfuscare': 'ob' (over) + 'fuscare' (to darken), from 'fuscus' (dark).", exampleSentence: "The dense legal language seemed designed to obfuscate rather than clarify."),
    WordEntry(headword: "Quixotic", definition: "Exceedingly idealistic; unrealistic and impractical.", partOfSpeech: "adjective", etymology: "From Don Quixote, the 1605 novel by Cervantes, whose hero tilted at windmills.", exampleSentence: "Her quixotic plan to row across the Atlantic alone charmed even those who doubted her."),
    WordEntry(headword: "Lacuna", definition: "A missing portion in a book or manuscript; a gap or missing part.", partOfSpeech: "noun", etymology: "Latin 'lacuna' (pit, pool), from 'lacus' (lake); hence English 'lagoon'.", exampleSentence: "Historians have long argued over the lacuna in the middle of the ancient text."),
    WordEntry(headword: "Verisimilitude", definition: "The appearance of being true or real; believability.", partOfSpeech: "noun", etymology: "Latin 'verisimilis': 'verus' (true) + 'similis' (like).", exampleSentence: "The film's meticulous period detail lent it a verisimilitude that drew audiences in."),
    WordEntry(headword: "Perspicacious", definition: "Having a ready insight into things; shrewd.", partOfSpeech: "adjective", etymology: "Latin 'perspicax' (sharp-sighted), from 'perspicere' (to see through).", exampleSentence: "A perspicacious reader will notice the clue hidden in the first chapter."),
    WordEntry(headword: "Concatenate", definition: "To link things together in a chain or series.", partOfSpeech: "verb", etymology: "Latin 'concatenare': 'con' (together) + 'catena' (chain).", exampleSentence: "The composer concatenated fragments of folk melodies into a seamless whole."),
    WordEntry(headword: "Susurrus", definition: "A whispering or murmuring sound.", partOfSpeech: "noun", etymology: "Latin 'susurrus' (humming, murmuring); an onomatopoeic word.", exampleSentence: "A susurrus of conversation filled the gallery as guests examined each painting."),
    WordEntry(headword: "Tenebrous", definition: "Dark, shadowy, or obscure.", partOfSpeech: "adjective", etymology: "Latin 'tenebrosus', from 'tenebrae' (darkness); cognate with 'tenebrae', the Good Friday service.", exampleSentence: "They descended into the tenebrous passageway, torches held high.")
]

// MARK: - AppModel

@MainActor
final class AppModel: ObservableObject {
    let container: ModelContainer
    weak var store: Store?

    @Published private(set) var todayWord: WordCard?
    @Published private(set) var allWords: [WordCard] = []
    @Published private(set) var streak: StreakState = StreakState()

    init(container: ModelContainer) {
        self.container = container
        reload()
    }

    static func makeContainer() -> ModelContainer {
        let schema = Schema([WordCard.self, StreakState.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
    }

    func reload() {
        let ctx = container.mainContext
        // Seed streak if needed
        let streakFetch = FetchDescriptor<StreakState>()
        if let existing = try? ctx.fetch(streakFetch), existing.isEmpty {
            let s = StreakState()
            ctx.insert(s)
            try? ctx.save()
        }
        if let s = (try? ctx.fetch(FetchDescriptor<StreakState>()))?.first {
            self.streak = s
        }
        // Seed words
        seedWordsIfNeeded(ctx: ctx)
        // Load all words
        let wordFetch = FetchDescriptor<WordCard>(sortBy: [SortDescriptor(\.dateUnlocked, order: .reverse)])
        self.allWords = (try? ctx.fetch(wordFetch)) ?? []
        // Today's word
        self.todayWord = allWords.first { Calendar.current.isDateInToday($0.dateUnlocked) }
        // Update streak
        updateStreak(ctx: ctx)
    }

    func refresh() { reload() }

    func markReviewed(_ card: WordCard) {
        card.wasReviewed = true
        try? container.mainContext.save()
        reload()
    }

    func toggleFavorite(_ card: WordCard) {
        card.isFavorite.toggle()
        try? container.mainContext.save()
        reload()
    }

    func deleteAllData() {
        let ctx = container.mainContext
        try? ctx.delete(model: WordCard.self)
        try? ctx.delete(model: StreakState.self)
        try? ctx.save()
        reload()
    }

    // MARK: - Private helpers

    private func seedWordsIfNeeded(ctx: ModelContext) {
        // Determine how many days we have words for already
        let wordFetch = FetchDescriptor<WordCard>(sortBy: [SortDescriptor(\.dateUnlocked)])
        let existing = (try? ctx.fetch(wordFetch)) ?? []
        // Seed from day -30 up to today so the archive has content on first launch
        let today = Calendar.current.startOfDay(for: Date())
        var seededCount = existing.count
        guard seededCount < builtInWords.count else { return }
        // Plant up to today + 0 days (no future unlocks in free tier)
        let startOffset = -(min(builtInWords.count - 1, 29))
        for offset in startOffset...0 {
            let dayDate = Calendar.current.date(byAdding: .day, value: offset, to: today) ?? today
            let alreadyHas = existing.contains { Calendar.current.isDate($0.dateUnlocked, inSameDayAs: dayDate) }
            if !alreadyHas, seededCount < builtInWords.count {
                let entry = builtInWords[seededCount % builtInWords.count]
                let card = WordCard(
                    headword: entry.headword,
                    definition: entry.definition,
                    partOfSpeech: entry.partOfSpeech,
                    etymology: entry.etymology,
                    exampleSentence: entry.exampleSentence,
                    dateUnlocked: dayDate
                )
                ctx.insert(card)
                seededCount += 1
            }
        }
        try? ctx.save()
    }

    private func updateStreak(ctx: ModelContext) {
        let streakFetch = FetchDescriptor<StreakState>()
        guard let s = (try? ctx.fetch(streakFetch))?.first else { return }
        let today = Calendar.current.startOfDay(for: Date())
        if let last = s.lastOpenedDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today {
                // already counted today
            } else if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                      lastDay == yesterday {
                s.currentStreak += 1
                s.longestStreak = max(s.longestStreak, s.currentStreak)
                s.lastOpenedDate = Date()
            } else {
                // streak broken
                s.currentStreak = 1
                s.lastOpenedDate = Date()
            }
        } else {
            s.currentStreak = 1
            s.longestStreak = max(s.longestStreak, 1)
            s.lastOpenedDate = Date()
        }
        try? ctx.save()
        self.streak = s
    }
}
