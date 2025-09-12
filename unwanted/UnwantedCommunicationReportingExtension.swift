import IdentityLookup
import IdentityLookupUI
import SwiftUI

class UnwantedCommunicationReportingExtension: ILClassificationUIExtensionViewController {
  private let viewModel = UnwantedReportViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSwiftUIView()
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Notify the system when you have completed gathering information
    // from the user and you are ready with a classification response
    self.extensionContext.isReadyForClassificationResponse = true
  }

  // Customize UI based on the classification request before the view is loaded
  override func prepare(for classificationRequest: ILClassificationRequest) {
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
    return ILClassificationResponse(action: .none)
  }
}
