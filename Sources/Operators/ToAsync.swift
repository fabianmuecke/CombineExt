//
//  ToAsync.swift
//  CombineExt
//
//  Created by Thibault Wittemberg on 2021-06-15.
//  Copyright © 2021 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
enum PublisherAsyncError: Error {
    case completionReceivedBeforeValue
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Future {
    func toAsync() async throws -> Output {
        var hasReceivedValue = false
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Output, Error>) in
            self.subscribe(Subscribers.Sink(receiveCompletion: { completion in
                switch completion {
                case .finished where hasReceivedValue == false: continuation.resume(throwing: PublisherAsyncError.completionReceivedBeforeValue)
                case let .failure(error): continuation.resume(throwing: error)
                default: return
                }
            }, receiveValue: { value in
                continuation.resume(returning: value)
                hasReceivedValue = true
            }))
        }
    }
}
#endif
