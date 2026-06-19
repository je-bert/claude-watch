import SwiftUI

/// Lets you pick a folder on the Mac and start a fresh Claude session there.
struct FolderPickerView: View {
    @EnvironmentObject private var state: WatchViewState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("New Claude in…") {
                if state.folders.isEmpty {
                    Text("Loading folders…")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                ForEach(state.folders) { folder in
                    Button {
                        state.spawnSession(cwd: folder.path)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(folder.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text(folder.path)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                                .lineLimit(1)
                                .truncationMode(.head)
                        }
                    }
                }
            }
        }
        .onAppear { state.loadFolders() }
    }
}
