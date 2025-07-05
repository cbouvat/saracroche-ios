import Foundation
import UIKit

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    case timeout
    case unknown
    
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "URL invalide."
        case .noData:
            return "Aucune donnée reçue du serveur."
        case .decodingError:
            return "Erreur lors du traitement des données."
        case .serverError(let code):
            return "Erreur serveur (\(code)). Veuillez réessayer plus tard."
        case .networkUnavailable:
            return "Connexion réseau indisponible. Vérifiez votre connexion Internet."
        case .timeout:
            return "Délai d'attente dépassé. Veuillez réessayer."
        case .unknown:
            return "Une erreur inattendue s'est produite."
        }
    }
}

class NetworkService {
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 30.0
        self.session = URLSession(configuration: configuration)
    }
    
    func reportPhoneNumber(_ phoneNumber: String) async throws {
        guard let url = URL(string: Config.reportServerURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = await ReportRequest(
            number: phoneNumber,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestData)
            request.httpBody = jsonData
        } catch {
            throw NetworkError.decodingError
        }
        
        do {
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    return // Success, no action needed
                case 400...499:
                    throw NetworkError.serverError(httpResponse.statusCode)
                case 500...599:
                    throw NetworkError.serverError(httpResponse.statusCode)
                default:
                    throw NetworkError.unknown
                }
            }
        } catch {
            if error is NetworkError {
                throw error
            }
            
            let nsError = error as NSError
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                throw NetworkError.networkUnavailable
            case NSURLErrorTimedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown
            }
        }
    }
}

private struct ReportRequest: Codable {
    let number: String
    let deviceId: String
    let appVersion: String
}
