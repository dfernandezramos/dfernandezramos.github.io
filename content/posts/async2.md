---
title: ".NET Concurrency Essentials II"
date: 2025-12-01
hero: /images/posts/threads.jpg
categories:
- Development
- DotNet
- Asynchrony
---

Let's continue with the .Net asynchronous programming series.

In the previous post we compared `Task` and `Thread` while explaining how the `Threadpool` and the `TaskScheduler` relate to tasks. Today I would like to expand more on two concepts so many others may have started with: `async` and `await`. What are they meant for? Are we achieving what we really want to achieve with them?

---
#### What are `async/await` for?

We all use `async` and `await`. Every day. They are commonly known to be used the next way:

- I have a method I want to run asynchronously > I add the `async` modifier to the method declaration. Normally, the method will then return a `Task` or a `Task<T>`.
- I want to call that asynchronous method > I call it adding the `await` keyword.

And that's it. Magic happens. You would be surprised how many developers stop their curiosity right there. It just works and they don't need to know why, but that is a dangerous way to get to the point where you think your code does something it actually doesn't. Here are some insights about this:

- Thinking that using `await` creates a new thread is a mistake. As mentioned on the previous post, `await` will tell the `TaskScheduler` to queue the task on the `ThreadPool`, which will then execute it in one of its available threads.
- When we add the `async` modifier to a method, it will tell the compiler to create a state machine during compilation. That will allow the code execution to suspend and resume on different points of the method without blocking the thread that awaited the method.
- The `await` keyword is what indicates a suspension point within an asynchronous method. Each `await` generates a return point in the state machine:
    - When the code is awaiting a task that hasn't finished, control is returned to the caller.
    - When the task finishes, the method continues from that point.

>In other words. The state machine the `async` modifier tells the compiler to create is a mechanism that allows the asynchronous method to remember what line was being executed when an `await` keyword is hit, save the value of the local variables among other things, pause the execution until the task being awaited is done and then resume the execution with that information it saved before.


#### What is the difference between concurrency and parallelism?

Since the state machine is pausing the execution of a method until an awaited task is done, returning the control to its caller, you may find yourself thinking that while the task is being executed, the caller is doing other stuff in parallel. This is the trickiest part where I think most developers get wrong. Here is where defining the difference between ***concurrency*** and ***parallelism*** takes its place:

{{< img src="/images/posts/concurrency_parallelism.png">}}

Imagine Santa's helpers packing Christmas presents. Picture one helper who has to do all the tasks (boxing, wrapping, and adding the ribbon) but can’t finish them in one straight shot because the materials arrive irregularly. He will keep switching between tasks:

- He starts boxing a toy.
- While waiting for more boxes, he switches to wrapping a half-finished gift.
- When the wrapping paper runs out, he jumps back to boxing.

Only one set of hands is doing the work, but progress is made on several gifts because each helper keeps alternating between them. Nothing happens at the same moment, but multiple tasks are in flight. That’s ***concurrency***: juggling progress on several tasks without doing them simultaneously.

Now picture three helpers standing next to each other, each doing their specific step continuously:

- One boxes toys nonstop.
- One wraps gifts nonstop.
- One adds ribbons nonstop.

All three are working at the same time, and multiple gifts advance through the pipeline simultaneously. That’s ***parallelism***: different workers actually working at the same time.

>*Okay David, I think I understand now. Each Santa's helper represents a thread, right? So when my code uses more than one thread then I am using parallelism.* 

Not exactly. A helper can represent a thread, but using more than one thread doesn’t automatically mean you’re running things in parallel. Multiple threads might still be taking turns on a single worker (CPU core), which puts you back in the “one helper switching tasks” situation. That’s  ***concurrency***, not ***parallelism***.

Remember this line from the previous post "*A CPU can only execute in parallel as many threads as cores it has*".

>"*Noted. So parallelism or concurrency will happen automatically depending on the CPU executing my code. The ThreadPool will see that my CPU has two cores, then use two threads in parallel*"

Not quite. Concurrency is almost guaranteed if you use multiple threads. `async/await` doesn’t run things in parallel. It just makes your code non-blocking. To actually leverage multiple CPU cores, you have to offload CPU-bound work to a `ThreadPool` thread using `Task.Run()` in combination with `Task.WhenAll()` or the `Parallel` class.


---

The topic of this post is the one that made me want to go deeper on how asynchrony works. As said, I think most developers get wrong how parallelism and concurrency get achieved.

I still have enough topics to cover in at least three more posts. In the next one we will talk about the `SynchronizationContext`, another important topic when awaiting tasks specially on UI applications. Please don't hesitate to comment anything in the comment section if you want to debate or clarify something.

See you all in the next post!
