import iTunesSearchAPI
import SwiftUI

// MARK: - UpdateAvailableButton

public struct UpdateAvailableButton: View {
    // MARK: Lifecycle

    public init(
        bundleID: String = Bundle.main.bundleIdentifier ?? "",
        localVersion: String? = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
    ) {
        self.bundleID = bundleID
        self.localVersion = localVersion
    }

    // MARK: Public

    public var body: some View {
        ZStack {
            if updateAvailable, let appID {
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

    private let bundleID: String
    private let localVersion: String?

    @State private var appID: Int?
    @State private var updateAvailable = false

    private func checkForUpdates() async {
        guard let localVersion,
              let result = try? await iTunesSearchAPI.lookup(
                  bundleIdentifier: bundleID
              ).results.first,
              let remoteVersion = result.version else { return }
        appID = result.trackId
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
    UpdateAvailableButton(bundleID: "com.finnvoorhees.HextEdit", localVersion: "1.0.0")
}
