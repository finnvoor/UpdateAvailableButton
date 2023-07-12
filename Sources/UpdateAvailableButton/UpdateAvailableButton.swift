import iTunesSearchAPI
import SwiftUI

// MARK: - UpdateAvailableButton

public struct UpdateAvailableButton: View {
    // MARK: Lifecycle

    public init(
        appID: Int,
        localVersion: String? = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
    ) {
        self.appID = appID
        self.localVersion = localVersion
    }

    // MARK: Public

    public var body: some View {
        ZStack {
            if updateAvailable {
                Link(destination: URL(string: "https://apps.apple.com/app/id\(appID)")!) {
                    Label("Update Available", systemImage: "sparkles")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
        }
        .task { await checkForUpdates() }
    }

    // MARK: Private

    private let appID: Int
    private let localVersion: String?

    @State private var updateAvailable = false

    private func checkForUpdates() async {
        guard let localVersion,
              let result = try? await iTunesSearchAPI.lookup(
                  iTunesID: appID
              ).results.first,
              let remoteVersion = result.version else { return }

        var localVersionComponents = localVersion.components(separatedBy: ".")
        var remoteVersionComponents = remoteVersion.components(separatedBy: ".")
        let zeroDiff = localVersionComponents.count - remoteVersionComponents.count
        if zeroDiff == 0 {
            withAnimation {
                updateAvailable = localVersion
                    .compare(remoteVersion, options: .numeric) == .orderedAscending
            }
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff))
            if zeroDiff > 0 {
                remoteVersionComponents.append(contentsOf: zeros)
            } else {
                localVersionComponents.append(contentsOf: zeros)
            }
            withAnimation {
                updateAvailable = localVersionComponents.joined(separator: ".")
                    .compare(remoteVersionComponents.joined(separator: "."), options: .numeric) == .orderedAscending
            }
        }
    }
}

#Preview {
    UpdateAvailableButton(appID: 1673518618, localVersion: "1.0.0")
}
