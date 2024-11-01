//
//  APIClient.swift
//  NetworkingManager
//
//  Created by Vitor Otero on 01/11/2024.
//

import Foundation
import Combine

public struct APIClient {
    private let baseURL: String
    private let networkDispatcher: NetworkDispatcher

    public init(baseURL: String, networkDispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }

    public func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ResponseType, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(error: .invalidRequest).eraseToAnyPublisher()
        }

        return networkDispatcher.dispatch(request: urlRequest)
            .tryMap { data in
                // Decode data to the expected `ResponseType`
                let decodedResponse = try JSONDecoder().decode(R.ResponseType.self, from: data)
                return decodedResponse
            }
            .mapError { error in
                // Map any errors to `NetworkRequestError`
                (error as? NetworkRequestError) ?? .unknownError
            }
            .eraseToAnyPublisher()
    }
}
