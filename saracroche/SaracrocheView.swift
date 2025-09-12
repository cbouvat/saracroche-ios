import SwiftUI

struct SaracrocheView: View {
  @StateObject private var viewModel = BlockerViewModel()

  var body: some View {
    TabView {
      HomeNavigationView(viewModel: viewModel)
        .tabItem {
          Label("Accueil", systemImage: "house.fill")
        }
      ReportNavigationView()
        .tabItem {
          Label("Signaler", systemImage: "exclamationmark.bubble.fill")
        }
      SettingsNavigationView(viewModel: viewModel)
        .tabItem {
          Label("Réglages", systemImage: "gearshape.fill")
        }
    }
  }
}

#Preview {
  SaracrocheView()
}
