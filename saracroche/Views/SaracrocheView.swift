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
          Label("Signaler", systemImage: "megaphone.fill")
        }
      NumbersNavigationView()
        .tabItem {
          Label("Numéros", systemImage: "number.square.fill")
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
