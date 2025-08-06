import SwiftUI

struct SaracrocheView: View {
  @StateObject private var viewModel = BlockerViewModel()
  @State private var showDeleteConfirmation = false

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
      HelpNavigationView()
        .tabItem {
          Label("Aide", systemImage: "questionmark.circle.fill")
        }
      SettingsNavigationView(
        viewModel: viewModel,
        showDeleteConfirmation: $showDeleteConfirmation
      )
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
  }
}

#Preview {
  SaracrocheView()
}
