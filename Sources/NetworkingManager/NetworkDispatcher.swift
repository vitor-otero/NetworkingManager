//
//  NetworkDispatcher.swift
//  NetworkingManager
//
//  Created by Vitor Otero on 01/11/2024.
//

import Foundation
import Combine
import os

public struct NetworkDispatcher {
    public let urlSession: URLSession
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "org.v0t.networking", category: "Networking")

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, NetworkRequestError> {
        logger.log(level: .info, "[\(request.httpMethod?.uppercased() ?? "")] Request to URL: \(request.url?.absoluteString ?? "Unknown URL")")

        return urlSession
            .dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw self.httpError(0)
                }

                self.logger.log(level: .info, "[\(httpResponse.statusCode)] Response from URL: \(request.url?.absoluteString ?? "Unknown URL")")

                if !(200...299).contains(httpResponse.statusCode) {
                    throw self.httpError(httpResponse.statusCode)
                }

                return data
            }
            .tryMap { data in
                // Directly return `data` as `ReturnType` if `ReturnType` is `Data`
                if ReturnType.self == Data.self, let data = data as? ReturnType {
                    return data
                }

                // Otherwise, attempt to decode into the specified `ReturnType`
                return try JSONDecoder().decode(ReturnType.self, from: data)
            }
            .mapError { error in
                self.logger.error("Error occurred: \(error.localizedDescription, privacy: .public)")
                return self.handleError(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }

    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError(error.localizedDescription)
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}
