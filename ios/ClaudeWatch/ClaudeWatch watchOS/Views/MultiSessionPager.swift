import SwiftUI

struct MultiSessionPager: View {
    @EnvironmentObject private var state: WatchViewState

    var body: some View {
        Group {
            if state.sessions.isEmpty {
                waitingView
            } else {
                TabView(selection: $state.activeSessionIndex) {
                    ForEach(Array(state.sessions.enumerated()), id: \.element.id) { index, _ in
                        SessionView(sessionIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
            }
        }
        .sheet(isPresented: $state.showFolderPicker) {
            FolderPickerView()
        }
    }

    private var waitingView: some View {
        VStack(spacing: 8) {
            AppLogo(size: 56)
                .opacity(0.6)
            Text("Waiting for session...")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
            Text("Start Claude or Codex on your Mac")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)

            // …or spawn one right here, from the watch — pick the folder first.
            Button {
                state.showFolderPicker = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                    Text("New Claude")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.9)))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview("Waiting") {
    MultiSessionPager()
        .environmentObject(WatchViewState.shared)
}
