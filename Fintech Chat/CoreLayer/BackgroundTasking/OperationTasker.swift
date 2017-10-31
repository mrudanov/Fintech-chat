//
//  OperationTasker.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 31/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class OperationTasker: Tasker {
    private class TaskOperation: Operation {
        private var task: () -> ()
        
        init(task: @escaping () -> ()) {
            self.task = task
            super.init()
        }
        
        override func main() {
            task()
        }
    }
    
    private let globalQueue = OperationQueue()
    
    func performBackgroundTask(task: @escaping () -> ()) {
        let saveOperation = TaskOperation(task: task)
        globalQueue.addOperation(saveOperation)
    }
}
