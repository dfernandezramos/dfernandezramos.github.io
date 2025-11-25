---
title: ".NET Concurrency Essentials I"
date: 2025-11-25
hero: /images/posts/threads.jpg
categories:
- Development
- DotNet
- Asynchrony
---

Do you ever feel that sometimes you just know how things are done but never stopped to understand why? You know you are doing things right because that is the way someone told you. Then when someone asks you something related to that topic you just find yourself explaining the "how" but not the "why". If that is not your case, you are a lucky one. That is not mine, so I decided to go deep on basic things I use on my every-day work basis and leave them as blog posts.

So let's start with a big one that we will split in some different blog posts. Fasten your seatbelts and let's talk about asynchronous programming. Today we are going to compare a `Task` and a `Thread`.

---
#### What is a Thread?

`Thread` is a .Net class that creates real Operating System threads. A thread is a unity of execution that runs our code.

- You are the one that controls its initialization, lifecycle and finalization.
- It runs *independently* until it finishes its work or until you kill it.
- It is used on long-running work (like a logger or a service that keeps listening for messages).
- A thread is *foreground* by default, meaning it keeps your application process alive until its work is done (or until you kill it).
- A thread can be *background*, meaning that stopping the process will kill it abruptly unless we configure it to keep the process alive until the thread work is done using `.join()`


#### What is a Task?

A `Task` is a high level abstraction managed by .Net that represents a unit of asynchronous work. It runs **on** threads from the `Threadpool` (that are also Operating System threads) managed by .Net.

- It is a modern scalable option useful when you want to execute asynchronous work.
- It is used in most of the cases where you don't need explicit control of the thread executing the task or when it is important to reuse ThreadPool threads because your work won't be continuously running.

Relating to threads, my old me would say: *"Well, you just create a thread awaiting a task."* Wrong! But I will explain that later.

>So, in a nutshell, a thread executes work and a task represents an asynchronous unit of work that will run on threads from the `ThreadPool`. It is important to note that we don't need to create a task to execute work if we create a thread ourselves. Using `Task` is like saying: *"Hey .Net, please execute this code asynchronously. Be the one in charge of selecting on which thread this code will run"*.

Ok until here? I know your mind might have popped some questions but I will try to clarify things bit by bit, topic by topic. That leads me to the next one you might have already asked yourself:


#### What is a ThreadPool?

It is a set of reusable threads. It has a queue of work since executing tasks immediately is not always possible (i.e.: the ThreadPool has two threads and there are 100 tasks to be executed, then 98 of them will go to the queue).

- It decides itself if it will reuse the threads it has or ask the Operating System for new ones to execute the tasks. Once it has available threads it will take dequeue tasks and execute them.
- It will mark threads for destruction if it doesn't need them anymore.
- It does not create nor destroy threads. It just asks the Operating System to do such things.

The ThreadPool observes the amount of tasks in the queue, the number of available threads and the time tasks take to execute. Based on that, it decides if it asks or not the Operating System to create new threads or if it marks any available one for its destruction. But why not just create unlimited threads so the queue never gets filled? It is important to keep a consistent number of threads because:

- Creating and destroying threads is expensive for the CPU and it degrades performance.
- When we change threads we are changing context, and that is also performance degrading.
- A CPU can only execute in parallel as many threads as cores it has.


#### Introducing the TaskScheduler:

Internally, .Net has a mechanism to schedule the tasks our code executes. That is the `TaskScheduler`:

- It is who decides on which queue tasks will be stored for their execution.
- By default, the `TaskScheduler` uses the `ThreadPool` queue.
- You can create your own `TaskScheduler` if you need to define your own rules (like using only one thread, using different queues, etc.).

---


I think that's enough for now. We've already introduced 4 basic concepts and already mentioned some of the ones I'll explain in the next post, where we will see what the `async/await` keywords do and how that relates to changing context when changing threads.

>Last time I wrote I’d build a fancy wedding site with cool tech. Reality won. I ended up using WordPress. Fair enough. Preparing a wedding came with lots of stress and anxiety. Now I've recently been promoted to "dad" at home so time is something really hard to promise, so I will just say that I'll try my best to keep posting as soon as my daughter lets me touch my keyboard.

Please don't hesitate to comment anything in the comment section if you need something else.

See you all in the next post!
