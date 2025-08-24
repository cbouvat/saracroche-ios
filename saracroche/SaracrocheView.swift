import SwiftUI

struct SaracrocheView: View {
  @StateObject private var viewModel = BlockerViewModel()
  @Environment(\.scenePhase) private var scenePhase
  @State private var lastScenePhase: ScenePhase = .active

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
    .sheet(isPresented: $viewModel.showUpdateListSheet) {
      UpdateListSheet(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }
    .sheet(isPresented: $viewModel.showDeleteBlockerSheet) {
      DeleteBlockerSheet(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }
    .sheet(isPresented: $viewModel.showUpdateListFinishedSheet) {
      UpdateListFinishedSheet(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }
    .sheet(isPresented: $viewModel.showDeleteFinishedSheet) {
      DeleteFinishedSheet(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }
    .sheet(isPresented: $viewModel.showActionErrorSheet) {
      ActionErrorSheet(viewModel: viewModel)
        .interactiveDismissDisabled(true)
    }
    .onAppear {
      viewModel.checkBlockerExtensionStatus()
    }
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active && (lastScenePhase == .inactive || lastScenePhase == .background) {
        viewModel.checkBlockerExtensionStatus()
      }
      lastScenePhase = newPhase
    }
  }
}

#Preview {
  SaracrocheView()
}
