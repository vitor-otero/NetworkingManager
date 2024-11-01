//
//  Request.swift
//  NetworkingManager
//
//  Created by Vitor Otero on 01/11/2024.
//

import Foundation
import os

public protocol Request {
    associatedtype ResponseType: Decodable   // For decoding the server response
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParams: [String: Any]? { get }
    var body: Encodable? { get }  // Use Encodable to encode request body

    func asURLRequest(baseURL: String) -> URLRequest?
}

extension Request {
    public var method: HTTPMethod { return .get }
    public var headers: [String: String]? { return ["Content-Type": "application/json"] }
    public var queryParams: [String: Any]? { return nil }
    public var body: Encodable? { return nil }  // Default body is nil

    // Helper to add query parameters to URL
    func addQueryItems(queryParams: [String: Any]?) -> [URLQueryItem]? {
        guard let queryParams = queryParams else { return nil }
        return queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }

    // Converts Request into a URLRequest with the necessary headers, query parameters, and body encoding
    public func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL + path) else { return nil }
        urlComponents.queryItems = addQueryItems(queryParams: queryParams)

        guard let finalURL = urlComponents.url else { return nil }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        // Using OSLog for logging URL and headers
        let log = OSLog(subsystem: "com.yourapp.networking", category: "networking")
        os_log("Request URL: %@", log: log, type: .info, finalURL.absoluteString)
        os_log("Request Headers: %@", log: log, type: .info, headers?.description ?? "None")

        // Encode the body if it's provided and conforms to Encodable
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "Invalid JSON"
                os_log("Request Body: %@", log: log, type: .info, jsonString) // Log the request body
            } catch {
                os_log("Error encoding body: %@", log: log, type: .error, "\(error)")
            }
        }

        return request
    }
}

// Helper to allow encoding of Encodable body data to JSON
public struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    public init<T: Encodable>(_ encodable: T) {
        self.encodeClosure = encodable.encode(to:)
    }

    public func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
