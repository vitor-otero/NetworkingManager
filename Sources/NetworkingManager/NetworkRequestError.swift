//
//  NetworkRequestError.swift
//  NetworkingManager
//
//  Created by Vitor Otero on 01/11/2024.
//

import Foundation

public enum NetworkRequestError: LocalizedError {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError(_ description: String)
    case urlSessionFailed(_ error: URLError)
    case timeOut
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .invalidRequest: return "Invalid request."
        case .badRequest: return "Bad request."
        case .unauthorized: return "Unauthorized access."
        case .forbidden: return "Forbidden access."
        case .notFound: return "Resource not found."
        case .error4xx(let code): return "Client error: \(code)"
        case .serverError: return "Server error."
        case .error5xx(let code): return "Server error: \(code)"
        case .decodingError(let description): return "Decoding error: \(description)"
        case .urlSessionFailed(let error): return "URL session error: \(error.localizedDescription)"
        case .timeOut: return "Request timed out."
        case .unknownError: return "Unknown error occurred."
        }
    }
}
