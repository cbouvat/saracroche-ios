import IdentityLookup
import IdentityLookupUI
import SwiftUI

class UnwantedCommunicationReportingExtension: ILClassificationUIExtensionViewController {
  private let viewModel = UnwantedReportViewModel()
  private var userDidReport = false
  private var selectedAction: ILClassificationAction = .reportJunk
  private var classificationRequest: ILClassificationRequest?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSwiftUIView()

    // Track action selection from view model
    viewModel.onActionSelected = { [weak self] action in
      self?.selectedAction = action
      // Mark as reported when user selects action
      self?.userDidReport = true
    }
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

    // Mark as ready for classification response
    // User will select action from the UI
    self.extensionContext.isReadyForClassificationResponse = true
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
    guard userDidReport else {
      return ILClassificationResponse(action: .none)
    }

    // Create response with selected action
    let response = ILClassificationResponse(action: selectedAction)

    // Build userInfo dictionary with metadata
    var userInfo: [String: Any] = [:]

    // Extract communication type and data from request
    let communicationType = extractCommunicationType(from: request)
    let phoneNumber = extractPhoneNumber(from: request)
    let dateReceived = extractDateReceived(from: request)
    let messageBody = extractMessageBody(from: request)
    let appVersion = Bundle.main.appVersionString

    // Populate userInfo with enriched metadata
    userInfo["phoneNumber"] = phoneNumber
    userInfo["communicationType"] = communicationType
    if let dateReceived = dateReceived {
      userInfo["dateReceived"] = dateReceived.iso8601String
    }
    if !messageBody.isEmpty {
      userInfo["messageBody"] = messageBody
    }
    userInfo["reportedAt"] = Date().iso8601String
    userInfo["appVersion"] = appVersion

    response.userInfo = userInfo
    
    // Log a summary of the response for debugging
    let redactedPhone = (response.userInfo?["phoneNumber"]) != nil ? "(redacted)" : "(none)"
    let hasMessageBody = (response.userInfo?["messageBody"]) != nil
    NSLog("ILClassificationResponse action=%@ phone=%@ hasMessageBody=%@ userInfoKeys=%@", String(describing: response.action), redactedPhone, hasMessageBody ? "true" : "false", String(describing: response.userInfo?.keys.sorted()))

    // Return response with enhanced metadata
    // iOS will POST the phone number and userInfo to ILClassificationExtensionNetworkReportDestination
    return response
  }

  // MARK: - Helper Methods

  private func extractCommunicationType(from request: ILClassificationRequest) -> String {
    if request is ILMessageClassificationRequest {
      return "message"
    } else if request is ILCallClassificationRequest {
      return "call"
    } else {
      return "unknown"
    }
  }

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

  private func extractDateReceived(from request: ILClassificationRequest) -> Date? {
    switch request {
    case let request as ILMessageClassificationRequest:
      return request.messageCommunications.first?.dateReceived
    case let request as ILCallClassificationRequest:
      return request.callCommunications.first?.dateReceived
    default:
      return nil
    }
  }

  private func extractMessageBody(from request: ILClassificationRequest) -> String {
    guard let request = request as? ILMessageClassificationRequest else {
      return ""
    }
    return request.messageCommunications.first?.messageBody ?? ""
  }
}

// MARK: - Bundle Extension

extension Bundle {
  /// Returns the app version string from Info.plist (e.g., "1.0.0")
  var appVersionString: String {
    (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
  }
}

// MARK: - Date Extension

extension Date {
  /// Returns the date in ISO8601 format
  var iso8601String: String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: self)
  }
}

