import Foundation
import IdentityLookup
import SwiftUI
import Combine

class UnwantedReportViewModel: ObservableObject {
  @Published var phoneNumber: String = ""
  @Published var selectedAction: ILClassificationAction?

  func selectAction(_ action: ILClassificationAction) {
    selectedAction = action
  }
}

struct UnwantedCommunicationReportingView: View {
  @ObservedObject var viewModel: UnwantedReportViewModel

  init(viewModel: UnwantedReportViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        VStack(alignment: .center, spacing: 24) {
          if #available(iOS 18.0, *) {
            Image(systemName: "megaphone.fill")
              .font(.system(size: 60))
              .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 0.8)))
              .foregroundColor(.orange)
          } else {
            Image(systemName: "megaphone.fill")
              .font(.system(size: 60))
              .foregroundColor(.orange)
          }

          VStack(alignment: .center, spacing: 12) {
            Text("Signaler un numéro")
              .font(.title2)
              .fontWeight(.bold)

            Text(viewModel.phoneNumber)
              .font(.title3)
              .fontWeight(.semibold)
              .foregroundColor(.orange)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text("Comment voulez-vous signaler ce numéro ?")
              .font(.subheadline)
              .fontWeight(.semibold)
              .padding(.bottom, 4)

            VStack(spacing: 12) {
              ActionButton(
                title: "C'est du spam",
                description: "Signaler comme indésirable",
                icon: "exclamationmark.circle.fill",
                isSelected: viewModel.selectedAction == .reportJunk,
                color: .red,
                action: {
                  viewModel.selectAction(.reportJunk)
                }
              )

              ActionButton(
                title: "C'est du spam et bloquer",
                description: "Signaler et bloquer l'expéditeur",
                icon: "lock.circle.fill",
                isSelected: viewModel.selectedAction == .reportJunkAndBlockSender,
                color: .red,
                action: {
                  viewModel.selectAction(.reportJunkAndBlockSender)
                }
              )

              ActionButton(
                title: "Ce n'est pas du spam",
                description: "Marquer comme légitime",
                icon: "checkmark.circle.fill",
                isSelected: viewModel.selectedAction == .reportNotJunk,
                color: .green,
                action: {
                  viewModel.selectAction(.reportNotJunk)
                }
              )
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.orange.opacity(0.1))
          )
        }
        .padding()
        .frame(maxWidth: .infinity)
      }
    }
  }
}

struct ActionButton: View {
  let title: String
  let description: String
  let icon: String
  let isSelected: Bool
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 18))
          .foregroundColor(color)
          .frame(width: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
          Text(description)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 18))
            .foregroundColor(color)
        }
      }
      .padding(12)
      .background(isSelected ? color.opacity(0.15) : Color(.systemBackground))
      .cornerRadius(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isSelected ? color : Color.gray.opacity(0.2), lineWidth: 1.5)
      )
    }
  }
}
