# LaunchTask

Language: English | [中文](README-ZH.md)

LaunchTask is a lib for managing App launch tasks.

A large app often needs to perform a large number of tasks during the launch phase. If there are many app developers, it is easy to cause the code of AppDelegate to be modified frequently and become more and more bloated. It is also easy to cause the app's launch duration to be longer, and app will eventually be killed by the watchdog.

LaunchTask encapsulates the launch code into subclasses of each task, and configures the execution order and dependencies of tasks through workflow. At the same time, the launch duration is accelerated by executing tasks concurrently.

## Installation
Install LaunchTask via CocoaPods.
```
pod 'LaunchTask'
```

## Using LaunchTask

There are two main concepts in the LaunchTask lib: `Task` and `Workflow`. The relationship between the two is similar to `NSOperation` and `NSOperationQueue`. Task is mainly used to perform specific tasks. Workflow is used to manage the execution sequence of multiple Tasks.

First, we need to create a workflow instance object:
```Swift
let workflow = TaskWorkflow(name: "Launch")
```
After creating the workflow, we need to create the Task that needs to be executed. Task can be created in three ways:
* Subclass LaunchTask.
```Swift
class SomeTask: LaunchTask {
     override func main(context: [AnyHashable: Any]?) {
         // Perform specific tasks
     }
}
let task = SomeTask()
```
* Create a ClosureTask instance and pass in the Closure to be executed.
```Swift
let task = ClosureTask(name: "TaskName") { context in
     // Perform specific tasks
}
```
* Create a SelectorTask instance, pass in target and selector.
```Swift
let task = SelectorTask(name: "TaskName", target: self, selector: #selector(someFunction))
```
After creating the Task instance, we need to add the Task to the workflow.
```Swift
workflow.addTask(task)
```
Finally, where the workflow needs to be executed, the start method is called.
```Swift
workflow.start()
```
Assuming task C needs to wait for all previous concurrent tasks (A, B) to complete, we can use the `addBlockingTasks` method of workflow.
```
              ╔═════╗
          ┌──>║  A  ║───┐
          │   ╚═════╝   │
┌─────┐   │             │   ╔═════╗    ┌──────┐
│Start│───┤             ├──>║  C  ║───>│Finish│
└─────┘   │             │   ╚═════╝    └──────┘
          │   ╔═════╗   │
          └──>║  B  ║───┘
              ╚═════╝
```
The specific code is as follows:
```
workflow.addBlockingTasks([
     TaskA(),
     TaskB(queue: .concurrentQueue),
])
workflow.addTask(TaskC())
workflow.start()
```

## Example

Assume that when the App starts, the initialization steps in the figure below need to be performed.
```
                                 ╔═════╗   ╔═════╗
                              ┌─>║  C  ║──>║  D  ║─┐
                              │  ╚═════╝   ╚═════╝ │
┌─────┐   ╔═════╗   ╔═════╗   │                    │   ╔═════╗   ╔═════╗   ┌──────┐
│Start│──>║  A  ║──>║  B  ║──>│                    ├──>║  G  ║──>║  H  ║──>│Finish│
└─────┘   ╚═════╝   ╚═════╝   │                    │   ╚═════╝   ╚═════╝   └──────┘
                              │       ╔═════╗      │
                              ├──────>║  E  ║──────┤
                              │       ╚═════╝      │
                              │                    │
                              │       ╔═════╗      │
                              └──────>║  F  ║──────┘
                                      ╚═════╝
```
The corresponding code implementation is as follows:
```Swift
let workflow = TaskWorkflow(name: "Launch")
workflow.delegate = self
workflow.addTask(TaskA())
workflow.addTask(TaskB())
workflow.addBlockingTasks([
     TaskC(),
     TaskD(),
     TaskE(queue: .concurrentQueue),
     TaskF(queue: .concurrentQueue),
])
workflow.addTask(TaskG())
workflow.addTask(TaskH())
workflow.start()
```
In the above code, TaskG will wait for all tasks in BlockingTasks to complete before continuing. We can create the RootViewController of the App in TaskG. Perform time-consuming operations concurrently in BlockingTasks, such as preloading resources needed for the homepage, initializing important SDKs, etc.
If we want to check the execution timeline of the workflow, we can generate a timeline at the end of the workflow:
```Swift
func workflowDidFinish(_ workflow: TaskWorkflow) {
     print(workflow.generateTimeline())
}
```
The timeline is as follows
```
[Launch start] - [TaskA 201ms] - [TaskB 201ms] - [TaskC 200ms] - [TaskD 201ms] - [Waiting 0ms] - [TaskG 13ms] - [TaskH 201ms] - [Launch finish]
                               - [TaskE 105ms]
                               - [TaskF 205ms]
```

## Author

Jayden Liu

## License

LaunchTask is available under the MIT license. See the LICENSE file for more info.