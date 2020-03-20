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

    private let queue = DispatchQueue(label: "AsyncOperation", attributes: .concurrent)

    private var _state: State = .unstarted

    private var state: State {
        get {
            return queue.sync {
                _state
            }
        }

        set {
            queue.sync(flags: .barrier) {
                precondition(!_state.isFinished, "Cannot change from finished state")

                _state = newValue
                _isExecuting = _state.isExecuting
                _isFinished = _state.isFinished
            }
        }
    }

    public override var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting: Bool = false {
        willSet {
            willChangeValue(for: \.isExecuting)
        }

        didSet {
            didChangeValue(for: \.isExecuting)
        }
    }

    public override var isExecuting: Bool {
        return _isExecuting
    }

    private var _isFinished: Bool = false {
        willSet {
            willChangeValue(for: \.isFinished)
        }

        didSet {
            didChangeValue(for: \.isFinished)
        }
    }

    public override var isFinished: Bool {
        return _isFinished
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
