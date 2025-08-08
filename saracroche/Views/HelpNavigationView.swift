import SwiftUI

struct HelpNavigationView: View {
  @State private var showDonationSheet = false

  var body: some View {
    NavigationView {
      List {
        HelpFAQSection(showDonationSheet: $showDonationSheet)
        HelpSupportSection()
        Section(
          footer:
            Text("Bisou 😘")
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .center)
        ) { EmptyView() }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Aide")
      .sheet(isPresented: $showDonationSheet) {
        DonationSheet()
      }
    }
  }
}

#Preview {
  HelpNavigationView()
}
