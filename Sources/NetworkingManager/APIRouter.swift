//
//  APIRouter.swift
//  NetworkingManager
//
//  Created by Vitor Otero on 01/11/2024.
//

import Foundation

public struct APIRouter<ResponseType: Decodable>: Request {
    public var additionalHeaders: [String : String]?
    public var path: String
    public var method: HTTPMethod
    public var headers: [String: String]?
    public var queryParams: [String: Any]?
    public var body: Encodable?

    public init(path: String,
                method: HTTPMethod = .get,
                headers: [String: String]? = nil,
                queryParams: [String: Any]? = nil,
                body: Encodable? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParams = queryParams
        self.body = body
    }
}
