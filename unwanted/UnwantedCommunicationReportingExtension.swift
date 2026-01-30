import Combine
import IdentityLookup
import IdentityLookupUI
import SwiftUI

class UnwantedCommunicationReportingExtension: ILClassificationUIExtensionViewController {
  private let viewModel = UnwantedReportViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var classificationRequest: ILClassificationRequest?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSwiftUIView()

    // Observe selectedAction to update isReadyForClassificationResponse
    viewModel.$selectedAction
      .sink { [weak self] action in
        self?.extensionContext.isReadyForClassificationResponse = action != nil
      }
      .store(in: &cancellables)
  }

  private func setupSwiftUIView() {
    let swiftUIView = UnwantedCommunicationReportingView(viewModel: viewModel)
    let hostingController = UIHostingController(rootView: swiftUIView)

    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  // Customize UI based on the classification request before the view is loaded
  override func prepare(for classificationRequest: ILClassificationRequest) {
    self.classificationRequest = classificationRequest

    switch classificationRequest {
    case let classificationRequest as ILMessageClassificationRequest:
      viewModel.phoneNumber = classificationRequest.messageCommunications.first?.sender ?? ""
    case let classificationRequest as ILCallClassificationRequest:
      viewModel.phoneNumber = classificationRequest.callCommunications.first?.sender ?? ""
    default:
      fatalError("Unknown classification request")
    }
  }

  // Provide a classification response for the classification request
  override func classificationResponse(for request: ILClassificationRequest)
    -> ILClassificationResponse
  {
    guard let action = viewModel.selectedAction else {
      return ILClassificationResponse(action: .none)
    }

    let response = ILClassificationResponse(action: action)
    let phoneNumber = extractPhoneNumber(from: request)

    // Get device ID
    let deviceId = getOrCreateDeviceID()

    // Determine if the number is good (legitimate) or spam
    let isGood: Bool
    switch action {
    case .reportNotJunk:
      isGood = true  // Legitimate number
    case .reportJunk, .reportJunkAndBlockSender:
      isGood = false // Spam number
    @unknown default:
      isGood = false // Default to spam for unknown actions
    }

    // Create userInfo with phone number, device ID, and is_good flag
    response.userInfo = [
      "phoneNumber": phoneNumber,
      "deviceId": deviceId,
      "is_good": isGood
    ]

    return response
  }

  // MARK: - Helper Methods

  private func getOrCreateDeviceID() -> String {
    // Key for storing device ID in UserDefaults
    let deviceIDKey = "extensionDeviceID"

    // Try to get UserDefaults
    let userDefaults = UserDefaults.standard

    // Check if we already have a device ID
    if let existingDeviceID = userDefaults.string(forKey: deviceIDKey) {
      return existingDeviceID
    }

    // Generate a new UUID for this extension
    let newDeviceID = UUID().uuidString

    // Store the device ID in UserDefaults
    userDefaults.set(newDeviceID, forKey: deviceIDKey)
    userDefaults.synchronize()

    return newDeviceID
  }

  // MARK: - Helper Methods

  private func extractPhoneNumber(from request: ILClassificationRequest) -> String {
    switch request {
    case let request as ILMessageClassificationRequest:
      return request.messageCommunications.first?.sender ?? ""
    case let request as ILCallClassificationRequest:
      return request.callCommunications.first?.sender ?? ""
    default:
      return ""
    }
  }
}
