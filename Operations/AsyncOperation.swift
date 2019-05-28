//
//  AsyncOperation.swift
//  Operations
//
//  Created by Paul Calnan on 5/28/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class AsyncOperation<Success, Failure>: Operation where Failure: Error {

    private enum State {

        case unstarted

        case executing

        case finished(Result<Success, Failure>)

        var isExecuting: Bool {
            switch self {
            case .executing:
                return true

            default:
                return false
            }
        }

        var isFinished: Bool {
            switch self {
            case .finished:
                return true

            default:
                return false
            }
        }

        var result: Result<Success, Failure>? {
            switch self {
            case .finished(let result):
                return result

            default:
                return nil
            }
        }
    }

    private let stateLock = NSLock()

    private var _state: State = .unstarted {
        willSet {
            if case .executing = _state {
                willChangeValue(for: \.isExecuting)
            }
            if case .finished = newValue {
                willChangeValue(for: \.isFinished)
            }
        }

        didSet {
            if case .executing = oldValue {
                didChangeValue(for: \.isExecuting)
            }
            if case .finished = state {
                didChangeValue(for: \.isFinished)
            }
        }
    }

    private var state: State {
        get {
            stateLock.lock()
            let result = _state
            stateLock.unlock()
            return result
        }

        set {
            stateLock.lock()
            precondition(!_state.isFinished, "Cannot change from finished state")
            _state = newValue
            stateLock.unlock()
        }
    }

    public override var isAsynchronous: Bool {
        return true
    }

    public override var isExecuting: Bool {
        return state.isExecuting
    }

    public override var isFinished: Bool {
        return state.isFinished
    }

    public var result: Result<Success, Failure>? {
        guard case .finished(let result) = state else {
            return nil
        }
        return result
    }

    public final func finish(with result: Result<Success, Failure>) {
        state = .finished(result)
    }

    public override func start() {
        state = .executing
    }
}
