---
title: ".NET in a box"
date: 2020-09-03
hero: /images/posts/dotnet.png
# categories:
# - writing-posts
# - writing-posts-category
---

One of the most important things a .NET developer should know is what .NET is. It seems stupid but I know a lot of people that just starts coding and focusing in learning the .NET code they use. They can tell you why that `.Count` field is better than using the `.Any ()` LINQ method to check for available values in your enumerator but they really don't know (and some of them sadly don't care) how their code is translated and optimized for a concrete processor in a concrete operative system.

I am on an intermediate position between the guy who can tell you what code is better and how .NET works (more or less). This blog is intended for finishing up with that kind of situations and investigate on that holes to properly talk about the things.

---
#### Introduction:

A simple explanation would be that each .NET language like Visual Basic .NET or C# is not directly read by the processor but for another element called `JIT` compiler and before that, for a major union between .NET languages, all of them are translated to a common language called Intermediate Language (`IL`). Then the `JIT` compiler translates that language into machine code.

.NET is composed by different elements you might heard before like `JIT`, `CLR`, `CLI`, etc. Let's define them: 

##### CIL (Common Intermediate Language or Intermediate Language or Microsoft intermediate language MSIL):

Is a set of binary instructions defined within the Common Language Infrastructure (`CLI`) specification that are executed by a `CLI-Compatible` runtime environment (`CLR`).

A language which targets the `CLI` compiles to `CIL`: 

1. The source code (i.e.: C#) is translated to `CIL` bytecode during compilation generating an assembly (`DLL`), which is a CPU/Platform independent instruction set that can be executed in any environment supporting the `CLI` (Mono runtime or .NET runtime on Windows).
2. While the assembly is being executed, the code is passed through the runtime’s Just-in-time (`JIT`) compiler that generates native code immediately executable by the CPU.
3. The CPU executes the code.
*There is a way to not use the `JIT` Compiler by using AOT (Ahead-of-time) compilation that creates a single executable of your program without any dependencies on a runtime, but at the cost of executable-file portability.

##### JIT (Just-in-time) compilation:

The name Just-in-time is given because of the code that is about to be executed is being compiled at the moment.

The difference between `JIT` and Virtual Machines with the traditional interpreted bytecode is that `JIT` combines the speed of compiled code with the flexibility of interpretation so the program can run faster. While the VM simply interprets the bytecode with worse performance, `JIT` compiles bytecode (`CIL`) continuously into machine code catching it minimizing lag on future executions of the same code in the current run and since just part of the program is compiled, there is less lag than if the entire program where compiled prior to execution.

`JIT` provides environment specific optimization for targeted CPUs and OS models, runtime type safety and assembly verification by examining the assembly metadata. Take in mind that there exists what is called “Startup or Warmup delay” that the more optimization `JIT` performs, the better code will be generated at the cost of an initial execution delay increment.

`JIT` outputs the machine code directly into memory and immediately executes it. That memory must be marked as read-only/executable after the code has been written there as writable/executable memory would be a security problem.

##### CLR (Common Language Runtime):

`CLR` (known as `CoreCLR` in .NET Core) Is a virtual machine component of the .NET framework that manages the execution of .NET programs providing type safety, memory management, exception handling, garbage collection, thread management and security.

It implements a `VES` (Virtual Execution System) which provides required support to execute the `CIL`.

##### CLI (Common Language Infrastructure):

Basically the `CLI` is an standardized open specification that describes executable code and a runtime environment that allows different languages (C#, Visual Basic .NET, F#, etc.) to be used on different computer platforms without being rewritten for each architecture. Examples of a `CLI` are .NET Framework, .NET Core and Mono.

It describes the next aspects:
* Metadata: information about the program structure.
* `CTS` (Common Type System): a set of data types and operations.
* `CLS` (Common Language Specification): subset of `CTS` containing rules that any language targeting the `CLI` should conform.
* `VES` (Virtual Execution System): loads and executes the `CIL`.

Regarding the `CLS`, when we talk about `CLS-Compliant` code we refer to code that can be used by any .NET language. Imagine the next situation with a class written in C# (case sensitive) that we want to use in Visual Basic (case insensitive):

* The C# class has defined two public fields “dog” and “Dog”. It works in C# because it is a case sensitive language.
* The Visual Basic creates an instance of the C# class and tries to use the Dog field. It appears that the instance cannot use the “dog” or “Dog” fields.

In this case we would say that the C# code is not `CLS-Compliant` and in order to fix that we should use different names for those fields.

By default, the assemblies are not marked as `CLS-Compliant` so in order to enable this attribute [please follow this page](https://docs.microsoft.com/en-us/dotnet/api/system.clscompliantattribute).

##### Big picture:

Following the notes I’ve been taking from this post I’ve created a diagram of how .NET works:

{{< img src="/images/posts/dotnet.png">}}


##### Sources:
* https://en.wikipedia.org/wiki/Common_Intermediate_Language
* https://en.wikipedia.org/wiki/Common_Language_Runtime
* https://en.wikipedia.org/wiki/Common_Language_Infrastructure
* https://en.wikipedia.org/wiki/Just-in-time_compilation
* https://www.onlinebuff.com/article_what-is-an-il-code-jit-clr-cls-cts-managed-and-unmanaged-code_61.html
* https://mattwarren.org/2018/07/05/.NET-JIT-and-CLR-Joined-at-the-Hip/
* https://docs.microsoft.com/en-us/dotnet/api/system.clscompliantattribute

---
<br />

So this is one of the hundred important things in my to-dig list. Just investigating the surface of this topic now I know how .NET works and I can have a conversation about this. Exaggerating things, before clarifying things on this topic for the post a conversation with me would be something like: "I use Mono because is the same thing as .NET but on macOS... but what is .NET? Well... the thing that makes my C# stuff work on a computer".

As always, if you find something wrong or you miss something in this post feel free to comment down below and I will make the proper corrections.

See you all in the next post!