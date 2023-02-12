# LaunchTask

Language: [English](README.md) | 中文

LaunchTask 是一个管理 App 启动任务的框架。

一个大型的 App 往往需要在启动阶段执行大量的任务。如果 App 的开发人员很多，容易导致 AppDelegate 的代码频繁修改，越来越臃肿。也容易导致 App 的启动时长变长，最终被 watchdog 杀死。

LaunchTask 是将启动的代码封装到一个个 task 的子类中，通过 workflow 配置 task 的执行顺序和依赖。同时通过并发执行任务，加快启动时间。

## Installation
通过 CocoaPods 安装 LaunchTask。
```
pod 'LaunchTask'
```

## Using LaunchTask

LaunchTask 库中主要有两个概念：`Task` 和 `Workflow`。二者的关系类似于 `NSOperation` 和 `NSOperationQueue`。Task 主要用于执行具体的任务。Workflow 则用于管理多个 Task 的执行顺序。

首先，我们需要创建一个 workflow 的实例对象：
```Swift
let workflow = TaskWorkflow(name: "Launch")
```
创建完 workflow 后，我们需要创建需要执行的 Task。Task 有三种创建方式：
* 子类化 LaunchTask。
```Swift
class SomeTask: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        // Perform specific tasks
    }
}
let task  = SomeTask()
```
* 创建 ClosureTask 实例，传入需要执行的 Closure。
```Swift
let task = ClosureTask(name: "TaskName") { context in
    // Perform specific tasks
}
```
* 创建 SelectorTask 实例，传入 target 和 selector。
```Swift
let task = SelectorTask(name: "TaskName", target: self, selector: #selector(someFunction))
```
创建完 Task 实例后，需要将 Task 添加到 workflow 中。
```Swift
workflow.addTask(task)
```
最后，在需要执行 workflow 的地方，调用 start 方法。
```Swift
workflow.start()
```
假设任务 C 需要等待前面的并发任务（A、B）全部完成，则可以使用 workflow 的 addBlockingTasks 方法。
```
                ╔═══════╗
            ┌──>║   A   ║───┐
            │   ╚═══════╝   │
┌───────┐   │               │   ╔═══════╗    ┌────────┐
│ Start │───┤               ├──>║   C   ║───>│ Finish │
└───────┘   │               │   ╚═══════╝    └────────┘
            │   ╔═══════╗   │
            └──>║   B   ║───┘
                ╚═══════╝
```
具体的代码如下：
```
workflow.addBlockingTasks([
    TaskA(),
    TaskB(queue: .concurrentQueue),
])
workflow.addTask(TaskC())
workflow.start()
```

## Example

假设在 App 启动的时候，需要执行下图中的初始化步骤。
```
                                       ╔═══════╗   ╔═══════╗
                                    ┌─>║   C   ║──>║   D   ║─┐
                                    │  ╚═══════╝   ╚═══════╝ │
┌───────┐   ╔═══════╗   ╔═══════╗   │                        │   ╔═══════╗   ╔═══════╗   ┌────────┐
│ Start │──>║   A   ║──>║   B   ║──>│                        ├──>║   G   ║──>║   H   ║──>│ Finish │
└───────┘   ╚═══════╝   ╚═══════╝   │                        │   ╚═══════╝   ╚═══════╝   └────────┘
                                    │        ╔═══════╗       │
                                    ├───────>║   E   ║───────┤
                                    │        ╚═══════╝       │
                                    │                        │
                                    │        ╔═══════╗       │
                                    └───────>║   F   ║───────┘
                                             ╚═══════╝
```
对应的代码实现如下：
```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
    return true
}
```
在上面的代码中，TaskG 会等待 BlockingTasks 中的任务全部执行完成后，才会继续执行。我们可以在 TaskG 中创建 App 的 RootViewController。在 BlockingTasks 中并发执行耗时的操作，比如预加载首页需要用到的资源，初始化重要的 SDK 等。
如果想查 workflow 的执行时间线，可以在 workflow 结束时，生成时间线:
```Swift
func workflowDidFinish(_ workflow: TaskWorkflow) {
    print(workflow.generateTimeline())
}
```
时间线如下
```
[Launch start] - [TaskA 201ms]  - [TaskB 201ms]  - [TaskC 200ms]  - [TaskD 201ms]  - [Waiting 0ms]  - [TaskG 13ms]  - [TaskH 201ms]  - [Launch finish]
                                - [TaskE 105ms]
                                - [TaskF 205ms]
```

## Author

Jayden Liu

## License

LaunchTask is available under the MIT license. See the LICENSE file for more info.