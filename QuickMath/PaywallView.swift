import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    private let benefits: [(icon: String, text: String)] = [
        ("books.vertical", "Full searchable archive of every past word"),
        ("flame.fill", "Streak tracking with milestone badges"),
        ("bell.fill", "Daily reminder notification at a chosen time")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                ScrollView {
                    VStack(spacing: 32) {
                        // Icon
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.qmCard)
                                    .frame(width: 96, height: 96)
                                Image(systemName: "books.vertical.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.qmAccent)
                            }
                            Text("Lexicon Pro")
                                .font(.largeTitle.weight(.bold))
                            Text("\(store.displayPrice) / month. Auto-renews until you cancel.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        // Benefits
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(benefits, id: \.text) { benefit in
                                HStack(spacing: 14) {
                                    Image(systemName: benefit.icon)
                                        .foregroundStyle(Color.qmAccent)
                                        .frame(width: 28)
                                    Text(benefit.text)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                        .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal)

                        // Buttons
                        VStack(spacing: 12) {
                            Button {
                                Task { await store.purchase() }
                            } label: {
                                if store.purchaseInFlight {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 3)
                                } else {
                                    Text("Start Lexicon Pro")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .prominentButton()
                            .disabled(store.purchaseInFlight)

                            Button {
                                Task { await store.restore() }
                            } label: {
                                Text("Restore Purchase")
                                    .frame(maxWidth: .infinity)
                            }
                            .softButton()
                        }
                        .padding(.horizontal)

                        // Manage subscription
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            Link("Manage Subscription", destination: url)
                                .font(.footnote)
                                .foregroundStyle(Color.qmAccent)
                        }

                        // Legal disclosure
                        VStack(spacing: 8) {
                            Text("Lexicon Pro is \(store.displayPrice)/month. Payment charged to your Apple ID at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Manage or cancel at any time in your Apple ID account settings.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 16) {
                                if let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                    Link("Terms of Use", destination: termsURL)
                                        .font(.caption2)
                                        .foregroundStyle(Color.qmAccent)
                                }
                                if let privacyURL = URL(string: "https://shimondeitel.github.io/lexicon-site/privacy.html") {
                                    Link("Privacy Policy", destination: privacyURL)
                                        .font(.caption2)
                                        .foregroundStyle(Color.qmAccent)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: store.isPro) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }
}
