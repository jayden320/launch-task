//
//  LaunchTask.swift
//  LaunchTask
//
//  Created by Jayden Liu on 2023/2/3.
//  Copyright (c) 2023 Jayden Liu. All rights reserved.
//

import Foundation

protocol TaskDelegate: AnyObject {
    func taskDidStart(_ task: LaunchTask)
    func taskDidFinish(_ task: LaunchTask)
}

public enum TaskQueue: String {
    case mainQueue
    case concurrentQueue
}

open class LaunchTask: NSObject {
    public private(set) var sons: [LaunchTask]?
    public let queue: TaskQueue

    weak var workflow: TaskWorkflow?
    weak var delegate: TaskDelegate?

    private var startDate: Date?
    private var endDate: Date?

    public required init(queue: TaskQueue = .mainQueue, sons: [LaunchTask]? = nil) {
        self.sons = sons
        self.queue = queue

        if queue == .concurrentQueue {
            assert(sons == nil, "Currently concurrent threads do not support sons")
        }
    }

    public func start(context: [AnyHashable: Any]? = nil) {
        startDate = Date()
        delegate?.taskDidStart(self)
        main(context: context)
        endDate = Date()
        delegate?.taskDidFinish(self)
    }

    open func main(context: [AnyHashable: Any]?) {}

    public func executionDuration() -> Double {
        guard let startDate, let endDate else {
            return 0
        }
        return endDate.timeIntervalSince(startDate)
    }
}
