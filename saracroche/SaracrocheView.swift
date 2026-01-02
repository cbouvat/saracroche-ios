import SwiftUI

struct SaracrocheView: View {
  @StateObject private var blockerViewModel = BlockerViewModel()

  var body: some View {
    TabView {
      HomeNavigationView(blockerViewModel: blockerViewModel)
        .tabItem {
          Label("Accueil", systemImage: "house.fill")
        }
      ReportNavigationView()
        .tabItem {
          Label("Signaler", systemImage: "exclamationmark.bubble.fill")
        }
      SettingsNavigationView(blockerViewModel: blockerViewModel)
        .tabItem {
          Label("Réglages", systemImage: "gearshape.fill")
        }
    }
  }
}

#Preview {
  SaracrocheView()
}
