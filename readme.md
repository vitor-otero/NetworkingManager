# NetworkingLayer

`NetworkingLayer` is a reusable and structured networking library for Swift that simplifies API calls using `Combine`, `Codable`, and `OSLog` for efficient logging. It supports HTTP methods (`GET`, `POST`, `PUT`, `DELETE`) and provides customizable error handling with `NetworkRequestError`.

## Features

- **CRUD Operations**: Simplifies API requests for common operations (Create, Read, Update, Delete).
- **Combine Support**: Uses `Combine` for asynchronous data handling.
- **Codable**: Decodes JSON responses into strongly-typed models.
- **Error Handling**: Custom error types for detailed error handling.
- **Structured Logging**: Uses `OSLog` for efficient, production-grade logging.

## Requirements

- iOS 14+ / macOS 13+

## Installation

Add `NetworkingLayer` as a dependency in your project:

1. Open your project in Xcode.
2. Go to **File > Add Packages...**.
3. Enter the URL of your `NetworkingLayer` repository.
4. Choose a version rule (e.g., **Branch**, **Commit**, or **Version**).
5. Click **Add Package**.

## Setup

To initialize and configure the `APIClient`:

1. Import `NetworkingLayer` into your Swift file.
2. Initialize `APIClient` with your base URL.

```swift
import NetworkingLayer

let apiClient = APIClient(baseURL: "https://api.example.com")
```

## Usage

### Define Your Model

Define a `Codable` model to map API response data:

```swift
struct User: Codable {
    let id: Int?
    let name: String
    let email: String
}
```

### CRUD Operations

#### 1. **Create (POST)** - Add a New User

```swift
func createUser(name: String, email: String) {
    let newUser = User(id: nil, name: name, email: email)
    let request = APIRouter<User>(
        path: "/users",
        method: .post,
        body: newUser.asDictionary
    )

    apiClient.dispatch(request)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error creating user: \(error.localizedDescription)")
            }
        }, receiveValue: { createdUser in
            print("User created: \(createdUser)")
        })
        .store(in: &cancellables)
}
```

#### 2. **Read (GET)** - Fetch Users

```swift
func fetchUsers() {
    let request = APIRouter<[User]>(
        path: "/users",
        method: .get
    )

    apiClient.dispatch(request)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Fetch error: \(error.localizedDescription)")
            }
        }, receiveValue: { users in
            print("Fetched users: \(users)")
        })
        .store(in: &cancellables)
}
```

#### 3. **Update (PUT)** - Update a User

```swift
func updateUser(id: Int, name: String, email: String) {
    let updatedUser = User(id: id, name: name, email: email)
    let request = APIRouter<User>(
        path: "/users/\(id)",
        method: .put,
        body: updatedUser.asDictionary
    )

    apiClient.dispatch(request)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Update error: \(error.localizedDescription)")
            }
        }, receiveValue: { user in
            print("User updated: \(user)")
        })
        .store(in: &cancellables)
}
```

#### 4. **Delete (DELETE)** - Delete a User

```swift
func deleteUser(id: Int) {
    let request = APIRouter<EmptyResponse>(
        path: "/users/\(id)",
        method: .delete
    )

    apiClient.dispatch(request)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Delete error: \(error.localizedDescription)")
            } else {
                print("User deleted successfully.")
            }
        }, receiveValue: { _ in })
        .store(in: &cancellables)
}
```

### Helper Extension for `Encodable`

Convert `Encodable` models to a dictionary for the request body:

```swift
extension Encodable {
    var asDictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
```

To add headers 

```swift
let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        let body = ["likedUserID": matchID.uuidString]

        let request = APIRouter<EmptyResponse>(
            path: "/like",
            method: .post,
            headers: headers,
            body: body
        )
```
## Logging

`NetworkingLayer` uses `OSLog` for structured, efficient logging. Request and response details, including HTTP status codes and errors, are automatically logged.

To view logs in the Console app:
1. Open **Console** on your Mac.
2. Filter by the category `"Networking"` to view logs specific to this library.

## Error Handling

The library uses the `NetworkRequestError` enum for custom error handling:

```swift
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
}
```

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
=======

