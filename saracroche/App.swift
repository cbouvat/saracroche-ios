import SwiftUI

@main
struct SaracrocheApp: App {
  @StateObject private var backgroundService = BackgroundService()
  @Environment(\.scenePhase) private var scenePhase

  init() {
    let boldFontName = "AtkinsonHyperlegibleNextVFLight-Bold"
    let regularFontName = "AtkinsonHyperlegibleNextVFLight-Regular"

    // Navigation bar
    let navAppearance = UINavigationBarAppearance()
    navAppearance.configureWithDefaultBackground()
    if let boldFont = UIFont(name: boldFontName, size: 34) {
      navAppearance.largeTitleTextAttributes = [.font: boldFont, .foregroundColor: UIColor.label]
    }
    if let boldFont = UIFont(name: boldFontName, size: 17) {
      navAppearance.titleTextAttributes = [.font: boldFont, .foregroundColor: UIColor.label]
    }
    UINavigationBar.appearance().standardAppearance = navAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    UINavigationBar.appearance().tintColor = .label

    // Tab bar
    let tabAppearance = UITabBarItemAppearance()
    if let font = UIFont(name: regularFontName, size: 10) {
      tabAppearance.normal.titleTextAttributes = [.font: font]
      tabAppearance.selected.titleTextAttributes = [.font: font]
    }
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithDefaultBackground()
    tabBarAppearance.stackedLayoutAppearance = tabAppearance
    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
  }

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
