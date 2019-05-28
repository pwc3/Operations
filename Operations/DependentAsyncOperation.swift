//
//  DependentAsyncOperation.swift
//  Operations
//
//  Created by Paul Calnan on 5/28/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class DependentAsyncOperation<DependentSuccess, DependentFailure, Success, Failure>: AsyncOperation<Success, Failure> where Failure: Error, DependentFailure: Error {

    private let dependency: AsyncOperation<DependentSuccess, DependentFailure>

    public init(dependency: AsyncOperation<DependentSuccess, DependentFailure>) {
        self.dependency = dependency
        super.init()

        addDependency(dependency)
    }

    public final override func start() {
        super.start()

        guard let dependencyResult = dependency.result else {
            fatalError("Dependency is not finished -- result is nil")
        }
        start(withDependencyResult: dependencyResult)
    }

    public func start(withDependencyResult value: Result<DependentSuccess, DependentFailure>) {

    }
}
