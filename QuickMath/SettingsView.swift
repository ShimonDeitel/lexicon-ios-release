import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("quickmath.theme") private var themeRaw = AppTheme.system.rawValue
    @AppStorage("lexicon.reminder.hour") private var reminderHour = 9
    @AppStorage("lexicon.reminder.minute") private var reminderMinute = 0
    @AppStorage("lexicon.reminder.enabled") private var reminderEnabled = false

    @State private var showPaywall = false
    @State private var showDeleteConfirm = false
    @State private var reminderTime = Date()

    private var theme: AppTheme {
        AppTheme(rawValue: themeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                List {
                    // Pro section
                    Section("Lexicon Pro") {
                        if store.isPro {
                            Label("Pro Active", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Color.qmAccent)

                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                Link(destination: url) {
                                    Label("Manage Subscription", systemImage: "arrow.up.right.square")
                                }
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                Label("Unlock Lexicon Pro", systemImage: "lock.open.fill")
                                    .foregroundStyle(Color.qmAccent)
                            }

                            Button {
                                Task { await store.restore() }
                            } label: {
                                Label("Restore Purchase", systemImage: "arrow.counterclockwise")
                            }
                        }
                    }
                    .listRowBackground(Color.qmCard)

                    // Appearance
                    Section("Appearance") {
                        Picker("Theme", selection: $themeRaw) {
                            ForEach(AppTheme.allCases) { t in
                                Text(t.label).tag(t.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color.qmCard)

                    // Reminders (Pro only)
                    Section("Daily Reminder") {
                        if store.isPro {
                            Toggle("Enable Reminder", isOn: $reminderEnabled)
                                .tint(Color.qmAccent)
                                .onChange(of: reminderEnabled) { _, enabled in
                                    if enabled {
                                        Task {
                                            let granted = await Reminders.requestAuthorization()
                                            if granted {
                                                Reminders.schedule(hour: reminderHour, minute: reminderMinute)
                                            } else {
                                                reminderEnabled = false
                                            }
                                        }
                                    } else {
                                        Reminders.cancel()
                                    }
                                }

                            if reminderEnabled {
                                DatePicker(
                                    "Time",
                                    selection: $reminderTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .onChange(of: reminderTime) { _, time in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                                    reminderHour = components.hour ?? 9
                                    reminderMinute = components.minute ?? 0
                                    Reminders.schedule(hour: reminderHour, minute: reminderMinute)
                                }
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                Label("Pro feature — unlock to set reminders", systemImage: "lock.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(Color.qmCard)

                    // Legal
                    Section("About") {
                        if let privacyURL = URL(string: "https://shimondeitel.github.io/lexicon-site/privacy.html") {
                            Link(destination: privacyURL) {
                                Label("Privacy Policy", systemImage: "hand.raised")
                            }
                        }
                        if let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            Link(destination: termsURL) {
                                Label("Terms of Use", systemImage: "doc.text")
                            }
                        }
                    }
                    .listRowBackground(Color.qmCard)

                    // Danger zone
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete All Data", systemImage: "trash")
                        }
                    }
                    .listRowBackground(Color.qmCard)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Delete all data?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    appModel.deleteAllData()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all your words, streak, and favorites. This cannot be undone.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(store)
            }
        }
        .onAppear {
            var comps = DateComponents()
            comps.hour = reminderHour
            comps.minute = reminderMinute
            reminderTime = Calendar.current.date(from: comps) ?? Date()
        }
    }
}
