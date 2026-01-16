import SwiftUI

struct APIPatternListView: View {
  let patterns: [Pattern]
  @State private var searchText = ""

  var filteredPatterns: [Pattern] {
    if searchText.isEmpty {
      return patterns
    }
    return patterns.filter { pattern in
      pattern.pattern?.contains(searchText) ?? false
        || pattern.name?.lowercased().contains(searchText.lowercased()) ?? false
    }
  }

  var body: some View {
    List(filteredPatterns) { pattern in
      PatternRow(pattern: pattern)
    }
    .searchable(text: $searchText, prompt: "Rechercher un préfixe ou un numéro")
    .navigationTitle("Préfixes de la liste")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationView {
    APIPatternListView(patterns: [])
  }
}
