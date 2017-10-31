//
//  GCDTasker.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 31/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol Tasker {
    func performBackgroundTask(task: @escaping () -> ()) -> Void
}

class GCDTasker: Tasker {
    private let globalQueue = DispatchQueue.global(qos: .userInitiated)
    func performBackgroundTask(task: @escaping () -> ()) {
        globalQueue.async {
            task()
        }
    }
}
