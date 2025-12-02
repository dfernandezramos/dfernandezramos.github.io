---
title: ".NET Concurrency Essentials III"
date: 2026-01-01
hero: /images/posts/threads.jpg
categories:
- Development
- DotNet
- Asynchrony
---

I wish you all a merry Christmas and a happy new year 2026. May your life goals be achieved this year! Here is my little present for you: the third post about concurrency on .Net!

In the previous post we compared `Concurrency` and `Parallelism` and also explained how `async` and `await` really work under the hood. Today we are going with a shorter (but not least important) one: `SynchronizationContext`. What is it and why is it important in UI applications? Does it make my application faster?

Let's go with it.

---
#### What is the `SynchronizationContext`?

Each thread has an associated `SynchronizationContext`, which is a mechanism that handles **where** and **how** the code is executed. It often redirects the execution of code to a specific thread after an `await`. Normally, it is used in situations where we need to return the code execution to the UI thread since that is the only one where we can update UI elements. It ensures that async continuations that touch UI controls run on the UI thread.

We can avoid returning the execution to the previous thread before the `await` asking the `Task` to not capture the context with its `ConfigureAwait(false)` method. This usually improves performance because the execution will continue in another ThreadPool thread instead of waiting for the previous one to be free. As mentioned, it is important to remember that if the code performs UI operations in a different thread other than the UI one the application may throw an exception and crash.

Since  ASP.Net Core doesn't have UI, the `SynchronizationContext` is always null by default so continuations after an `await` will continue on any ThreadPool thread. This is intentional to avoid blocking threads unnecessarily. Classic ASP.Net did have a `SynchronizationContext`, although, in order to preserve request context. Today, we rely on IHttpContextAccessor to handle the HTTP context differently.

Each UI framework like Avalonia, WPF, WinForms, etc. have their own implementation. [Here you can check the implementation of the Avalonia SynchronizationContext](https://github.com/AvaloniaUI/Avalonia/blob/master/src/Avalonia.Base/Threading/AvaloniaSynchronizationContext.cs).

Some key points on the `SynchronizationContext`:

- **UI frameworks** use a *single-threaded* model where all UI operations must run on the UI thread. Their custom SynchronizationContext returns the code execution back to that thread so code that touches UI elements behaves safely.
- If you use any **library** code it doesn’t need to know anything about your application threading model. Continuations will resume on the context of the caller of the library method letting libraries remain context-agnostic.
- It helps make thread continuation scheduling predictable by allowing you to know where the continuation runs.


---

I think the post covers the introduction to the `SynchronizationContext` concept clearly without overwhelming readers. We could expand way more, for example, by looking at what its methods are for and how we can write our own implementation, but in most cases you won't need to do so. In the next one we will go back to `Task` and `Thread` and when and how to use each of them.

As always, please don't hesitate to comment if you want to debate or clarify something.

See you all in the next post!
