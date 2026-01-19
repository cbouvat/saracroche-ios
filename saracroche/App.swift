import SwiftUI

@main
struct SaracrocheApp: App {
  @StateObject private var backgroundService = BackgroundService()
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      SaracrocheView()
    }
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .background {
        backgroundService.applicationDidEnterBackground()
      }
    }
  }
}
